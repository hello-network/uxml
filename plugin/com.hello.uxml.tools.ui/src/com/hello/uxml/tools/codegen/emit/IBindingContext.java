package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.dom.Model;

/**
 * Provides property value translation service for CodeSerializer.
 *
 * @author ferhat
 */
public interface IBindingContext {
  Model getResourceModel(String bindingExpression);
}
