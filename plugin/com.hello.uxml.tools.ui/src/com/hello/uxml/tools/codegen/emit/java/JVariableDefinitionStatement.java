package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Defines a local variable declaration statement.
 *
 * @author ferhat
 */
public class JVariableDefinitionStatement extends VariableDefinitionStatement {
  private Reference variableReference;
  private Expression initExpression;

  /**
   * Constructor.
   */
  public JVariableDefinitionStatement(Reference variableReference) {
    this.variableReference = variableReference;
  }

  /**
   * Constructor with initializer.
   */
  public JVariableDefinitionStatement(Reference reference,
      Expression initializer) {
    this.variableReference = reference;
    this.initExpression = initializer;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print(JFrameworkTypes.tokenTypeToString(variableReference.getType()));
    writer.print(" ");
    writer.print(variableReference.getName());
    // Write initializer
    if (initExpression != null) {
      writer.print(" = ");
      initExpression.toCode(writer);
    }
    if (!omitSemicolon) {
      writer.print(";");
    }
  }

  /**
   * Returns a reference to the variable.
   */
  @Override
  public Reference getReference() {
    return this.variableReference;
  }

  /**
   * Returns the initialization expression.
   */
  @Override
  public Expression getInitializationExpression() {
    return this.initExpression;
  }
}
