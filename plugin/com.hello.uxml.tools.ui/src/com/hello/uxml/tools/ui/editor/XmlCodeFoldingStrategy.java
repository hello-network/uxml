package com.hello.uxml.tools.ui.editor;

import com.google.common.collect.Lists;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.reconciler.IReconcilingStrategyExtension;
import org.eclipse.swt.widgets.Display;

import java.util.ArrayList;

/**
 * Implements code folding strategy for reconciler.
 * @author ferhat@
 */
public class XmlCodeFoldingStrategy implements IReconcilingStrategy,
                                               IReconcilingStrategyExtension {

  // Editor to update when doc is reconciled.
  private UXMLTextEditor textEditor;
  private IDocument document;

  private ArrayList<Position> docPositions = Lists.newArrayList();
  /**
   * Constructor.
   * @param targetEditor Editor to be updated.
   */
  public XmlCodeFoldingStrategy(UXMLTextEditor targetEditor) {
    textEditor = targetEditor;
  }

  public void setDocument(IDocument document) {
    this.document = document;
  }


  public void initialReconcile() {
    // Called when document is viewed or opened for edit for the first time.
    docPositions.clear();
    calculatePositions(0, document.getLength());
    Display.getDefault().asyncExec(new Runnable() {
      public void run() {
        textEditor.updateFoldingStructure(docPositions);
      }});
  }

  public void setProgressMonitor(IProgressMonitor monitor) {
  }

  public void reconcile(IRegion region) {
    // no incremental support, just call full doc reconcile.
    initialReconcile();
  }

  public void reconcile(DirtyRegion dirtyRegion, IRegion region) {
    // no incremental support, just call full doc reconcile.
    initialReconcile();
  }

  /**
   * Calculates code folding positions.
   */
  private void calculatePositions(int start, int length) {
    docPositions.add(new Position(0, 80));

    // <?   ?> PI
    // <!-- --> Comment
    // <starttag>
    // <leaftag/>
    // </endtag>
    // ENDPOINT OF DOC
    // CDATA
    DocumentTagScanner scanner = new DocumentTagScanner(document);
    buildPositions(scanner);
  }

  private void buildPositions(DocumentTagScanner scanner) {
    int token;
    do {
      token = scanner.nextToken();
      if (token == DocumentTagScanner.TOKEN_TYPE_START_TAG) {
        int tagStartPos = scanner.getTokenStart();
        int tagStartLine = scanner.getLineNumber();
        buildPositions(scanner);
        if (scanner.getLineNumber() > tagStartLine) {
          scanner.moveToEndOfLine();
          docPositions.add(new Position(tagStartPos, scanner.getTokenStart() +
              scanner.getTokenLength() - tagStartPos));
        }
      } else if (token == DocumentTagScanner.TOKEN_TYPE_END_TAG) {
        return;
      }
    } while (token != DocumentTagScanner.TOKEN_TYPE_EOF);
  }

  /**
   * Partitions document stream into tags.
   */
  private static class DocumentTagScanner {

    private IDocument document;

    // Document start position of current token
    private int tokenStartPos;
    private int tokenStartLine;

    // Length of current token
    private int tokenLength;

    // Current scan position
    private int currentPos;

    // Current line number
    private int currentLine;

    // Document length
    private int documentLength;

    public static final int TOKEN_TYPE_START_TAG = 1;
    public static final int TOKEN_TYPE_END_TAG = 2;
    public static final int TOKEN_TYPE_LEAF_TAG = 3;
    public static final int TOKEN_TYPE_PI = 4;
    public static final int TOKEN_TYPE_COMMENT = 5;
    public static final int TOKEN_TYPE_ERROR = -2;
    public static final int TOKEN_TYPE_EOF = -1;

    /**
     * Constructor.
     * @param document Source document
     */
    public DocumentTagScanner(IDocument document) {
      this.document = document;
      currentPos = 0;
      currentLine = 1;
      documentLength = document.getLength();
    }

    /**
     * Scans next token and returns token type.
     */
    public int nextToken() {
      try {
        if (!skipWhiteSpace()) {
          return TOKEN_TYPE_EOF;
        }

        tokenStartPos = currentPos;
        tokenStartLine = currentLine;
        tokenLength = 0;
        int ch = document.getChar(currentPos++);
        if (ch != '<') {
          skipToStartOfTag();
          return TOKEN_TYPE_ERROR;
        }
        int firstChar = document.getChar(currentPos);
        // We are at start of tag
        do {
          ch = document.getChar(currentPos++);
        } while ((ch != '>') && (currentPos < documentLength));
        tokenLength = currentPos - tokenStartPos;
        if ((ch == '>') && (currentPos > 2) && (document.getChar(currentPos - 2) == '/')) {
          return TOKEN_TYPE_LEAF_TAG;
        }
        if (firstChar == '/') {
          return TOKEN_TYPE_END_TAG;
        } else if (firstChar == '?') {
          return TOKEN_TYPE_PI;
        } else if (firstChar == '!') {
          return TOKEN_TYPE_COMMENT;
        }
        return TOKEN_TYPE_START_TAG;
      } catch (BadLocationException e) {
        return TOKEN_TYPE_EOF;
      }
    }

    /**
     * Scans to end of line and adds space to current tokenlength
     */
    public void moveToEndOfLine() {
      int startPos = currentPos;
      skipWhiteSpace();
      tokenLength += currentPos - startPos;
    }

    private boolean skipWhiteSpace() {
      int ch;
      int lastNewLineChar = ' ';
      if (currentPos >= documentLength) {
        return false;
      }
      try {
        do {
          ch = document.getChar(currentPos);
          if ((ch == '\r') || (ch == '\n')) {
            if ((lastNewLineChar == ' ') || (ch == lastNewLineChar)) {
              ++currentLine;
            }
            lastNewLineChar = ch;
          }
          if ((ch == ' ') || (ch == '\t') || (ch == '\r') || (ch == '\n')) {
            ++currentPos;
          } else {
            break;
          }
        } while (currentPos < documentLength);
      } catch (BadLocationException e) {
        return false;
      }
      return true;
    }

    private void skipToStartOfTag() {
      int ch;
      if (currentPos >= documentLength) {
        return;
      }
      try {
        do {
          ch = document.getChar(currentPos++);
          if (currentPos >= documentLength) {
            return;
          }
        } while (ch != '<');
      } catch (BadLocationException e) {
        return;
      }
      if (ch == '<') {
        currentPos--;
      }
    }

    /**
     * @return start position of token.
     */
    public int getTokenStart() {
      return tokenStartPos;
    }

    /**
     * @return length of token.
     */
    public int getTokenLength() {
      return tokenLength;
    }

    /**
     * Returns tag name.
     */
    @SuppressWarnings("unused")
    public String getTagName() {
      String tag = "";
      int beginIndex = 0;
      int endTrim = 0;
      try {
        tag = document.get(tokenStartPos, tokenLength);
        if ((tokenLength > 0) && (tag.charAt(0) == '<')) {
          ++beginIndex;
          if ((tokenLength > 1) && (tag.charAt(1) == '/')) {
            ++beginIndex;
          }
        }
        if ((tokenLength > 0) && (tag.charAt(tokenLength - 1) == '>')) {
          endTrim++;
          if ((tokenLength > 1) && (tag.charAt(tokenLength - 2) == '/')) {
            endTrim++;
          }
        }
        tag = tag.substring(beginIndex, tokenLength - endTrim);
      } catch (BadLocationException e) {
        return null;
      }
      return tag;
    }

    /**
     * Returns current line number at token.
     * @return
     */
    public int getLineNumber() {
      return tokenStartLine;
    }
  }
}
