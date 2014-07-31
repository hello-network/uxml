package com.hello.uxml.tools.codegen.emit;

import com.hello.uxml.tools.framework.Command;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.StringLiteralExpression;

/**
 * Serializes a Command object.
 *
 * @author ferhat
 */
public class CommandSerializer implements CodeModelSerializer {

  public CommandSerializer() {
  }

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    return true;
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler, CodeBlock codeBlock) {
    compiler.getErrors().add(new CompilerError("Binding directly to command not supported."));
    return null;
  }

  /**
   * Create value expression for margin model item.
   */
  @Override
  public Expression createExpression(Model node, ModelCompiler compiler, CodeBlock codeBlock) {
    TypeToken commandType = TypeToken.fromClass(Command.class);
    PackageBuilder packageBuilder = compiler.getPackageBuilder();
    packageBuilder.addImport(commandType);
    String id = "";
    if (node.hasProperty("id")) {
      id = node.getStringProperty("id");
    } else {
      compiler.getErrors().add(new CompilerError("Expecting id attribute"));
    }
    return compiler.getPackageBuilder().createNewObjectExpression(commandType, new Expression[] {
        new StringLiteralExpression(id)});
  }
}
