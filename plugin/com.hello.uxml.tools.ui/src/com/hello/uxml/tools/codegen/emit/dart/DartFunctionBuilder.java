package com.hello.uxml.tools.codegen.emit.dart;


import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.MethodParameter;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.java.JPackageBuilder;

import java.util.List;

/**
 * A Dash representation for a function, contained in a class method.
 *
 * @author ericarnold
 */
public class DartFunctionBuilder extends FunctionBuilder {
  protected PackageBuilder packageBuilder;

  public DartFunctionBuilder(String name, TypeToken returnType) {
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
      // TODO(ericarnold): I'm thinking that we may want to let the MethodBuilder handle this, and
      //                   separate out writeParameters as a public function.

      this.writeType(writer);

      if (this.name != null) {
        // Write out the name.
        writer.print(this.name);
      } else {
        // Otherwise, if no name is present, write out "function" because we are a lambda.
        writer.print("function");
      }
    }

    // Write out parameters
    writer.print("(");
    writeParams(writer);
    writer.print(") ");

    if (this.method != null && this.method.isConstructor) {
      TypeToken baseClass = this.method.getClassBuilder().getBaseClass();
      if (baseClass != null && !baseClass.equals(TypeToken.OBJECT)) {
        writer.print(" : super() ");
      }
    }

    // Write out the code
    codeBlock.toCode(writer);
  }

  public void writeType(SourceWriter writer) {
    // Write out the return type if any.
    if (returnType != null) {
      writer.print(packageBuilder.tokenTypeToString(returnType));
      writer.print(" ");
    }
  }
}
