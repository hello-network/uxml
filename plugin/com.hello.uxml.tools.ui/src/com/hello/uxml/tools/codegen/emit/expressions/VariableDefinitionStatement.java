package com.hello.uxml.tools.codegen.emit.expressions;

/**
 * Provides abstract base class for local variable definition.
 *
 * @author ferhat
 */
public abstract class VariableDefinitionStatement extends Statement {

  /** Returns reference for variable */
  public abstract Reference getReference();

  /** Returns the initialization expression. */
  public abstract Expression getInitializationExpression();
}
