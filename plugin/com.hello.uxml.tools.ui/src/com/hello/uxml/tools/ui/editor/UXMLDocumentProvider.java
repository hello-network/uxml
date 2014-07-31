package com.hello.uxml.tools.ui.editor;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.dom.Model;
import com.hello.uxml.tools.codegen.dom.ModelParser;
import com.hello.uxml.tools.codegen.dom.ModelReflector;
import com.hello.uxml.tools.ui.editor.rules.XMLPartitionScanner;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.rules.FastPartitioner;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.editors.text.FileDocumentProvider;
import org.xml.sax.SAXException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

/**
 * Provides FileDocumentProvider for Uxml document type.
 *
 * @author ferhat
 */
public class UXMLDocumentProvider extends FileDocumentProvider {

  /** Specifies weather we have to rebuild model */
  private boolean modelDirty = true;

  /** Holds root element of model */
  private Model modelRoot;

  @Override
  protected IDocument createDocument(Object element) throws CoreException {
    IDocument document = super.createDocument(element);
    if (document != null) {
      IDocumentPartitioner partitioner =
        new FastPartitioner(
          new XMLPartitionScanner(),
          new String[] {
            XMLPartitionScanner.XML_TAG,
            com.hello.uxml.tools.ui.editor.rules.XMLPartitionScanner.XML_PI,
            XMLPartitionScanner.XML_CDATA,
            XMLPartitionScanner.XML_COMMENT
            });
      partitioner.connect(document);
      document.setDocumentPartitioner(partitioner);
    }
    return document;
  }

  @Override
  public void changed(Object element) {
    super.changed(element);
    modelDirty = true;
  }

  /**
   * Returns codegen DOM model
   */
  public Model getModel() {
    return modelRoot;
  }

  /**
   * Converts text input to Model.
   */
  public void textToModel(IEditorInput input) {
    if (modelDirty) {
      updateModel(input);
    }
  }

  /**
   * Converts model to text.
   */
  public String modelToText(Model model) {
    return model.toString();
  }

  /**
   * Parses document contents and creates modelRoot.
   */
  private void updateModel(IEditorInput input) {
    List<CompilerError> errors = Lists.newArrayList();
    ModelReflector reflector = new ModelReflector();
    try {
      SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
      ModelParser modelParser = new ModelParser(reflector, errors);
      String content = this.getDocument(input).get();
      parser.parse(new ByteArrayInputStream(content.getBytes()), modelParser);
      modelRoot = modelParser.getModel();
    } catch (SAXException e) {
      // Add error if ModelParser has not already reported it.
      errors.add(new CompilerError("SAX parse error:" + e.toString()));
    } catch (ParserConfigurationException e) {
      errors.add(new CompilerError("SAX parse error:" + e.toString()));
    } catch (IOException e) {
      errors.add(new CompilerError("SAX parse error:" + e.toString()));
    }
  }
}

