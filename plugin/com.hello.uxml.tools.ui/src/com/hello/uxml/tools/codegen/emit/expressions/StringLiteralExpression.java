package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for string literal.
 *
 * @author ferhat
 */
public class StringLiteralExpression extends Expression {
  private String value;

  /**
   * Constructor.
   */
  public StringLiteralExpression(String value) {
    this.value = value;
    if (value == null || value.equals("null")) {
      throw new RuntimeException("Invalid string literal expression value");
    }
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("\"" + value + "\"");
  }
}
