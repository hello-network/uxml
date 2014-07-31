
package com.hello.uxml.tools.ui.internal.properties;

import org.eclipse.core.runtime.CoreException;

/**
 * Defines CRUD interface for a list of preference key/value pairs.
 *
 * @author ferhat
 */
public interface ProjectItemMetadata {
  public static final String LANG_KEY = "CodeGen.Lang";
  /** Preference key for target path*/
  public static final String TARGETPATH_KEY = "CodeGen.TargetPath";
  public static final String IMPORTS_KEY = "CodeGen.Imports";
  public static final String LIBRARY_KEY = "CodeGen.Library";
  public static final String LOCALIZATION_WARNING_KEY = "CodeGen.LocalizeWarnEnabled";
  public static final String DEBUG_ENABLED_KEY = "CodeGen.DebugEnabled";
  public static final String DEVSERVER_URL_KEY = "CodeGen.DevServerUrl";
  public static final String DART_SCRIPT_KEY = "CodeGen.DartStartupScript";
  public static final String DART_AS_COMPILE_ENABLED_KEY = "CodeGen.DartCompileAsEnabled";
  public static final String DART_AS_COMPILE_TARGETPATH_KEY = "CodeGen.DartCompileAsTargetPath";
  public static final String DART_JS_COMPILE_ENABLED_KEY = "CodeGen.DartCompileJsEnabled";
  public static final String DART_JS_COMPILE_TARGETPATH_KEY = "CodeGen.DartCompileJsTargetPath";
  public static final String DART_OBJC_COMPILE_ENABLED_KEY = "CodeGen.DartCompileObjCEnabled";
  public static final String DART_OBJC_COMPILE_TARGETPATH_KEY = "CodeGen.DartCompileObjCTargetPath";

  /**
   * Stores a key/value pair at the project level.
   */
  void put(String key, String value) throws CoreException;
  /**
   * Retrieves the value at the project level. Returns null if key doesn't exist
   */
  String get(String key) throws CoreException;
  /**
   * Deletes a key/value pair
   */
  void delete(String key) throws CoreException;
}
