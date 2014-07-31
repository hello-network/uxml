package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for java get property expression.
 *
 * @author ferhat
 */
public class JGetPropertyExpression extends Expression {
  private Expression source;
  private String fieldName;

  /**
   * Constructor.
   */
  public JGetPropertyExpression(Expression source, String fieldName) {
    this.source = source;
    this.fieldName = fieldName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    source.toCode(writer);
    writer.print(".get");
    String javaFieldName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1, fieldName.length());
    writer.print(javaFieldName);
    writer.print("(");
    writer.print(")");
  }
}
