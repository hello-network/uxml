package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for accessing a class object.
 *
 * @author ferhat
 */
public class JClassReferenceExpression extends Expression {
  private TypeToken type;

  /**
   * Constructor.
   */
  public JClassReferenceExpression(TypeToken type) {
    this.type = type;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(type.getName());
    writer.print(".class");
  }
}
