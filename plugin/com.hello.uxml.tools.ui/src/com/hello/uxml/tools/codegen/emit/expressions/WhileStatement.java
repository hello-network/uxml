package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a while statement (ie. while (1) { trace() })
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class WhileStatement extends Statement {
  private final CodeBlock codeBlock;
  private final Condition condition;

  /**
   * Constructs a while statement (ie. while (1) { trace() })
   *
   * @param codeBlock The CodeBlock for the while statement (ie. while (1) <codeBlock>)
   * @param condition The Condition for the while statement (ie. while (<condition>) { trace() })
   */
  public WhileStatement(CodeBlock codeBlock, Condition condition) {
    this.codeBlock = codeBlock;
    this.condition = condition;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("while (");
    condition.toCode(writer);
    writer.print(") ");
    codeBlock.toCode(writer);
  }
}
