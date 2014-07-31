package com.hello.uxml.tools.codegen;

import com.hello.uxml.tools.codegen.dom.Model;

import java.util.List;

/**
 * Defines interface for importing models of referenced uxml files
 * specified using a relative path.
 *
 * @author ferhat@
 *
 */
public interface IUXMLImporter {

  /**
   * Imports uxml file.
   *
   * @param path Relative or absolute path of uxml.
   * @param errors compilation errors and warnings.
   * @return DOM of uxml.
   */
  Model importModel(String path, List<CompilerError> errors);
}
