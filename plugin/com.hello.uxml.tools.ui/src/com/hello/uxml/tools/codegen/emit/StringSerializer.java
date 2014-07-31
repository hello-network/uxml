package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes a String property.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class StringSerializer implements CodeSerializer {

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    if (value.startsWith("{")) {
      // We can't serialize non const bindings.
      ResourceInfo resInfo = compiler.getResourceInfo(value);
      if (resInfo == null || resInfo.isConst == false) {
        return false;
      }
    }
    if (value.startsWith("%")) {
      return false;
    }
    return true;
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {
    if (value.startsWith("{")) {
      Expression constStrExpression = compiler.getBindingExpression(value);
      return constStrExpression;
    }
    return compiler.getPackageBuilder().createStringLiteralExpression(value);
  }
}
