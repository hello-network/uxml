package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * Provides reference to self for code generation.
 *
 * @author ferhat
 */
public class SelfReferenceExpression extends Reference {
  @Override public void toCode(SourceWriter writer) {
    writer.print("this");
  }
}
