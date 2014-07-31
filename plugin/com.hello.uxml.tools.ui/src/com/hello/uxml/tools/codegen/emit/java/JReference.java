package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * A reference specific to Java output
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class JReference extends Reference {
  public JReference(String name) {
    super(name);
  }

  public JReference(String name, TypeToken type) {
    super(name, type);
  }

  public JReference(String name, TypeToken type, Boolean includeType) {
    super(name, type, includeType);
  }

  @Override
  public void toCode(SourceWriter writer) {
    if (this.includeType) {
      writer.print(this.resultType.toString());
      writer.print(" ");
      writer.print(varName);
    } else {
      super.toCode(writer);
    }
  }
}
