package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Writes code for a method definition.
 *
 * @author ferhat
 */
public class DartMethodBuilder extends MethodBuilder {
  protected DartPackageBuilder packageBuilder;

  /**
   * Constructor.
   */
  public DartMethodBuilder(String name, TypeToken returnType, DartPackageBuilder packageBuilder,
      DartClassBuilder classBuilder) {
    super(name, returnType, classBuilder);
    this.packageBuilder = packageBuilder;
  }

  /**
   * Returns packageBuilder for method.
   */
  public DartPackageBuilder getPackageBuilder() {
    return packageBuilder;
  }

  public void write(SourceWriter writer) {
    DartFunctionBuilder dartFunction = (DartFunctionBuilder) this.function;

    // Include the static modifier if this is a static method.
    if (this.isStatic) {
      writer.print("static ");
    }

    // Skip visibility since dash doesn't support it.

    // Write out the type
    dartFunction.writeType(writer);

    // Write out the getter / setter descriptor if there is one.
    switch (this.methodType) {
      case GETTER:
        writer.print("get ");
        break;
      case SETTER:
        writer.print("set ");
        break;
      default:
        break;
    }

    // Change the name if this is a constructor
    if (this.isConstructor) {
      this.function.setName(this.classBuilder.getName());
    }

    // Print out the name
    writer.print(function.getName().toString());

    // Ask the function to write itself (without type and name)
    this.function.toCode(writer, false);

    // Add a newline to the end of a method definition
    writer.println("");
  }

  @Override
  public void toCode(SourceWriter writer) {
    write(writer);
  }

  @Override
  protected DartFunctionBuilder createNewFunctionBuilder(String name, TypeToken returnType) {
    return new DartFunctionBuilder(name, returnType);
  }

  @Override
  public PackageBuilder getPackage() {
    return packageBuilder;
  }
}
