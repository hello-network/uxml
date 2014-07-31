package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.graphics.utils.CurveUtil;

/**
 * Implements quadratic bezier curve.
 *
 * @author ferhat
 */
public class QuadraticBezierCommand extends PathCommand {

  /** Curve control point. */
  private Point control;

  /** Curve end point. */
  private Point anchor;

  /**
   * Constructor
   */
  public QuadraticBezierCommand(Point control, Point anchor) {
    this.control = control;
    this.anchor = anchor;
  }

  /**
   * Returns control point of curve.
   */
  public Point getControlPoint() {
    return control;
  }

  public void setControlPoint(Point value) {
    control = value;
  }

  /**
   * Returns end point of curve
   */
  public Point getAnchor() {
    return anchor;
  }

  public void setAnchor(Point value) {
    anchor = value;
  }

  /**
   * Returns bounds of command.
   */
  @Override
  protected Rectangle getBounds(Point startPoint) {
    return CurveUtil.calcBezierBounds(startPoint, control, anchor);
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
    replayTarget.curveTo(control, anchor);
  }
}
