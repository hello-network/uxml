package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code for null literal.
 *
 * @author ferhat
 */
public class NullLiteralExpression extends Expression {

  /**
   * Constructor.
   */
  public NullLiteralExpression() {
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("null");
  }
}
