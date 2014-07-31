package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

/**
 * Creates code for adding item to a list.
 *
 * @author ferhat
 */
public class JCollectionAddStatement extends Statement {
  private Expression collection;
  private Expression value;

  /**
   * Constructor.
   */
  public JCollectionAddStatement(Expression collection, Expression value) {
    this.collection = collection;
    this.value = value;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    collection.toCode(writer);
    writer.print(".add(");
    value.toCode(writer);
    writer.print(")");
    if (!omitSemicolon) {
      writer.print(";");
    }
  }
}
