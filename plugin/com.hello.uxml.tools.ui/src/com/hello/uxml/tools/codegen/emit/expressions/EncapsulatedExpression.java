package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * An encapsulated (contained within parentheses) expression
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class EncapsulatedExpression extends Expression {
  public Expression containedExpression;

  /**
   * Creates a new encapsulated expression
   *
   * @param containedExpression The expression contained within the
   *                            encapsulated expression
   */
  public EncapsulatedExpression(Expression containedExpression) {
    super();
    this.containedExpression = containedExpression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("(");
    if (containedExpression != null) {
      containedExpression.toCode(writer);
    }
    writer.print(")");
  }
}
