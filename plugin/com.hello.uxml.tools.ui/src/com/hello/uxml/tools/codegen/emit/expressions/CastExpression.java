package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Represents a method call expression.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class CastExpression extends Expression {
  protected String methodName;
  private final Reference classToCastTo;
  private final Expression expressionToCast;

  /**
   * Constructor.
   */
  public CastExpression(Reference classToCastTo, Expression expressionToCast) {
    super();
    this.classToCastTo = classToCastTo;
    this.expressionToCast = expressionToCast;
  }

  @Override
  public void toCode(SourceWriter writer) {
    classToCastTo.toCode(writer);
    writer.print("(");
    expressionToCast.toCode(writer);
    writer.print(")");
  }
}
