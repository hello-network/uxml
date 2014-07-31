package com.hello.uxml.tools.core.internal.builder;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.UxmlElement;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.Configuration;
import com.hello.uxml.tools.codegen.Severity;
import com.hello.uxml.tools.codegen.UXMLCompiler;
import com.hello.uxml.tools.codegen.emit.BuilderFactoryRegistry;
import com.hello.uxml.tools.codegen.emit.as3.As3BuilderFactory;
import com.hello.uxml.tools.codegen.emit.dart.DartBuilderFactory;
import com.hello.uxml.tools.codegen.emit.java.JBuilderFactory;
import com.hello.uxml.tools.core.internal.dartf.DartToXCompiler;
import com.hello.uxml.tools.core.internal.dartf.DartToXCompiler.CompilerMessage;
import com.hello.uxml.tools.ui.CodeGenLanguage;
import com.hello.uxml.tools.ui.internal.properties.ProjectItemMetadata;
import com.hello.uxml.tools.ui.internal.properties.UXMLProjectMetadata;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IPathVariableManager;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Provides code update service using a resource change listener.
 *
 * <p> This is a singleton created by Activator.
 *
 * @author ferhat
 */
public class CodeUpdater implements IResourceChangeListener {

  private static CodeUpdater defaultUpdater;
  private static final Logger logger = Logger.getLogger(CodeUpdater.class.getName());

  // Max # of errors reported.
  private static final int MAX_ERROR_REPORT_COUNT = 50;

  /** Holds language builder factories */
  private static final BuilderFactoryRegistry registry = new BuilderFactoryRegistry();

  private static final String IMPORT_PACKAGE_PREFIX = "package:";

  /** Hold on to IProject of last resource to reduce metadata lookups */
  private IProject cachedProject;
  /** Caches metadata for {@code cachedProject} */
  private ProjectItemMetadata cachedMeta;

  /** DartToX compiler. */
  private DartToXCompiler dartToX = null;

  /**
   * Constructor.
   */
  public CodeUpdater() {
    new CompileApp();
    registry.registerFactory(CodeGenLanguage.ActionScript3.toString(), new As3BuilderFactory());
    registry.registerFactory(CodeGenLanguage.Dart.toString(), new DartBuilderFactory());
    registry.registerFactory(CodeGenLanguage.Java.toString(), new JBuilderFactory());
  }

  private static class CompileApp extends Application {

    @Override
    protected Object readDynamicValue(Object source, String keyName) {
      //just use the dynamic getter
      try {
        return source.getClass().getDeclaredField((String) keyName).get(source);
      } catch (IllegalAccessException exp) {
        logger.log(Level.SEVERE, "Illegal access on field binding", exp);
        return null;
      } catch (NoSuchFieldException noFieldExp) {
        logger.log(Level.SEVERE, "Invalid field binding", noFieldExp);
        return null;
      }
    }

    @Override
    protected void writeDynamicValue(Object targetObject, String keyName, Object value) {
    // just use the dynamic setter
    try {
      targetObject.getClass().getDeclaredField((String) keyName).set(targetObject, value);
    } catch (IllegalAccessException exp) {
      logger.log(Level.SEVERE, "Illegal access on field binding", exp);
    } catch (NoSuchFieldException noFieldExp) {
      logger.log(Level.SEVERE, "Invalid field binding", noFieldExp);
    }
    }

    /**
     * Verifies that a class has been loaded. Classes have to be loaded for
     * PropertyDefinitions to be registered.
     */
    @Override
    public boolean verifyClassLoaded(Class<? extends UxmlElement> ownerClass) {
      if (!classLoaded.contains(ownerClass)) {
        classLoaded.add(ownerClass);
        if (ownerClass.equals(Brush.class)) { // skip abstract
          return true;
        }
        try {
          ownerClass.newInstance();
          return true;
        } catch (IllegalAccessException e) {
          logger.log(Level.SEVERE, "getPropertyDefinitions failed to initialize class", e);
        } catch (InstantiationException e) {
          logger.log(Level.SEVERE, "getPropertyDefinitions failed to initialize class", e);
        }
      }
      return false;
    }
  }

