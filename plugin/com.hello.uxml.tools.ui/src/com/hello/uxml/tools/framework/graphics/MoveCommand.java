package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Implements a MoveTo path drawing command
 *
 * @author ferhat
 */
public class MoveCommand extends PathCommand{

  /** Move to coordinate */
  private Point point;

  /**
   * Constructor.
   */
  public MoveCommand(Point point) {
    this.point = point;
  }

  /**
   * Returns move location
   */
  public Point getPoint() {
    return point;
  }

  /**
   * Returns bounds of command.
   */
  @Override
  protected Rectangle getBounds(Point startPoint) {
    return new Rectangle(point.getX(), point.getY(), 0, 0);
  }

  /**
   * Returns end point of path after command.
   */
  @Override
  protected Point getEndPoint(Point startPoint) {
    return point;
  }

  /**
   * Sends moveto command to surface.
   */
  @Override
  public void replay(IPathReplay replayTarget) {
    replayTarget.moveTo(point);
  }
}
