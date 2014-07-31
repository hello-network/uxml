
package com.hello.uxml.tools.core.internal.builder;

import com.google.common.collect.Lists;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;

import java.util.List;
import java.util.Map;

/**
 * Implements builder for UXML Project Nature to recompile all
 * uxml files when doing a full_build.
 * (Incremental updates are handled through resource change listener).
 *
 * @author ferhat
 */
public class UXMLBuilder extends IncrementalProjectBuilder {
  public static final String BUILDER_ID = "com.hello.uxml.tools.uxmlBuilder";

  public UXMLBuilder() {
    super();
  }

  class UxmlResourceVisitor implements IResourceVisitor {
    private CodeUpdater codeUpdater;
    private List<CodeUpdater.UpdateInfo> targetList;

    /**
     * Constructor.
     * @param codeUpdater updater to use to create list to compile.
     */
    public UxmlResourceVisitor(CodeUpdater codeUpdater,
        List<CodeUpdater.UpdateInfo> targetList) {
      this.codeUpdater = codeUpdater;
      this.targetList = targetList;
    }

    public boolean visit(IResource resource) {
      if (resource instanceof IFile && (resource.getName().endsWith(".hts") ||
        resource.getName().endsWith(".uxml"))) {
        codeUpdater.createUpdateInfo(resource, targetList);
      }
      return true; // continue visiting children.
    }
  }

  /*
   * (non-Javadoc)
   *
   * @see org.eclipse.core.internal.events.InternalBuilder#build(int,
   *      java.util.Map, org.eclipse.core.runtime.IProgressMonitor)
   */
  protected IProject[] build(int kind, @SuppressWarnings("rawtypes") Map args,
      IProgressMonitor monitor) throws CoreException {
    IProject project = getProject();
    if (kind == FULL_BUILD) {
      fullBuild(monitor, project);
    } else {
      IResourceDelta delta = getDelta(project);
      if (delta == null) {
        fullBuild(monitor, project);
      } else {
        incrementalBuild(delta, monitor);
      }
    }
    return null;
  }

  protected void clean(IProgressMonitor monitor) throws CoreException {
    try {
      CodeUpdater codeUpdater = new CodeUpdater();
      List<CodeUpdater.UpdateInfo> updateList = Lists.newArrayList();
      getProject().accept(new UxmlResourceVisitor(codeUpdater, updateList));
      IProject project = getProject();
      codeUpdater.removeAllGenFiles(getProject(), monitor);
      codeUpdater.compileUpdates(updateList);
      codeUpdater.buildAll(project);
    } catch (CoreException e) {
      // ignore.
    }
  }

  protected boolean fullBuild(final IProgressMonitor monitor, final IProject project)
            throws CoreException {
    try {
      CodeUpdater codeUpdater = new CodeUpdater();
      List<CodeUpdater.UpdateInfo> updateList = Lists.newArrayList();
      getProject().accept(new UxmlResourceVisitor(codeUpdater, updateList));
      codeUpdater.removeAllGenFiles(getProject(), monitor);
      codeUpdater.compileUpdates(updateList);
      codeUpdater.buildAll(project);
      return true;
    } catch (CoreException e) {
      return false;
    }
  }

  protected void incrementalBuild(IResourceDelta delta,
      IProgressMonitor monitor) throws CoreException {
  }
}
