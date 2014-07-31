package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.StaticMethodCall;

/**
 * Represents a method call expression.
 *
 * @author ferhat
 */
public class JStaticMethodCall extends StaticMethodCall {

  public JStaticMethodCall(TypeToken targetType, String methodName) {
    super(targetType, methodName, null);
  }

  public JStaticMethodCall(TypeToken targetType, String methodName, Expression[] parameters) {
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
