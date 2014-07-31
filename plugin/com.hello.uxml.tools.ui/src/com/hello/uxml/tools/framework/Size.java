package com.hello.uxml.tools.framework;

/**
 * Represents extents in coordinate space specified in double precision.
 *
 * @author ferhat
 *
 */
public class Size {

  /** width of extent*/
  public double width;

  /** y coordinate of point */
  public double height;

  /**
   * Constructs a size object at (0,0).
   */
  public Size() {
    width = 0.0;
    height = 0.0;
  }

  /**
   * Constructs a size object.
   */
  public Size(double width, double height) {
    this.width = width;
    this.height = height;
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

  /** Clones size */
  @Override
  public Size clone() {
    return new Size(width, height);
  }

  @Override
  public boolean equals(Object o) {
    if ((o == null) || (!(o instanceof Size))) {
      return false;
    }
    Size s = (Size) o;
    return (s.width == width) && (s.height == height);
  }

  @Override
  public int hashCode() {
    // TODO(ferhat)
    return super.hashCode();
  }
}
