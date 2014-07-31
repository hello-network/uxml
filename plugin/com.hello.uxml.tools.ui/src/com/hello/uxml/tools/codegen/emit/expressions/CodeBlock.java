package com.hello.uxml.tools.codegen.emit.expressions;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.AssignmentExpression.AssignmentExpressionType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Represents a group of statements in a method.
 *
 * @author ferhat
 */
public class CodeBlock extends Statement {

  private FunctionBuilder function;
  private List<Statement> statements = Lists.newArrayList();
  private Map<TypeToken, ArrayList<VariableDefinitionStatement>> reusableLocalPool = null;

  /**
   * Constructor.
   * @param function method that owns this block of code.
   */
  public CodeBlock(FunctionBuilder function) {
    this.function = function;
  }

  public CodeBlock(MethodBuilder method) {
    this.function = method.getFunction();
  }

  public CodeBlock() {
    this.function = null;
  }

  /**
   * Returns function that owns this block of statements.
   */
  public FunctionBuilder getFunction() {
    return function;
  }

  /**
   * Returns mutable list of statements.
   */
  public List<Statement> getStatements() {
    return statements;
  }

  /**
   * Creates a variable name inside code block.
   */
  public String createVariableName(String namePrefix) {
    return (function == null) ? null : function.getNameGenerator().createVariableName(namePrefix);
  }

  public VariableDefinitionStatement defineLocal(String namePrefix, TypeToken dataType,
      Expression initExpression) {
    VariableDefinitionStatement varDef;
    PackageBuilder packageBuilder = function.getMethod().getClassBuilder().getPackage();
    if (reusableLocalPool != null) {
      List<VariableDefinitionStatement> poolForType = reusableLocalPool.get(dataType);
      if ((poolForType != null) && (poolForType.size() != 0)) {
        varDef = poolForType.get(0);
        poolForType.remove(0);
        if (initExpression != null) {
          addStatement(new ExpressionStatement(new AssignmentExpression(
              varDef.getReference(), initExpression, AssignmentExpressionType.REGULAR)));
        }
        return varDef;
      }
    }

    String varName = createVariableName(namePrefix);
    varDef = packageBuilder.createVariableDefinition(packageBuilder.createReferenceExpression(
        varName, dataType), initExpression);
     addStatement(varDef);
     return varDef;
  }

  /**
   * Releases the variable name for reuse.
   */
  public void releaseLocal(VariableDefinitionStatement statement) {
    if (reusableLocalPool == null) {
      reusableLocalPool = new HashMap<TypeToken, ArrayList<VariableDefinitionStatement>>();
    }
    TypeToken dataType = statement.getReference().resultType;
    ArrayList<VariableDefinitionStatement> list = reusableLocalPool.get(dataType);
    if (list == null) {
      list = new ArrayList<VariableDefinitionStatement>();
      list.add(statement);
      reusableLocalPool.put(dataType, list);
    }
  }

  /**
   * Adds a statement.
   */
  public void addStatement(Statement stmt) {
    statements.add(stmt);
  }

  /**
   * Adds a codeblock to this codeblock
   */
  public void addCodeBlock(CodeBlock codeBlockToAppend) {
    List<Statement> statementsToAppend = codeBlockToAppend.statements;
    for (Statement statement : statementsToAppend) {
      this.statements.add(statement);
    }
  }


  @Override
  public void toCode(SourceWriter writer, boolean omitSemicolon) {
    writer.println("{");
    writer.indent();
    for (Statement statement : statements) {
      statement.toCode(writer);
      writer.println("");
    }
    writer.outdent();
    writer.print("}");
  }
}
