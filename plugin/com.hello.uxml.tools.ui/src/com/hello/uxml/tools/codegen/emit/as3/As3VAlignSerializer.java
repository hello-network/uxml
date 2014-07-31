package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes VAlign.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3VAlignSerializer implements CodeSerializer {

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
      return new Reference("UIElement.VALIGN_FILL");
    } else if (value.equals("top")) {
      return new Reference("UIElement.VALIGN_TOP");
    } else if (value.equals("center")) {
      return new Reference("UIElement.VALIGN_CENTER");
    } else if (value.equals("bottom")) {
      return new Reference("UIElement.VALIGN_BOTTOM");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid VAlign value '%s'", value)));
      return null;
    }
  }
}
