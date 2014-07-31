package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.SolidBrush;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.CodeModelSerializer;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes Color.
 *
 * @author ferhat
 */
public class As3SolidBrushSerializer implements CodeModelSerializer {

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    // we can only serialize binding expressions if they evaluate to resource
    // references.
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
    PackageBuilder packageBuilder = compiler.getPackageBuilder();

    // if binding expression is a Color object use it to create SolidBrush
    if (value.startsWith("{")) {
      Expression brushExpression = compiler.getBindingExpression(value);
      return brushExpression;
    }

    // We have a constant "#FF0000" type color value, create SolidBrush directly
    CodeSerializer serializer = packageBuilder.getSerializer(TypeToken.fromClass(Color.class));
    Expression colorExpression = serializer.createExpression(value, compiler, codeBlock);
    TypeToken brushType = TypeToken.fromClass(SolidBrush.class);
    packageBuilder.addImport(brushType);
    return packageBuilder.createNewObjectExpression(brushType, new Expression[] {colorExpression});
  }

  /**
   * Create value expression for color model item.
   */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
    if (!node.hasProperty("color")) {
      compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
          "Expecting color attribute"));
      return null;
    }

    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    packageBuilder.addImport(TypeToken.fromClass(Color.class));
    String colorValue = node.getStringProperty("color");
    if (colorValue.startsWith("{")) {
      Expression colorExpr = compiler.getBindingExpression(colorValue);
      if (colorExpr == null) {
        compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
            "Unknown color resource."));
        return null;
      }
      TypeToken colorType = TypeToken.fromClass(Color.class);
      packageBuilder.addImport(colorType);
      if (!colorType.equals(colorExpr.getType())) {
        if (!packageBuilder.normalizeType(colorType).equals(packageBuilder.normalizeType(
            colorExpr.getType()))) {
          colorExpr = packageBuilder.createTypeCast(colorType, colorExpr);
        }
      }
      TypeToken solidBrushType = TypeToken.fromClass(SolidBrush.class);
      packageBuilder.addImport(solidBrushType);
      return packageBuilder.createNewObjectExpression(solidBrushType,
          new Expression[] {colorExpr});
    }
    return createExpression(colorValue , compiler, codeBlock);
  }
}
