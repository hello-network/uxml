package com.hello.uxml.tools.ui.editor.rules;

import org.eclipse.jface.text.rules.ICharacterScanner;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.Token;

/**
 * Implements tag rule for CDATA inside XML file.
 *
 * @author ferhat
 */
public class CDataRule implements IRule {

  private String match;
  private IToken successToken;
  private int charsRead = 0;

  private static final String CDATA_PREFIX  = "<![CDATA[";
  private static final String CDATA_POSTFIX = "]]>";

  public CDataRule(IToken token, boolean start) {
    super();
    this.match = start ? CDATA_PREFIX : CDATA_POSTFIX;
    this.successToken = token;
  }


  /*
   * @see IRule
   */
  public IToken evaluate(ICharacterScanner scanner) {
    int ch = scanner.read();
    charsRead = 1;
    if (ch == match.charAt(0)) {
      do {
        ch = scanner.read();
        charsRead++;
      } while (isMatch((char) ch));

      if (charsRead == match.length()) {
        return successToken;
      } else {
        // full rewind
        for (int i = 0; i < charsRead; ++i) {
          scanner.unread();
        }
        return Token.UNDEFINED;
      }
    }
    scanner.unread();
    return Token.UNDEFINED;
  }

  private boolean isMatch(char ch) {
    if (charsRead >= match.length()) {
      return false;
    }
    return match.charAt(charsRead - 1) == ch;
  }
}