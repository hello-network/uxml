package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for java set property expression.
 *
 * @author ferhat
 */
public class JSetPropertyExpression extends Expression {
  private Expression target;
  private String fieldName;
  private Expression rhs;

  /**
   * Constructor.
   */
  public JSetPropertyExpression(Expression target, String fieldName, Expression rhs) {
    this.target = target;
    this.fieldName = fieldName;
    this.rhs = rhs;
  }

  @Override
  public void toCode(SourceWriter writer) {
    target.toCode(writer);
    writer.print(".set");
    String javaFieldName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1, fieldName.length());
    writer.print(javaFieldName);
    writer.print("(");
    rhs.toCode(writer);
    writer.print(")");
  }
}
