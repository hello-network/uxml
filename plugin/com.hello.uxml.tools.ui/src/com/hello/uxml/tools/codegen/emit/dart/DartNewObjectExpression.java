package com.hello.uxml.tools.codegen.emit.dart;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.NewObjectExpression;

/**
 * Writes java code for object instantiation.
 *
 * @author ferhat
 */
public class DartNewObjectExpression extends NewObjectExpression {
  private TypeToken type;
  private String constructorName;
  private Expression[] parameters;

  public DartNewObjectExpression(TypeToken type) {
    this(type, "", null);
  }

  public DartNewObjectExpression(TypeToken type, Expression[] parameters) {
    this(type, "", parameters);
  }

  public DartNewObjectExpression(TypeToken type, String ctorName,
      Expression[] parameters) {
    this.type = type;
    this.constructorName = ctorName;
    this.parameters = parameters;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("new ");
    writer.print(type.getName());
    if (constructorName.length() != 0) {
      writer.print(".");
      writer.print(constructorName);
    }
    writer.print("(");
    if (parameters != null) {
      Boolean firstParam = true;
      for (Expression param : parameters) {
        if (firstParam) {
          firstParam = false;
        } else {
          writer.print(", ");
        }
        if (param == null) {
          writer.print ("/*ERROR*/");
        } else {
          param.toCode(writer);
        }
      }
    }
    writer.print(")");
  }
}
