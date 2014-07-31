part of uxml;

/**
 * Parses an SVG Path and returns an array of command objects.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class PathParser {

  static const String PARSE_ERROR_MSG_NUMBER =
      "Invalid path format, expecting number";
  static const String PARSE_ERROR_MSG_CMD =
      "Unrecognized command";
  static const String PARSE_ERROR_START_M =
      "Path should start with M,m";

  /** Tokenizer for path */
  PathTokenizer tokenizer;

  num _readX;
  num _readY;

  PathParser() {
  }

  /**
   * Parses SVG path definition.
   */
  List<PathCommand> parse(String data) {
    List<PathCommand> commands = <PathCommand>[];
    tokenizer = new PathTokenizer(data);
    int token;
    // Point
    num ptx = 0.0;
    num pty = 0.0;
    num controlPoint1X = 0.0;
    num controlPoint1Y = 0.0;
    num controlPoint2X = 0.0;
    num controlPoint2Y = 0.0;
    num lastControlPointX = 0.0;
    num lastControlPointY = 0.0;
    num curPointX = 0.0;
    num curPointY = 0.0;
    bool startOfSegment = true;
    do {
      token = tokenizer.nextToken();
      if (token == PathTokenizer.TOKENTYPE_CMD) {
        String cmd = tokenizer.command.toLowerCase();
        bool isRelative = (cmd == tokenizer.command);
        if (startOfSegment) {
          if (cmd != "m") {
            throw new ArgumentError(PARSE_ERROR_START_M);
          }
          startOfSegment = false;
        }
        switch (cmd) {
          case 'm': // moveto
            readPoint();
            ptx = _readX;
            pty = _readY;
            if (isRelative) {
              ptx += curPointX;
              pty += curPointY;
            }
            commands.add(new MoveCommand(ptx, pty));
            curPointX = ptx;
            curPointY = pty;
            lastControlPointX = ptx;
            lastControlPointY = pty;
            // If M is followed by number pairs they are treated as explicit
            // lineto commands
            while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER) {
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new LineCommand(ptx, pty));
              curPointX = ptx;
              curPointY = pty;
            }
            break;
          case 'l': // lineto
            do {
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new LineCommand(ptx, pty));
              curPointX = ptx;
              curPointY = pty;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 'v': // vertical line
            do {
              token = tokenizer.nextToken();
              if (token != PathTokenizer.TOKENTYPE_NUMBER) {
                throw new ArgumentError(PARSE_ERROR_MSG_NUMBER);
              }
              pty = isRelative ? (curPointY + tokenizer.number) :
                  tokenizer.number;
              commands.add(new LineCommand(curPointX, pty));
              curPointY = pty;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 'h': // horizontal line
            do {
              token = tokenizer.nextToken();
              if (token != PathTokenizer.TOKENTYPE_NUMBER) {
                throw new ArgumentError(PARSE_ERROR_MSG_NUMBER);
              }
              ptx = isRelative ? (curPointX + tokenizer.number) :
                  tokenizer.number;
              commands.add(new LineCommand(ptx, curPointY));
              curPointX = ptx;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 'q': // quadratic bezier
            do {
              readPoint();
              controlPoint1X = _readX;
              controlPoint1Y = _readY;
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                controlPoint1X += curPointX;
                controlPoint1Y += curPointY;
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new QuadraticBezierCommand(controlPoint1X,
                  controlPoint1Y, ptx, pty));
              curPointX = ptx;
              curPointY = pty;
              lastControlPointX = controlPoint1X;
              lastControlPointY = controlPoint1Y;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 't':
            do {
              controlPoint1X = (2 * curPointX) - lastControlPointX;
              controlPoint1Y = (2 * curPointY) - lastControlPointY;
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new QuadraticBezierCommand(controlPoint1X,
                  controlPoint1Y, ptx, pty));
              curPointX = ptx;
              curPointY = pty;
              lastControlPointX = controlPoint1X;
              lastControlPointY = controlPoint1Y;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 'c': // cubic bezier
            do {
              readPoint();
              controlPoint1X = _readX;
              controlPoint1Y = _readY;
              readPoint();
              controlPoint2X = _readX;
              controlPoint2Y = _readY;
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                controlPoint1X += curPointX;
                controlPoint1Y += curPointY;
                controlPoint2X += curPointX;
                controlPoint2Y += curPointY;
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new CubicBezierCommand(controlPoint1X,
                  controlPoint1Y, controlPoint2X, controlPoint2Y, ptx, pty));
              curPointX = ptx;
              curPointY = pty;
              lastControlPointX = controlPoint2X;
              lastControlPointY = controlPoint2Y;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 's':
            do {
              controlPoint1X = (2 * curPointX) - lastControlPointX;
              controlPoint1Y = (2 * curPointY) - lastControlPointY;
              readPoint();
              controlPoint2X = _readX;
              controlPoint2Y = _readY;
              readPoint();
              ptx = _readX;
              pty = _readY;
              if (isRelative) {
                controlPoint2X += curPointX;
                controlPoint2Y += curPointY;
                ptx += curPointX;
                pty += curPointY;
              }
              commands.add(new CubicBezierCommand(controlPoint1X,
                  controlPoint1Y, controlPoint2X, controlPoint2Y, ptx, pty));
              curPointX = ptx;
              curPointY = pty;
              lastControlPointX = controlPoint2X;
              lastControlPointY = controlPoint2Y;
            } while (tokenizer.lookAhead() == PathTokenizer.TOKENTYPE_NUMBER);
            break;
          case 'a':
            throw new ArgumentError("Not implemented yet");
            // TODO(ferhat):implement arc
          case 'z':
            commands.add(new CloseCommand());
            startOfSegment = true;
            break;
          default:
            throw new ArgumentError("$PARSE_ERROR_MSG_CMD ' $cmd '");
        }
      }
    } while (token != PathTokenizer.TOKENTYPE_EOF);
    return commands;
  }

  void readPoint() {
    int token = tokenizer.nextToken();
    if (token != PathTokenizer.TOKENTYPE_NUMBER) {
      throw new ArgumentError(PARSE_ERROR_MSG_NUMBER);
    }
    _readX = tokenizer.number;
    token = tokenizer.nextToken();
    if (token != PathTokenizer.TOKENTYPE_NUMBER) {
      throw new ArgumentError(PARSE_ERROR_MSG_NUMBER);
    }
    _readY = tokenizer.number;
  }
}

