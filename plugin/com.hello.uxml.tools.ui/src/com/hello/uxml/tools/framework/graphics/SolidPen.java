package com.hello.uxml.tools.framework.graphics;

/**
 * Represents attributes of a line drawing.
 *
 * @author ferhat
 */
public class SolidPen extends Pen {
  /** Color of pen */
  private Color color;

  /**
   * Constructs a black pen of 1.0 thickness.
   */
  public SolidPen() {
    color = Color.fromRGB(0);
  }

  /**
   * Constructor
   */
  public SolidPen(Color color, double thickness) {
    this.color = color;
    this.thickness = thickness;
  }

  /**
   *  Sets/returns color of pen
   */
  public void setColor(Color value) {
    color = value;
  }

  public Color getColor() {
    return color;
  }
}