  /**
   * Returns shared code updater (singleton).
   */
  public static CodeUpdater getDefault() {
    if (defaultUpdater == null) {
      defaultUpdater = new CodeUpdater();
    }
    return defaultUpdater;
  }

  /**
   * Handles resources changes in the project and creates updateinfo instances
   * to kick off a uxmlc compile task.
   */
  public void resourceChanged(IResourceChangeEvent event) {
    if (event.getType() != IResourceChangeEvent.POST_CHANGE) {
      return;
    }
    IResourceDelta rootDelta = event.getDelta();
    final List<UpdateInfo> updateList = new ArrayList<UpdateInfo>();

    IResourceDeltaVisitor visitor = new IResourceDeltaVisitor() {
      public boolean visit(IResourceDelta delta) {
        // only interested in changed or added resources
        // to filter for content changes use IResourceDelta.Content

        IResource resource = delta.getResource();
        if (resource.isDerived()) {
          return true;
        }

        int change = delta.getKind();

        // Ignore if not changed and not added
        if (((change & IResourceDelta.CHANGED) == 0)
            && ((change & IResourceDelta.ADDED) == 0)
            && ((change & IResourceDelta.ADDED_PHANTOM) == 0)) {
          return true;
        }
        // Ignore if content hasn't changed but markers did
        if (((delta.getFlags() & IResourceDelta.CONTENT) == 0)
            && ((delta.getFlags() & IResourceDelta.MARKERS) != 0)) {
            return true;
        }

        //only interested in files with "hts, uxml, dart" extension
        if (resource.getType() == IResource.FILE && (
            "hts".equalsIgnoreCase(resource.getFileExtension()) ||
            "uxml".equalsIgnoreCase(resource.getFileExtension()) ||
            "dart".equalsIgnoreCase(resource.getFileExtension()))) {
          if (!createUpdateInfo(resource, updateList)) {
            return false;
          }
        }
        return true;
      }
    };

    // Visit every node and construct updateList
    try {
      rootDelta.accept(visitor);
    } catch (CoreException e) {
      //TODO(ferhat) open error dialog with syncExec or print to plugin log file
    }
    compileUpdates(updateList);
  }

  /**
   * Handles a resource change.
   * @param resource changed resource.
   * @param targetList targetList to add to.
   * @return success/failure.
   */
  public boolean createUpdateInfo(IResource resource, List<UpdateInfo> targetList) {
    String targetPath;
    String languages;
    boolean locaWarnEnabled;
    String importsPath;
    String libName;

    // Get ProjectItemMetadata , use cached metadata if possible.
    IProject project = resource.getProject();
    if (project != cachedProject) {
      // update cache
      cachedProject = project;
      cachedMeta = UXMLProjectMetadata.getProjectPreferences(project);
    }
    try {
      targetPath = cachedMeta.get(ProjectItemMetadata.TARGETPATH_KEY);
      languages = cachedMeta.get(ProjectItemMetadata.LANG_KEY);
      importsPath = cachedMeta.get(ProjectItemMetadata.IMPORTS_KEY);
      importsPath = resolvePathVariables(project, importsPath, resource.getPathVariableManager());
    } catch (CoreException e) {
      //TODO(ferhat) create markers to report failure
      return false;
    }
    try {
      libName = cachedMeta.get(ProjectItemMetadata.LIBRARY_KEY);
    } catch (CoreException e) {
      // Default to empty part name.
      libName = "";
    }
    try {
      locaWarnEnabled = Boolean.valueOf(cachedMeta.get(
          ProjectItemMetadata.LOCALIZATION_WARNING_KEY));
    } catch (CoreException e) {
      locaWarnEnabled = true;
    }
    if (languages == null) {
      languages = CodeGenLanguage.None.toString();
    }
    if (resource.getProjectRelativePath() != null &&
        resource.getProjectRelativePath().toString() != null &&
        resource.getProjectRelativePath().toString().contains("packages")) {
      return false;
    }
    for (String lang : languages.split(",")) {
      targetList.add(new UpdateInfo(resource, lang, libName, targetPath, importsPath.split(";"),
          locaWarnEnabled));
    }
    return true;
  }

