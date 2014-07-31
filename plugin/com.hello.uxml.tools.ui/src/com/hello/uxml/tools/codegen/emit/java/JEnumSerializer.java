package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes an enum property.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class JEnumSerializer implements CodeSerializer {

  private Class<?> enumClass;

  /**
   * Constructor.
   */
  public JEnumSerializer(Class<?> enumClass) {
    this.enumClass = enumClass;
  }

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    return !value.startsWith("{");
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {

    String fieldName = value.substring(0, 1).toUpperCase() + value.substring(1);
    compiler.getPackageBuilder().addImport(TypeToken.fromFullName(enumClass.getName()));
    try {
      enumClass.getField(fieldName);
    } catch (NoSuchFieldException e) {
      try {
       enumClass.getField(value);
      } catch (NoSuchFieldException e2) {
        compiler.getErrors().add(new CompilerError(String.format(
            "Invalid enum value %s", value)));
        return null;
      }
    }

    return new Reference(enumClass.getSimpleName() + "." + fieldName);
  }
}
