package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a for in loop Statement.
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class ForInStatement extends Statement {
  /** The init ie. for ( <init> in someArray ) ... **/
  private final Statement init;

  /** The condition ie. for ( var i in <container> ) ... **/
  private final Expression container;

  /** The then CodeBlock ie. for ( var i in someArray ) { <code block> **/
  private final CodeBlock codeBlock;

  /**
   * Constructs a for in loop with init, container, and codeblock.
   *
   * @param init The init Statement: ie. for (<init> in container) {}
   * @param container The container expression: ie. for (var i in <container>) {}
   * @param codeBlock The codeBlock of the loop: ie. for (var i in container) <codeBlock>
   */
  public ForInStatement(Statement init, Expression container, CodeBlock codeBlock) {
    this.init = init;
    this.container = container;
    this.codeBlock = codeBlock;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("for ");
    writer.print("(");
    init.toCode(writer, true);
    writer.print(" in ");
    container.toCode(writer);
    writer.print(") ");
    codeBlock.toCode(writer);
  }
}
