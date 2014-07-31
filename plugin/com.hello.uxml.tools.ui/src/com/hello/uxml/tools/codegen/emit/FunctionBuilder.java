package com.hello.uxml.tools.codegen.emit;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

import java.util.List;

/**
 * Provides access to a method declaration.
 *
 * @author ferhat
 *         ericarnold@google.com (Eric Arnold)
 *
 */
public abstract class FunctionBuilder extends Expression {

  /** Name of method. If method is a constructor it holds CONSTRUCTOR_NAME. */
  protected String name;

  /** The method which may be the parent of this function (if any). **/
  protected MethodBuilder method;

  /** Method parameters*/
  protected final List<MethodParameter> parameters = Lists.newArrayList();

  private UniqueNameGenerator nameGenerator;

  /** Statements in method */
  public CodeBlock codeBlock = new CodeBlock(this);

  /** Return data type. */
  protected TypeToken returnType;

  public FunctionBuilder(String name, TypeToken returnType) {
    this.name = name;
    this.returnType = returnType;
  }

  /**
   * Returns name of method.
   */
  public String getName() {
    return name;
  }

  /**
   * Returns return data type of method.
   */
  public TypeToken getReturnType() {
    return returnType;
  }

  /**
   * Returns method that owns this block of statements.
   */
  public MethodBuilder getMethod() {
    return method;
  }

  /**
   * Sets the name of the function
   *
   * @param newName
   */
  public void setName(String newName) {
    this.name = newName;
  }

  /**
   * Adds a method parameter.
   */
  public void addParameter(MethodParameter param) {
    parameters.add(param);
  }

  /**
   * Returns list of method parameters.
   */
  public List<MethodParameter> getParameters() {
    return parameters;
  }

  // TODO(ericarnold): Separate this out into a codeblock and refactor
  /**
   * Adds a statement to the method.
   */
  public void addStatement(Statement statement) {
    codeBlock.addStatement(statement);
  }

  /**
   * Adds a block of statements to the method.
   */
  public void add(CodeBlock codeBlock) {
    this.codeBlock.addCodeBlock(codeBlock);
  }

  /**
   * Returns list of statements in method.
   */
  public List<Statement> getStatements() {
    return codeBlock.getStatements();
  }

  /**
   * Returns unique variable name generator.
   */
  public UniqueNameGenerator getNameGenerator() {
    if (nameGenerator == null) {
      nameGenerator = new UniqueNameGenerator();
    }
    return nameGenerator;
  }

  @Override
  public void toCode(SourceWriter writer) {
    this.toCode(writer, true);
  }

  public abstract void toCode(SourceWriter writer, boolean includeNameAndType);
}
