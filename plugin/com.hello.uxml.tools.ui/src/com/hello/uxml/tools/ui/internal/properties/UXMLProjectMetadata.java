
package com.hello.uxml.tools.ui.internal.properties;

import com.google.common.base.Charsets;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.QualifiedName;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.Writer;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

/**
 * Constructs project and resource level Preferences implementations.
 * Used by UxmlPropertyPage.
 *
 * @author ferhat
 */
public final class UXMLProjectMetadata{
  private UXMLProjectMetadata() {
  }

  /**
   * Returns project level preferences object.
   */
  public static ProjectItemMetadata getProjectPreferences(IProject project) {
    return new ProjectItemMetadataImpl(project);
  }

  /**
   * Returns hts file level preferences object.
   */
  public static ProjectItemMetadata getFilePreferences(IResource resource) {
    return new ProjectItemMetadataImpl(resource);
  }

  /**
   * Implements project/file level preferences.
   */
  static class ProjectItemMetadataImpl implements ProjectItemMetadata{
    private IResource resource;
    private Document settingsModel;
    private static final String UXML_SETTINGS_FILENAME = ".uxmlProperties";

    public ProjectItemMetadataImpl(IResource resource) {
      this.resource = resource;
      File projectFileLoc = resource.getLocation().toFile();
      if (projectFileLoc.exists()) {
        File settingsFile = new File(projectFileLoc, UXML_SETTINGS_FILENAME);
        this.settingsModel = readSettingsModel(settingsFile);
      }
    }

    public void put(String key, String value) throws CoreException {
      if (settingsModel == null) {
        settingsModel = createEmptyDocument();
      }
      NodeList list = settingsModel.getDocumentElement().getElementsByTagName(key);
      if (list == null || list.getLength() != 1) {
        Element element = settingsModel.createElement(key);
        element.setTextContent(value);
        settingsModel.getDocumentElement().appendChild(element);
      } else {
        list.item(0).setTextContent(value);
      }
      saveSettings(settingsModel);
    }

    private boolean saveSettings(Document model) {
      File projectFileLoc = resource.getLocation().toFile();
      File settingsFile = new File(projectFileLoc, UXML_SETTINGS_FILENAME);
      Writer out = null;
      try {
        // set up a transformer
        TransformerFactory transfac = TransformerFactory.newInstance();
        Transformer trans = transfac.newTransformer();
        trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        trans.setOutputProperty(OutputKeys.INDENT, "yes");

        StringWriter writer = new StringWriter();
        StreamResult streamResult = new StreamResult(writer);
        DOMSource source = new DOMSource(model);
        trans.transform(source, streamResult);
        String xmlString = writer.toString();
        if (settingsFile.exists()) {
          settingsFile.delete();
        }
        out = new OutputStreamWriter(new FileOutputStream(settingsFile), Charsets.UTF_8);
        out.write(xmlString);
      } catch (IOException e) {
        return false;
      } catch (TransformerException e) {
        return false;
      } finally {
        if (out != null) {
          try {
            out.close();
          } catch (IOException e) {
            return false;
          }
        }
      }
      return true;
    }

    public String get(String key) {
      if (settingsModel == null) {
        return null;
      }
      NodeList list = settingsModel.getDocumentElement().getElementsByTagName(key);
      if (list == null || list.getLength() != 1) {
        return null;
      }
      return list.item(0).getTextContent();
    }

    public void delete(String key) throws CoreException {
      QualifiedName qName = new QualifiedName("HtsPreferences", key);
      resource.setPersistentProperty(qName, null);
    }

    private Document readSettingsModel(File settingsFile) {
      Document doc = null;
      if (settingsFile.exists()) {
        try {
          DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
          DocumentBuilder docBuilder = dbfac.newDocumentBuilder();
          doc = docBuilder.parse(settingsFile);
        } catch (ParserConfigurationException e) {
          return null;
        } catch (SAXException e) {
          return null;
        } catch (IOException e) {
          return null;
        }
      } else {
        doc = createEmptyDocument();
      }
      return doc;
    }

    private Document createEmptyDocument() {
      DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
      try {
        DocumentBuilder docBuilder = dbfac.newDocumentBuilder();
        Document doc = docBuilder.newDocument();
        Element root = doc.createElement("uxmlProperties");
        doc.appendChild(root);
        // TODO(ferhat): remove legacy settings read below.
        readLegacyValue(doc, root, ProjectItemMetadata.LANG_KEY);
        readLegacyValue(doc, root, ProjectItemMetadata.TARGETPATH_KEY);
        readLegacyValue(doc, root, ProjectItemMetadata.LOCALIZATION_WARNING_KEY);
        readLegacyValue(doc, root, ProjectItemMetadata.IMPORTS_KEY);
        saveSettings(doc);
        return doc;
      } catch (ParserConfigurationException e) {
        return null;
      }
    }

    private void readLegacyValue(Document doc, Element root, String key) {
      try {
        QualifiedName qName = new QualifiedName("HtsPreferences", key);
        String val = resource.getPersistentProperty(qName);
        Element element = doc.createElement(key);
        element.setTextContent(val);
        root.appendChild(element);
      } catch (CoreException e) {
        // ok to ignore. targetPath not set.
      }
    }
  }
}
