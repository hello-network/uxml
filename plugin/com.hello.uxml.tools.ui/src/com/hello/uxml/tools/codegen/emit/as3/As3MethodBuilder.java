package com.hello.uxml.tools.codegen.emit.as3;


import com.hello.uxml.tools.codegen.emit.ClassBuilder;
import com.hello.uxml.tools.codegen.emit.FunctionBuilder;
import com.hello.uxml.tools.codegen.emit.MethodBuilder;
import com.hello.uxml.tools.codegen.emit.PackageBuilder;
import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;

/**
 * Writes code for a method definition.
 *
 * @author ferhat
 */
public class As3MethodBuilder extends MethodBuilder {

  /**
   * Constructor.
   */
  public As3MethodBuilder(String name, TypeToken returnType, ClassBuilder classBuilder) {
    super(name, returnType, classBuilder);
  }

  @Override
  protected FunctionBuilder createNewFunctionBuilder(String name, TypeToken returnType) {
    return new AS3FunctionBuilder(name, returnType);
  }

  @Override
  public void toCode(SourceWriter writer) {
    String name = this.function.getName();

    boolean isClosure = (name.equals(MethodBuilder.CLOSURE_NAME));

    // Include the @Override tag if this is an overridden method.
    if (this.isOverridden) {
      writer.print("override ");
    }

    // Include the static modifier if this is a static method.
    if (this.isStatic) {
      writer.print("static ");
    }

    if (this.isConstructor) {
      writer.print("public ");
    } else {
      if (!isClosure) {
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
    }

    // Code writing
    // If this is a constructor, then set the name of the function to the class name.
    if (this.isConstructor) {
      this.function.setName(this.getClassBuilder().getName());
    }

    // Ask the function to write itself out
    this.function.toCode(writer);
  }

  @Override
  public PackageBuilder getPackage() {
    return classBuilder == null ? null : classBuilder.getPackage();
  }
}

