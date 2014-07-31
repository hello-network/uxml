package com.hello.uxml.tools.codegen.emit.as3;

import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.ModelCompiler;
import com.hello.uxml.tools.codegen.emit.CodeSerializer;
import com.hello.uxml.tools.codegen.emit.TypeToken;
import com.hello.uxml.tools.codegen.emit.expressions.CodeBlock;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Reference;

/**
 * Serializes Transition.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class As3TransitionSerializer implements CodeSerializer {

  /** Returns true if value can be serialized */
  @Override
  public boolean canSerialize(String value, ModelCompiler compiler) {
    return !value.startsWith("{");
  }

  /**
   * Create expression for string value.
   */
  @Override
  public Expression createExpression(String value, ModelCompiler compiler,
      CodeBlock codeBlock) {
    value = value.toLowerCase();
    compiler.getPackageBuilder().addImport(TypeToken.fromFullName(
        "com.google.uxml.DisclosureBox"));
    if (value.equals("none")) {
      return new Reference("DisclosureBox.TRANSITION_NONE");
    } else if (value.equals("revealheight")) {
      return new Reference("DisclosureBox.TRANSITION_REVEAL_HEIGHT");
    } else if (value.equals("revealwidth")) {
      return new Reference("DisclosureBox.TRANSITION_REVEAL_WIDTH");
    } else if (value.equals("reveal")) {
      return new Reference("DisclosureBox.TRANSITION_REVEAL");
    } else if (value.equals("scrollup")) {
      return new Reference("DisclosureBox.TRANSITION_SCROLL_UP");
    } else if (value.equals("scrolldown")) {
      return new Reference("DisclosureBox.TRANSITION_SCROLL_DOWN");
    } else if (value.equals("scrollleft")) {
      return new Reference("DisclosureBox.TRANSITION_SCROLL_LEFT");
    } else if (value.equals("scrollright")) {
      return new Reference("DisclosureBox.TRANSITION_SCROLL_RIGHT");
    } else if (value.equals("slideup")) {
      return new Reference("DisclosureBox.TRANSITION_SLIDE_UP");
    } else if (value.equals("slidedown")) {
      return new Reference("DisclosureBox.TRANSITION_SLIDE_DOWN");
    } else if (value.equals("slideleft")) {
      return new Reference("DisclosureBox.TRANSITION_SLIDE_LEFT");
    } else if (value.equals("slideright")) {
      return new Reference("DisclosureBox.TRANSITION_SLIDE_RIGHT");
    } else if (value.equals("zoom")) {
      return new Reference("DisclosureBox.TRANSITION_ZOOM");
    } else if (value.equals("grow")) {
      return new Reference("DisclosureBox.TRANSITION_GROW");
    } else {
      compiler.getErrors().add(new CompilerError(String.format(
          "Invalid transition value '%s'", value)));
      return null;
    }
  }
}
