package com.hello.uxml.tools.framework;


/**
 * Represents a rectangular area (x,y,width,height) on the coordinate space
 * specified in double precision.
 *
 * @author ferhat
 *
 */
public class Rectangle {

  /** left coordinate of rectangle */
  public double x;

  /** top coordinate of rectangle */
  public double y;

  /** width of rectangle*/
  public double width;

  /** height of rectangle*/
  public double height;

  /**
   * Constructs an empty Rectangle.
   */
  public Rectangle() {
    x = 0.0;
    y = 0.0;
    width = 0.0;
    height = 0.0;
  }

  /**
   * Construct rectangle object
   */
  public Rectangle(double x, double y, double width, double height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
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

  /**
   * Returns width.
   */
  public double getWidth() {
    return width;
  }

  public void setWidth(double value) {
    width = value;
  }

  /**
   * Returns height.
   */
  public double getHeight() {
    return height;
  }

  public void setHeight(double value) {
    height = value;
  }


  /**
   * Returns left coordinate of rectangle.
   */
  public double getLeft() {
    return x;
  }

  /**
   * Returns top coordinate of rectangle.
   */
  public double getTop() {
    return y;
  }

  /**
   * Returns right coordinate of rectangle.
   */
  public double getRight() {
    return x + width;
  }

  /**
   * Returns bottom coordinate of rectangle.
   */
  public double getBottom() {
    return y + height;
  }

  /**
   * Returns whether the (x,y) coordinate is within the bounds of rectangle.
   */
  public boolean contains(double px, double py) {
    return (px >= x) && (py >= y) && (px < (x + width)) && (py < (y + height));
  }

  /**
   * Returns whether the point is within the bounds of rectangle.
   */
  public boolean contains(Point p) {
    return (p.getX() >= x) && (p.getY() >= y) && (p.getX() < (x + width))
        && (p.getY() < (y + height));
  }

  /**
   * Add the two rectangles. The result is the union of both rectangles.
   */
  public void add(Rectangle r) {
   if (r.x < x) {
     width += x - r.x;
     x = r.x;
   }
   if (r.y < y) {
     height += y - r.y;
     y = r.y;
   }
   if (r.getRight() > getRight()) {
     width = r.getRight() - x;
   }
   if (r.getBottom() > getBottom()) {
     height = r.getBottom() - y;
   }
  }

  /**
   * Grow rectangle to include point p.
   */
  public void add(Point p) {
    if (p.getX() < x) {
      width += x - p.getX();
      x = p.getX();
    }
    if (p.getY() < y) {
      height += y - p.getY();
      y = p.getY();
    }
    if (p.getX() > getRight()) {
      width = p.getX() - x;
    }
    if (p.getY() > getBottom()) {
      height = p.getY() - y;
    }
   }

  @Override
  public int hashCode() {
    return (int) (x + (y * 0xFFFF0000) + (width * 0xFF) + (height * 0xFF00));
  }

  @Override
  public boolean equals(Object value) {
    if ((value == null) || (!(value instanceof Rectangle))) {
      return false;
    }
    Rectangle rectValue = (Rectangle) value;
    return (rectValue.x == x) && (rectValue.y == y) && (rectValue.width == width)
        && (rectValue.height == height);
  }
}
