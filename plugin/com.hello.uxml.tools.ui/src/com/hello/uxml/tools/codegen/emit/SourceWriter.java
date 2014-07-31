package com.hello.uxml.tools.codegen.emit;

import com.google.common.base.Preconditions;
import com.hello.uxml.tools.codegen.emit.expressions.Expression;
import com.hello.uxml.tools.codegen.emit.expressions.Statement;

/**
 * Writes properly indented source code.
 *
 * This class is used by Package/Class/CodeBuilder to generate output.
 * This class is NOT safe for multithreaded access.
 *
 * @author ferhat
 */
public class SourceWriter {

  private static final int TAB_SPACE_COUNT = 2;
  private StringBuilder sb;
  private int tabLevel = 0;

  // Indicates if writer is at start of line and should indent before output
  private boolean isStartOfLine = true;

  /**
   * Creates an empty source writer.
   */
  public SourceWriter() {
    sb = new StringBuilder();
  }

  public void indent() {
    tabLevel++;
  }

  public void outdent() {
    Preconditions.checkState(tabLevel > 0);
    tabLevel--;
  }

  /**
   * Writes a line of text with indentation.
   *
   * @param str text to be written
   */
  public void println(String str) {
    print(str);
    sb.append('\n');
    isStartOfLine = true;
  }

  /**
   * Prints a string.
   */
  public void print(String str) {
    if (isStartOfLine) {
      for (int i = 0; i < (tabLevel * TAB_SPACE_COUNT); ++i) {
        sb.append(' ');
      }
    }
    sb.append(str);
    isStartOfLine = false;
  }

  /**
   * Output an empty line with no indentation prefix.
   *
   * If we are not at the start of a line, it will end the current line before
   * writing out an empty line.
   */
  public void printEmptyLine() {
    if (!isStartOfLine) {
      sb.append("\n\n");
      isStartOfLine = true;
    } else {
      sb.append('\n');
    }
  }

  /**
   * Returns tab space count.
   */
  public int getTabSpaceCount() {

    // for now this is specified as static constant. This is an instance method instead of static
    // so that we can support future per instance tab spaces if the need arises.
    return TAB_SPACE_COUNT;
  }

  @Override public String toString() {
    return sb.toString();
  }

  /**
   * Compiles an expression to a string.
   *
   * @param expression The expression to compile
   * @return A string representation of the expression
   */
  public static String toString(Expression expression) {
    SourceWriter writer = new SourceWriter();
    expression.toCode(writer);
    return writer.toString();
  }

  /**
   * Compiles a statement to a string.
   *
   * @param statement The statement to compile
   * @return A string representation of the statement
   */
  public static String toString(Statement statement) {
    SourceWriter writer = new SourceWriter();
    statement.toCode(writer);
    return writer.toString();
  }
}
