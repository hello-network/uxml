package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.FieldAttributes;
import com.hello.uxml.tools.codegen.emit.FieldBuilder;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

import java.util.EnumSet;

/**
 * Provides field information for a class.
 *
 * @author ferhat
 */
public class As3FieldBuilder implements FieldBuilder {

  private Reference reference;
  private EnumSet<FieldAttributes> attributes;
  private final Expression initExpression;
  /**
   * Constructors.
   */
  public As3FieldBuilder(Reference fieldReference, EnumSet<FieldAttributes> attributes) {
    this(fieldReference, attributes, null);
  }

  public As3FieldBuilder(Reference fieldReference, EnumSet<FieldAttributes> attributes,
      Expression initExpression) {
    this.reference = fieldReference;
    this.attributes = attributes;
    this.initExpression = initExpression;
  }

  /**
   * Returns name of field.
   */
  @Override
  public String getName() {
    return reference.getName();
  }

  /**
   * Returns the initialization expression.
   */
  @Override
  public Expression getInitExpression() {
    return this.initExpression;
  }

  /**
   * Returns type of field.
   */
  @Override
  public TypeToken getType() {
    return reference.getType();
  }

  /**
   * Returns field attributes.
   */
  @Override
  public EnumSet<FieldAttributes> getAttributes() {
    return attributes;
  }

  /** Returns a code reference */
  @Override
  public Reference getReference() {
    return reference;
  }
}
