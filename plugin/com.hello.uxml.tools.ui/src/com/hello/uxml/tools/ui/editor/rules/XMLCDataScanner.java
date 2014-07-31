
package com.hello.uxml.tools.ui.editor.rules;

import com.hello.uxml.tools.ui.editor.ColorCache;
import com.hello.uxml.tools.ui.editor.IXMLColorConstants;

import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.Token;

/**
 * Provides scanner for CDATA sections.
 *
 * @author ferhat
 */
public class XMLCDataScanner extends RuleBasedScanner {
  public IToken ESCAPED_CHAR;
  public IToken CDATA;

  public XMLCDataScanner(ColorCache colorCache) {
    CDATA = new Token(new TextAttribute(colorCache.getColor(IXMLColorConstants.CDATA)));
    IRule[] rules = new IRule[2];

    // Add rule to pick up start of c section
    rules[0] = new CDataRule(CDATA, true);

    // Add a rule to pick up end of CDATA sections
    rules[1] = new CDataRule(CDATA, false);

    setRules(rules);
  }

  public IToken nextToken() {
    return super.nextToken();
  }
}
