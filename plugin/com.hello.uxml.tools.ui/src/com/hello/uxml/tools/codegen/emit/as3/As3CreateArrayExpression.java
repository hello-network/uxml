package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Writes code for array creation.
 *
 * @author ferhat
 */
public class As3CreateArrayExpression extends Expression {
  private Expression[] values;

  /**
   * Constructor.
   */
  public As3CreateArrayExpression(Expression[] values) {
    this.values = values;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("[");
    boolean firstItem = true;
    for (Expression expr : values) {
      if (firstItem) {
        firstItem = false;
      } else {
        writer.print(", ");
      }
      expr.toCode(writer);
    }
    writer.print("]");
  }
}
