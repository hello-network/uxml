package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NewObjectExpression;

/**
 * Writes actionscript code for object instantiation.
 *
 * @author ferhat
 */
public class As3NewObjectExpression extends NewObjectExpression {
  private TypeToken type;
  private Expression[] parameters;

  public As3NewObjectExpression(TypeToken type) {
    this.type = type;
  }

  public As3NewObjectExpression(TypeToken type, Expression[] parameters) {
    this.type = type;
    this.parameters = parameters;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("new ");
    writer.print(type.getName());
    writer.print("(");
    if (parameters != null) {
      Boolean firstParam = true;
      for (Expression param : parameters) {
        if (firstParam) {
          firstParam = false;
        } else {
          writer.print(", ");
        }
        if (param == null) {
          writer.print("/*ERROR*/");
        } else {
          param.toCode(writer);
        }
      }
    }
    writer.print(")");
  }
}
