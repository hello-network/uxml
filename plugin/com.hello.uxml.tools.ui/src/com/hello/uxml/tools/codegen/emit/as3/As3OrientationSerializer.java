package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes Orientation.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3OrientationSerializer implements CodeSerializer {

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
    if (value.equals("horizontal")) {
      return new Reference("UIElement.HORIZONTAL");
    } else if (value.equals("vertical")) {
      return new Reference("UIElement.VERTICAL");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid Orientation value '%s'", value)));
      return null;
    }
  }
}