/**
 * Tokenizes path data.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class PathTokenizer {

  // Token type constants
  static const int TOKENTYPE_CMD = 1;
  static const int TOKENTYPE_NUMBER = 2;
  static const int TOKENTYPE_EOF = 3;

  String _data;

  String command;
  num number;

  /** Current parse location */
  int _pos;

  PathTokenizer(String data) {
    _data = data;
    _pos = 0;
  }

  /**
   * Reads and returns token type.
   */
  int nextToken() {
    if (_pos >= _data.length) {
      return TOKENTYPE_EOF;
    }

    String ch;
    // Skip whitespace
    do {
      ch = _data[_pos];
      ++_pos;
    } while ((isWhitespace(ch) || (ch == ',')) &&
        (_pos < _data.length));
    if (isLetter(ch)) {
      command = ch;
      return TOKENTYPE_CMD;
    } else {
      // Parse number
      int startPos = _pos - 1;
      if (_pos != _data.length) {
        do {
          ch = _data[_pos];
          ++_pos;
        } while ((_pos < _data.length) && (!isWhitespace(ch)) &&
              (!isLetter(ch)) && (ch != '-') && (ch != ','));

        if (isWhitespace(ch) || ch == ',' || isLetter(ch) ||
            (ch == '-')) {
          --_pos;
        }
      }
      if (_pos == startPos) {
        return TOKENTYPE_EOF;
      }
      number = double.parse(_data.substring(startPos, _pos));
      return TOKENTYPE_NUMBER;
    }
  }

  /** Returns token type in stream without consuming token. */
  int lookAhead() {
    int loc = _pos;
    if (loc >= _data.length) {
      return TOKENTYPE_EOF;
    }
    String ch;
    do {
      ch = _data[loc];
      ++loc;
    } while (isWhitespace(ch) && (loc < _data.length));
    if (isWhitespace(ch) && (loc == _data.length)) {
      return TOKENTYPE_EOF;
    }
    if ((ch == '-') || ((ch.compareTo('0') >= 0) && (ch.compareTo('9') <= 0)) ||
        (ch == '.')) {
      return TOKENTYPE_NUMBER;
    }
    return TOKENTYPE_CMD;
  }

  /** Returns true if character is letter. */
  bool isLetter(String character) {
    // TODO(ferhat) : Use isLetter and whitespace in frog/tokenizer.dart ,
    // compareTo perf killer.
    return (character.compareTo('A') >= 0 && character.compareTo('Z') <=0) ||
        (character.compareTo('a') >= 0 && character.compareTo('z') <=0);
  }

  /** Returns true if character is whitespace. */
  bool isWhitespace(String character) {
    return character == ' ' || character == '\t';
  }
}
