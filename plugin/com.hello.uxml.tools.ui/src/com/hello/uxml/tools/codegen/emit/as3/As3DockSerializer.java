package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes DockBox style.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3DockSerializer implements CodeSerializer {

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
        "com.hello.uxml.tools.framework.DockBox"));
    if (value.equals("left")) {
      return new Reference("DockBox.DOCK_LEFT");
    } else if (value.equals("top")) {
      return new Reference("DockBox.DOCK_TOP");
    } else if (value.equals("right")) {
      return new Reference("DockBox.DOCK_RIGHT");
    } else if (value.equals("bottom")) {
      return new Reference("DockBox.DOCK_BOTTOM");
    } else if (value.equals("none")) {
      return new Reference("DockBox.DOCK_NONE");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid Dock value '%s'", value)));
      return null;
    }
  }
}
