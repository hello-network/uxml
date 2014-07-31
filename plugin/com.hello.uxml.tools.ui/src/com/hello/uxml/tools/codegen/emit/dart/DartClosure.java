package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;

/**
 * Implements java backend for closures used for event handlers.
 *
 * @author ferhat
 */
public class DartClosure extends DartMethodBuilder {
  public DartClosure(String name, TypeToken returnType, DartPackageBuilder packageBuilder,
      DartClassBuilder classBuilder) {
    super(name, returnType, packageBuilder, classBuilder);
  }

  @Override
  public void write(SourceWriter writer) {
    writer.print("(EventArgs e) ");
    writer.indent();
    writer.indent();
    writer.indent();
    CodeBlock codeBlock = this.function.codeBlock;
    codeBlock.toCode(writer);
    writer.outdent();
    writer.print("");
    writer.outdent();
    writer.outdent();
  }
}
