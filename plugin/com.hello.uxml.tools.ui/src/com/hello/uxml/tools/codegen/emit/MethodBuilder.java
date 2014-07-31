package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

import java.util.List;

/**
 * Provides access to a method declaration.
 *
 * @author ferhat
 */
public abstract class MethodBuilder extends Expression {

  public boolean isConstructor = false;
  public static final String CLOSURE_NAME = "";

  /** Parent class builder of method */
  protected final ClassBuilder classBuilder;

  /** The contained function body of the method **/
  protected FunctionBuilder function;

  /** Visibility of method. */
  protected MemberScope scope;

  /** Whether the method is overridden or not. */
  protected boolean isOverridden;

  /** Whether the method is static or not. */
  protected boolean isStatic;

  /** The type of method (regular, getter or setter). */
  protected Type methodType = Type.REGULAR;
  public Type getMethodType() {
    return this.methodType;
  }
  public void setMethodType(Type methodType) {
    this.methodType = methodType;
  }

  /** The type of function */
  public enum Type {
    GETTER,
    SETTER,
    REGULAR
  }

  /**
   * Constructor.
   */
  public MethodBuilder(String name, TypeToken returnType, ClassBuilder classBuilder) {
    this.function = createNewFunctionBuilder(name, returnType);
    this.function.method = this;
    this.classBuilder = classBuilder;
    scope = MemberScope.PUBLIC;
  }

  protected abstract FunctionBuilder createNewFunctionBuilder(String name, TypeToken returnType);
  public abstract PackageBuilder getPackage();

  /**
   * Whether the method is static or not
   */
  public boolean isStatic() {
    return isStatic;
  }

  public void setStatic(boolean isStatic) {
    this.isStatic = isStatic;
  }

  /**
   * Returns parent class builder.
   */
  public ClassBuilder getClassBuilder() {
    return classBuilder;
  }

  /**
   * Sets visibility of method.
   */
  public void setScope(MemberScope scope) {
    this.scope = scope;
  }

  /**
   * Whether the method is overridden or not.
   */
  public boolean isOverridden() {
    return isOverridden;
  }

  public void setOverridden(boolean overridden) {
    this.isOverridden = overridden;
  }

  @Override
  public abstract void toCode(SourceWriter writer);

  public String getName() {
    return function.getName();
  }

  public FunctionBuilder getFunction() {
    return this.function;
  }

  public TypeToken getReturnType() {
    return function.getReturnType();
  }

  //TODO(ericarnold): We may want to refactor (remove) these (getParameters, addParameter,
  //                  addStatement, add, getStatements convenience methods)
  public void addParameter(MethodParameter param) {
    function.addParameter(param);
  }

  public List<MethodParameter> getParameters() {
    return function.getParameters();
  }

  public void addStatement(Statement statement) {
    function.addStatement(statement);
  }

  public void add(CodeBlock codeBlock) {
    function.add(codeBlock);
  }

  public List<Statement> getStatements() {
    return function.getStatements();
  }

  public UniqueNameGenerator getNameGenerator() {
    return function.getNameGenerator();
  }
}


