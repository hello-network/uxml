package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a statement that consists of evaluating an expression and ignoring
 * the return value.
 *
 * @author ferhat
 */
public class ExpressionStatement extends Statement {

  private Expression expr;

  /**
   * Constructor.
   */
  public ExpressionStatement(Expression expression) {
    expr = expression;
  }

  /**
   * Returns expression.
   */
  public Expression getExpression() {
    return expr;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    expr.toCode(writer);

    // Selectively add semicolons depending upon the expression type
    if (!(expr instanceof FunctionBuilder)) {
      if (!omitSemicolon) {
        writer.print(";");
      }
    }
  }
}

