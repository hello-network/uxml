package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Represents a static method call.
 *
 * @author ferhat
 */
public abstract class StaticMethodCall extends Expression {
  protected TypeToken targetType;
  protected String methodName;
  protected Expression[] parameters;

  /**
   * Constructor.
   */
  public StaticMethodCall(TypeToken targetType, String methodName) {
    this(targetType, methodName, null);
  }

  /**
   * Constructor.
   */
  public StaticMethodCall(TypeToken targetType, String methodName,
      Expression[] parameters) {
    this.targetType = targetType;
    this.methodName = methodName;
    this.parameters = parameters;
    if (parameters != null) {
      for (int p = 0; p < parameters.length; p++) {
        if (parameters[p] == null) {
          throw new RuntimeException("Method " + methodName +
              " is missing parameters");
        }
      }
    }
  }

  /**
   * Returns target type of method call.
   */
  public TypeToken getTargetType() {
    return targetType;
  }

  /**
   * Returns parameters to method call.
   */
  public Expression[] getParameters() {
    return parameters;
  }

  /**
   * Returns method name.
   */
  public String getMethodName() {
    return methodName;
  }

}
