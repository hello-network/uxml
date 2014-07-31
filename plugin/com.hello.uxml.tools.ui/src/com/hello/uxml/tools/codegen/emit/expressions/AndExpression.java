package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines an AND (&&, etc) expression for conditions
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class AndExpression extends Expression {
  private final Expression leftExpression;
  private final Expression rightExpression;

  /**
   * Create an and expression with a left (base) expression and a right (may be continued and
   * expressions) expression
   *
   * @param leftExpression The base expression
   * @param rightExpression The (perhaps same, nested) expression to the right of the operand
   */
  public AndExpression(Expression leftExpression, Expression rightExpression) {
    super();
    this.leftExpression = leftExpression;
    this.rightExpression = rightExpression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    leftExpression.toCode(writer);
    writer.print(" && ");
    rightExpression.toCode(writer);
  }
}
