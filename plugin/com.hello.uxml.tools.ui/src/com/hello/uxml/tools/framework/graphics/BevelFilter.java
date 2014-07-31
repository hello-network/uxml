package com.hello.uxml.tools.framework.graphics;

/**
 * Holds Bevel graphics filter parameters.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class BevelFilter extends Filter {
  private int quality;
  private double angle;
  private double blurX;
  private double blurY;
  private double distance;
  private double strength;
  private boolean knockout;
  private Color highlightColor;
  private Color shadowColor;
  private String bevelType;

  public BevelFilter() {
    this(45, 4, 4, 4, 1, Color.fromRGB(0xFFFFFF), Color.fromRGB(0x0), "inner");
  }

  /**
   * Constructor.
   */
  public BevelFilter(double angle, double blurX, double blurY, double distance,
      int quality, Color highlightColor, Color shadowColor, String bevelType) {
    this.highlightColor = highlightColor;
    this.shadowColor = shadowColor;
    this.blurX = blurX;
    this.blurY = blurY;
    this.distance = distance;
    this.quality = quality;
    this.bevelType = bevelType;
  }

  /**
   * Sets/returns blur quality.
   *
   * <li>1 = normal
   * <li>2 = 2x2 4x sampling
   * <li>3 = 4x4 16x sampling
   */
  public int getQuality() {
    return quality;
  }

  public void setQuality(int value) {
    quality = value;
  }

  /**
   * Sets/returns blur distance.
   */
  public double getBlurX() {
    return blurX;
  }

  public void setBlurX(double value) {
    blurX = value;
  }

  /**
   * Sets/returns blur distance.
   */
  public double getBlurY() {
    return blurY;
  }

  public void setBlurY(double value) {
    blurY = value;
  }

  /**
   * Returns shadow distance.
   */
  public double getDistance() {
    return distance;
  }

  public void setDistance(double value) {
    distance = value;
  }

  /**
   * Sets/returns angle.
   */
  public double getAngle() {
    return angle;
  }

  public void setAngle(double value) {
    angle = value;
  }

  /**
   * Sets/returns highlight color.
   */
  public Color getHighlightColor() {
    return highlightColor;
  }

  public void setHighlightColor(Color value) {
    highlightColor = value;
  }

  /**
   * Sets/returns highlight color.
   */
  public Color getShadowColor() {
    return shadowColor;
  }

  public void setShadowColor(Color value) {
    shadowColor = value;
  }


  /**
   * Sets/returns strength.
   */
  public double getStrength() {
    return strength;
  }

  public void setStrength(double value) {
    strength = value;
  }

  /**
   * Sets/returns knockout.
   */
  public boolean getKnockout() {
    return knockout;
  }

  public void setKnockout(boolean value) {
    knockout = value;
  }

  /**
   * Sets/returns bevel type.
   */
  public String getType() {
    return bevelType;
  }

  public void setType(String value) {
    bevelType = value;
  }
}