  private String resolvePathVariables(IProject project, String path, IPathVariableManager varManager) {
    if ((path == null) || (path.length() == 0)) {
      return "";
    }
    String pref = Platform.getPreferencesService().getString(
        "com.hello.dart.tools.core", "package root", "", null);
    if (pref.endsWith("/")) {
      pref = pref.substring(0, pref.length() - 1);
    }

    StringBuilder sb = new StringBuilder();
    String[] parts = path.split(";");
    for (int p = 0; p < parts.length; p++) {
      String part = parts[p].trim();
      if (p != 0) {
        sb.append(";");
      }
      if (part.length() != 0) {
        if (path.startsWith("$PACKAGES")) {
          String absPackages = project.getFolder("packages").getRawLocation().toOSString();
          String packagesPath = absPackages == null ? "nullres" : absPackages;
          if (packagesPath.startsWith("/")) {
            packagesPath.substring(1);
          }
          path = packagesPath + "/" + path.substring("$PACKAGES:".length());
        }
        if (part.startsWith(IMPORT_PACKAGE_PREFIX)) {
          part = part.substring(IMPORT_PACKAGE_PREFIX.length());
          if (part.startsWith("/")) {
            part = part.substring(1);
          }
          path = pref + "/" + part;
        } else {
          try {
            URI resolvedPath = varManager.resolveURI(URI.create(part));
            if (resolvedPath != null) {
              path = resolvedPath.getPath();
            }
          } catch (IllegalArgumentException e) {
            // empty. just skip variable path resolve.
          }
        }
      }
      sb.append(path);
    }
    return sb.toString();
  }

  /**
   * Compiles a list of uxml files.
   * @param updateList list of files to compile.
   */
  public void compileUpdates(List<UpdateInfo> updateList) {
    // Now updateList has IResource for every hts file we need to gen code for
    File targetDirectory = null;
    List<CompilerError> allErrors = new ArrayList<CompilerError>();
    List<File> allOutputs = new ArrayList<File>();
    List<IResource> allResources = new ArrayList<IResource>();
    List<IResource> markerResources = new ArrayList<IResource>();

    for (UpdateInfo updateInfo : updateList) {
      try {
        if (updateInfo.getTargetPath().length() == 0) {
          targetDirectory = null;
        } else {
          targetDirectory = getTargetDirectory(updateInfo.resource, updateInfo.getTargetPath());
        }
      } catch (CoreException e) {

        logger.log(Level.SEVERE, "Target directory problem in CodeUpdater", e);
        //TODO(ferhat) report this to eclipse problems pane
        continue;
      }

      try {
        File sourceFile = updateInfo.getResource().getLocation().toFile();

        if (sourceFile.getPath().endsWith(".dart")) {
          buildIncremental(updateInfo, sourceFile, allOutputs);
          continue;
        }

        if (updateInfo.getLanguage().equals("None")) {
          continue;
        }

        // Create compile configuration
        CompileConfiguration config = new CompileConfiguration(sourceFile,
            targetDirectory, null, updateInfo.getLibraryName(), updateInfo.importPaths,
            updateInfo.getLanguage(), true, updateInfo.getLocalizationWarnEnabled());

        UXMLCompiler compiler = new UXMLCompiler(config, registry);
        logger.log(Level.INFO, "Compiling " + updateInfo.getResource().getName());

        if ((compiler.compile() == false) || (compiler.getErrors().size() != 0)) {
          List<CompilerError> errors = compiler.getErrors();
          IResource errorResource = updateInfo.getResource();
          for (int i = 0; i < errors.size(); i++) {
            allErrors.add(errors.get(i));
            allResources.add(errorResource);
          }
        } else {
          markerResources.add(updateInfo.getResource());
          // Refresh resources to make new target files visible
          List<File> outputs = compiler.getOutputs();
          if (!outputs.isEmpty()) {
            for (File output : outputs) {
              allOutputs.add(output);
            }
          }
        }
      } catch (Exception e) {
        IResource errorResource = updateInfo.getResource();
        StringBuilder sb = new StringBuilder();
        sb.append("Markup compiler failed for ");
        sb.append(updateInfo.getResource().getName());
        sb.append(" Exception=" + e.toString());
        StackTraceElement[] st = e.getStackTrace();
        if (st != null) {
          for (int s = 0; s < st.length; s++) {
            sb.append(" | ");
            sb.append(st[s].getFileName() + ":" + st[s].getLineNumber());
          }
        }

        allErrors.add(new CompilerError(sb.toString(), e));
        allResources.add(errorResource);
      }
    }

    UpdateWorkspaceJob job = new UpdateWorkspaceJob(allOutputs);
    job.schedule();

    if (allErrors.size() != 0) {
      CreateUXMLMarkersJob createMarkersJob = new CreateUXMLMarkersJob(allResources,
          allErrors);
      createMarkersJob.schedule();
    }
    DeleteHtsMarkersJob deleteMarkerJob = new DeleteHtsMarkersJob(markerResources);
    deleteMarkerJob.schedule();
    cachedProject = null;
    cachedMeta = null;
  }

