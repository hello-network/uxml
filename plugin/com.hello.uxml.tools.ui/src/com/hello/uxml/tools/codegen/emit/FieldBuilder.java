package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

import java.util.EnumSet;

/**
 * Provides abstraction for a language neutral field member.
 *
 * @author ferhat
 */
public interface FieldBuilder {

  /** Returns name of field */
  String getName();

  /** Returns initialization expression */
  Expression getInitExpression();

  /** Returns data type of field */
  TypeToken getType();

  /** Returns Attributes of field */
  EnumSet<FieldAttributes> getAttributes();

  /** Returns a code reference */
  Reference getReference();
}
