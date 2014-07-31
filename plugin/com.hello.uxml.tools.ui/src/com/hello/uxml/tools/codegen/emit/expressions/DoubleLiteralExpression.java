package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for floating point literal.
 *
 * @author ferhat
 */
public class DoubleLiteralExpression extends Expression {
  private double value;

  /**
   * Constructor.
   */
  public DoubleLiteralExpression(double value) {
    this.value = value;
  }

  /**
   * Returns value of expression.
   */
  public double getValue() {
    return value;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(Double.toString(value));
  }
}
