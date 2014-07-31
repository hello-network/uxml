package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes ScaleMode.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3ScaleModeSerializer implements CodeSerializer {

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
        "com.hello.uxml.tools.framework.Shape"));
    if (value.equals("none")) {
      return new Reference("Shape.SCALEMODE_NONE");
    } else if (value.equals("fill")) {
      return new Reference("Shape.SCALEMODE_FILL");
    } else if (value.equals("uniform")) {
      return new Reference("Shape.SCALEMODE_UNIFORM");
    } else if (value.equals("zoom")) {
      return new Reference("Shape.SCALEMODE_ZOOM");
    } else if (value.equals("zoomout")) {
      return new Reference("Shape.SCALEMODE_ZOOM_OUT");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid ScaleMode value '%s'", value)));
      return null;
    }
  }
}
