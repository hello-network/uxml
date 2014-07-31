package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.StaticMethodCall;

/**
 * Represents a method call expression.
 *
 * @author ferhat
 */
public class As3StaticMethodCall extends StaticMethodCall {

  public As3StaticMethodCall(TypeToken targetType, String methodName) {
    super(targetType, methodName, null);
  }

  public As3StaticMethodCall(TypeToken targetType, String methodName, Expression[] parameters) {
    super(targetType, methodName, parameters);
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(targetType.getName());
    writer.print(".");
    writer.print(methodName);
    writer.print("(");
    int paramCount = (parameters == null) ? 0 : parameters.length;
    for (int i = 0; i < paramCount; ++i) {
      if (i != 0) {
        writer.print(", ");
      }
      parameters[i].toCode(writer);
    }
    writer.print(")");
  }
}
