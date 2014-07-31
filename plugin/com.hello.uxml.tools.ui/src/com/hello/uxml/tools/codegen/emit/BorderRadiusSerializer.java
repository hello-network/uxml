package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes a BorderRadius object.
 *
 * @author ferhat
 */
public class BorderRadiusSerializer implements CodeModelSerializer {

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    if (value.startsWith("{")) {
      ResourceInfo info = compiler.getResourceInfo(value);
      if (info == null) {
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
      Expression radiusExpression = compiler.getBindingExpression(value);
      return radiusExpression;
    }

    String[] parts = value.split(",");
    if (parts.length > 4) {
      compiler.getErrors().add(new CompilerError("Invalid border radius syntax"));
      return null;
    }
    try {
      double topRight = 0;
      double bottomRight = 0;
      double bottomLeft = 0;
      double topLeft = Double.parseDouble(parts[0]);
      if (parts.length > 1) {
        topRight = Double.parseDouble(parts[1]);
      }
      if (parts.length > 2) {
        bottomRight = Double.parseDouble(parts[2]);
      }
      if (parts.length > 3) {
        bottomLeft = Double.parseDouble(parts[3]);
      }

      PackageBuilder packageBuilder = compiler.getPackageBuilder();
      TypeToken borderRadiusType = TypeToken.fromClass(BorderRadius.class);
      packageBuilder.addImport(borderRadiusType);
      if ((parts.length == 1) || (topLeft == topRight && bottomLeft == bottomRight &&
          topLeft == bottomLeft)) {
        return createUniformBorderExpression(compiler, topLeft);
      } else {
        Expression[] params = new Expression[] {new DoubleLiteralExpression(topLeft),
            new DoubleLiteralExpression(topRight), new DoubleLiteralExpression(bottomRight),
            new DoubleLiteralExpression(bottomLeft)};
        return packageBuilder.createNewObjectExpression(
            borderRadiusType, params);
      }
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError("Invalid border radius value", e));
      return null;
    }
  }

  /**
   * Create value expression for border radius model item.
   */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
    TypeToken borderRadiusType = TypeToken.fromClass(BorderRadius.class);
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    packageBuilder.addImport(borderRadiusType);
    double topLeft = 0, topRight = 0, bottomRight = 0, bottomLeft = 0;
    if (node.hasProperty("topLeft")) {
      topLeft = Double.parseDouble(node.getStringProperty("topLeft"));
    }
    if (node.hasProperty("topRight")) {
      topRight = Double.parseDouble(node.getStringProperty("topRight"));
    }
    if (node.hasProperty("bottomRight")) {
      bottomRight = Double.parseDouble(node.getStringProperty("bottomRight"));
    }
    if (node.hasProperty("bottomLeft")) {
      bottomLeft = Double.parseDouble(node.getStringProperty("bottomLeft"));
    }
    if ((topLeft == topRight && bottomLeft == bottomRight &&
        topLeft == bottomLeft)) {
      return createUniformBorderExpression(compiler, topLeft);
    } else {
      Expression[] params = new Expression[] {new DoubleLiteralExpression(topLeft),
          new DoubleLiteralExpression(topRight), new DoubleLiteralExpression(bottomRight),
          new DoubleLiteralExpression(bottomLeft)};
      return packageBuilder.createNewObjectExpression(
          borderRadiusType, params);
    }
  }

  protected Expression createUniformBorderExpression(ModelCompiler compiler, double size) {
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken borderRadiusType = TypeToken.fromClass(BorderRadius.class);
    return packageBuilder.createStaticMethodCall(borderRadiusType, "create",
        new Expression[] {new DoubleLiteralExpression(size)});
  }
}
