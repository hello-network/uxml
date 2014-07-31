package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for actionscript get field expression.
 *
 * @author ferhat
 */
public class As3GetFieldExpression extends Expression {
  private Expression source;
  private String fieldName;

  /**
   * Constructor.
   */
  public As3GetFieldExpression(Expression source, String fieldName) {
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
