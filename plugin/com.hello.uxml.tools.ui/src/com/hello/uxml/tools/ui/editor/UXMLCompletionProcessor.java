package com.hello.uxml.tools.ui.editor;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.UXMLCompiler;
import com.hello.uxml.tools.codegen.dom.ModelReflector;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;

import java.util.List;

/**
 * Provides content assist (completition) for uxml.
 *
 * @author ferhat
 */
public class UXMLCompletionProcessor implements IContentAssistProcessor {

  /* current document position */
  private int docPos;
  private String errorMessage;
  // list of uxml keywords that are not elements.
  private static final String[] UXML_KEYWORDS = {"Component", "Elements", "Properties", "Import",
      "Effects"};

  @Override
  public ICompletionProposal[] computeCompletionProposals(ITextViewer textViewer, int offset) {
    docPos = offset;
    errorMessage = null;
    IDocument document = textViewer.getDocument();
    int docLen = document.getLength();
    char ch;
    int pos = docPos - 1;
    try {
      // Find start of element.
      while (pos > 0) {
        ch = document.getChar(pos);
        if (ch == '<') {
          break;
        }
        --pos;
      }
      if (pos < 0) {
        errorMessage = "nothing to complete";
      } else {
        while (docPos < docLen) {
          if (!Character.isLetterOrDigit(document.getChar(docPos))) {
            break;
          }
          ++docPos;
        }
        String word = document.get(pos + 1, docPos - (pos + 1));
        ICompletionProposal[] proposals = computeCompletionForElement(textViewer, pos, docPos,
            word);
        if (proposals == null) {
          errorMessage = "no completion";
        }
        return proposals;
      }
    } catch (BadLocationException e) {
      errorMessage = "completion failed";
    }
    return null;
  }

  private ICompletionProposal[] computeCompletionForElement(ITextViewer viewer, int elementStartPos,
      int cursorPos, String elementPartialText) {
    // Check if we are inside element name.
    int p = 0;
    while (p < elementPartialText.length()) {
      if (Character.isWhitespace(elementPartialText.charAt(p))) {
        break;
      }
      ++p;
    }
    if (p == elementPartialText.length()) {
      return suggestElementTypes(viewer, cursorPos, p == 0 ? "" :
          elementPartialText.substring(0, p));
    }
    return null;
  }

  private ICompletionProposal[] suggestElementTypes(ITextViewer viewer, int cursorPos,
      String prefix) {
    ModelReflector reflector = UXMLCompiler.getReflector();
    List<TypeToken> allTypes = reflector.getRegisteredElements();
    List<String> elementTypes = Lists.newArrayList();
    for (int t = 0; t < allTypes.size(); t++) {
      String name = allTypes.get(t).getName();
      if (prefix.length() == 0 || name.startsWith(prefix)) {
        elementTypes.add(allTypes.get(t).getName());
      }
    }
    for (int k = 0; k < UXML_KEYWORDS.length; k++) {
      if (prefix.length() == 0 || UXML_KEYWORDS[k].startsWith(prefix)) {
        elementTypes.add(UXML_KEYWORDS[k]);
      }
    }
    int typeCount = elementTypes.size();
    ICompletionProposal[] elementProposals = new ICompletionProposal[typeCount];
    for (int i = 0; i < typeCount; i++) {
      elementProposals[i] = new UXMLCompletionProposal(elementTypes.get(i),
          cursorPos - prefix.length(), prefix.length(), UXMLCompletionProposal.CT_ELEMENT);
    }
    return elementProposals;
  }

  @Override
  public IContextInformation[] computeContextInformation(ITextViewer viewer,
      int offset) {
    return null;
  }

  @Override
  public char[] getCompletionProposalAutoActivationCharacters() {
    return new char[] {'<'};
  }

  @Override
  public char[] getContextInformationAutoActivationCharacters() {
    return null;
  }

  @Override
  public String getErrorMessage() {
    return errorMessage;
  }

  @Override
  public IContextInformationValidator getContextInformationValidator() {
    return null;
  }

  static class UXMLCompletionProposal implements ICompletionProposal {

    // Completition types.
    public static final int CT_ELEMENT = 0;

    private String replaceText;
    private int replaceOffset;
    private int replaceLength;
    private int cType;
    private int cursorDelta = 0;
    private static final String[] SIMPLE_ELEMENT_LIST = {"Label", "Button", "CheckBox",
        "RadioButton", "ContentContainer", "Component", "Image", "Item", "LineShape",
        "RectShape", "PathShape", "EllipseShape", "Slider", "Transform", "WaitIndicator",
        "Control", "ProgressControl", "Color", "SolidBrush", "SolidPen", "VecPath"};

    /**
     * Constructor.
     *
     * @param textViewer the text viewer to create proposals for.
     * @param replacementString the actual string to be inserted into the document.
     * @param replacementOffset the offset of the text to be replaced.
     * @param replacementLength the length of the text to be replaced.
     * @param cursorPosition the position of the cursor following the insert
     *   relative to replacementOffset.
     */
    public UXMLCompletionProposal(String replacementString, int replacementOffset,
        int replacementLength, int completionType) {
      replaceText = replacementString;
      replaceOffset = replacementOffset;
      replaceLength = replacementLength;
      cType = completionType;
    }

    @Override
    public void apply(IDocument document) {
      try {
        String newText = replaceText + "></" + replaceText + ">";
        cursorDelta = replaceText.length() + 1;
        for (int i = 0; i < SIMPLE_ELEMENT_LIST.length; i++) {
          if (replaceText.equals(SIMPLE_ELEMENT_LIST[i])) {
            newText = replaceText + "/>";
            cursorDelta = replaceText.length();
            break;
          }
        }
        document.replace(replaceOffset, replaceLength, newText);
      } catch (BadLocationException e) {
        e.printStackTrace();
      }
    }

    @Override
    public Point getSelection(IDocument document) {
      switch (cType) {
        case CT_ELEMENT:
          return new Point(replaceOffset + cursorDelta, 0);
      }
      return null;
    }

    @Override
    public String getAdditionalProposalInfo() {
      return null;
    }

    @Override
    public String getDisplayString() {
      return replaceText;
    }

    @Override
    public Image getImage() {
      return null;
    }

    @Override
    public IContextInformation getContextInformation() {
      return null;
    }
  }
}
