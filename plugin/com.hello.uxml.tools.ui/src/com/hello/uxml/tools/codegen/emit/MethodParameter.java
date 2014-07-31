package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Stores method parameter information.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class MethodParameter {
  private Reference parameterReference;
  private Expression initExpression;

  /**
   * Constructor.
   */
  public MethodParameter(Reference parameterReference) {
    this(parameterReference, null);
  }

  /**
   * Constructor.
   */
  public MethodParameter(Reference parameterReference, Expression initExpression) {
    this.parameterReference = parameterReference;
    this.initExpression = initExpression;
  }

  /**
   * Returns parameter name.
   */
  public String getName() {
    return parameterReference.getName();
  }

  /**
   * Returns parameter name.
   */
  public Expression getInitExpression() {
    return this.initExpression;
  }

  /**
   * Returns parameter data type.
   */
  public TypeToken getType() {
    return parameterReference.getType();
  }
}
