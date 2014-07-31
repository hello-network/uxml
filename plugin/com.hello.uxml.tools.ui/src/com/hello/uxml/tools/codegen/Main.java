package com.hello.uxml.tools.codegen;

import com.google.common.collect.Sets;
import com.google.common.flags.Flag;
import com.google.common.flags.FlagSpec;
import com.google.common.flags.Flags;
import com.google.common.io.Files;
import com.hello.uxml.tools.codegen.emit.BuilderFactoryRegistry;
import com.hello.uxml.tools.codegen.emit.as3.As3BuilderFactory;
import com.hello.uxml.tools.codegen.emit.dart.DartBuilderFactory;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Implements command line entry point to htsc compiler.
 *
 * <p>Collects command line flags and file list to pass a Configuration to HtsCompiler.
 *
 * @author ferhat
 */
public class Main {

  @FlagSpec(help = "If true, includes debug information in generated code")
  private static final Flag<Boolean> debug = Flag.value(false);

  @FlagSpec(help = "If true, generates localization warnings")
  private static final Flag<Boolean> warnlocalization = Flag.value(false);

  @FlagSpec(help = "Specifies comma separated paths to use for uxml imports")
  private static final Flag<String> imports = Flag.value("");
  @FlagSpec(help = "Sets output language. Supported values are As3, Dart, Java,ObjC")
  private static final Flag<String> lang = Flag.value("As3");
  @FlagSpec(help = "Creates aslib file with list of outputs and md5sum")
  private static final Flag<String> aslib = Flag.value("");

  @FlagSpec(altName = "out", help = "Sets project specific output path")
  private static final Flag<String> FLAG_out = Flag.value("");
  @FlagSpec(altName = "sourceroot", help = "Sets root of source files.")
  private static final Flag<String> FLAG_sourceRoot = Flag.value("");
  @FlagSpec(altName = "libraryname", help = "Sets the part name to use for generated files.")
  private static final Flag<String> FLAG_libraryName = Flag.value("");

  /**
   * Output directory.
   * If null, source hts directory is used for output
   */
  private static File outputDir;

  private static final Logger logger = Logger.getLogger(Main.class.getName());

  /**
   * Non public constructor.
   */
  private Main() {
  }

  public static void main(final String[] args) {
    String[] fileArgs = Flags.parseAndReturnLeftovers(args);

    if (fileArgs.length == 0) {
      logger.log(Level.SEVERE, "No input files specified");
      return;
    }
    Set<File> srcFiles = createFileSetFromNames(fileArgs);

    // Verify output directory if it was specified in flags
    if (FLAG_out.get().length() != 0) {
      outputDir = new File(FLAG_out.get());
      outputDir.mkdir();
      if (!outputDir.isDirectory()) {
        logger.log(Level.SEVERE , "Invalid output directory." + outputDir);
        return;
      }
    }

    File sourceRoot = null;
    if (FLAG_sourceRoot.get().length() != 0) {
      sourceRoot = new File(FLAG_sourceRoot.get());
    }

    // Additional languages supported by htsc should be registered here:
    BuilderFactoryRegistry registry = new BuilderFactoryRegistry();
    registry.registerFactory("As3", new As3BuilderFactory());
    registry.registerFactory("Dart", new DartBuilderFactory());
    String[] importsPath = normalizeImportsPath(imports.get());
    CommandLineConfiguration config = new Main.CommandLineConfiguration(srcFiles, outputDir,
        sourceRoot, FLAG_libraryName.get(), importsPath, lang.get(), debug.get(),
        warnlocalization.get());
    UXMLCompiler comp = new UXMLCompiler(config, registry);
    if (!comp.compile()) {
      for (CompilerError error : comp.getErrors()) {
        System.err.println(error.toString());
      }
    } else {
      if (!aslib.get().equals("")) {
        StringBuilder sb = new StringBuilder();
        try {

          // Build a string of mdsum1 filename1\n mdsum2 filename2\n....
          // See AsLibrary build rule for details
          int outputCount = comp.getOutputs().size();
          for (int i = 0; i < outputCount; ++i) {
            sb.append(comp.getOutputMd5s().get(i));
            sb.append(" ");
            String absPath = comp.getOutputs().get(i).getAbsolutePath();
            sb.append(absPath);
            sb.append("\n");
          }
          String aslibContent = sb.toString();

          // Now write aslib file
          File aslibFile = new File(aslib.get());
          if (aslibFile.exists()) {
            aslibFile.delete();
          }
          Files.write(aslibContent, aslibFile, Charset.defaultCharset());
        } catch (IOException e) {
          System.err.println(String.format("Could not generate aslib file. %s", e.toString()));
        }
      }
    }
  }

