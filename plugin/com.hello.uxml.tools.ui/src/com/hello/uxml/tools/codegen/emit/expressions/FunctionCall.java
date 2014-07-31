package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.ParameterList;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Base FunctionCall class for any kind of function call.
 *
 * @author ericarnold
 */
public class FunctionCall extends Expression {
  protected Expression target;
  protected ParameterList parameterList;

  /**
   * Constructor.
   */
  public FunctionCall(Expression target) {
    this(target, null);
  }

  /**
   * Constructor.
   */
  public FunctionCall(Expression target, Expression[] parameters) {
    this.target = target;
    this.parameterList = new ParameterList(parameters);
  }

  /**
   * Returns parameters to method call.
   */
  public ParameterList getParameters() {
    return parameterList;
  }

  /**
   * Returns target of method call.
   */
  public Expression getTarget() {
    return target;
  }

  @Override
  public void toCode(SourceWriter writer) {
    target.toCode(writer);
    writer.print("(");
    parameterList.toCode(writer);
    writer.print(")");
  }
}
