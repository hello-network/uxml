package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.SetFieldExpression;

/**
 * Creates code for java get field expression.
 *
 * @author ferhat
 */
public class JGetFieldExpression extends SetFieldExpression {
  private Expression source;
  private String fieldName;

  /**
   * Constructor.
   */
  public JGetFieldExpression(Expression source, String fieldName) {
    this.source = source;
    this.fieldName = fieldName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    source.toCode(writer);
    writer.print(".");
    String javaFieldName = fieldName.substring(0, 1).toLowerCase()
      + fieldName.substring(1, fieldName.length());
    writer.print(javaFieldName);
  }
}
