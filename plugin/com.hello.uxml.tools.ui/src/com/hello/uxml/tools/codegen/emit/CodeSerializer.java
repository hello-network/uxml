package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Defines interface for serialization of object properties.
 *
 * @author ferhat
 */
public interface CodeSerializer {

  /** Returns true if value can be serialized */
  boolean canSerialize(String value, ModelCompiler compiler);

  /** Creates expression from string value */
  Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock);
}
