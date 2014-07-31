package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes HAlign.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3HAlignSerializer implements CodeSerializer {

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
        "com.hello.uxml.tools.framework.UIElement"));
    if (value.equals("fill")) {
      return new Reference("UIElement.HALIGN_FILL");
    } else if (value.equals("left")) {
      return new Reference("UIElement.HALIGN_LEFT");
    } else if (value.equals("center")) {
      return new Reference("UIElement.HALIGN_CENTER");
    } else if (value.equals("right")) {
      return new Reference("UIElement.HALIGN_RIGHT");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid HAlign value '%s'", value)));
      return null;
    }
  }
}
