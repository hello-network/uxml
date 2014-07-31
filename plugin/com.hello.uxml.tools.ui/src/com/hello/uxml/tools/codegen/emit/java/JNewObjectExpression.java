package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NewObjectExpression;

/**
 * Writes java code for object instantiation.
 *
 * @author ferhat
 */
public class JNewObjectExpression extends NewObjectExpression {
  private TypeToken type;
  private Expression[] parameters;

  public JNewObjectExpression(TypeToken type) {
    this.type = type;
  }

  public JNewObjectExpression(TypeToken type, Expression[] parameters) {
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
          writer.print ("/*ERROR*/");
        } else {
          param.toCode(writer);
        }
      }
    }
    writer.print(")");
  }
}
