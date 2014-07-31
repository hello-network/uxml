package com.hello.uxml.tools.ui.editor;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.jface.text.source.projection.ProjectionSupport;
import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.editors.text.TextEditor;
import org.eclipse.ui.texteditor.IDocumentProvider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Implements source code editor for UXML files.
 *
 * @author ferhat
 */
public class UXMLTextEditor extends TextEditor {

  private static final Logger logger = Logger.getLogger(UXMLTextEditor.class.getName());

  // Code folding support
  private ProjectionSupport projectionSupport;
  private Annotation[] oldAnnotations;
  private ProjectionAnnotationModel annotationModel;

  /**
   * Constructor.
   */
  public UXMLTextEditor(ColorCache colorCache) {
      super();
      setSourceViewerConfiguration(new UXMLSourceConfiguration(this, colorCache));
      setDocumentProvider(new UXMLDocumentProvider());
  }

  @Override
  public void createPartControl(Composite parent) {
    super.createPartControl(parent);

    ProjectionViewer viewer = (ProjectionViewer) getSourceViewer();

    projectionSupport = new ProjectionSupport(viewer, getAnnotationAccess(), getSharedColors());
    projectionSupport.install();

    //turn projection mode on
    viewer.doOperation(ProjectionViewer.TOGGLE);

    annotationModel = viewer.getProjectionAnnotationModel();
  }

  /*
   * @see org.eclipse.ui.texteditor.AbstractTextEditor#createSourceViewer
   */
  protected ISourceViewer createSourceViewer(Composite parent, IVerticalRuler ruler, int styles) {
    ISourceViewer viewer = new ProjectionViewer(parent, ruler, getOverviewRuler(),
        isOverviewRulerVisible(), styles);

    // configure decoration support
    getSourceViewerDecorationSupport(viewer);

    return viewer;
  }

  /**
   * Updates annotationModel
   */
  public void updateFoldingStructure(ArrayList<Position> positions) {
    Annotation[] annotations = new Annotation[positions.size()];
    // Map positions to annotation
    HashMap<ProjectionAnnotation, Position> newAnnotations =
        new HashMap<ProjectionAnnotation, Position>();

    for (int i = 0; i < positions.size(); i++) {
      ProjectionAnnotation annotation = new ProjectionAnnotation();
      newAnnotations.put(annotation, positions.get(i));
      annotations[i] = annotation;
    }
    annotationModel.modifyAnnotations(oldAnnotations, newAnnotations, null);
    oldAnnotations = annotations;
  }

  /**
   * Inserts text into editor.
   */
  public void insertText(String text) {
    IDocumentProvider dp = getDocumentProvider();
    IDocument doc = dp.getDocument(getEditorInput());
    int offset;
    boolean insertNewLineBefore = true;
    boolean insertNewLineAfter = true;

    try {
      String cursorPos = this.getCursorPosition();
      String[] parts = cursorPos.split(":");
      int line = Integer.parseInt(parts[0].trim()) - 1;
      int column = Integer.parseInt(parts[1].trim()) - 1;
      insertNewLineBefore = column != 0;
      offset = doc.getLineOffset(line) + column;
      insertNewLineAfter = doc.getLineLength(line) == 0;
    } catch (BadLocationException e) {
      offset = 0;
    }
    try {
      doc.replace(offset, 0, (insertNewLineBefore ? "\n" : "")
          + text
          + (insertNewLineAfter ? "\n" : ""));
    } catch (BadLocationException e) {
      logger.log(Level.SEVERE, "text editor update failed", e);
    }
  }

  @Override
  protected boolean isTabsToSpacesConversionEnabled() {
    return true;
  }

  public void removeTrailingWhiteSpace() {
    try {
      IDocumentProvider dp = getDocumentProvider();
      IDocument doc = dp.getDocument(getEditorInput());
      int lineCount = doc.getNumberOfLines();
      for (int l = 0; l < lineCount; ++l) {
        int offset = doc.getLineOffset(l);
        int len = doc.getLineLength(l);
        String line = doc.get(offset, len);
        int trimAmount = 0;
        int eolSize = 0; // amount of \n \r at end of line to keep
        int pos = line.length() - 1;
        while (pos > 0) {
          char ch = line.charAt(pos);
          if ((ch == '\n') || (ch == '\r')) {
            ++eolSize;
            --pos;
          } else {
            break;
          }
        }
        while (pos >= 0) {
          char ch = line.charAt(pos);
          if (ch == ' ' || ch == '\t') {
            ++trimAmount;
            --pos;
          } else {
            break;
          }
        }
        if (trimAmount != 0) {
          String trimmedLine = line.substring(0, line.length() - (trimAmount + eolSize));
          if (eolSize != 0) {
            String eolValue = line.substring(line.length() - eolSize);
            trimmedLine += eolValue;
          }
          doc.replace(offset, len, trimmedLine);
        }
      }
    } catch (BadLocationException e) {
      logger.log(Level.WARNING, "Remove trailing spaces failed in UXML editor");
    }
  }

  @Override
  public void dispose() {
      super.dispose();
  }
}
