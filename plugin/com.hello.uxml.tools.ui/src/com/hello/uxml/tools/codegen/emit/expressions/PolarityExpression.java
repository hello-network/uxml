package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a polarity unary Expression.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class PolarityExpression extends Expression {
  private final Expression expression;
  private final boolean negative;

  /**
   * Constructs a polarity unary Expression from an existing expression.
   *
   * @param expression The expression to polarize.
   * @param negative Whether to negate or not.
   */
  public PolarityExpression(Expression expression,
      boolean negative) {
    this.expression = expression;
    this.negative = negative;
  }

  /* (non-Javadoc)
   * @see com.hello.uxml.tools.codegen.emit.expressions.Expression#toCode()
   */
  @Override
  public void toCode(SourceWriter writer) {
    writer.print(this.negative ? "-" : "+");
    expression.toCode(writer);
  }

}