  /**
   * Removes all generated files in genfiles.
   */
  public void removeAllGenFiles(IProject project, IProgressMonitor monitor) {
    String targetPath;
    if (project != cachedProject) {
      // update cache
      cachedProject = project;
      cachedMeta = UXMLProjectMetadata.getProjectPreferences(project);
    }
    try {
      targetPath = cachedMeta.get(ProjectItemMetadata.TARGETPATH_KEY);
      if (targetPath.length() != 0) {
        IFolder targetDir = project.getFolder(targetPath);
        targetDir.accept(new RemoveGeneratedFileVisitor(monitor), IResource.DEPTH_INFINITE,
            IContainer.INCLUDE_HIDDEN | IContainer.INCLUDE_PHANTOMS |
            IContainer.INCLUDE_TEAM_PRIVATE_MEMBERS);
      }
    } catch (CoreException e) {
      return; // ignore empty or nonexistant targetpath.
    }
  }

  private boolean createDartToX(IProject project) {
    dartToX = new DartToXCompiler();
    ProjectItemMetadata meta = UXMLProjectMetadata.getProjectPreferences(project);
    try {
      String serverUrl = meta.get(ProjectItemMetadata.DEVSERVER_URL_KEY);
      String dartStartup = meta.get(ProjectItemMetadata.DART_SCRIPT_KEY);
      String asTargetPath = meta.get(ProjectItemMetadata.DART_AS_COMPILE_TARGETPATH_KEY);
      String jsTargetPath = meta.get(ProjectItemMetadata.DART_JS_COMPILE_TARGETPATH_KEY);
      String objCTargetPath = meta.get(ProjectItemMetadata.DART_OBJC_COMPILE_TARGETPATH_KEY);
      boolean asEnabled = "true".equals(meta.get(ProjectItemMetadata.DART_AS_COMPILE_ENABLED_KEY));
      boolean jsEnabled = "true".equals(meta.get(ProjectItemMetadata.DART_JS_COMPILE_ENABLED_KEY));
      boolean objCEnabled = "true".equals(meta.get(
          ProjectItemMetadata.DART_OBJC_COMPILE_ENABLED_KEY));
      dartToX.setServerUrl(serverUrl);
      if (dartStartup != null && dartStartup.length() != 0) {
        dartStartup = resolveAbsolutePath(project, resolvePathVariables(project, dartStartup,
            project.getPathVariableManager()));
      }
      dartToX.setDartStartup(dartStartup);

      if (asTargetPath == null) {
        asTargetPath = "";
      } else if (asTargetPath.length() != 0) {
        asTargetPath = resolveAbsolutePath(project, resolvePathVariables(project, asTargetPath,
            project.getPathVariableManager()));
      }
      if (jsTargetPath == null) {
        jsTargetPath = "";
      } else if (jsTargetPath.length() != 0) {
        jsTargetPath = resolveAbsolutePath(project, resolvePathVariables(project, jsTargetPath,
            project.getPathVariableManager()));
      }
      if (objCTargetPath == null) {
        objCTargetPath = "";
      } else if (objCTargetPath.length() != 0) {
        objCTargetPath = resolveAbsolutePath(project, resolvePathVariables(project, objCTargetPath,
            project.getPathVariableManager()));
      }
      dartToX.addTarget(DartToXCompiler.LANG_AS, asEnabled, asTargetPath);
      dartToX.addTarget(DartToXCompiler.LANG_JS, jsEnabled, jsTargetPath);
      dartToX.addTarget(DartToXCompiler.LANG_OBJC, objCEnabled, objCTargetPath);
    } catch (CoreException e) {
      return false;
    }
    return true;
  }

