package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * An expression abstracted as a condition (to declare intent).
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class Condition extends Expression {
  public Expression expression;

  /**
   * @param expression The expression contained in the condition
   */
  public Condition(Expression expression) {
    super();
    this.expression = expression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    expression.toCode(writer);
  }

}
