package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.framework.Margin;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.IntegralLiteralExpression;

/**
 * Serializes a Margin object.
 *
 * @author ferhat
 */
public class MarginSerializer implements CodeModelSerializer {

  private boolean serializeToInt;

  public MarginSerializer() {
    this.serializeToInt = false;
  }

  public MarginSerializer(boolean serializeToInt) {
    this.serializeToInt = serializeToInt;
  }

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
      Expression marginExpression = compiler.getBindingExpression(value);
      return marginExpression;
    }
    String[] parts = value.split(",");
    if (parts.length > 4) {
      compiler.getErrors().add(new CompilerError("Invalid margin syntax"));
      return null;
    }
    try {
      double top = 0;
      double right = 0;
      double bottom = 0;
      double left = Double.parseDouble(parts[0]);
      if (parts.length > 1) {
        top = Double.parseDouble(parts[1]);
      }
      if (parts.length > 2) {
        right = Double.parseDouble(parts[2]);
      }
      if (parts.length > 3) {
        bottom = Double.parseDouble(parts[3]);
      }
      TypeToken marginType = TypeToken.fromClass(Margin.class);
      Expression[] params;
      if (serializeToInt) {
        params = new Expression[] {new IntegralLiteralExpression((int) left),
            new IntegralLiteralExpression((int) top), new IntegralLiteralExpression((int) right),
            new IntegralLiteralExpression((int) bottom)};
      } else {
        params = new Expression[] {new DoubleLiteralExpression(left),
            new DoubleLiteralExpression(top), new DoubleLiteralExpression(right),
            new DoubleLiteralExpression(bottom)};
      }
      PackageBuilder packageBuilder = compiler.getPackageBuilder();
      packageBuilder.addImport(marginType);
      return packageBuilder.createNewObjectExpression(marginType, params);
    } catch (NumberFormatException e) {
      compiler.getErrors().add(new CompilerError("Invalid margin value", e));
      return null;
    }
  }

  /**
   * Create value expression for margin model item.
   */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
    TypeToken marginType = TypeToken.fromClass(Margin.class);
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    packageBuilder.addImport(marginType);
    double left = 0, top = 0, right = 0, bottom = 0;
    if (node.hasProperty("left")) {
      left = Double.parseDouble(node.getStringProperty("left"));
    }
    if (node.hasProperty("top")) {
      top = Double.parseDouble(node.getStringProperty("top"));
    }
    if (node.hasProperty("right")) {
      right = Double.parseDouble(node.getStringProperty("right"));
    }
    if (node.hasProperty("bottom")) {
      bottom = Double.parseDouble(node.getStringProperty("bottom"));
    }
    Expression[] params;
    if (right == 0.0 && bottom == 0.0) {
      if (serializeToInt) {
        params = new Expression[] {new IntegralLiteralExpression((int) left),
            new IntegralLiteralExpression((int) top)};
      } else {
        params = new Expression[] {new DoubleLiteralExpression(left),
            new DoubleLiteralExpression(top)};
      }
    } else {
      if (serializeToInt) {
        params = new Expression[] {new IntegralLiteralExpression((int) left),
            new IntegralLiteralExpression((int) top), new IntegralLiteralExpression((int) right),
            new IntegralLiteralExpression((int) bottom)};
      } else {
        params = new Expression[] {new DoubleLiteralExpression(left),
            new DoubleLiteralExpression(top), new DoubleLiteralExpression(right),
            new DoubleLiteralExpression(bottom)};
      }
    }
    return compiler.getPackageBuilder().createNewObjectExpression(marginType, params);
  }
}
