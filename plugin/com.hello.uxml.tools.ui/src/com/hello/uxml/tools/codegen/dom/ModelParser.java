package com.hello.uxml.tools.codegen.dom;

import com.google.common.base.Preconditions;
import com.google.common.collect.Lists;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.codegen.CompilerError;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import org.xml.sax.Attributes;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

import java.util.List;

/**
 * Creates document object model for hts by providing SAX handler for hts parsing.
 *
 * @author ferhat
 */
public class ModelParser extends DefaultHandler {

  /** Root element of model */
  private Model root = new Model("Root");

  /** Holds temp string data while parsing */
  private StringBuilder tempVal = new StringBuilder();

  /** ModelReflector used to resolve PropertyDefinitions */
  private ModelReflector reflector;

  /** Target error collection */
  private List<CompilerError> errors;

  /** Document locator used to get line/column info for errors */
  private Locator docLocator;

  /** Current parse context */
  private ParseContext parseContext = new ParseContext();

  private static final String COMPONENT_NODE_NAME = "Component";

  /**
   * Constructor.
   */
  public ModelParser(List<CompilerError> errors) {
    this.errors = errors;
  }

  /**
   * Constructor.
   */
  public ModelParser(ModelReflector reflector, List<CompilerError> errors) {
    this.reflector = reflector;
    this.errors = errors;
  }

  /**
   * Returns top level Model.
   */
  public Model getModel() {
    return root.getChildCount() == 0 ? null : root.getChild(0);
  }

  @Override
  public void startDocument() {
    parseContext.push(root);
  }

  @Override
  public void startElement(String uri, String localName, String name, Attributes attributes) {
    Preconditions.checkArgument(name.length() > 0);
    tempVal.setLength(0);
    // If element is a property of our parent , create a property node. Property tags
    // start with lowercase letter, camelCase
    if (parseContext.isModel() && Character.isLowerCase(name.charAt(0))) {
      TypeToken parentTypeToken = reflector.elementTypeToToken(
          parseContext.getCurrentModel().getTypeName());
      if ((parentTypeToken != null)) {
        if (reflector.hasProperty(parentTypeToken, name)) {
          int attribCount = attributes.getLength();
          if (attribCount != 0) {
            errors.add(new CompilerError("Property setter tags should not contain attributes."));
          }
          Class<?> dataType = reflector.getDataType(parentTypeToken, name);
          ModelProperty property;
          boolean isCollection = false;
          // Treat all List<> as preallocated collection nodes.
          if (List.class.isAssignableFrom(dataType)) {
            isCollection = true;
          }
          if (reflector.isCollectionField(parentTypeToken, name)) {
            isCollection = true;
          }
          if (isCollection) {
            property = createModelCollectionProperty(parseContext.getCurrentModel(), name);
          } else {
            property = createModelProperty(parseContext.getCurrentModel(), name, null);
          }
          parseContext.push(property);
          return;
        }
      }
    }

    // Create Model node
    Model item = new Model(name);
    if (docLocator != null) {
      item.setLineNumber(docLocator.getLineNumber());
      item.setColumn(docLocator.getColumnNumber());
    }

    // Add new node to current parent
    if (parseContext.isModel()) {
      Model curNode = parseContext.getCurrentModel();
      curNode.addChild(item);
    } else {
      ModelProperty prop = parseContext.getCurrentProperty();
      if (prop instanceof ModelCollectionProperty) {
        ((ModelCollectionProperty) prop).addChild(item);
      } else {
        prop.setValue(item);
      }
    }
    parseContext.push(item);

    // Read attributes and generate ModelProperty(s)
    int attribCount = attributes.getLength();
    for (int i = 0; i < attribCount; ++i) {
      String type = attributes.getType(i);
      String attrName = attributes.getQName(i);
      String val = attributes.getValue(i);
      if (type.equals("CDATA")) {
        createModelProperty(item, attrName, val);
      }
    }
  }

