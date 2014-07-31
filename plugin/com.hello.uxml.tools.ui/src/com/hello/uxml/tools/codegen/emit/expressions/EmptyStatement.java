package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a Statement with no contents
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class EmptyStatement extends Statement {

  /**
   * Constructor.
   */
  public EmptyStatement() {
  }

  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    if (!omitSemicolon) {
      writer.print(";");
    }
  }
}
