package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for boolean literal.
 *
 * @author ferhat
 */
public class BooleanLiteralExpression extends Expression {
  private Boolean value;

  /**
   * Constructor.
   */
  public BooleanLiteralExpression(Boolean value) {
    this.value = value;
  }

  /**
   * Returns value of expression.
   */
  public boolean getValue() {
    return value;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(Boolean.toString(value));
  }
}
