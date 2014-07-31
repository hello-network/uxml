package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Defines the parameters of a call-type construct (function call, instantiation, etc)
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class ParameterList {
  protected Expression[] parameters;

  /**
   * Constructs the parameters of a call-type construct (function call, instantiation, etc)
   *
   * @param parameters An array of the parameters to be added.
   *
   */
  public ParameterList(Expression[] parameters) {
    this.parameters = parameters;
    if (parameters != null) {
      for (int p = 0; p < parameters.length; p++) {
        if (parameters[p] == null) {
          throw new RuntimeException();
        }
      }
    }
  }

  /**
   * Gets a parameter by index.
   *
   * @param parameterIndex The index of the parameter to get.
   * @return The parameter (expression) at that index.
   */
  public Expression getParameter(int parameterIndex) {
    return parameters[parameterIndex];
  }

  /**
   * Returns the number of parameters in theis ParameterList.
   *
   * @return The number of parameters.
   */
  public int length() {
    return (parameters == null) ? 0 : parameters.length;
  }

  /**
   * Writes the parameterList out to a writer.
   *
   * @param writer The writer to write the code out to.
   */
  public void toCode(SourceWriter writer) {
    int paramCount = length();
    for (int i = 0; i < paramCount; ++i) {
      if (i != 0) {
        writer.print(", ");
      }
      parameters[i].toCode(writer);
    }
  }
}
