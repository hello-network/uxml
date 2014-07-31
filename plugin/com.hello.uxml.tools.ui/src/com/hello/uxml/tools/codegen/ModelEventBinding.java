package com.hello.uxml.tools.codegen;

import com.hello.uxml.tools.codegen.dom.ModelProperty;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Holds information about event bindings to be processed in second phase
 * of ModelCompiler/ChromeCompiler.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class ModelEventBinding {
  private Reference sourceObject;
  private ModelProperty boundProperty;

  public ModelEventBinding(Reference source, ModelProperty property) {
    sourceObject = source;
    boundProperty = property;
  }

  /**
   * Returns reference to source of event.
   */
  public Reference getSource() {
    return sourceObject;
  }

  /**
   * Returns property that holds event target value.
   */
  public ModelProperty getProperty() {
    return boundProperty;
  }
}
