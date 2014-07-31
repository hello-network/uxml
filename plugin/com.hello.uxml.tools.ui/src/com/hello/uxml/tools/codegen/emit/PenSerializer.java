package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NullLiteralExpression;

/**
 * Serializes a Pen object.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class PenSerializer implements CodeSerializer {

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
    if (value.length() != 0) {
      compiler.getErrors().add(new CompilerError("Invalid pen value"));
      return null;
    }
    return new NullLiteralExpression();
  }
}
