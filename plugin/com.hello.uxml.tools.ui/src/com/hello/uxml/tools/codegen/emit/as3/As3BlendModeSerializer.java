package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.framework.BlendMode;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes Blend mode.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3BlendModeSerializer implements CodeSerializer {

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
    compiler.getPackageBuilder().addImport(TypeToken.fromFullName(
        "flash.display.BlendMode"));
    try {
      String valueInUpperCase = value.toUpperCase();
      BlendMode mode = BlendMode.valueOf(valueInUpperCase);
      return new Reference("BlendMode." + mode.toString().toUpperCase());
    } catch (IllegalArgumentException e) {
      try {
        String fieldName = value.substring(0, 1).toUpperCase() + value.substring(1);
        BlendMode mode2 = BlendMode.valueOf(fieldName);
        return new Reference("BlendMode." + mode2.toString().toUpperCase());
      } catch (IllegalArgumentException e2) {
        compiler.getErrors().add(new CompilerError(String.format(
            "Invalid blendmode value '%s'", value)));
        return null;
      }
    }
  }
}
