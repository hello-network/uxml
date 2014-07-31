package com.hello.uxml.tools.framework.graphics;

/**
 * Represents a gradient color, offset pair.
 *
 * @author ferhat
 *
 */
public class GradientStop {

  /** Color of gradient stop */
  private Color color;

  /** Offset of gradient */
  private double offset;

  /**
   * Constructor.
   */
  public GradientStop() {
  }

  /**
   * Constructor.
   */
  public GradientStop(Color color, double offset) {
    this.color = color;
    this.offset = offset;
  }

  /**
   * Returns color.
   */
  public Color getColor() {
    return color;
  }

  public void setColor(Color value) {
    color = value;
  }

  /**
   * Returns offset of gradient stop.
   */
  public double getOffset() {
    return offset;
  }

  public void setOffset(double value) {
    offset = value;
  }
}
