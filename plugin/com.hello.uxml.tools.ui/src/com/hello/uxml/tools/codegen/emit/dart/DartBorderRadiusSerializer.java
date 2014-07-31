package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.BorderRadiusSerializer;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.DoubleLiteralExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Serializes BorderRadius model to expression.
 *
 * @author ferhat
 */
public class DartBorderRadiusSerializer extends BorderRadiusSerializer {
  @Override
  protected Expression createUniformBorderExpression(ModelCompiler compiler, double size) {
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken borderRadiusType = TypeToken.fromClass(BorderRadius.class);
    return packageBuilder.createNewObjectExpression(borderRadiusType, "uniform",
        new Expression[] {new DoubleLiteralExpression(size)});
  }
}
