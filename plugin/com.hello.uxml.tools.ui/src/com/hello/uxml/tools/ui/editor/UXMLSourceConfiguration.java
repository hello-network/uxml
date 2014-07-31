package com.hello.uxml.tools.ui.editor;

import com.hello.uxml.tools.ui.editor.rules.XMLCDataScanner;
import com.hello.uxml.tools.ui.editor.rules.XMLPartitionScanner;
import com.hello.uxml.tools.ui.editor.rules.XMLScanner;
import com.hello.uxml.tools.ui.editor.rules.XMLTagScanner;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextDoubleClickStrategy;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.contentassist.ContentAssistant;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContentAssistant;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.reconciler.IReconciler;
import org.eclipse.jface.text.reconciler.MonoReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;

import java.util.Arrays;

/**
 * Provides SourceViewerConfiguration for Uxml files.
 *
 * @author ferhat
 */
public class UXMLSourceConfiguration extends SourceViewerConfiguration {

  private XMLDoubleClickStrategy doubleClickStrategy;
  private XMLTagScanner tagScanner;
  private XMLScanner scanner;
  private XMLCDataScanner cdataScanner;
  private UXMLTextEditor textEditor;
  private ColorCache colorCache;

  public UXMLSourceConfiguration(UXMLTextEditor editor, ColorCache colorCache) {
    textEditor = editor;
    this.colorCache = colorCache;
  }

  public String[] getConfiguredContentTypes(ISourceViewer sourceViewer) {
    return new String[] {
      IDocument.DEFAULT_CONTENT_TYPE,
      XMLPartitionScanner.XML_COMMENT,
      XMLPartitionScanner.XML_TAG,
      XMLPartitionScanner.XML_PI,
      XMLPartitionScanner.XML_CDATA
      };
  }

  public ITextDoubleClickStrategy getDoubleClickStrategy(
      ISourceViewer sourceViewer,
      String contentType) {
    if (doubleClickStrategy == null) {
      doubleClickStrategy = new XMLDoubleClickStrategy();
    }
    return doubleClickStrategy;
  }

  /**
   * Returns the prefixes to be used by the line-shift operation.
   */
  @Override
  public String[] getIndentPrefixes(ISourceViewer sourceViewer, String contentType) {
    return new String[] { "  ", "    ", "" }; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
  }

  /**
   * Computes and returns the indent prefixes for tab indentation
   * which is represented as <code>tabSizeInSpaces</code>.
   */
  @Override
  protected String[] getIndentPrefixesForTab(int tabWidth) {
    String[] indentPrefixes = new String[tabWidth + 2];
    for (int i = 0; i <= tabWidth; i++) {
      char[] spaceChars = new char[i];
      Arrays.fill(spaceChars, ' ');
      String spaces = new String(spaceChars);
      if (i < tabWidth) {
        indentPrefixes[i] = spaces + "  ";
      } else {
        indentPrefixes[i] = new String(spaces);
      }
    }
    indentPrefixes[tabWidth + 1] = ""; //$NON-NLS-1$
    return indentPrefixes;
  }


  protected XMLScanner getXMLScanner() {
    if (scanner == null) {
      scanner = new XMLScanner(colorCache);
      scanner.setDefaultReturnToken(
        new Token(
          new TextAttribute(
            colorCache.getColor(IXMLColorConstants.DEFAULT))));
    }
    return scanner;
  }
  protected XMLTagScanner getXMLTagScanner() {
    if (tagScanner == null) {
      tagScanner = new XMLTagScanner(colorCache);
      tagScanner.setDefaultReturnToken(
        new Token(
          new TextAttribute(
              colorCache.getColor(IXMLColorConstants.TAG))));
    }
    return tagScanner;
  }

  protected XMLCDataScanner getXMLCDataScanner() {
    if (cdataScanner == null) {
      cdataScanner = new XMLCDataScanner(colorCache);
      cdataScanner.setDefaultReturnToken(new Token(new TextAttribute(colorCache
          .getColor(IXMLColorConstants.CDATA))));
    }
    return cdataScanner;
  }

  public IPresentationReconciler getPresentationReconciler(ISourceViewer sourceViewer) {
    PresentationReconciler reconciler = new PresentationReconciler();

    DefaultDamagerRepairer dr =
      new DefaultDamagerRepairer(getXMLTagScanner());
    reconciler.setDamager(dr, XMLPartitionScanner.XML_TAG);
    reconciler.setRepairer(dr, XMLPartitionScanner.XML_TAG);

    dr = new DefaultDamagerRepairer(getXMLScanner());
    reconciler.setDamager(dr, IDocument.DEFAULT_CONTENT_TYPE);
    reconciler.setRepairer(dr, IDocument.DEFAULT_CONTENT_TYPE);

    dr = new DefaultDamagerRepairer(getXMLCDataScanner());
    reconciler.setDamager(dr, XMLPartitionScanner.XML_CDATA);
    reconciler.setRepairer(dr, XMLPartitionScanner.XML_CDATA);

    NonRuleBasedDamagerRepairer ndr =
      new NonRuleBasedDamagerRepairer(
        new TextAttribute(
          colorCache.getColor(IXMLColorConstants.XML_COMMENT)));
    reconciler.setDamager(ndr, XMLPartitionScanner.XML_COMMENT);
    reconciler.setRepairer(ndr, XMLPartitionScanner.XML_COMMENT);

    ndr =
      new NonRuleBasedDamagerRepairer(
        new TextAttribute(
          colorCache.getColor(IXMLColorConstants.PI)));
    reconciler.setDamager(ndr, XMLPartitionScanner.XML_PI);
    reconciler.setRepairer(ndr, XMLPartitionScanner.XML_PI);

    return reconciler;
  }

  /*
   * @see org.eclipse.jface.text.source.SourceViewerConfiguration#getReconciler
   */
  public IReconciler getReconciler(ISourceViewer sourceViewer) {
    // MonoReconciler is a background process to execute the XMLReconcileStrategy.
    // XMLReconcile strategy calculates positions in the document that can be folded
    // and calls UxmlTextEditor.updateFoldingStructure.
    XmlCodeFoldingStrategy strategy = new XmlCodeFoldingStrategy(textEditor);

    // Incremental is reported as buggy so we're using false=non incremental
    return new MonoReconciler(strategy, false);
  }

  /*
   * (non-Javadoc)
   * @see org.eclipse.jface.text.source.SourceViewerConfiguration#getContentAssistant
   * (org.eclipse.jface.text.source.ISourceViewer)
   */
  public IContentAssistant getContentAssistant(ISourceViewer sourceViewer) {
    ContentAssistant assistant = new ContentAssistant();
    IContentAssistProcessor cap = new UXMLCompletionProcessor();
    assistant.setContentAssistProcessor(cap, XMLPartitionScanner.XML_TAG);
    assistant.setContentAssistProcessor(cap, IDocument.DEFAULT_CONTENT_TYPE);
    assistant.enableAutoActivation(true);
    assistant.setAutoActivationDelay(0);
    assistant.enableAutoInsert(true);
    assistant.setInformationControlCreator(getInformationControlCreator(sourceViewer));
    return assistant;
  }

  public void dispose() {
  }
}
