package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * An equality (==, ===, !=, !==) expression
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class EqualityExpression extends Expression {
  private final Expression leftExpression;
  private final Expression rightExpression;
  private final boolean strict;
  private final boolean inverse;

  /**
   * Create an equality expression with a left (base) expression and a right (may be another nested
   * equality) expression with or without strictness and with or without inverse (not equals)
   *
   * @param leftExpression The base expression
   * @param rightExpression The (perhaps another nested equality) expression to the right of
   *                        the operand
   * @param inverse If true, will ensure not-equal
   * @param strict If true, will do a strict (exact .. ===) comparison
   */
  public EqualityExpression(Expression leftExpression,
      Expression rightExpression,
      boolean strict,
      boolean inverse) {
    super();
    this.leftExpression = leftExpression;
    this.rightExpression = rightExpression;
    this.strict = strict;
    this.inverse = inverse;
  }

  @Override
  public void toCode(SourceWriter writer) {
    leftExpression.toCode(writer);
    writer.print(" ");
    if (this.strict) {
      if (this.inverse) {
        writer.print("!==");
      } else {
        writer.print("===");
      }
    } else {
      if (this.inverse) {
        writer.print("!=");
      } else {
        writer.print("==");
      }
    }
    writer.print(" ");
    rightExpression.toCode(writer);
  }
}
