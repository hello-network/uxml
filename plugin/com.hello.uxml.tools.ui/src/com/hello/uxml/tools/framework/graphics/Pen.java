package com.hello.uxml.tools.framework.graphics;

/**
 * Represents attributes of a line drawing.
 *
 * @author ferhat
 */
public class Pen {
  /** Thickness of pen */
  protected double thickness = 1.0;
  private String id;

  /**
   * Constructs a pen of 0 thickness.
   */
  public Pen() {
  }

  /**
   * Constructor
   */
  public Pen(double thickness) {
    this.thickness = thickness;
  }

  /**
   * Sets/returns thickness of pen
   */
  public void setThickness(double value) {
    thickness = value;
  }

  public double getThickness() {
    return thickness;
  }

  /**
   * Sets/returns id of element
   */
  public String getId() {
    return id;
  }

  public void setId(String value) {
    id = value;
  }
}
