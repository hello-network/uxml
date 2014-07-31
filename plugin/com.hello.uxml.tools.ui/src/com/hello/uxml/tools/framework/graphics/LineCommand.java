package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Implements a LineTo path drawing command
 *
 * @author ferhat
 */
public class LineCommand extends PathCommand{

  /** Target coordinate */
  private Point point;

  /**
   * Constructor.
   */
  public LineCommand(Point point) {
    this.point = point;
  }

  /**
   * Returns line target location.
   */
  public Point getPoint() {
    return point;
  }

  /**
   * Returns bounds of line.
   */
  @Override
  public Rectangle getBounds(Point startPoint) {
    return new Rectangle(Math.min(point.getX(), startPoint.getX()),
        Math.min(point.getY(), startPoint.getY()),
        Math.abs(point.getX() - startPoint.getX()),
        Math.abs(point.getY() - startPoint.getY()));
  }

  /**
   * Returns end point of path after command.
   */
  @Override
  protected Point getEndPoint(Point startPoint) {
    return point;
  }

  /**
   * Sends lineto command to surface.
   */
  @Override
  public void replay(IPathReplay replayTarget) {
    replayTarget.lineTo(point);
  }
}
