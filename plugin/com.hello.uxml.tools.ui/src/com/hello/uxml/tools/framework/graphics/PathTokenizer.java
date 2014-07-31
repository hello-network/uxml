package com.hello.uxml.tools.framework.graphics;

import java.text.ParseException;

/**
 * Tokenizes a SVG path string.
 *
 * @author ferhat@
 */
class PathTokenizer {
  /**
   * Token type for End of File.
   */
  public static final int TT_EOF = 3;
  /**
   * Token type for Number.
   */
  public static final int TT_NUMBER = 2;
  /**
   * Token type for path command
   */
  public static final int TT_CMD = 1;

  /**
   * path command if token type is TT_CMD.
   */
  public String commandVal;

  /**
   * number value if token type is TT_NUMBER
   */
  public double numberVal;

  /**
   * current character position.
   */
  private int pos;

  /**
   * Path string.
   */
  private String data;

  /** Length of path data */
  private int dataLen;

  public PathTokenizer(String data) {
    this.data = data;
    dataLen = data.length();
  }

  public int nextToken() throws ParseException {
    StringBuffer sb = new StringBuffer();
    while (pos < dataLen) {
      int ch = data.charAt(pos);
      ++pos;
      if (Character.isLetter((char) ch)) {
        if (sb.length() != 0) {
          --pos;
          numberVal = Double.parseDouble(sb.toString());
          return TT_NUMBER;
        }
        commandVal = String.valueOf((char) ch);
        return TT_CMD;
      } else if (isWhitespace(ch) && sb.length() != 0) {
        numberVal = Double.parseDouble(sb.toString());
        return TT_NUMBER;
      } else if (ch == ',') {
        if (sb.length() == 0) {
          throw new ParseException(data, 0);
        } else {
          numberVal = Double.parseDouble(sb.toString());
          return TT_NUMBER;
        }
      } else if (ch == '-') {
        if (sb.length() != 0) {
          --pos;
          numberVal = Double.parseDouble(sb.toString());
          return TT_NUMBER;
        }
      }
      if (!isWhitespace(ch)) {
        sb.append((char) ch);
      }
    }
    if (sb.length() != 0) {
      numberVal = Double.parseDouble(sb.toString());
      return TT_NUMBER;
    }
    return TT_EOF;
  }

  public int lookAhead() {
    int loc = pos;
    if (loc >= dataLen) {
      return TT_EOF;
    }
    int ch;
    do {
      ch = data.charAt(loc);
      ++loc;
    } while (isWhitespace(ch) && (loc < dataLen));
    if (isWhitespace(ch) && (loc == dataLen)) {
      return TT_EOF;
    }
    if ((ch == '-') || Character.isDigit((char) ch) || (ch == '.')) {
      return TT_NUMBER;
    }
    return TT_CMD;
  }

  private boolean isWhitespace(int ch) {
    return (ch == ' ') || (ch == '\t');
  }
}
