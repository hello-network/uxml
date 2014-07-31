package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Defines interface for custom serialization of resource model nodes.
 *
 * @author ferhat
 */
public interface CodeModelSerializer extends CodeSerializer {

  /** Creates expression from model */
  Expression createExpression(Model model, ModelCompiler compiler, CodeBlock codeBlock);
}
