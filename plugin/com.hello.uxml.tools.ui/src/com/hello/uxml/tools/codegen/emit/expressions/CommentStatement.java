package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Writes code for a comment.
 *
 * @author ferhat
 */
public class CommentStatement extends Statement {
  private String comment;

  /**
   * Constructor.
   */
  public CommentStatement(String comment) {
    this.comment = comment;
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.print("// " + comment);
  }
}
