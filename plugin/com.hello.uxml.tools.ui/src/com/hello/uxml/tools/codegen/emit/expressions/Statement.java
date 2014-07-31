package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Defines a statement in a codeblock.
 *
 * @author ferhat
 * @author ericarnold@ (Eric Arnold)
 */
public abstract class Statement {
  public void toCode(SourceWriter writer) {
    this.toCode(writer, false);
  }

  public abstract void toCode(SourceWriter writer, boolean omitSemicolon);
}
