package com.hello.uxml.tools.codegen.dom;

import java.util.Stack;

/**
 * Manages current parse stack.
 *
 * <p>The parse stack contains Model and ModelProperty object based
 * on current node being parsed by ModelParser.
 *
 * @author ferhat@
 *
 */
public class ParseContext {

  /** Holds stack of model items */
  private Stack<Object> parseStack = new Stack<Object>();

  /**
   * Sets context to model.
   */
  public void push(Model model) {
    parseStack.push(model);
  }

  /**
   * Sets context to property.
   */
  public void push(ModelProperty modelProperty) {
    parseStack.push(modelProperty);
  }

  /**
   * Pops item from context stack.
   */
  public void pop() {
    parseStack.pop();
  }

  /**
   * Returns whether current context is model node.
   */
  public boolean isModel() {
    return parseStack.isEmpty() ? false : (parseStack.peek() instanceof Model);
  }

  /**
   * Returns whether current context is a property.
   */
  public boolean isProperty() {
    return parseStack.isEmpty() ? false : (parseStack.peek() instanceof ModelProperty);
  }

  /**
   * Returns current context property.
   */
  public ModelProperty getCurrentProperty() {
    return parseStack.isEmpty() ? null : ((ModelProperty) parseStack.peek());
  }

  /**
   * Returns current context model.
   */
  public Model getCurrentModel() {
    return parseStack.isEmpty() ? null : ((Model) parseStack.peek());
  }
}
