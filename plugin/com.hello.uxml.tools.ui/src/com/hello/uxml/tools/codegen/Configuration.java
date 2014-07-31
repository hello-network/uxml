package com.hello.uxml.tools.codegen;

import java.io.File;
import java.util.Set;

/**
 * Configuration for HTS compiler.
 *
 * @author ferhat
 */
public interface Configuration {

  /**
   * Returns the set of source files to be compiled.
   */
  Set<File> getSourceFiles();

  /**
   * Returns target directory to compile to.
   */
  File getTargetDir();

  /**
   * Returns source root directory.
   * genfiles/dir/file.uxml is created based on root for languages
   * without package structure such as dart.
   */
  File getSourceRoot();

  /**
   * Returns output language.
   */
  String getOutputLanguage();

  /**
   * Returns library (part name).
   */
  String getLibraryName();

  /**
   * Returns whether debug information should be included.
   */
  boolean isDebugEnabled();

  /**
   * Returns whether warnings are enabled for unlocalized strings.
   */
  boolean isLocalizationWarnEnabled();

  /**
   * Returns list of paths to use for uxml imports.
   */
  String[] getImportPaths();
}
