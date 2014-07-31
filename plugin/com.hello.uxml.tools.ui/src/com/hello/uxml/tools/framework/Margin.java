package com.hello.uxml.tools.framework;

/**
 * Represents immutable element margins.
 *
 * @author ferhat
 *
 */
public class Margin{

  private double left;
  private double top;
  private double right;
  private double bottom;

  /**
   * Empty margin object.
   */
  public static final Margin EMPTY = new Margin(0, 0, 0, 0);

  /**
   * Constructor.
   */
  public Margin(double left, double top, double right, double bottom) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  /**
   * Returns left margin.
   */
  public double getLeft() {
    return left;
  }

  /**
   * Returns top margin.
   */
  public double getTop() {
    return top;
  }

  /**
   * Returns right margin.
   */
  public double getRight() {
    return right;
  }

  /**
   * Returns bottom margin.
   */
  public double getBottom() {
    return bottom;
  }

  /**
   * Returns total left+right margin
   */
  public double getWidth() {
    return left + right;
  }

  /**
   * Returns total top+bottom margin
   */
  public double getHeight() {
    return top + bottom;
  }

  @Override
  public String toString() {
    // Not using String.format due to GWT
    StringBuilder sb = new StringBuilder();
    sb.append("Margin(");
    sb.append(left);
    sb.append(",");
    sb.append(top);
    sb.append(",");
    sb.append(right);
    sb.append(",");
    sb.append(bottom);
    sb.append(")");
    return sb.toString();
  }
}
