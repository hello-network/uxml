package com.hello.uxml.tools.framework;

/**
 * Represents immutable border radius of an element.
 *
 * @author ferhat
 *
 */
public class BorderRadius{

  private double topLeft;
  private double topRight;
  private double bottomRight;
  private double bottomLeft;

  /**
   * Empty margin object.
   */
  public static final BorderRadius EMPTY = new BorderRadius(0, 0, 0, 0);

  /**
   * Constructor.
   */
  public BorderRadius(double topLeft, double topRight, double bottomRight, double bottomLeft) {
    this.topLeft = topLeft;
    this.topRight = topRight;
    this.bottomRight = bottomRight;
    this.bottomLeft = bottomLeft;
  }

  public static BorderRadius create(double size) {
    return new BorderRadius(size, size, size, size);
  }

  /**
   * Returns top left radii.
   */
  public double getTopLeft() {
    return topLeft;
  }

  /**
   * Returns top right radii.
   */
  public double getTopRight() {
    return topRight;
  }

  /**
   * Returns bottom right radii.
   */
  public double getBottomRight() {
    return bottomRight;
  }

  /**
   * Returns bottom left radii.
   */
  public double getBottomLeft() {
    return bottomLeft;
  }

  @Override
  public String toString() {
    // Not using String.format due to GWT
    StringBuilder sb = new StringBuilder();
    sb.append(topLeft);
    sb.append(" ");
    sb.append(topRight);
    sb.append(" ");
    sb.append(bottomRight);
    sb.append(" ");
    sb.append(bottomLeft);
    return sb.toString();
  }
}
