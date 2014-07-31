package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * A reference specific to AS3 output
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class As3Reference extends Reference {
  public As3Reference(String name) {
    super(name);
  }

  public As3Reference(String name, TypeToken type) {
    super(name, type);
  }

  public As3Reference(String name, TypeToken type, Boolean includeType) {
    super(name, type, includeType);
  }

  @Override
  public void toCode(SourceWriter writer) {
    if (this.includeType) {
      writer.print(varName);
      writer.print(":");
      writer.print(this.resultType.toString());
    } else {
      super.toCode(writer);
    }
  }
}
