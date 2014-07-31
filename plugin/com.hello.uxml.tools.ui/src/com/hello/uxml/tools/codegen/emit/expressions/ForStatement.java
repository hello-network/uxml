package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a classic for Statement (ie. for (var i; i < 10; i++) {})
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class ForStatement extends Statement {
  /** The init ie. for ( <init>; i < 1; i++ ) ... **/
  private Statement init;

  /** The condition ie. for ( var i = 0; <condition>; i++ ) ... **/
  private Condition condition;

  /** The iterator ie. for ( var i = 0; i < 1; <iterator> ) ... **/
  private Expression iterator;

  /** The then CodeBlock ie. for (;;) { <code block> } **/
  private CodeBlock codeBlock;

  /**
   * Constructs a for statement with init, condition, iterator, and codeblock.
   *
   * @param init The init Statement (ie. for (<init>; i < 10; i++) {})
   * @param condition The Condition (ie. for (var i; <condition>; i++) {})
   * @param iterator The iterator Expression (ie. for (var i; i < 10; <iterator>) {})
   * @param codeBlock The code block of the for loop (ie. for (var i; i < 10; i++) <codeBlock>)
   */
  public ForStatement(Statement init, Condition condition,
      Expression iterator, CodeBlock codeBlock) {
        this.init = init;
        this.condition = condition;
        this.iterator = iterator;
        this.codeBlock = codeBlock;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("for ");
    writer.print("(");
    init.toCode(writer, true);
    writer.print("; ");
    condition.toCode(writer);
    writer.print("; ");
    iterator.toCode(writer);
    writer.print(") ");
    codeBlock.toCode(writer);
  }
}
