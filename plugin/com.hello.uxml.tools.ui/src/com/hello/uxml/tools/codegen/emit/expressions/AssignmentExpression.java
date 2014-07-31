package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a class for an assignment Statement (var left = right).
 *
 * @author ferhat
 *         ericarnold@google.com (Eric Arnold)
 */
public class AssignmentExpression extends Expression {

  /** Left hand side of assignment */
  private Expression leftExpression;

  /** Right hand side of assignment */
  private Expression rightExpression;

  /** The assignment type (+=, =, etc) */
  private AssignmentExpressionType type;

  /**
   * Constructs a class for an assignment Statement (var left = right).
   *
   * @param leftExpression The left hand stat
   * @param rightExpression
   * @param type The assignment type (+=, =, etc)
   */
  public AssignmentExpression(Expression leftExpression, Expression rightExpression,
      AssignmentExpressionType type) {
    this.leftExpression = leftExpression;
    this.rightExpression = rightExpression;
    this.type = type;
  }

  @Override
  public void toCode(SourceWriter writer) {
    leftExpression.toCode(writer);
    writer.print(" " + type.toString() + "= ");
    rightExpression.toCode(writer);
  }

  /**
   * The type of assignment an AssignmentExpression is.
   *
   * @author ericarnold@ (Eric Arnold)
   */
  public enum AssignmentExpressionType {
    REGULAR(""),
    ADDITION("+"),
    MULTIPLICATION("*"),
    SUBTRACTION("-"),
    DIVIDE("/"),
    LOGICAL_OR("||"),
    LOGICAL_AND("&&"),
    BITWISE_OR("|"),
    MODULO("&"),
    BITWISE_AND("&"),
    BITWISE_XOR("^"),
    SHIFT_LEFT("<<"),
    SHIFT_RIGHT(">>"),
    SHIFT_RIGHT_UNSIGNED(">>>");

    private final String type;

    AssignmentExpressionType(String type){
        this.type = type;
    }

    @Override
    public String toString() {
        return type;
    }
  }
}
