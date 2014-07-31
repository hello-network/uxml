package com.hello.uxml.tools.codegen;

import com.google.common.base.Strings;

/**
 * Description of an hts compiler error.
 *
 * <p>When an error or exception occurs during compilation, instead of stopping
 * compilation, these errors are logged and returned to eclipse plugin.
 *
 * @author ferhat
 */
public class CompilerError {

  /** Constant used by toString */
  private static final String NO_DESCRIPTION_AVAIL = "No description available";

  /** Line number where error occurred or 0 for not initialized */
  private final int line;

  /** Column number where error occurred */
  private final int column;

  /** Description of error */
  private final String description;

  /** Holds the exception that caused this error */
  private final Exception exception;

  private Severity severity = Severity.CRITICAL;

  /**
   * Holds path to source.
   */
  private String sourcePath;

  /**
   * Creates compiler error from description.
   */
  public CompilerError(int line, int column, String description) {
    this(line, column, description, null);
  }

  /**
   * Creates compiler error from exception.
   */
  public CompilerError(int line, int column, Exception exception) {
    this(line, column, "", exception);
  }

  /**
   * Creates compiler error from description and exception.
   */
  public CompilerError(int line, int column, String description, Exception exception) {
    this.line = line;
    this.column = column;
    this.description = description;
    this.exception = exception;
  }

  /**
   * Creates compiler error from description.
   */
  public CompilerError(String description) {
    this(0, 0, description);
  }

  /**
   * Creates compiler error from description and exception.
   */
  public CompilerError(String description, Exception exception) {
    this(0, 0, description, exception);
  }

  /**
   * Creates compiler error from exception.
   */
  public CompilerError(Exception exception) {
    this(0, 0, exception);
  }

  public int getColumn() {
    return column;
  }

  public int getLine() {
    return line;
  }

  public String getDescription() {
    return description;
  }

  public Exception getException() {
    return exception;
  }

  @Override public String toString() {
    StringBuilder sb = new StringBuilder();
    if (!Strings.isNullOrEmpty(sourcePath)) {
      sb.append(sourcePath);
      sb.append(": ");
    }
    if ((line != 0) || (column != 0)) {
      sb.append(String.format("%d, %d : ", line, column));
    }
    sb.append(String.format("%s%s", description == null ? NO_DESCRIPTION_AVAIL : description,
        exception == null ? "" : " : " + exception.toString()));
    return sb.toString();
  }

  public void setSource(String path) {
    sourcePath = path;
  }

  public void setSeverity(Severity value) {
    severity = value;
  }

  public Severity getSeverity() {
    return severity;
  }
}
