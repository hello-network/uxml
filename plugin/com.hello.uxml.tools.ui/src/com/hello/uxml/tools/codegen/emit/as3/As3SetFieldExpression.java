package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.SetFieldExpression;

/**
 * Creates code for actionscript set field expression.
 *
 * @author ferhat
 */
public class As3SetFieldExpression extends SetFieldExpression {
  private Expression target;
  private String fieldName;
  private Expression rhs;

  /**
   * Constructor.
   */
  public As3SetFieldExpression(Expression target, String fieldName, Expression rhs) {
    this.target = target;
    this.fieldName = fieldName;
    this.rhs = rhs;
  }

  @Override
  public void toCode(SourceWriter writer) {
    target.toCode(writer);
    writer.print(".");
    writer.print(fieldName.substring(0, 1).toLowerCase());
    writer.print(fieldName.substring(1));
    writer.print(" = ");
    rhs.toCode(writer);
  }
}
