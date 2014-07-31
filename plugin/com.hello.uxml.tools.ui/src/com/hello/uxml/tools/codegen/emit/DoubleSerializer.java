package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes a Double property.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class DoubleSerializer implements CodeSerializer {

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
    try {
      double val = Double.parseDouble(value);
      return new DoubleLiteralExpression(val);
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid floating point number %s", value)));
      return null;
    }
  }
}
