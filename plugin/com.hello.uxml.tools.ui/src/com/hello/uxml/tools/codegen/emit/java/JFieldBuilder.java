package com.hello.uxml.tools.codegen.emit.java;

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
public class JFieldBuilder implements FieldBuilder {

  private Reference reference;
  private EnumSet<FieldAttributes> attributes;
  private final Expression initExpression;

  /**
   * Constructor.
   */
  public JFieldBuilder(Reference reference, EnumSet<FieldAttributes> attributes) {
    this(reference, attributes, null);
  }

  public JFieldBuilder(Reference reference, EnumSet<FieldAttributes> attributes,
      Expression initExpression) {
    this.reference = reference;
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

  @Override
  public Expression getInitExpression() {
    return this.initExpression;
  }
}