  private String resolveAbsolutePath(IProject project, String targetPath) {
    if (targetPath.startsWith("/")) {
      return targetPath;
    } else {
      IFolder folder = project.getFolder(targetPath);
      return folder.getLocation().toFile().getAbsolutePath();
    }
  }

  /**
   * Called when rebuild all is required.
   */
  public void buildAll(IProject project) {
    if (dartToX == null) {
      createDartToX(project);
    }
    dartToX.buildAll();
    List<File> files = Lists.newArrayList();
    List<String> buildTargets = dartToX.getBuildTargets();
    if (buildTargets != null) {
      for (int f = 0; f < buildTargets.size(); f++) {
        files.add(new File(buildTargets.get(f)));
      }
    }
    UpdateWorkspaceJob job = new UpdateWorkspaceJob(files);
    job.schedule();
    List<String> sources = Lists.newArrayList();
    CreateDartMarkersJob markJob = new CreateDartMarkersJob(project, sources,
        dartToX.getMessages());
    markJob.schedule();
  }

  private void buildIncremental(UpdateInfo updateInfo, File sourceFile,
      List<File> targets) {
    IProject project = updateInfo.getResource().getProject();
    if (dartToX == null) {
      createDartToX(project);
    }
    dartToX.compileIncremental(sourceFile);
    List<String> buildTargets = dartToX.getBuildTargets();
    if (buildTargets != null) {
      for (int f = 0; f < buildTargets.size(); f++) {
        targets.add(new File(buildTargets.get(f)));
      }
    }
    List<String> sources = Lists.newArrayList();
    sources.add(sourceFile.getAbsolutePath());
    CreateDartMarkersJob markJob = new CreateDartMarkersJob(project, sources,
        dartToX.getMessages());
    markJob.schedule();
  }

  private static class RemoveGeneratedFileVisitor implements IResourceVisitor {
  private IProgressMonitor monitor;
  public RemoveGeneratedFileVisitor(IProgressMonitor monitor) {
      this.monitor = monitor;
  }
  @Override
  public boolean visit(IResource resource) throws CoreException {
      if (!resource.exists()) {
    return true;
    }
      if (resource.getType() != IResource.FILE) {
      return true;
      }
      File fullPath = resource.getLocation().toFile();
      if (validateFileIsGeneratedFile(fullPath)) {
      resource.delete(true, monitor);
      }
      return true;
  }
  }

  private static boolean validateFileIsGeneratedFile(File file) {
  String res = readFileContents(file);
  if (res != null) {
    if (res.contains("Auto-generated")) {
    return true;
    }
  }
    return false;
  }

  private static String readFileContents(File filePath) {
    byte[] buffer = new byte[(int) filePath.length()];
    BufferedInputStream stream = null;
    try {
      stream = new BufferedInputStream(new FileInputStream(filePath));
      stream.read(buffer);
    } catch (FileNotFoundException e) {
      return null;
    } catch (IOException ignore) {
      return null;
    } finally {
      if (stream != null) {
        try {
          stream.close();
        } catch (IOException ignore) {
          return null;
        }
      }
    }
    return new String(buffer);
  }

