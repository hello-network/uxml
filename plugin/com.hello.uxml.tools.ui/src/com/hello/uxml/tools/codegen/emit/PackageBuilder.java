package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.ExpressionStatement;
import com.hello.uxml.tools.codegen.emit.expressions.MethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.NameExpression;
import com.hello.uxml.tools.codegen.emit.expressions.NewObjectExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;
import com.hello.uxml.tools.codegen.emit.expressions.SelfReferenceExpression;
import com.hello.uxml.tools.codegen.emit.expressions.SetFieldExpression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;
import com.hello.uxml.tools.codegen.emit.expressions.StaticMethodCall;
import com.hello.uxml.tools.codegen.emit.expressions.VariableDefinitionStatement;

import java.io.File;

/**
 * Defines interface for package code generation.
 *
 * @author ferhat
 */
public interface PackageBuilder {

  /**
   * Sets name of package.
   */
  void setName(String packageName);

  /**
   * Sets name of library (part).
   */
  void setPartName(String partName);

  /**
   * Returns name of package.
   */
  String getName();

  /**
   * Creates a ClassBuilder object and adds it to package.
   *
   * @param name Class name
   * @return builder for class members
   */
  ClassBuilder createClass(String name);

  /**
   * Imports a new type to the package.
   */
  void addImport(TypeToken type);

  // Methods to create expression and statements :

  /**
   * Create SelfReferenceExpression instance.
   */
  SelfReferenceExpression createSelfReferenceExpression();

  /**
   * Create method call.
   */
  MethodCall createMethodCall(Expression target, String methodName);

  /**
   * Create method call.
   */
  MethodCall createMethodCall(Expression target, String methodName,
      Expression[] parameters);

  /**
   * Create a method call to a static member function.
   */
  StaticMethodCall createStaticMethodCall(TypeToken targetType, String methodName);

  /**
   * Creates dynamic late bound method call.
   */
  Expression createDynamicCall(Expression target, String methodName,
      Expression[] parameters, MethodBuilder method);

  /**
   * Create a method call to a static member function.
   */
  StaticMethodCall createStaticMethodCall(TypeToken targetType, String methodName,
      Expression[] parameters);

  /**
   * Creates a closure.
   */
  MethodBuilder createClosure(TypeToken returnType);

  /**
   * Create a statement from an expression.
   */
  ExpressionStatement createExpressionStatement(Expression expression);

  /**
   * Creates variable declaration statement.
   */
  VariableDefinitionStatement createVariableDefinition(Reference variableReference);

  /**
   * Creates variable declaration statement with initialzier.
   */
  VariableDefinitionStatement createVariableDefinition(Reference variableReference,
      Expression expr);

  /**
  * Creates a StringLiteralExpression.
  *
  * <p>For As3 and Java double quoted strings are generated. For ObjC @"value".
  */
  Expression createStringLiteralExpression(String value);

  /**
   * Creates a NewObjectExpression.
   */
  NewObjectExpression createNewObjectExpression(TypeToken type);

  /**
   * Creates a NewObjectExpression with parameters.
   */
  NewObjectExpression createNewObjectExpression(TypeToken type, Expression[] parameters);

  /**
   * Creates a NewObjectExpression with a named constructor. See generative constructors
   * in Dart language spec.
   */
  NewObjectExpression createNewObjectExpression(TypeToken type, String constructorName,
      Expression[] parameters);

  /**
   * Creates a set field expression.
   */
  SetFieldExpression createSetFieldExpression(Expression target, String fieldName,
      Expression rhs);

  /**
   * Creates a get field expression.
   */
  Expression createGetFieldExpression(Expression source, String fieldName);

  /**
   * Creates a set static field expression.
   */
  SetFieldExpression createSetStaticFieldExpression(TypeToken type, String fieldName,
      Expression rhs);

  /**
   * Creates a get static field expression.
   */
  Expression createGetStaticFieldExpression(TypeToken type, String fieldName);

  /**
   * Creates a set property expression.
   */
  Expression createSetPropertyExpression(Expression target, String fieldName,
      Expression rhs);

  /**
   * Creates a get property expression.
   */
  Expression createGetPropertyExpression(Expression source, String fieldName);

  /**
   * Creates a reference.
   */
  Reference createReferenceExpression(String varName);

  /**
   * Creates a reference.
   */
  Reference createReferenceExpression(String varName, TypeToken type);

  /**
   * Creates a reference.
   */
  Reference createReferenceExpression(String varName, TypeToken type, Boolean includeType);

  /**
   * Creates a statement that adds an expression to a list/array collection
   * in target language.
   *
   * <p>As3: myList.push(value)
   * <p>Java: myList.add(value)
   * <p>ObjC: [myList addObject: value]
   */
  Statement createCollectionAddStatement(Expression collection, Expression value);

  /**
   * Creates a reference to a class object.
   *
   * <p>As3: Button
   * <p>Java: Button.class
   * <p>ObjC: [Button class]
   */
  Expression createClassReferenceExpression(TypeToken type);

  /**
   * Creates a reference to a class element definition.
   *
   * <p>As3: Button
   * <p>Java: Button.class
   * <p>ObjC: [Button class]
   */
  Expression createElementTypeReferenceExpression(TypeToken type);

  /**
   * Creates a type cast expression.
   */
  Expression createTypeCast(TypeToken targetType, Expression expression);

  /**
   * Creates an array object from a list of expressions.
   */
  Expression createArray(TypeToken arrayType, Expression[] values);

  /**
   * Creates a property expression for inside an object (ie {prop:value}).
   */
  Expression createPropertyExpression(NameExpression name,
      Expression rightExpression);

  /**
   * Creates expression to get array element.
   */
  Expression createGetArrayElementExpression(Expression array, Expression[] indices);

  /**
   * Creates a delegate (Flash function or Java EventListener)
   */
  Expression createDelegate(Expression targetObject,
      String targetMethodName);

  /**
   * Creates a chrome handler delegate.
   */
  Expression createChromeDelegate(String targetMethodName);

  /**
   * Create a function
   */
  public FunctionBuilder createNewFunction(String name, TypeToken returnType);

  /**
   * Translate primitive type names to target.
   */
  String tokenTypeToString(TypeToken type);

  /**blaze test javatests/com/google/social/hello/tools/codegen/...
   * Returns custom code serializer for element type.
   */
  CodeSerializer getSerializer(TypeToken elementType);

  /**
   * Output package and contents using SourceWriter.
   *
   * @return whether code generation succeeded
   */
  boolean write(SourceWriter writer);

  /**
   * Returns default file extension.
   */
  public String getDefaultFileExtension();

  /**
   * Returns language specific target directory for package name.
   *
   * Languages such as Dart don't have package names and use
   * import prefix instead.
   */
  public String getFileTargetDir(String path, File uxmlFile, String packageName,
      File sourceRoot);

  /**
   * Normalized a TypeToken to target language.
   */
  TypeToken normalizeType(TypeToken type);

  /**
   * Returns if language supports explicity type casting.
   */
  boolean supportsExplicitCast();

  /**
   * Returns property definition naming convention.
   */
  String getPropertyDefPostFix();

  /*
   * Creates expression for localized string lookup. Returns null for default impl.
   */
  Expression localizeLiteralString(String value);
}
