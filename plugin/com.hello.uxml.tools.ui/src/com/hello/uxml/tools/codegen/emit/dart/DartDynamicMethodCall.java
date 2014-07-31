package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.MethodCall;

/**
 * Represents a dynamic reflection based method call.
 *
 * @author ferhat
 */
public class DartDynamicMethodCall extends MethodCall {

  // Used to add intermediate statements.
  private final Expression lhsExpr;

  public DartDynamicMethodCall(Expression target, String methodName, Expression[] parameters,
      MethodBuilder method) {
    super(target, methodName, parameters);
    lhsExpr = target;
  }

  @Override
  public void toCode(SourceWriter writer) {
    lhsExpr.toCode(writer);
    writer.print("." + methodName + "(");
    parameterList.toCode(writer);
    writer.print(")");
  }
}
