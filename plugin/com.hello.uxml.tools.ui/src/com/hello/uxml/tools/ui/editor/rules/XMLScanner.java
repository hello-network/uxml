
package com.hello.uxml.tools.ui.editor.rules;

import com.hello.uxml.tools.ui.editor.ColorCache;
import com.hello.uxml.tools.ui.editor.IXMLColorConstants;
import com.hello.uxml.tools.ui.editor.XMLWhitespaceDetector;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.SingleLineRule;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.rules.WhitespaceRule;


/**
 * Provides scanner for processing instructions.
 *
 * @author ferhat
 */
public class XMLScanner extends RuleBasedScanner {

  public XMLScanner(ColorCache manager) {
    IToken procInstr =
      new Token(
        new TextAttribute(
          manager.getColor(IXMLColorConstants.PROC_INSTR)));

    IRule[] rules = new IRule[2];
    //Add rule for processing instructions
    rules[0] = new SingleLineRule("<?", "?>", procInstr);
    // Add generic whitespace rule.
    rules[1] = new WhitespaceRule(new XMLWhitespaceDetector());

    setRules(rules);
  }
}
