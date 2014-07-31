package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

import java.util.EnumSet;
import java.util.List;

/**
 * A language neutral interface for generating class source code.
 *
 * @author ferhat
 */
public interface ClassBuilder {

  /**
   * Returns class name.
   */
  String getName();

  /**
   * Sets or returns class comments.
   */
  String getComments();
  void setComments(String value);

  /**
   * Returns parent package.
   */
  PackageBuilder getPackage();

  /**
   * Sets or returns base class.
   */
  TypeToken getBaseClass();
  void setBaseClass(TypeToken baseClassType);

  /**
   * Creates a field.
   */
  FieldBuilder createField(Reference fieldReference,
      EnumSet<FieldAttributes> fieldAttributes);

  /**
   * Creates a field.
   */
  FieldBuilder createField(Reference fieldReference,
      EnumSet<FieldAttributes> fieldAttributes,
      Expression initExpression);

  /**
   * Creates default constructor
   */
  MethodBuilder createDefaultConstructor();

  /**
   * Creates a method.
   */
  MethodBuilder createMethod(String name, TypeToken returnType);

  /**
   * Add an implements class to the class
   *
   * @param implementsClass
   */
  void addImplements(TypeToken implementsClass);

  /**
   * Returns package-wide unique name generator.
   */
  public UniqueNameGenerator getNameGenerator();

  /**
   * Writes class code to source writer.
   *
   * @param writer target SourceWriter
   * @return success
   */
  boolean write(SourceWriter writer);

  /**
   * Returns a list of implemented classes.
   */
  List<TypeToken> getImplementedClasses();

}
