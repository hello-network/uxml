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
public class As3LayoutTypeSerializer implements CodeSerializer {

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
        "com.hello.uxml.tools.framework.GridDef"));
    if (value.equals("auto")) {
      return new Reference("GridDef.LAYOUT_TYPE_AUTO");
    } else if (value.equals("fixed")) {
      return new Reference("GridDef.LAYOUT_TYPE_FIXED");
    } else if (value.equals("percent")) {
      return new Reference("GridDef.LAYOUT_TYPE_PERCENT");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid Layout type value '%s'", value)));
      return null;
    }
  }
}
