package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Represents a close path command.
 *
 * @author ferhat
 */
public class CloseCommand extends PathCommand {

  /**
   * Returns bounds of command.
   */
  @Override
  protected Rectangle getBounds(Point startPoint) {
    return new Rectangle(startPoint.getX(), startPoint.getY(), 0, 0);
  }

  /**
   * Returns end point of path after command.
   */
  @Override
  protected Point getEndPoint(Point startPoint) {
    return startPoint;
  }

  @Override
  public void replay(IPathReplay replayTarget) {
  }
}
