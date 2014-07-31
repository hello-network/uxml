package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.SolidPen;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ErrorCode;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.ModelCompiler.ResourceInfo;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.as3.As3ColorSerializer;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NullLiteralExpression;

/**
 * Serializes SolidPen model to expression.
 *
 * @author ferhat
 */
public class SolidPenSerializer implements CodeModelSerializer {
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

  /** Creates expression from model */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
   if (!node.hasProperty("color")) {
     compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
         "Expecting color attribute"));
     return new NullLiteralExpression();
   }

   double thickness = 1.0;
   if (!node.hasProperty("thickness")) {
     thickness = Double.parseDouble(node.getStringProperty("thickness"));
   }
   Expression thicknessExpr = new DoubleLiteralExpression(thickness);
   Expression colorExpr = null;

   PackageBuilder packageBuilder = compiler.getPackageBuilder();
   TypeToken colorType = TypeToken.fromClass(Color.class);
   packageBuilder.addImport(colorType);
   String colorValue = node.getStringProperty("color");
   if (colorValue.startsWith("{")) {
     colorExpr = compiler.getBindingExpression(colorValue);
     if (colorExpr == null) {
       compiler.getErrors().add(new CompilerError(node.getLineNumber(), node.getColumn(),
           "Unknown color resource."));
       return null;
     }
     if (!colorType.equals(colorExpr.getType())) {
       if (!packageBuilder.normalizeType(colorType).equals(packageBuilder.normalizeType(
           colorExpr.getType()))) {
         colorExpr = packageBuilder.createTypeCast(colorType, colorExpr);
       }
     }
   } else {
     colorExpr = As3ColorSerializer.colorExpressionFromConstColor(compiler,
         node.getStringProperty("color"));
   }
   TypeToken solidPenType = TypeToken.fromClass(SolidPen.class);
   return compiler.getPackageBuilder().createNewObjectExpression(solidPenType,
       new Expression[] {colorExpr, thicknessExpr});
  }

  /**
  * Create expression for string value.
  */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {
   PackageBuilder packageBuilder = compiler.getPackageBuilder();
   packageBuilder.addImport(TypeToken.fromClass(Color.class));
   if (value.startsWith("{") && value.endsWith("}")) {
     return compiler.getBindingExpression(value);
   } else {
     compiler.addError(ErrorCode.EXPECTING_RESOURCE_ID);
     return null;
   }
  }
}
