package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes a Point object.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3PointSerializer implements CodeSerializer {

  private static final String ERROR_MSG_INVALID_NUMBER_OF_PARAMS =
      "Invalid number of point parameters";
  private static final String ERROR_MSG_INVALID_PARAM_FORMAT =
      "Invalid point parameter format";

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
    if (parts.length != 2) {
      compiler.getErrors().add(new CompilerError(ERROR_MSG_INVALID_NUMBER_OF_PARAMS));
      return null;
    }
    double x;
    double y;
    try {
      x = Double.parseDouble(parts[0]);
      y = Double.parseDouble(parts[1]);
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError(ERROR_MSG_INVALID_PARAM_FORMAT, e));
      return null;
    }
    Expression[] params = new Expression[] {new DoubleLiteralExpression(x),
          new DoubleLiteralExpression(y)};
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken pointType = TypeToken.fromClass(Point.class);
    packageBuilder.addImport(pointType);
    return packageBuilder.createNewObjectExpression(pointType, params);
  }
}
