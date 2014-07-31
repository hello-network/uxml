package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.framework.graphics.VecPath;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.ExpressionStatement;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Serializes a Path objects.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3PathSerializer implements CodeSerializer {

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
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    TypeToken pathType = TypeToken.fromClass(VecPath.class);
    String varName = codeBlock.createVariableName(pathType.getName());
    packageBuilder.addImport(pathType);
    VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
        new As3Reference(varName, pathType), packageBuilder.createNewObjectExpression(pathType));
    codeBlock.addStatement(varDef);
    Expression setPropertyExpr = packageBuilder.createSetPropertyExpression(
        varDef.getReference(), "content", packageBuilder.createStringLiteralExpression(value));
    codeBlock.addStatement(new ExpressionStatement(setPropertyExpr));
    return varDef.getReference();
  }
}
