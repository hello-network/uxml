package com.hello.uxml.tools.framework;

/**
 * Represents a location (x,y) on the coordinate space specified in double
 * precision.
 *
 * @author ferhat
 *
 */
public class Point {

  /** x coordinate of point */
  public double x;
  /** y coordinate of point */
  public double y;

  /**
   * Constructs a point object at (0,0)
   */
  public Point() {
    x = 0.0;
    y = 0.0;
  }

  /**
   * Constructs a point object
   */
  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  /**
   * Returns x coordinate of point
   */
  public double getX() {
    return x;
  }

  public void setX(double value) {
    x = value;
  }

  /**
   * Returns y coordinate of point
   */
  public double getY() {
    return y;
  }

  public void setY(double value) {
    y = value;
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Point)) {
      return false;
    }
    Point p = (Point) obj;
    return (p.x == x) && (p.y == y);
  }

  @Override
  public int hashCode() {
    return super.hashCode();
  }

  @Override
  public String toString() {
    // Not using String.format due to GWT
    StringBuilder sb = new StringBuilder();
    sb.append("Point(");
    sb.append(x);
    sb.append(",");
    sb.append(y);
    sb.append(")");
    return sb.toString();
  }
}
