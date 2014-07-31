
package com.hello.uxml.tools.ui.editor.rules;

import org.eclipse.jface.text.rules.*;

/**
 * Defines a rule for a tag sequence spanning multiple lines.
 *
 * @author ferhat
 */
public class TagRule extends MultiLineRule {

  public TagRule(IToken token) {
    super("<", ">", token);
  }
  protected boolean sequenceDetected(
    ICharacterScanner scanner,
    char[] sequence,
    boolean eofAllowed) {
    int c = scanner.read();
    if (sequence[0] == '<') {
      if (c == '?') {
        // processing instruction - abort
        scanner.unread();
        return false;
      }
      if (c == '!') {
        scanner.unread();
        // comment - abort
        return false;
      }
    } else if (sequence[0] == '>') {
      scanner.unread();
    }
    return super.sequenceDetected(scanner, sequence, eofAllowed);
  }
}
