package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.Severity;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.IntegralLiteralExpression;

/**
 * Serializes an Integer property.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class IntegerSerializer implements CodeSerializer {

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
      int val;
      if (value.startsWith("0x") || value.startsWith("0X")) {
        val = Integer.parseInt(value.substring(2), 16);
      } else {
        val = Integer.parseInt(value);
      }
      return new IntegralLiteralExpression(val);
    } catch (NumberFormatException e) {
      try {
        double dblVal = Double.parseDouble(value);
        int iVal = (int) dblVal;
        if (iVal == dblVal) {
          return new IntegralLiteralExpression(iVal);
        } else {
          CompilerError error = new CompilerError(String.format(
            "Invalid integer number %s", value));
          error.setSeverity(Severity.WARNING);
          compiler.getErrors().add(error);
          return new IntegralLiteralExpression(iVal);
        }
      } catch (NumberFormatException e2) {
        compiler.getErrors().add(new CompilerError(String.format(
          "Invalid integer number %s", value)));
      }
    }
    return null;
  }
}
