package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Provides base class for expressions.
 *
 * @author ferhat
 */
public abstract class Expression {

  protected TypeToken resultType = null;

  /**
   * Returns data type of expression if available or null if untyped.
   */
  public TypeToken getType() {
    return resultType;
  }

  /**
   * Converts the expression to code.
   */
  public abstract void toCode(SourceWriter writer);
}