  /**
   * Returns target directory for a resource
   */
  private File getTargetDirectory(IResource resource, String targetPath) throws CoreException {
    IProject project = resource.getProject();
    if (project.exists() && (!project.isOpen())) {
      project.open(null);
    }
    if (targetPath == null) {
      return null;
    } else {
      if (targetPath.startsWith("/")) {
        return new File(targetPath);
      } else {
        IFolder folder = project.getFolder(targetPath);
        return folder.getLocation().toFile();
      }
    }
  }

  /**
   * Refreshes files in workspace.
   */
  static class UpdateWorkspaceJob extends Job {
    private List<File> outputs;

    public UpdateWorkspaceJob(final List<File> outputs) {
      super("Update uxml workspace");
      this.outputs = outputs;
    }

    @Override
    public IStatus run(IProgressMonitor monitor) {
      monitor.beginTask("Updating uxml workspace", 1);
      for (File output : outputs) {
        IWorkspaceRoot myWorkspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
        IFile[] files = myWorkspaceRoot.findFilesForLocationURI(output.toURI());
        for (IFile f : files) {
          try {
            f.refreshLocal(1, null);
            f.setDerived(true, monitor);
          } catch (CoreException e) {
            logger.log(Level.SEVERE, "workspace update failed after compile", e);
          }
        }
      }
      monitor.worked(1);
      monitor.done();
      return Status.OK_STATUS;
    }
  }

  /**
   * Deletes all markers for the list of resources.
   */
  static class DeleteHtsMarkersJob extends Job {
    private List<IResource> resources;

    public DeleteHtsMarkersJob(List<IResource> resources) {
      super("Updating Uxml");
      this.resources = resources;
    }

    @Override
    public IStatus run(IProgressMonitor monitor) {
      monitor.beginTask("Updating Uxml", 1);
      // Compile succeeded so delete markers
      int depth = IResource.DEPTH_INFINITE;
      for (int i = 0; i < resources.size(); i++) {
        try {
          resources.get(i).deleteMarkers(IMarker.PROBLEM, true, depth);
        } catch (CoreException e) {
          logger.log(Level.WARNING, "Uxml Marker deletion failed.");
        }
      }
      monitor.worked(1);
      monitor.done();
      resources = null;
      return Status.OK_STATUS;
    }
  }

  // Creates markers for uxml compiler errors.
  static class CreateUXMLMarkersJob extends Job {
    private List<IResource> resources;
    private List<CompilerError> errors;

    public CreateUXMLMarkersJob(List<IResource> resources, List<CompilerError> errors) {
      super("Compile UXML markup");
      this.resources = resources;
      this.errors = errors;
    }

    @Override
    public IStatus run(IProgressMonitor monitor) {
      monitor.beginTask("Compile UXML markup", 1);

      // Delete old markers
      int depth = IResource.DEPTH_INFINITE;
      for (int i = 0; i < resources.size(); i++) {
        try {
          resources.get(i).deleteMarkers(IMarker.PROBLEM, true, depth);
        } catch (CoreException e) {
          logger.log(Level.WARNING, "UXML Marker deletion failed.");
        }
      }

      int errorCount = 0;
      // Compile failed so add error markers
      for (int i = 0; i < errors.size(); i++) {
        try {
          CompilerError error = errors.get(i);
          IMarker marker = resources.get(i).createMarker(IMarker.PROBLEM);
          marker.setAttribute(IMarker.MESSAGE, error.getDescription());
          marker.setAttribute(IMarker.PRIORITY, IMarker.PRIORITY_HIGH);
          marker.setAttribute(IMarker.LINE_NUMBER, error.getLine());
          marker.setAttribute(IMarker.SEVERITY, error.getSeverity().equals(Severity.WARNING) ?
              IMarker.SEVERITY_WARNING : IMarker.SEVERITY_ERROR);
        } catch (CoreException e) {
          logger.log(Level.WARNING, "Uxml marker creation failed.");
        }
        if (errorCount++ > MAX_ERROR_REPORT_COUNT) {
          break;
        }
      }
      monitor.worked(1);
      monitor.done();
      resources = null;
      errors = null;
      return Status.OK_STATUS;
    }
  }

