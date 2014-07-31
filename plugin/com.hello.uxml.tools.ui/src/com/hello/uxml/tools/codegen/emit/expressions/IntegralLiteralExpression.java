package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines an Expression for a whole-number literal.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class IntegralLiteralExpression extends Expression {
  private final long value;

  /**
   * Constructs an Expression for a whole-number literal.
   *
   * @param value The literal value.
   */
  public IntegralLiteralExpression(long value) {
    this.value = value;
  }

  /**
   * Returns value of expression.
   */
  public long getValue() {
    return value;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(Long.toString(value));
  }
}
