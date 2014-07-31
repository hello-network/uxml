package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * A do {} while(); statement.
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class DoWhileStatement extends Statement {
  private final CodeBlock codeBlock;
  private final Condition condition;

  public DoWhileStatement(CodeBlock codeBlock, Condition condition) {
    this.codeBlock = codeBlock;
    this.condition = condition;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("do ");
    codeBlock.toCode(writer);
    writer.print(" while (");
    condition.toCode(writer);
    writer.print(")");
    if (!omitSemicolon) {
      writer.print(";");
    }
  }

}
