package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.UIElement;

/**
 * Returns results of hit testing a UISurface
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class HitTestResult {

  private UIElement target;
  private double x;
  private double y;

  /**
   * Constructor.
   */
  public HitTestResult() {
  }

  /**
   * Gets or sets hit test target. null if no item was found during hit test.
   */
  public void setTarget(UIElement target) {
    this.target = target;
  }

  public UIElement getTarget() {
    return target;
  }

  /**
   * Gets or sets mouse position relative to target.
   */
  public double getX() {
    return x;
  }

  public void setX(double x) {
    this.x = x;
  }

  /**
   * Gets or sets mouse position relative to target.
   */
  public double getY() {
    return y;
  }

  public void setY(double y) {
    this.y = y;
  }
}
