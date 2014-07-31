part of uxml;

/**
 * The Path class represents an SVG Path. It contains drawing instructions
 * using moveto, lineto, curveto, etc encoded in a string. It provides a
 * parsing function to convert the drawing instructions to individual
 * path command objects.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class VecPath extends UxmlElement {

  /** Sufficiently small number */
  static final num EPSILON = 0.000000001;

  // data holds the string representation of the path
  String _content;

  /**
   * Array of PathCommand objects.
   */
  List<PathCommand> _commands;

  /** Cached bounding rectangle */
  Rect _cachedBounds;

  /** Direction of path. */
  int _direction;
  bool _directionValid = false;

  static const int DIRECTION_UNKNOWN = 0;
  static const int DIRECTION_CLOCKWISE = 1;
  static const int DIRECTION_COUNTER_CLOCKWISE = 2;

  VecPath() : super() {
    _cachedBounds = null;
    _content = null;
  }

  /**
   * Set the string representation of the Path. It is parsed into an array
   * of individual PathCommand objects based on the type of individual
   * path commands.
   */
  set content(String path) {
    _content = path;
    _commands = null;
    _cachedBounds = null;
  }

  /// Gets the string representation of the Path.
  String get content => _content;

  List<PathCommand> get commands {
    if (_commands == null) {
      if (_content != null) {
        PathParser parser = new PathParser();
        _commands = parser.parse(_content);
      } else {
        _commands = <PathCommand>[];
      }
    }
    return _commands;
  }

  /**
   * Returns direction of path as clockwise, counter-clockwise or unknown.
   */
  int get direction {
    if (_content == null) {
      return DIRECTION_UNKNOWN;
    }
    if (_directionValid == false) {
      // Calculate angle between adjacent points on the path to see if
      // >180 or less. The total count of positive cross products vs negative
      // tell us if the curve is clockwise or not. a x b = |a| |b| sin(theta)
      int count = 0;
      // Find last command with valid coordinate that forms a closed path.
      int lastCmd = 0;
      int cmdCount = commands.length;
      while (lastCmd < cmdCount) {
        PathCommand cmd = _commands[lastCmd];
        if (cmd.type == PathCommand.CLOSE_COMMAND) {
          break;
        }
        ++lastCmd;
      }
      // Check if we have at least 2 valid points.
      if (lastCmd < 1) {
        _direction = DIRECTION_UNKNOWN;
      } else {
        for (int index = 0; index < (lastCmd - 1); index++) {
          PathCommand cmd1 = _commands[index];
          PathCommand cmd2 = _commands[index + 1];
          PathCommand cmd3 = (index == (lastCmd - 2)) ? _commands[0] :
              _commands[index + 2];
          num crossVal = (cmd2.x - cmd1.x) * (cmd3.y - cmd2.y) -
              (cmd2.y - cmd1.y) * (cmd3.x - cmd2.x);
          if (crossVal > 0) {
            count++;
          } else if (crossVal < 0) {
            count--;
          }
        }
      }
      if (count > 0) {
        _direction = DIRECTION_CLOCKWISE;
      } else if (count < 0) {
        _direction = DIRECTION_COUNTER_CLOCKWISE;
      }
      _directionValid = true;
    }
    return _direction;
  }

  /**
   * Computes the bounds of the Path.
   *
   * This function is used quite a bit so param is used to return
   * bounds to reduce Rectangle allocations.
   */
  Rect getBounds() {
    if (_cachedBounds == null) {
      _cachedBounds = new Rect(0.0, 0.0, 0.0, 0.0);
      num curX = 0.0;
      num curY = 0.0;
      bool boundsInitialized = false;
      int commandCount = commands.length;
      for (int i = 0; i < commandCount; i++) {
        PathCommand command = _commands[i];
        if (command is CloseCommand) {
          continue;
        }
        if (!boundsInitialized) {
          command.getBounds(curX, curY, _cachedBounds);
          boundsInitialized = true;
        }
        else {
          command.growBounds(curX, curY, _cachedBounds);
        }
        curX = command.x;
        curY = command.y;
      }
    }
    return _cachedBounds;
  }

  /**
   * Clears all path drawing commands.
   */
  void clear() {
    if (_commands != null) {
      _commands.clear();
    }
    _cachedBounds = null;
    _directionValid = false;
  }

  /**
   * Adds a moveTo command to path.
   */
  void moveTo(num x, num y) {
    if (_commands == null) {
      _commands = <PathCommand>[];
    }
    _commands.add(new MoveCommand(x, y));
  }

  /**
   * Adds a lineTo command to path.
   */
  void lineTo(num x, num y) {
    if (_commands == null) {
      _commands = <PathCommand>[];
    }
    _commands.add(new LineCommand(x, y));
  }

  /**
   *  Calculate Quadratic bezier curve bounds.
   */
  static void calcQuadraticBezierBounds(num point1x, num point1y,
      num controlX,num controlY, num point2x, num point2y, Rect bounds) {
    // Initialize bounds rectangle
    bounds.x = min(point1x, point2x);
    bounds.y = min(point1y, point2y);
    bounds.width = (point2x - point1x).abs();
    bounds.height = (point2y - point1y).abs();
    growQuadraticBezierBounds(point1x, point1y,controlX,controlY, point2x,
        point2y, bounds);
  }

  /**
   * Grows a bounding rectangle to include quadratic curve.
   */
  static void growQuadraticBezierBounds(num point1x, num point1y,
                                        num controlX,num controlY,
                                        num point2x, num point2y, bounds) {
    bounds.add(point1x, point1y);
    bounds.add(point2x, point2y);
    _growQuadraticBezierBounds(point1x, point1y,controlX,controlY, point2x,
        point2y, bounds);
  }

  static void _growQuadraticBezierBounds(num point1x, num point1y,
      num controlX,num controlY, num point2x, num point2y, Rect bounds) {
    // The Quadratic bezier curve equation is:
    // (1-t)(1-t)P1 + 2t(1-t)PC + t*t*P2.
    // To find the bounds of the curve, we have to find extrema where
    // derivative = 0.
    // derivative dx/dt((1-2t+tt)P1X + 2tPCX-2ttPCX + ttP2X)
    // = -2P1X+2tP1X + 2PCX + 4tPCX + 2tP2X = 0
    // = -2P1X + 2PCX +2t(P1X + 2PCX + P2X) = 0
    // t = (P1X - PCX) / (P1X + 2PCX + P2X)

    num denom = (point1x + (2 * controlX) + point2x);
    if ((denom).abs() > EPSILON) {
      num t1 = (point1x - controlX) / denom;
      if ((t1 >= 0) && (t1 <= 1.0)) {
        // If we solve (x,y) for curve at t=tx , we have an extrema
        num tprime = 1.0 - t1;
        num extremaX = (tprime * tprime * point1x) +
            ((2 * t1 * tprime * controlX)) + (t1 * t1 * point2x);
        num extremaY = (tprime * tprime * point1y) +
            ((2 * t1 * tprime * controlY)) + (t1 * t1 * point2y);
        bounds.add(extremaX, extremaY);
      }
    }
    // Now calculate dy/dt = 0
    denom = (point1y + (2 * controlY) + point2y);
    if (denom.abs() > EPSILON) {
      num t2 = (point1y - controlY) / denom;
      if ((t2 >= 0) && (t2 <= 1.0)) {
        num tprime2 = 1.0 - t2;
        num extrema2X = (tprime2 * tprime2 * point1x) +
            (2 * t2 * tprime2 * controlX) + (t2 * t2 * point2x);
        num extrema2Y = (tprime2 * tprime2 * point1y) +
            (2 * t2 * tprime2 * controlY) + (t2 * t2 * point2y);
        bounds.add(extrema2X, extrema2Y);
      }
    }
  }

  /**
   * Calculate bounds of cubic bezier curve and grows the bounds to include
   * curve.
   *
   * p1 Start anchor point.
   * c1 Control point 1.
   * c2 Control point 2.
   * p2 End anchor point.
   */
  static void growCubicBezierBounds(num point1x, num point1y,
                               num c1x, num c1y, num c2x, num c2y,
                               num point2x, num point2y, Rect bounds) {
    bounds.add(point1x, point1y);
    bounds.add(point2x, point2y);
    _growCubicBezierBounds(point1x, point1y, c1x, c1y, c2x, c2y, point2x,
        point2y, bounds);
  }

  static void _growCubicBezierBounds(num p1x, num p1y,
      num c1x, num c1y, num c2x, num c2y, num p2x, num p2y, Rect bounds) {
    // We can find the bounding box by finding all points on curve where
    // monotonicity changes.

    // initialize max/min bounds based on anchor points
    num minX = min(p1x, p2x);
    num minY = min(p1y, p2y);
    num maxX = max(p1x, p2x);
    num maxY = max(p1y, p2y);

    num extremaX;
    num extremaY;
    num a,b,c;

    // Check for simple case of strong ordering before calculating extrema
    if (!(((p1x < c1x) && (c1x < c2x) && (c2x < p2x)) ||
        (((p1x > c1x) && (c1x > c2x) && (c2x > p2x))))) {

      // The extrema point is dx/dt B(t) = 0
      // The derivative of B(t) for cubic bezier is a quadratic equation with
      // multiple roots
      // B'(t) = a*t*t + b*t + c*t
      a = -p1x + (3 * (c1x - c2x)) + p2x;
      b = 2 * (p1x - (2 * c1x) + c2x);
      c = -p1x + c1x;

      // Now find roots for quadratic equation with known coefficients a,b,c
      // The roots are (-b+-sqrt(b*b-4*a*c)) / 2a
      num s = (b * b) - (4 * a * c);
      // If s is negative, we have no real roots
      if ((s >= 0.0) && (a.abs() > EPSILON)) {
        if (s == 0.0) {
          // we have only 1 root
          num t = -b / (2 * a);
          num tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaX = ((tprime * tprime * tprime) * p1x) +
                ((3 * tprime * tprime * t) * c1x) +
                ((3 * tprime * t * t) * c2x) +
                (t * t * t * p2x);
            minX = min(extremaX, minX);
            maxX = max(extremaX, maxX);
          }
        } else {
          // we have 2 roots
          s = sqrt(s);
          num t = (-b - s) / (2 * a);
          num tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaX = ((tprime * tprime * tprime) * p1x) +
                ((3 * tprime * tprime * t) * c1x) +
                ((3 * tprime * t * t) * c2x) +
                (t * t * t * p2x);
            minX = min(extremaX, minX);
            maxX = max(extremaX, maxX);
          }
          // check 2nd root
          t = (-b + s) / (2 * a);
          tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaX = ((tprime * tprime * tprime) * p1x) +
                ((3 * tprime * tprime * t) * c1x) +
                ((3 * tprime * t * t) * c2x) +
                (t * t * t * p2x);

            minX = min(extremaX, minX);
            maxX = max(extremaX, maxX);
          }
        }
      }
    }

    // Now calc extremes for dy/dt = 0 just like above
    if (!(((p1y < c1y) && (c1y < c2y) && (c2y < p2y)) ||
        (((p1y > c1y) && (c1y > c2y) && (c2y > p2y))))) {

      // The extrema point is dy/dt B(t) = 0
      // The derivative of B(t) for cubic bezier is a quadratic equation with
      // multiple roots
      // B'(t) = a*t*t + b*t + c*t
      a = -p1y + (3 * (c1y - c2y)) + p2y;
      b = 2 * (p1y - (2 * c1y) + c2y);
      c = -p1y + c1y;

      // Now find roots for quadratic equation with known coefficients a,b,c
      // The roots are (-b+-sqrt(b*b-4*a*c)) / 2a
      num s = (b * b) - (4 * a * c);
      // If s is negative, we have no real roots
      if ((s >= 0.0) && (a.abs() > EPSILON)) {
        if (s == 0.0) {
          // we have only 1 root
          num t = -b / (2 * a);
          num tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaY = ((tprime * tprime * tprime) * p1y) +
                ((3 * tprime * tprime * t) * c1y) +
                ((3 * tprime * t * t) * c2y) +
                (t * t * t * p2y);
            minY = min(extremaY, minY);
            maxY = max(extremaY, maxY);
          }
        } else {

          // we have 2 roots
          s = sqrt(s);
          num t = (-b - s) / (2 * a);
          num tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaY = ((tprime * tprime * tprime) * p1y) +
                ((3 * tprime * tprime * t) * c1y) +
                ((3 * tprime * t * t) * c2y) +
                (t * t * t * p2y);
            minY = min(extremaY, minY);
            maxY = max(extremaY, maxY);
          }
          // check 2nd root
          t = (-b + s) / (2 * a);
          tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            extremaY = ((tprime * tprime * tprime) * p1y) +
                ((3 * tprime * tprime * t) * c1y) +
                ((3 * tprime * t * t) * c2y) +
                (t * t * t * p2y);
            minY = min(extremaY, minY);
            maxY = max(extremaY, maxY);
          }
        }
      }
    }
    bounds.add(minX, minY);
    bounds.add(maxX, maxY);
  }
}
