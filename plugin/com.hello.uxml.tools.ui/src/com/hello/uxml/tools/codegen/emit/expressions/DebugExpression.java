package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * A debug expression for tracking unhandled expressions (for debugging only).
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class DebugExpression extends Expression {
  public String debugMessage = "";

  public DebugExpression(String debugMessage) {
    this.debugMessage = debugMessage;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("<<" + debugMessage + ">>");
  }
}
