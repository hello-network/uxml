part of uxml;

/**
 * The base class of a path command.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 * @author sanjayc@ (Sanjay Chouksey)
 */
class PathCommand {
  final int type;
  static const int MOVE_COMMAND = 1;
  static const int LINETO_COMMAND = 2;
  static const int CLOSE_COMMAND = 3;
  static const int CUBIC_CURVE_COMMAND = 4;
  static const int QUAD_CURVE_COMMAND = 5;

  /**
   * Sets/returns the coordinate position of the pen.
   */
  num x;
  num y;

  /**
   * Constructor
   * @param point The position of the pen in the current coordinate system.
   */
  PathCommand(this.type) {
  }

  /**
   * Returns bounds of a drawing command given the reference point.
   */
  void getBounds(num px, num py, Rect bounds) {
    bounds.x = px;
    bounds.y = py;
    bounds.width = 0.0;
    bounds.height = 0.0;
  }

  /**
   * Grows the bounds of the Rect to include part of path traversed by
   * command.
   */
  void growBounds(num px, num py, Rect bounds) {
  }
}

/**
 * Path moveTo coordinate command.
 */
class MoveCommand extends PathCommand {
  MoveCommand(num mx, num my) : super(PathCommand.MOVE_COMMAND) {
    x = mx;
    y = my;
  }

  void getBounds(num px, num py, Rect bounds) {
    bounds.x = x;
    bounds.y = y;
    bounds.width = 0.0;
    bounds.height = 0.0;
  }

  void growBounds(num px, num py, Rect bounds) {
    bounds.add(x, y);
  }
}

/**
 * Path lineTo coordinate command.
 */
class LineCommand extends PathCommand {
  LineCommand(num lx, num ly) : super(PathCommand.LINETO_COMMAND) {
    x = lx;
    y = ly;
  }

  void growBounds(num px, num py, Rect bounds) {
    bounds.add(x, y);
  }
}

/**
 * Command to close path.
 */
class CloseCommand extends PathCommand {
  CloseCommand() : super(PathCommand.CLOSE_COMMAND) {
    x = 0.0;
    y = 0.0;
  }

  void growBounds(num px, num py, Rect bounds) {
  }
}

/**
 * Defines command to draw cubic bezier curve.
 */
class CubicBezierCommand extends PathCommand {
  num controlPoint1X;
  num controlPoint1Y;
  num controlPoint2X;
  num controlPoint2Y;
  CubicBezierCommand(num control1X,
                     num control1Y,
                     num control2X,
                     num control2Y,
                     num anchorX,
                     num anchorY) : super(PathCommand.CUBIC_CURVE_COMMAND) {
    x = anchorX;
    y = anchorY;
    controlPoint1X = control1X;
    controlPoint1Y = control1Y;
    controlPoint2X = control2X;
    controlPoint2Y = control2Y;
  }

  void growBounds(num px, num py, Rect bounds) {
    VecPath.growCubicBezierBounds(px, py, controlPoint1X, controlPoint1Y,
        controlPoint2X, controlPoint2Y, x, y, bounds);
  }
}

/**
 * Defines command to draw quadratic bezier curve.
 */
class QuadraticBezierCommand extends PathCommand {
  num controlPointX;
  num controlPointY;
  QuadraticBezierCommand(num controlX,
                         num controlY,
                         num anchorX,
                         num anchorY) : super(PathCommand.QUAD_CURVE_COMMAND) {
    x = anchorX;
    y = anchorY;
    controlPointX = controlX;
    controlPointY = controlY;
  }

  void growBounds(num px, num py, Rect bounds) {
    VecPath.growQuadraticBezierBounds(px, py, controlPointX, controlPointY, x, y,
        bounds);
  }
}
