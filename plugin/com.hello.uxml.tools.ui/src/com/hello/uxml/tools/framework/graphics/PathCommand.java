package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Implements base class for path instructions.
 *
 * @author ferhat
 */
public abstract class PathCommand {

  /**
   * Returns bounds of a drawing command given the reference point.
   */
  abstract Rectangle getBounds(Point curPoint);

  /**
   * Returns end point of a drawing command given the reference point.
   */
  abstract Point getEndPoint(Point curPoint);

  /**
   * Sends command to IPathReplay for device dependent rendering.
   */
  abstract void replay(IPathReplay replayTarget);
}
