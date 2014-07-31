package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.MethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

/**
 * Represents a dynamic reflection based method call.
 *
 * @author ferhat
 */
public class JDynamicMethodCall extends MethodCall {

  // Used to add intermediate statements.
  private final MethodBuilder targetMethod;
  private Expression lhsExpr;

  public JDynamicMethodCall(Expression target, String methodName, Expression[] parameters,
      MethodBuilder method) {
    super(target, methodName, parameters);
    targetMethod = method;
    lhsExpr = target;

    PackageBuilder packageBuilder = method.getPackage();

    String[] parts = methodName.split("\\.");
    for (int p = 0; p < parts.length - 1; p++) {
      String varName = method.getNameGenerator().createVariableName("f");
      Expression getFieldExpr = packageBuilder.createMethodCall(
          packageBuilder.createMethodCall(lhsExpr, "getClass"), "getField",
          new Expression[] {packageBuilder.createStringLiteralExpression(parts[p])});
      VariableDefinitionStatement varDef = packageBuilder.createVariableDefinition(
          packageBuilder.createReferenceExpression(varName, TypeToken.OBJECT), getFieldExpr);
      targetMethod.addStatement(varDef);
      lhsExpr = varDef.getReference();
    }
    methodName = parts[parts.length - 1];
  }

  @Override
  public void toCode(SourceWriter writer) {
    // use foo() instead of this.foo()
    if (!SourceWriter.toString(lhsExpr).equals("this")) {
      lhsExpr.toCode(writer);
      writer.print(".");
    }

    writer.print("getClass().getMethod(");
    writer.print("\"" + methodName + "\"");
    if (parameterList.length() != 0) {
      writer.print(", new Class<?>[] {");
      for (int tIndex = 0; tIndex < parameterList.length(); tIndex++) {
        writer.print(parameterList.getParameter(tIndex).getType().getName());
        writer.print(".class");
      }
      writer.print("}");
    }
    writer.print(").invoke(");
    lhsExpr.toCode(writer);
    parameterList.toCode(writer);
    writer.print(")");
  }
}
