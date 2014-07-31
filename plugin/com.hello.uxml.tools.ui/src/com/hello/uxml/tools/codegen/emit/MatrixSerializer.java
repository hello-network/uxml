package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.framework.Matrix;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes a Point object.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class MatrixSerializer implements CodeSerializer {

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
    String[] parts = value.split(",");
    if (parts.length != 6) {
      compiler.getErrors().add(new CompilerError("Invalid matrix value. Expecting 6 parameters."));
      return null;
    }
    int paramCount = parts.length;
    Expression[] params = new Expression[paramCount];
    try {
    for (int p = 0; p < paramCount; ++p) {
      double val = Double.parseDouble(parts[p]);
      params[p] = new DoubleLiteralExpression(val);
    }
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken matrixType = TypeToken.fromClass(Matrix.class);
    packageBuilder.addImport(matrixType);
    return packageBuilder.createNewObjectExpression(matrixType, params);
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError("Invalid matrix value.", e));
      return null;
    }
  }
}
