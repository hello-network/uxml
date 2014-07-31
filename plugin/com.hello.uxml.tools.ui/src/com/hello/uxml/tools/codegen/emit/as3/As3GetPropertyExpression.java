package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for actionscript get property expression.
 *
 * @author ferhat
 */
public class As3GetPropertyExpression extends Expression {
  private Expression source;
  private String fieldName;

  /**
   * Constructor.
   */
  public As3GetPropertyExpression(Expression source, String fieldName) {
    this.source = source;
    this.fieldName = fieldName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    source.toCode(writer);
    writer.print(".");
    writer.print(fieldName);
  }
}
