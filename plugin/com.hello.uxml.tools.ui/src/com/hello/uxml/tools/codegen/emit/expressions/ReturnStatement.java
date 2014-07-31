package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Creates code method return statement.
 *
 * @author ferhat
 */
public class ReturnStatement extends Statement {

  /**
   * Return expression or null if return for void method.
   */
  private Expression returnExpression;

  /**
   * Constructor.
   */
  public ReturnStatement(Expression expression) {
    returnExpression = expression;
  }

  /**
   * Constructor.
   */
  public ReturnStatement() {
    returnExpression = null;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    if (returnExpression == null) {
      writer.print("return;");
    } else {
      writer.print("return ");
      returnExpression.toCode(writer);
      if (!omitSemicolon) {
        writer.print(";");
      }
    }
  }
}
