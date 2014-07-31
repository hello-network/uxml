part of uxml;

/**
* Provides string utility functions.
*
* @author:ferhat@ (Ferhat Buyukkokten)
*/
class StringUtil {

  /**
   * Returns true if character is white space.
   */
  static bool isWhitespace(String character) {
    switch (character) {
      case " ":
      case "\t":
      case "\r":
      case "\n":
      case "\f":
        return true;
      default:
        return false;
    }
  }

  /**
  * Removes whitespace characters on front and back of a string.
  */
  static String trim(String str){
    return trimBack(trimFront(str));
  }

  /**
   * Removes whitespace characters from front of string.
   */
  static String trimFront(String str) {
    int pos = 0;
    int len = str.length;
    while (pos < len) {
      if (!StringUtil.isWhitespace(str[pos])) {
        break;
      }
      ++pos;
    }
    if (pos != 0) {
      return str.substring(pos);
    }
    return str;
  }

  /**
   * Removes whitespace characters from the back of string.
   */
  static String trimBack(String str) {
    int pos = str.length - 1;
    while (pos > 0) {
      if (!StringUtil.isWhitespace(str[pos])) {
        break;
      }
      --pos;
    }
    if (pos != (str.length - 1)) {
      return str.substring(0, pos + 1);
    }
    return str;
  }

  /**
   * Formats a string. {n} is replaced by argument(n).
   */
  static String format(String formatStr, List<Object> args) {
    StringBuffer result = new StringBuffer();
    int pos = 0;
    int formatLen = formatStr.length;

    do {
      int paramPos = formatStr.indexOf("{", 0);
      if (paramPos == -1) {
        // We're done, copy the rest of the string and return.
        result.write(formatStr.substring(pos, formatLen));
        pos += formatLen - pos;
        break;
      } else {
        // Copy up to {
        if (pos != paramPos) {
          result.write(formatStr.substring(pos, paramPos));
        }
        int paramEndPos = formatStr.indexOf("}", 0 );
        if (paramEndPos == -1) {
          throw new ArgumentError("Missing closing brace in format "
              "spec");
        }
        int paramIndex = int.parse(formatStr.substring(
            paramPos + 1, paramEndPos));
        if (paramIndex >= args.length) {
          throw new ArgumentError("Invalid number of arguments in "
              "format call.");
        }
        Object s = args[paramIndex];
        result.write(s is String ? s : s.toString());
        formatStr = formatStr.substring(paramEndPos + 1);
        formatLen = formatStr.length;
      }
    } while (formatStr.length > 0);
    return result.toString();
  }
}
