package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * A reference specific to Dart output
 *
 * @author ericarnold@ (Eric Arnold)
 */
public class DartReference extends Reference {

  public DartReference(String name) {
    super(name);
  }

  public DartReference(String name, TypeToken type) {
    super(name, type);
  }

  public DartReference(String name, TypeToken type, Boolean includeType) {
    super(name, type, includeType);
  }

  @Override
  public void toCode(SourceWriter writer) {
    if (this.includeType) {
      writer.print(this.resultType.toString());
      writer.print(" ");
      writer.print(varName);
    } else {
      writer.print(varName);
    }
  }

  /**
   * Returns data type of expression if available or null if untyped.
   */
  @Override
  public TypeToken getType() {
    return resultType;
  }
}
