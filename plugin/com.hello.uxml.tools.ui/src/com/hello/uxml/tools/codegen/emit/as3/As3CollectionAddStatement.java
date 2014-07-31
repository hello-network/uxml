package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

/**
 * Creates code for adding item to an array.
 *
 * @author ferhat
 */
public class As3CollectionAddStatement extends Statement {
  private Expression collection;
  private Expression value;

  /**
   * Constructor.
   */
  public As3CollectionAddStatement(Expression collection, Expression value) {
    this.collection = collection;
    this.value = value;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    collection.toCode(writer);
    writer.print(".push(");
    value.toCode(writer);
    writer.print(")");
    if (!omitSemicolon) {
      writer.print(";");
    }
  }
}