  /**
   * Creates a Set of File objects from an array of file names.
   */
  private static Set<File> createFileSetFromNames(String[] fileArgs) {
    Set<File> srcFiles = Sets.newHashSet();
    for (String filename : fileArgs) {
      if (filename.endsWith(",")) {
        filename = filename.substring(0, filename.length() - 1);
      }
      srcFiles.add(new File(filename));
    }
    return srcFiles;
  }

  private static String[] normalizeImportsPath(String baseImports) {
    if ((baseImports == null) || (baseImports.length() == 0)) {
      return new String[] {};
    }
    Set<String> importSet = Sets.newHashSet();

    baseImports = baseImports.trim();
    if (baseImports.startsWith("[")) {
      baseImports = baseImports.substring(1, baseImports.lastIndexOf("]"));
    }

    String[] imports = baseImports.split(";");
    for (int i = 0; i < imports.length; i++) {
      String path = imports[i].trim();
      if (path.length() == 0) {
        continue;
      }

      String[] items = path.split(",");
      for (String item : items) {
        readItems(item.trim(), importSet);
      }
    }
    return importSet.toArray(new String[importSet.size()]);
  }

  private static void readItems(String path, Set<String> importSet) {
    while (path.startsWith("'")) {
      path = path.substring(1, path.lastIndexOf("'")).trim();
    }
    String[] parts = path.split(" ");
    for (String part : parts) {
      if (part.endsWith(".hts") || part.endsWith(".xlb") || part.endsWith(".uxml")) {
        part = part.substring(0, part.lastIndexOf("/")).trim();
      }
      if (!importSet.contains(part)) {
        importSet.add(part);
      }
    }
  }

  /**
   * Implements configuration interface.
   */
  public static class CommandLineConfiguration implements Configuration {

    private final Set<File> sourceFiles;
    private final File outputDirectory;
    private final File sourceRoot;
    private final String[] importPaths;
    private final String language;
    private final String libraryName;
    private final boolean debugEnabled;
    private final boolean localizationWarnEnabled;

    /**
     * Creates a command line configuration to pass onto {@code HtsCompiler}.
     */
    public CommandLineConfiguration(Set<File> sourceFiles, File outputDirectory,
        File sourceRoot, String libraryName, String[] importPaths, String language,
        boolean debugEnabled, boolean localizationWarnEnabled) {
      this.sourceFiles = sourceFiles;
      this.importPaths = importPaths;
      this.outputDirectory = outputDirectory;
      this.language = language;
      this.debugEnabled = debugEnabled;
      this.localizationWarnEnabled = localizationWarnEnabled;
      this.sourceRoot = sourceRoot;
      this.libraryName = libraryName;
    }

    @Override
    public Set<File> getSourceFiles() {
      return sourceFiles;
    }

    @Override
    public File getTargetDir() {
      return outputDirectory;
    }

    @Override
    public File getSourceRoot() {
      return sourceRoot;
    }

    @Override
    public String getLibraryName() {
      return libraryName;
    }

    @Override
    public String getOutputLanguage() {
      return language;
    }

    @Override
    public boolean isDebugEnabled() {
      return debugEnabled;
    }

    @Override
    public boolean isLocalizationWarnEnabled() {
      return localizationWarnEnabled;
    }

    @Override
    public String[] getImportPaths() {
      return importPaths;
    }
  }
}
