package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
* Defines a local variable declaration statement.
*
* @author ericarnold@ (Eric Arnold)
*/
public class DartVariableDefinitionStatement extends
    VariableDefinitionStatement {
  private Reference variableReference;
  private Expression initExpression;

  /**
  * Constructor.
  */
  public DartVariableDefinitionStatement(Reference variableReference) {
    this.variableReference = variableReference;
  }

  /**
  * Constructor with initializer.
  */
  public DartVariableDefinitionStatement(Reference variableReference,
     Expression initializer) {
    this.variableReference = variableReference;
    this.initExpression = initializer;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    String name = variableReference.getName();
    TypeToken type = variableReference.getType();

    String typeToken = DartFrameworkTypes.tokenTypeToString(type);

    // Write var statement if typeToken is empty
    if (typeToken == "" || typeToken == null) {
      writer.print("var");
    } else {
      writer.print(typeToken);
    }
    writer.print(" ");
    writer.print(name);
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
