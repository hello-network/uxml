package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Writes code for array creation.
 *
 * @author ferhat
 */
public class JCreateArrayExpression extends Expression {
  private Expression[] values;
  private TypeToken arrayType;

  /**
   * Constructor.
   */
  public JCreateArrayExpression(TypeToken arrayType, Expression[] values) {
    this.arrayType = arrayType;
    this.values = values;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("new ");
    writer.print(arrayType.getName());
    writer.print("[] {");
    boolean firstItem = true;
    for (Expression expr : values) {
      if (firstItem) {
        firstItem = false;
      } else {
        writer.print(", ");
      }
      expr.toCode(writer);
    }
    writer.print("}");
  }
}
