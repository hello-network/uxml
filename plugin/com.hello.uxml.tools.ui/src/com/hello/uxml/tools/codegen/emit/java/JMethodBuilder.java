package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Writes code for a method definition.
 *
 * @author ferhat
 */
public class JMethodBuilder extends MethodBuilder {
  protected JPackageBuilder packageBuilder;

  /**
   * Constructor.
   */
  public JMethodBuilder(String name, TypeToken returnType, JPackageBuilder packageBuilder,
      JClassBuilder classBuilder) {
    super(name, returnType, classBuilder);
    this.packageBuilder = packageBuilder;
  }

  /**
   * Returns packageBuilder for method.
   */
  public JPackageBuilder getPackageBuilder() {
    return packageBuilder;
  }

  public void write(SourceWriter writer) {
    // TODO(ericarnold): remove write (change to toCode)

    // Include the @Override tag if this is an overridden method.
    if (this.isOverridden) {
      writer.println("@Override");
    }

    // Include the static modifier if this is a static method.
    if (this.isStatic) {
      writer.print("static ");
    }

    // Write out the visibility type
    if (this.isConstructor) {
      writer.print("public ");
    } else {
      switch (scope) {
        case PRIVATE:
          writer.print("private ");
          break;
        case PROTECTED:
          writer.print("protected ");
          break;
        case PUBLIC:
        default:
          writer.print("public ");
          break;
      }
    }

    // Change the name if this is a constructor
    if (this.isConstructor) {
      this.function.setName(this.classBuilder.getName());
    }

    // Ask the function to write itself
    this.function.toCode(writer);

    // Add a newline to the end of a method definition
    writer.println("");
  }

  @Override
  public void toCode(SourceWriter writer) {
    write(writer);
  }

  @Override
  protected JFunctionBuilder createNewFunctionBuilder(String name, TypeToken returnType) {
    return new JFunctionBuilder(name, returnType);
  }

  @Override
  public PackageBuilder getPackage() {
    return packageBuilder;
  }
}
