package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;

/**
 * Defines interface for replaying path commands.
 *
 * @author ferhat
 *
 */
public interface IPathReplay {

  /**
   * Moves to point.
   */
  void moveTo(Point p);

  /**
   * Creates line to point.
   */
  void lineTo(Point p);

  /**
   * Quadratic curve to point.
   */
  void curveTo(Point c, Point p);

  /**
   * Cubic curve to point
   */
  void curveTo(Point c1, Point c2, Point p);

  /**
   * Arc to point.
   */
  void arcTo(Point point, Point radius, double startAngle, double arcAngle);
}
