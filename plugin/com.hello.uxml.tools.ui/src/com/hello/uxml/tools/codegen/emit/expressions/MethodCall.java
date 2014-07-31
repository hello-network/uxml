package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Represents a method call expression.
 *
 * @author ferhat
 */
public class MethodCall extends FunctionCall {
  protected String methodName;

  /**
   * Constructor.
   */
  public MethodCall(Expression target, String methodName) {
    this(target, methodName, null);
  }

  /**
   * Constructor.
   */
  public MethodCall(Expression target, String methodName, Expression[] parameters) {
    super(target, parameters);
    this.methodName = methodName;
  }

  /**
   * Returns method name.
   */
  public String getMethodName() {
    return methodName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    // use foo() instead of this.foo()
    if (!SourceWriter.toString(target).equals("this")) {
      target.toCode(writer);
      writer.print(".");
    }
    writer.print(methodName);
    writer.print("(");
    parameterList.toCode(writer);
    writer.print(")");
  }
}
