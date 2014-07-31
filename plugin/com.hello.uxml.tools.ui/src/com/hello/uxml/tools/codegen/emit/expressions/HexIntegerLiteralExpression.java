package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for integer literal in hex form (for Colors).
 *
 * @author ferhat
 */
public class HexIntegerLiteralExpression extends Expression {
  private final int value;

  /**
   * Constructor.
   */
  public HexIntegerLiteralExpression(int value) {
    this.value = value;
  }

  /**
   * @return value of expression.
   */
  public int intValue() {
    return value;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("0x" + Integer.toHexString(value));
  }
}