  /**
   * Create ModelProperty and resolve propDef/data type if available from reflector.
   */
  private ModelProperty createModelProperty(Model item, String attributeName, String value) {
    TypeToken token = null;
    if (reflector != null) {
      if (item.getTypeName().equals(COMPONENT_NODE_NAME)) {
        token = TypeToken.fromClass(UIElement.class);
      } else {
        token = reflector.elementTypeToToken(item.getTypeName());
      }
    }
    ModelProperty property = item.createProperty(attributeName, value);

    // Check for attached property
    int periodPos = attributeName.indexOf('.');
    if (periodPos != -1) {
      String ownerClassName = attributeName.substring(0, periodPos);
      token = reflector.elementTypeToToken(ownerClassName);
      if (token != null) {
        // valid owner , set target name to Class.*name*
        attributeName = attributeName.substring(periodPos + 1);
        property.setTargetName(attributeName);
      }
    }
    if ((reflector != null) && (token != null)) {
      PropertyDefinition propDef = reflector.getPropDef(token, attributeName);
      if (propDef != null) {
        property.setPropDef(propDef);
      } else {
        EventDefinition eventDef = reflector.getEventDef(token, attributeName);
        if (eventDef != null) {
          property.setEventDef(eventDef);
        } else {
          property.setDataType(reflector.getDataType(token, attributeName));
        }
      }
    }
    return property;
  }

  private ModelProperty createModelCollectionProperty(Model item, String attributeName) {
    TypeToken token = null;
    if (reflector != null) {
      token = reflector.elementTypeToToken(item.getTypeName());
    }
    List<Model> items = Lists.newArrayList();
    ModelCollectionProperty property = item.createProperty(attributeName, items);
    if ((reflector != null) && (token != null)) {
      PropertyDefinition propDef = reflector.getPropDef(token, attributeName);
      if (propDef != null) {
        property.setPropDef(propDef);
      } else {
        property.setDataType(reflector.getDataType(token, attributeName));
      }
    } else {
      item.createProperty(attributeName, items);
    }
    return property;
  }

  @Override
  public void characters(char[] ch, int start, int length) {
    tempVal.append(new String(ch, start, length));
  }

  @Override
  public void endElement(String uri, String localName, String name) {
    if (parseContext.isModel()) {
      Model model = parseContext.getCurrentModel();
      String contentValue = tempVal.toString().trim();
      if (contentValue.length() != 0) {
        model.setContent(contentValue);
        if (!model.hasProperty("content")) {
          createModelProperty(model, "content", contentValue);
        }
      }
      parseContext.pop();
    } else if (parseContext.isProperty()){
      ModelProperty prop = parseContext.getCurrentProperty();
      if (prop.getDataType().equals(String.class) && prop.getValue() == null) {
        prop.setValue(tempVal.toString().trim());
      }
      parseContext.pop();
    } else {
      // Context is property
      parseContext.pop();
    }
    tempVal.setLength(0); // clear stringbuffer
  }

  // this is called when document is not valid:
  @Override
  public void error(SAXParseException ex) throws SAXException {
    if (errors != null) {
      errors.add(new CompilerError(ex.getLineNumber(), ex.getColumnNumber(),
          ex.getMessage()));
      return;
    }
    throw ex;
  }

  // this is called when document is not well-formed:
  @Override
  public void fatalError(SAXParseException ex) throws SAXException {
    if (errors != null) {
      errors.add(new CompilerError(ex.getLineNumber(), ex.getColumnNumber(),
          ex.getMessage()));
      return;
    }
    throw ex;
  }

  @Override
  public void warning(SAXParseException ex) throws SAXException {
    if (errors != null) {
      errors.add(new CompilerError(ex.getLineNumber(), ex.getColumnNumber(),
          ex.getMessage()));
      return;
    }
    throw ex;
  }

  @Override
  public void setDocumentLocator(Locator locator) {
    docLocator = locator;
  }
}
