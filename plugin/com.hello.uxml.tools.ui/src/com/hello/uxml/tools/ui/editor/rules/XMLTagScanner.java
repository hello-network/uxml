
package com.hello.uxml.tools.ui.editor.rules;

import com.hello.uxml.tools.ui.editor.ColorCache;
import com.hello.uxml.tools.ui.editor.IXMLColorConstants;
import com.hello.uxml.tools.ui.editor.XMLWhitespaceDetector;

import org.eclipse.jface.text.*;
import org.eclipse.jface.text.rules.*;

/**
 * Provides scanner for whitespace and string rules.
 *
 * @author ferhat
 */
public class XMLTagScanner extends RuleBasedScanner {

  public XMLTagScanner(ColorCache manager) {
    IToken string =
      new Token(
        new TextAttribute(manager.getColor(IXMLColorConstants.STRING)));

    IRule[] rules = new IRule[3];

    // Add rule for double quotes
    rules[0] = new SingleLineRule("\"", "\"", string, '\\');
    // Add a rule for single quotes
    rules[1] = new SingleLineRule("'", "'", string, '\\');
    // Add generic whitespace rule.
    rules[2] = new WhitespaceRule(new XMLWhitespaceDetector());

    setRules(rules);
  }
}
