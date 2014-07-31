package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Defines a local variable declaration statement.
 *
 * @author ferhat
 * @author ericarnold@ (Eric Arnold)
 */
public class As3VariableDefinitionStatement extends VariableDefinitionStatement {
  private Reference variableReference;
  private Expression initExpression;

  /**
   * Constructor.
   */
  public As3VariableDefinitionStatement(Reference variableReference) {
    this.variableReference = variableReference;
  }

  /**
   * Constructor with initializer.
   */
  public As3VariableDefinitionStatement(Reference variableReference,
      Expression initializer) {
    this.variableReference = variableReference;
    this.initExpression = initializer;
  }

  /**
   * Converts statement to code.
   */
  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    String name = variableReference.getName();
    TypeToken type = variableReference.getType();

    writer.print("var ");
    writer.print(name);
    writer.print(":");
    writer.print(As3FrameworkTypes.tokenTypeToString(type));

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
    return variableReference;
  }

  /**
   * Returns the initialization expression.
   */
  @Override
  public Expression getInitializationExpression() {
    return this.initExpression;
  }
}
