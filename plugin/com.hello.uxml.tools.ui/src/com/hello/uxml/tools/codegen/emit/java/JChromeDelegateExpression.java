package com.hello.uxml.tools.codegen.emit.java;

import com.hello.uxml.tools.codegen.emit.SourceWriter;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;

/**
 * Creates code for chrome createElements delegate.
 *
 * @author ferhat
 */
public class JChromeDelegateExpression extends Expression {
  private String methodName;

  /**
   * Constructor.
   */
  public JChromeDelegateExpression(String methodName) {
    this.methodName = methodName;
  }

  @Override
  public void toCode(SourceWriter writer) {
    writer.print("new ChromeHandler");
    writer.print("() {");
    writer.print("\n      public UIElement createElements(UIElement targetElement) {");
    writer.print("\n        return ");
    writer.print(methodName);
    writer.print("(targetElement);");
    writer.print("\n      }}");
  }
}
