package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for accessing a class.
 *
 * @author ferhat
 */
public class As3ClassReferenceExpression extends Expression {
  private TypeToken type;

  /**
   * Constructor.
   */
  public As3ClassReferenceExpression(TypeToken type) {
    this.type = type;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(type.getName());
  }
}
