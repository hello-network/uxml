package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes Label text alignment.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3TextAlignSerializer implements CodeSerializer {

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
    value = value.toLowerCase();
    compiler.getPackageBuilder().addImport(TypeToken.fromFullName(
        "com.hello.uxml.tools.framework.Label"));
    if (value.equals("left")) {
      return new Reference("Label.ALIGN_LEFT");
    } else if (value.equals("center")) {
      return new Reference("Label.ALIGN_CENTER");
    } else if (value.equals("right")) {
      return new Reference("Label.ALIGN_RIGHT");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid TextAlign value '%s'", value)));
      return null;
    }
  }
}
