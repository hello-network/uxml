package com.hello.uxml.tools.framework.graphics;

/**
 * Holds GlowShadow graphics filter parameters.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class GlowFilter extends Filter{
  private int quality;
  private double alpha;
  private double blurX;
  private double blurY;
  private double strength;
  private Color color;
  private boolean knockout;
  private boolean inner;

  public GlowFilter() {
    this(1.0, 6.0, 6.0, Color.fromRGB(0xFF0000), 1, false, 2, false);
  }

  /**
   * Constructor.
   */
  public GlowFilter(double alpha, double blurX, double blurY, Color color,
      int quality, boolean inner, double strength, boolean knockout) {
    this.alpha = alpha;
    this.blurX = blurX;
    this.blurY = blurY;
    this.color = color;
    this.quality = quality;
    this.strength = strength;
    this.knockout = knockout;
    this.inner = inner;
  }

  /**
   * Sets/returns glow quality.
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
   * Sets/returns glow distance.
   */
  public Color getColor() {
    return color;
  }

  public void setColor(Color value) {
    color = value;
  }

  /**
   * Returns opacity.
   */
  public double getAlpha() {
    return alpha;
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
   * Sets/returns if filter is innerglow.
   */
  public boolean getInner() {
    return inner;
  }

  public void setInner(boolean value) {
    inner = value;
  }
}