  // Creates markers for dart compiler messages.
  static class CreateDartMarkersJob extends Job {
    private IProject project;
    private List<CompilerMessage> errors;
    private List<String> sources;
    private static final String DARTX_SOURCE_ID = "DartXSource";

    public CreateDartMarkersJob(IProject project, List<String> sourceFiles,
        List<CompilerMessage> errors) {
      super("Compile DartToX");
      this.project = project;
      this.errors = errors;
      this.sources = sourceFiles;
    }

    @Override
    public IStatus run(IProgressMonitor monitor) {
      monitor.beginTask("Compile DartToX", 1);

      EclipsePathResolver resolver = new EclipsePathResolver(project);

      // Create list of unique file names.
      Set<String> fileNames = Sets.newHashSet();
      if (errors != null) {
        for (int i = 0; i < errors.size(); i++) {
          String fileName = errors.get(i).getLocation().getFileName();
          fileNames.add(fileName);
        }
      }
      for (String source : sources) {
        fileNames.add(source);
      }
      Map<String, IResource> resourceMap = Maps.newHashMap();
      // Delete old markers
      int depth = IResource.DEPTH_INFINITE;
      for (String fileName : fileNames) {
        try {
          IResource resource = resolver.findFile(fileName);
          if (resource != null) {
            resourceMap.put(fileName, resource);
            resource.deleteMarkers(IMarker.PROBLEM, true, depth);
          }
        } catch (CoreException e) {
          logger.log(Level.WARNING, "Marker deletion failed.");
        }
      }
      // Delete all project markers that belong to us.
      try {
        IMarker[] markers = project.findMarkers(IMarker.PROBLEM, true, depth);
        for (int i = 0; i < markers.length; i++) {
          IMarker marker = markers[i];
          if (marker.getAttribute(IMarker.SOURCE_ID) == DARTX_SOURCE_ID) {
            marker.delete();
          }
        }
      } catch (CoreException e1) {
        logger.log(Level.WARNING, "Marker deletion failed.");
      }

      int errorCount = 0;
      // Compile failed so add error markers
      if (errors != null) {
        for (int i = 0; i < errors.size(); i++) {
          try {
            CompilerMessage error = errors.get(i);
            IResource resource = resourceMap.get(error.getLocation().getFileName());
            if (resource == null) {
              resource = project;
            }
            IMarker marker = resource.createMarker(IMarker.PROBLEM);
            marker.setAttribute(IMarker.MESSAGE, error.getMessage());
            marker.setAttribute(IMarker.PRIORITY, IMarker.PRIORITY_HIGH);
            marker.setAttribute(IMarker.LINE_NUMBER, error.getLocation().getLine());
            marker.setAttribute(IMarker.SEVERITY, error.getType().equals("fatal:") ?
                IMarker.SEVERITY_ERROR : IMarker.SEVERITY_WARNING);
            marker.setAttribute(IMarker.SOURCE_ID, DARTX_SOURCE_ID);
          } catch (CoreException e) {
            logger.log(Level.WARNING, "Marker creation failed.");
          }
          if (errorCount++ > MAX_ERROR_REPORT_COUNT) {
            break;
          }
        }
      }
      monitor.worked(1);
      monitor.done();
      project = null;
      errors = null;
      resolver.clear();
      return Status.OK_STATUS;
    }
  }

  static class CompileConfiguration implements Configuration {

    private final Set<File> sourceFiles;
    private final File outputDirectory;
    private final File sourceRoot;
    private final String language;
    private final String libName;
    private final boolean debugEnabled;
    private final boolean localizationWarnEnabled;
    private final String[] importPaths;

