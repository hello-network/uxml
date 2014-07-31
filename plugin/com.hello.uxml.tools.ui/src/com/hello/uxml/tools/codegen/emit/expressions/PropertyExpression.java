package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * A property (name: value) expression.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class PropertyExpression extends Expression {

  protected final NameExpression name;
  protected final Expression value;

  /**
   * Create a property expression with a left (base) expression and a right (may be another nested
   * property) expression.
   *
   * @param name The base expression
   * @param rightExpression The (possibly another nested property) expression to the right of the
   * operand
   */
  public PropertyExpression(NameExpression name,
      Expression rightExpression) {
    super();
    this.name = name;
    this.value = rightExpression;
  }

  @Override
  public void toCode(SourceWriter writer) {
    name.toCode(writer);
    writer.print(":");
    value.toCode(writer);
  }
}
