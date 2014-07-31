package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

import java.util.List;

/**
 * Interface for FunctionBuilders of various languages.
 *
 * @author ericarnold@ (Eric Arnold)
 *
 */
public interface IFunctionBuilder {
  /**
   * Returns name of method.
   */
  public String getName();

  /**
   * Returns return data type of method.
   */
  public TypeToken getReturnType();

  /**
   * Adds a method parameter.
   */
  public void addParameter(MethodParameter param);

  /**
   * Returns list of method parameters.
   */
  public List<MethodParameter> getParameters();

  // TODO(ericarnold): Separate this out into a codeblock?
  /**
   * Adds a statement to the method.
   */
  public void addStatement(Statement statement);

  /**
   * Adds a block of statements to the method.
   */
  public void add(CodeBlock codeBlock);

  /**
   * Returns list of statements in method.
   */
  public List<Statement> getStatements();

  /**
   * Returns unique variable name generator.
   */
  public UniqueNameGenerator getNameGenerator();

  /**
   * Writes the code of the function to a SourceWriter.
   */
  public void toCode(SourceWriter writer);

  /**
   * Creates a new function with name and return type.
   */
  public FunctionBuilder createNewFunction(String name, TypeToken returnType);
}
