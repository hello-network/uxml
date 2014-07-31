package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for java event listener calling a target method.
 *
 * @author ferhat
 */
public class JEventListenerExpression extends Expression {
  private TypeToken eventListenerType;
  private Expression targetObject;
  private String methodName;

  /**
   * Constructor.
   */
  public JEventListenerExpression(TypeToken eventListenerType, Expression targetObject,
    String methodName) {
    this.eventListenerType = eventListenerType;
    this.targetObject = targetObject;
    this.methodName = methodName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("new ");
    writer.print(eventListenerType.getName());
    writer.print("() {");
    writer.print("\n    public void handleEvent(EventNotifier target, EventArgs e) {");
    writer.print("\n      ");
    targetObject.toCode(writer);
    writer.print(".");
    writer.print(methodName);
    writer.print("((UIElement) target, e);");
    writer.print("\n  }}");
  }
}
