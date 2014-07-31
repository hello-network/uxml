
package com.hello.uxml.tools.ui.editor.rules;

import org.eclipse.jface.text.rules.*;

/**
 * Provides scanner for partitioning comments and processing instructions.
 *
 * @author ferhat
 */
public class XMLPartitionScanner extends RuleBasedPartitionScanner {
  public static final String XML_COMMENT = "__xml_comment";
  public static final String XML_TAG = "__xml_tag";
  public static final String XML_PI = "__xml_pi";
  public static final String XML_CDATA = "__xml_cdata";

  public XMLPartitionScanner() {

    IToken xmlComment = new Token(XML_COMMENT);
    IToken xmlPI = new Token(XML_PI);
    IToken tag = new Token(XML_TAG);

    IPredicateRule[] rules = new IPredicateRule[3];

    rules[0] = new MultiLineRule("<!--", "-->", xmlComment);
    rules[1] = new MultiLineRule("<?", "?>", xmlPI);
    rules[2] = new TagRule(tag);

    setPredicateRules(rules);
  }
}
