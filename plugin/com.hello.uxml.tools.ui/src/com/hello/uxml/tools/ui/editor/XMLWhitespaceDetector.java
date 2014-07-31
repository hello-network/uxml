package com.hello.uxml.tools.ui.editor;

import org.eclipse.jface.text.rules.IWhitespaceDetector;


/**
 * Whitespace detector for uxml document.
 *
 * @author ferhat
 */
public class XMLWhitespaceDetector implements IWhitespaceDetector {

  public boolean isWhitespace(char c) {
    return (c == ' ' || c == '\t' || c == '\n' || c == '\r');
  }
}
