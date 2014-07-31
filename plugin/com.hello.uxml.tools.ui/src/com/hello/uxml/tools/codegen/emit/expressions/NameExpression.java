package com.hello.uxml.tools.codegen.emit.expressions;

import com.hello.uxml.tools.codegen.emit.SourceWriter;

/**
 * A name expression for property expressions (ie. name:value)
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public class NameExpression extends Expression {

  private final String nameString;

  public NameExpression(String nameString) {
    this.nameString = nameString;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print(this.nameString);
  }
}
