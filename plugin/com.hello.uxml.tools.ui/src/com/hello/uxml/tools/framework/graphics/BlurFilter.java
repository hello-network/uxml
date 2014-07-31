package com.hello.uxml.tools.framework.graphics;

/**
 * Holds Blur graphics filter parameters.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class BlurFilter extends Filter{
  private int quality;
  private double blurX;
  private double blurY;

  /**
   * Constructor.
   */
  public BlurFilter() {
    this(4, 4, 1);
  }

  /**
   * Constructor.
   */
  public BlurFilter(double blurX, double blurY, int quality) {
    this.blurX = blurX;
    this.blurY = blurY;
    this.quality = quality;
  }

  /**
   * Returns blur quality.
   *
   * <li>1 = normal
   * <li>2 = 2x2 4x sampling
   * <li>3 = 4x4 16x sampling
   */
  public int getQuality() {
    return quality;
  }

  /**
   * Returns blur distance.
   */
  public double getBlurX() {
    return blurX;
  }

  /**
   * Returns blur distance.
   */
  public double getBlurY() {
    return blurY;
  }
}
