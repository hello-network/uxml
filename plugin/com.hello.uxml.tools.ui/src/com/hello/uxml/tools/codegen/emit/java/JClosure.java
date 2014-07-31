package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;

/**
 * Implements java backend for closures used for event handlers.
 *
 * @author ferhat
 */
public class JClosure extends JMethodBuilder {
  public JClosure(String name, TypeToken returnType, JPackageBuilder packageBuilder,
      JClassBuilder classBuilder) {
    super(name, returnType, packageBuilder, classBuilder);
  }

  @Override
  public void write(SourceWriter writer) {
    writer.println("new EventHandler() {");
    writer.indent();
    writer.indent();
    writer.indent();
    writer.println("@Override");
    writer.println("public void handleEvent(EventNotifier targetElement, EventArgs e) {");
    writer.indent();
    CodeBlock codeBlock = this.function.codeBlock;
    codeBlock.toCode(writer);
    writer.outdent();
    writer.println("}");
    writer.outdent();
    writer.println("}");
    writer.outdent();
    writer.outdent();
  }
}
