package com.hello.uxml.tools.codegen.emit.java;


import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.MethodParameter;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import java.util.List;

/**
 * A Java representation for a function, contained in a class method.
 *
 * @author ericarnold
 */
public class JFunctionBuilder extends FunctionBuilder {
  protected PackageBuilder packageBuilder;

  public JFunctionBuilder(String name, TypeToken returnType) {
    super(name, returnType);
    this.packageBuilder = new JPackageBuilder();
  }

  /**
   * Writes parameters (DataType name,...)
   **/
  protected void writeParams(SourceWriter writer) {
    List<MethodParameter> parameters = this.getParameters();
    boolean firstParam = true;

    for (MethodParameter param : parameters) {
      if (firstParam) {
        firstParam = false;
      } else {
        writer.print(", ");
      }
      writer.print(packageBuilder.tokenTypeToString(param.getType()));
      writer.print(" ");
      writer.print(param.getName());
    }
  }


  @Override
  public void toCode(SourceWriter writer, boolean includeBeginning) {
    if (includeBeginning) {
      // Write out the return type if any.
      if (returnType != null) {
        writer.print(packageBuilder.tokenTypeToString(returnType));
        writer.print(" ");
      }

      // Write out the name.
      writer.print(this.name);
    }

    // Write out parameters
    writer.print("(");
    writeParams(writer);
    writer.print(") ");

    // Write out the code
    codeBlock.toCode(writer);
  }
}
