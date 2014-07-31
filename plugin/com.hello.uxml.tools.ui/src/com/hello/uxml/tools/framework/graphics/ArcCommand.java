package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Implements an arc path drawing command
 *
 * @author ferhat
 */
public class ArcCommand extends PathCommand{

  /** ArcTo coordinate */
  private Point point;

  /** Radius of arc */
  private Point radius;

  /** arc start angle */
  private double startAngle;

  /** arc sweep angle */
  private double sweep;

  /**
   * Constructor
   *
   * @param point anchor point of arc
   * @param radius radii of arc
   * @param startAngle starting arc angle in radians
   * @param sweep sweep of arc angle
   */
  public ArcCommand(Point point, Point radius, double startAngle, double sweep) {
    this.point = point;
    this.radius = radius;
    this.startAngle = startAngle;
    this.sweep = sweep;
  }

  /**
   * Returns arc anchor position.
   */
  public Point getPoint() {
    return point;
  }

  /**
   * Returns radius of arc.
   */
  public Point getRadius() {
    return radius;
  }

  /**
   * Returns arc start angle.
   */
  public double getStartAngle() {
    return startAngle;
  }

  /**
   * Returns sweep of arc.
   */
  public double getSweep() {
    return sweep;
  }

  /**
   * Returns end point.
   */
  @Override
  protected Point getEndPoint(Point startPoint) {
    return point;
  }

  /**
   * Returns bounds of arc.
   */
  @Override
  protected Rectangle getBounds(Point startPoint) {
    return new Rectangle(Math.min(point.getX(), startPoint.getX()),
        Math.min(point.getY(), startPoint.getY()),
        Math.abs(point.getX() - startPoint.getX()),
        Math.abs(point.getY() - startPoint.getY()));
  }

  @Override
  public void replay(IPathReplay replayTarget) {
    replayTarget.arcTo(point, radius, startAngle, sweep);
  }
}
