package com.hello.uxml.tools.framework.graphics;

/**
 * Represents a Brush with a single solid color.
 *
 * @author ferhat
 */
public class SolidBrush extends Brush {

  /** brush color */
  private Color color;

  /**
   * Constructor.
   */
  public SolidBrush() {
    this.color = Color.EMPTY;
  }

  /**
   * Constructor.
   */
  public SolidBrush(Color color) {
    this.color = color;
  }

  /**
   * Returns brush color.
   */
  public Color getColor() {
    return color;
  }

  public void setColor(Color value) {
    color = value;
  }
}
