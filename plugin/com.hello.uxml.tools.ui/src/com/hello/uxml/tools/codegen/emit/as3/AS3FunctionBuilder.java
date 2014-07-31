package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.MethodParameter;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

import java.util.List;

/**
 * An AS3 representation for a function (whether contained in a class method,
 * of as an anonymous or in-function function)
 *
 * @author ericarnold
 */
public class AS3FunctionBuilder extends FunctionBuilder {

  public AS3FunctionBuilder(String name, TypeToken returnType) {
    super(name, returnType);
  }


  /**
   * Writes out the params of this function to a {@link SourceWriter}
   *
   * @param writer
   */
  private void writeParams(SourceWriter writer) {
    ClassBuilder classBuilder = (this.method == null) ? null : this.method.getClassBuilder();

    // Param opener
    writer.print("(");

    // Cycle through parameters and put commas between them
    boolean firstParam = true;
    List<MethodParameter> parameters = this.getParameters();
    for (MethodParameter param : parameters) {
      // Write comma if not first
      if (firstParam) {
        firstParam = false;
      } else {
        writer.print(", ");
      }

      String paramName = param.getName();
      TypeToken type = param.getType();
      String typeName = "";


      if (classBuilder == null) {
        typeName = type.getName();
        // closure
      } else {
        typeName = classBuilder.getPackage().tokenTypeToString(param.getType());
      }

      if (!typeName.equals("")) {
        // Rest
        if (typeName.equals("...")) {
          writer.print("...");
          writer.print(paramName);
        // Type provided
        } else {
          writer.print(paramName);
          writer.print(":");
          writer.print(typeName);
        }
      // Type omitted
      } else {
        writer.print(paramName);
      }

      Expression initExpression = param.getInitExpression();

      if (initExpression != null) {
        writer.print(" = ");
        initExpression.toCode(writer);
      }
    }
    writer.print(")");
  }

  /**
   * Writes method contents.
   */
  @Override
  public void toCode(SourceWriter writer, boolean includeBeginning) {
    ClassBuilder classBuilder = (this.method == null) ? null : this.method.getClassBuilder();

    if (includeBeginning) {
      // Write out the function specifier
      writer.print("function ");

      // Write out the name
      writer.print(name);
    }

    // Write out the parameters
    this.writeParams(writer);

    // TODO(ericarnold): What is going on here?  Figure out the closure usage.
    // Write out the return type if any
    if (returnType != null) {
      writer.print(":");
      if (classBuilder == null) {
        // closure
        writer.print(returnType.getName());
      } else {
        writer.print(classBuilder.getPackage().tokenTypeToString(returnType));
      }
    }

    // Space after the return type
    writer.print(" ");

    // Code writing
    codeBlock.toCode(writer);
    writer.println("");
  }
}
