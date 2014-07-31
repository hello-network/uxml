package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code type-casting.
 *
 * @author ferhat
 */
public class As3TypeCastExpression extends Expression {
  private TypeToken targetType;
  private Expression expression;

  /**
   * Constructor.
   */
  public As3TypeCastExpression(TypeToken targetType, Expression expression) {
    this.targetType = targetType;
    this.expression = expression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(targetType.getName());
    writer.print("(");
    expression.toCode(writer);
    writer.print(")");
  }
}
