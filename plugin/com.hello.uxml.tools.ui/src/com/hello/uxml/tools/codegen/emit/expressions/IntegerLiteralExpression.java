package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for integer literal.
 *
 * @author ferhat
 */
public class IntegerLiteralExpression extends Expression {
  private int value;

  /**
   * Constructor.
   */
  public IntegerLiteralExpression(int value) {
    this.value = value;
  }

  /**
   * Returns value of expression.
   */
  public int getValue() {
    return value;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(Integer.toString(value));
  }
}
