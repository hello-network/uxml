package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NameExpression;
import com.hello.uxml.tools.codegen.emit.expressions.PropertyExpression;

/**
 * A property expression with a left (base) expression and a right (may be another nested
 * property) expression.
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class DartPropertyExpression extends PropertyExpression{

  /**
   * Create a property expression with a left (base) expression and a right (may be another nested
   * property) expression.
   *
   * @param name The base expression
   * @param rightExpression The (possibly another nested property) expression to the right of the
   * operand
   */
  public DartPropertyExpression(NameExpression name,
      Expression rightExpression) {
    super(name, rightExpression);
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("\"");
    name.toCode(writer);
    writer.print("\":");
    value.toCode(writer);
  }
}
