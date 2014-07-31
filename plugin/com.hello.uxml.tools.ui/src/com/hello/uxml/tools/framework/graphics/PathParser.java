package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Point;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

/**
 * Parses a SVG path.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class PathParser {

  /**
   * Constructor.
   */
  public PathParser() {
  }

  private static final String PARSE_ERROR_MSG_NUMBER =
      "Invalid path format, expecting number";
  private static final String PARSE_ERROR_MSG_CMD =
      "Unrecognized command";
  private static final String PARSE_ERROR_MSG_NO_PREV_CP =
      "Missing prior control point for inflection";

  /** Tokenizer for path */
  private PathTokenizer tokenizer;

  /**
   * Parses path and returns list of PathCommands.
   */
  public List<PathCommand> parse(String data) throws ParseException {

    // ! For better performance this has not been re-factored.
    // Tokenize path and build PathCommand objects
    List<PathCommand> commands = new ArrayList<PathCommand>();

    tokenizer = new PathTokenizer(data);
    int token;
    // Point
    Point pt;
    Point controlPoint1;
    Point controlPoint2;
    Point lastControlPoint = new Point(0, 0);
    Point curPoint = new Point(0, 0);
    Boolean prevControlPointValid = false;
    do {
      token = tokenizer.nextToken();
      if (token == PathTokenizer.TT_CMD) {
        String cmd = tokenizer.commandVal.toLowerCase();
        boolean isRelative = cmd.equals(tokenizer.commandVal);
        switch (cmd.charAt(0)) {
          case 'm': // moveto
            pt = readPoint();
            if (isRelative) {
              pt.x += curPoint.x;
              pt.y += curPoint.y;
            }
            commands.add(new MoveCommand(pt));
            curPoint = pt;
            break;
          case 'l': // lineto
            do {
              pt = readPoint();
              if (isRelative) {
                pt.x += curPoint.x;
                pt.y += curPoint.y;
              }
              commands.add(new LineCommand(pt));
              curPoint = pt;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 'v': // vertical line
            do {
              token = tokenizer.nextToken();
              if (token != PathTokenizer.TT_NUMBER) {
                throw new ParseException(PARSE_ERROR_MSG_NUMBER, 0);
              }
              pt = new Point(curPoint.x, isRelative
                  ? (curPoint.y + tokenizer.numberVal)
                  : tokenizer.numberVal);
              commands.add(new LineCommand(pt));
              curPoint = pt;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 'h': // horizontal line
            do {
              token = tokenizer.nextToken();
              if (token != PathTokenizer.TT_NUMBER) {
                throw new ParseException(PARSE_ERROR_MSG_NUMBER, 0);
              }
              pt = new Point(isRelative ? (curPoint.x + tokenizer.numberVal)
                  : tokenizer.numberVal, curPoint.y);
              commands.add(new LineCommand(pt));
              curPoint = pt;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 'q': // quadratic bezier
            do {
              controlPoint1 = readPoint();
              pt = readPoint();
              if (isRelative) {
                controlPoint1.x += curPoint.x;
                controlPoint1.y += curPoint.y;
                pt.x += curPoint.x;
                pt.y += curPoint.y;
              }
              commands.add(new QuadraticBezierCommand(controlPoint1, pt));
              curPoint = pt;
              lastControlPoint = controlPoint1;
              prevControlPointValid = true;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 't':
            do {
              if (prevControlPointValid == false) {
                throw new ParseException(PARSE_ERROR_MSG_NO_PREV_CP, 0);
              }
              controlPoint1 = new Point((2 * curPoint.x) - lastControlPoint.x,
                  (2 * curPoint.y) - lastControlPoint.y);
              pt = readPoint();
              if (isRelative) {
                pt.x += curPoint.x;
                pt.y += curPoint.y;
              }
              commands.add(new QuadraticBezierCommand(controlPoint1, pt));
              curPoint = pt;
              lastControlPoint = controlPoint1;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 'c': // cubic bezier
            do {
              controlPoint1 = readPoint();
              controlPoint2 = readPoint();
              pt = readPoint();
              if (isRelative) {
                controlPoint1.x += curPoint.x;
                controlPoint1.y += curPoint.y;
                controlPoint2.x += curPoint.x;
                controlPoint2.y += curPoint.y;
                pt.x += curPoint.x;
                pt.y += curPoint.y;
              }
              commands.add(new CubicBezierCommand(controlPoint1, controlPoint2, pt));
              curPoint = pt;
              lastControlPoint = controlPoint2;
              prevControlPointValid = true;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 's':
            do {
              if (prevControlPointValid == false) {
                throw new ParseException(PARSE_ERROR_MSG_NO_PREV_CP, 0);
              }
              controlPoint1 = new Point((2 * curPoint.x) - lastControlPoint.x,
                  (2 * curPoint.y) - lastControlPoint.y);
              controlPoint2 = readPoint();
              pt = readPoint();
              if (isRelative) {
                controlPoint2.x += curPoint.x;
                controlPoint2.y += curPoint.y;
                pt.x += curPoint.x;
                pt.y += curPoint.y;
              }
              commands.add(new CubicBezierCommand(controlPoint1, controlPoint2, pt));
              curPoint = pt;
              lastControlPoint = controlPoint2;
            } while (tokenizer.lookAhead() == PathTokenizer.TT_NUMBER);
            break;
          case 'a':
            throw new ParseException("Not implemented yet", 0);
            // TODO(ferhat):implement arc
          case 'z':
            commands.add(new CloseCommand());
            break;
          default:
            throw new ParseException(PARSE_ERROR_MSG_CMD + " '" + cmd + "'", 0);
        }
      }
    } while (token != PathTokenizer.TT_EOF);
    return commands;
  }

  /**
   * Reads two numbers from stream and returns Point object.
   */
  private Point readPoint() throws ParseException{
    int token = tokenizer.nextToken();
    if (token != PathTokenizer.TT_NUMBER) {
      throw new ParseException(PARSE_ERROR_MSG_NUMBER, 0);
    }
    double x = tokenizer.numberVal;
    token = tokenizer.nextToken();
    if (token != PathTokenizer.TT_NUMBER) {
      throw new ParseException(PARSE_ERROR_MSG_NUMBER, 0);
    }
    double y = tokenizer.numberVal;
    return new Point(x, y);
  }
}
