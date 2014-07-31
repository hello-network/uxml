package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.graphics.utils.CurveUtil;

/**
 * Implements quadratic bezier curve.
 *
 * @author ferhat
 */
public class CubicBezierCommand extends PathCommand {

  /** Curve control point1. */
  private Point control1;

  /** Curve control point2. */
  private Point control2;

  /** Curve end point. */
  private Point anchor;

  /**
   * Constructor
   */
  public CubicBezierCommand(Point control1, Point control2, Point anchor) {
    this.control1 = control1;
    this.control2 = control2;
    this.anchor = anchor;
  }

  /**
   * Returns first control point of curve.
   */
  public Point getControlPoint1() {
    return this.control1;
  }

  /**
   * Returns second control point of curve.
   */
  public Point getControlPoint2() {
    return this.control2;
  }

  /**
   * Returns end point of curve
   */
  public Point getAnchor() {
    return this.anchor;
  }

  @Override
  protected Rectangle getBounds(Point startPoint) {
    return CurveUtil.calcBezierBounds(startPoint, control1, control2, anchor);
  }

  /**
   * Returns end point of path after command.
   */
  @Override
  protected Point getEndPoint(Point startPoint) {
    return anchor;
  }

  /**
   * Sends curve command to surface.
   */
  @Override
  public void replay(IPathReplay replayTarget) {
    replayTarget.curveTo(control1, control2, anchor);
  }
}