    /**
     * Creates a command line configuration to pass onto {@code HtsCompiler}.
     */
    public CompileConfiguration(File markupFile, File outputDirectory, File sourceRoot,
        String libName,
        String[] importPaths, String language, boolean debugEnabled,
        boolean localizationWarnEnabled) {
      sourceFiles = new HashSet<File>();
      sourceFiles.add(markupFile);
      this.outputDirectory = outputDirectory;
      this.language = language;
      this.debugEnabled = debugEnabled;
      this.localizationWarnEnabled = localizationWarnEnabled;
      this.importPaths = importPaths;
      this.sourceRoot = sourceRoot;
      this.libName = libName;
    }

    public Set<File> getSourceFiles() {
      return sourceFiles;
    }

    public File getTargetDir() {
      return outputDirectory;
    }

    public String getOutputLanguage() {
      return language;
    }

    public String getLibraryName() {
      return libName;
    }

    public File getSourceRoot() {
      return sourceRoot;
    }

    public boolean isDebugEnabled() {
      return debugEnabled;
    }

    public boolean isLocalizationWarnEnabled() {
      return localizationWarnEnabled;
    }

    public String[] getImportPaths() {
      return importPaths;
    }
  }

  /**
   * Represents an update to .uxml file in the project
   */
  public static class UpdateInfo {
    private final IResource resource;
    private final String targetLang;
    private final String targetPath;
    private final String libName;
    private final boolean locaWarnEnabled;
    private final List<File> outputs = Lists.newArrayList();
    private final String[] importPaths;

    /**
     * Constructor.
     */
    public UpdateInfo(IResource resource, String targetLang, String libName,
        String targetPath, String[] importPaths, boolean locaWarnEnabled) {
      this.resource = resource;
      this.targetLang = targetLang;
      this.targetPath = targetPath;
      this.locaWarnEnabled = locaWarnEnabled;
      this.importPaths = importPaths;
      this.libName = libName;
    }

    /** Returns resource that was updated */
    public IResource getResource() {
      return this.resource;
    }

    /** Returns target language. */
    public String getLanguage() {
      return this.targetLang;
    }

    /** Returns library part name. */
    public String getLibraryName() {
      return this.libName;
    }

    /** Returns path for generated targets. */
    public String getTargetPath() {
      return this.targetPath;
    }

    /** Returns a list of outputs generated from compiler. */
    public List<File> getOutputs() {
      return outputs;
    }

    /** Returns true if localization warnings should be enabled. */
    public boolean getLocalizationWarnEnabled() {
      return locaWarnEnabled;
    }

    /** Adds a new output generated for the resource change. */
    public void addOutputs(List<File> files) {
      for (File f : files) {
        outputs.add(f);
      }
    }

    /** Returns a list of paths to use to resolve import references. */
    public String[] getImportPaths() {
      return importPaths;
    }
  }

  /**
   * Resolves project relative resource from absolute paths.
   * The compiler input & targets are all file system absolute.
   * To be able to create markers from build messages we need to
   * resolve the absolute name to a IProject name. Folders inside
   * the project might be linked to any absolute location so we
   * need to check each and find the file.
   **/
  static class EclipsePathResolver implements IResourceVisitor {
    private IProject project;
    private Map<String, IResource> folders;

    EclipsePathResolver(IProject project) {
      this.project = project;
      folders = Maps.newHashMap();
      try {
        project.accept(this);
      } catch (CoreException e) {
        e.printStackTrace();
      }
    }

    IResource findFile(String absolutePath) {
      for (String path : folders.keySet()) {
        if (absolutePath.startsWith(path)) {
          IResource folder = folders.get(path);
          String relPath = absolutePath.substring(path.length());
          if (relPath.startsWith("/")) {
            relPath = relPath.substring(1);
          }
          return project.findMember(folder.getProjectRelativePath().append(relPath), true);
        }
      }
      return null;
    }

    public void clear() {
      folders.clear();
    }

    @Override
    public boolean visit(IResource resource) throws CoreException {
      if (resource.getType() == IFolder.FOLDER) {
        if (resource.getLocation() != null) {
          folders.put(resource.getLocation().toString(), resource);
        }
      }
      return true;
    }
  }
}
