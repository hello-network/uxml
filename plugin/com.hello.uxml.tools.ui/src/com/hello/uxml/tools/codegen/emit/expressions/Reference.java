package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Represents an object reference expression.
 *
 * @author ferhat
 */
public class Reference extends Expression {
  protected String varName;
  public Boolean includeType;

  protected Reference() {
  }

  public Reference(String varName) {
    this(varName, null, false);
  }

  public Reference(String varName, TypeToken type) {
    this(varName, type, false);
  }

  public Reference(String varName, TypeToken type, Boolean includeType) {
    this.varName = varName;
    this.resultType = type;
    this.includeType = includeType;
  }

  /**
   * @return name of reference.
   */
  public String getName() {
    return varName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(varName);
  }
}
