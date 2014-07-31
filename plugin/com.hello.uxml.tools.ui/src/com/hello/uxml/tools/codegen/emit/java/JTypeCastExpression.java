package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code type-casting.
 *
 * @author ferhat
 */
public class JTypeCastExpression extends Expression {
  private TypeToken targetType;
  private Expression expression;

  /**
   * Constructor.
   */
  public JTypeCastExpression(TypeToken targetType, Expression expression) {
    this.targetType = targetType;
    this.expression = expression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("((");
    writer.print(targetType.getName());
    writer.print(") ");
    expression.toCode(writer);
    writer.print(")");
  }
}
