package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.SetFieldExpression;

/**
 * Creates code for java set field expression.
 *
 * @author ferhat
 */
public class JSetFieldExpression extends SetFieldExpression {
  private Expression target;
  private String fieldName;
  private Expression rhs;

  /**
   * Constructor.
   */
  public JSetFieldExpression(Expression target, String fieldName, Expression rhs) {
    this.target = target;
    this.fieldName = fieldName;
    this.rhs = rhs;
  }

  @Override
  public void toCode(SourceWriter writer) {
    target.toCode(writer);
    writer.print(".");
    String javaFieldName = fieldName.substring(0, 1).toLowerCase()
      + fieldName.substring(1, fieldName.length());
    writer.print(javaFieldName);
    writer.print(" = ");
    rhs.toCode(writer);
  }
}
