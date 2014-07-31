package com.hello.uxml.tools.codegen.dom;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import java.util.HashMap;
import java.util.List;

/**
 * Represents a markup model node.
 *
 * @author ferhat
 */
public class Model {

  /** Name of item */
  private String typeName;

  /** Inner text of item */
  private String content;

  /** Parent node of item */
  private Model parent;

  /** Maps name to property */
  private HashMap<String, ModelProperty> propertyMap;

  /** List of properties */
  private List<ModelProperty> properties;

  /** Holds child items */
  private List<Model> children;

  /** Parse location */
  private int lineNumber = -1;
  private int column = -1;

  /** Model change listeners */
  private List<ModelChangeListener> modelChangeListeners;

  /**
   * Constructor.
   */
  public Model(String name) {
    typeName = name;
  }

  /**
   * Returns number of children.
   */
  public int getChildCount() {
    return children == null ? 0 : children.size();
  }

  /**
   * Returns child at index.
   */
  public Model getChild(int index) {
    return children.get(index);
  }

  /**
   * Adds a child.
   */
  public void addChild(Model child) {
    if (children == null) {
      children = Lists.newArrayList();
    }
    children.add(child);
    child.parent = this;
  }

  /**
   * Returns parent of item.
   */
  public Model getParent() {
    return this.parent;
  }

  /**
   * Returns number of properties.
   */
  public int getPropertyCount() {
    return (properties == null) ? 0 : properties.size();
  }

  /**
   * Returns property at index.
   */
  public ModelProperty getProperty(int index) {
    return properties.get(index);
  }

  /**
   * Returns property by name.
   */
  public ModelProperty getProperty(String name) {
    return propertyMap == null ? null : propertyMap.get(name);
  }

  /**
   * Returns whether item has a property.
   */
  public boolean hasProperty(String name) {
    return propertyMap == null ? false : propertyMap.containsKey(name);
  }

  /**
   *  Returns a string property.
   */
  public String getStringProperty(String name) {
    return (String) propertyMap.get(name).getValue();
  }

  /**
   * Adds a new {@link ModelProperty}.
   */
  public ModelProperty createProperty(String name, Model value) {
    if (propertyMap == null) {
      propertyMap = Maps.newHashMap();
    }
    if (properties == null) {
      properties = Lists.newArrayList();
    }
    ModelProperty prop = new ModelProperty(name, null);
    prop.setValue(value);
    propertyMap.put(name, prop);
    properties.add(prop);
    notifyChangeListeners(prop, null, value);
    return prop;
  }

  /**
   * Adds a new {@link ModelProperty}.
   */
  public ModelCollectionProperty createProperty(String name, List<Model> value) {
    if (propertyMap == null) {
      propertyMap = Maps.newHashMap();
    }
    if (properties == null) {
      properties = Lists.newArrayList();
    }
    ModelCollectionProperty prop = new ModelCollectionProperty(name, value);
    propertyMap.put(name, prop);
    properties.add(prop);
    notifyChangeListeners(prop, null, value);
    return prop;
  }

  /**
   * Adds a new {@link ModelProperty}.
   */
  public ModelProperty createProperty(String name, String value) {
    if (propertyMap == null) {
      propertyMap = Maps.newHashMap();
    }
    if (properties == null) {
      properties = Lists.newArrayList();
    }
    ModelProperty prop = new ModelProperty(name, value);
    if (!propertyMap.containsKey(name)) {
      propertyMap.put(name, prop);
      properties.add(prop);
    }
    notifyChangeListeners(prop, null, value);
    return prop;
  }

  /**
   * Returns node name.
   */
  public String getTypeName() {
    return typeName;
  }

  /**
   * Sets/returns value of node.
   */
  public String getContent() {
    return content;
  }

  public void setContent(String value) {
    content = value;
  }

  /** Gets or sets line number */
  public int getLineNumber() {
    return lineNumber;
  }

  public void setLineNumber(int value) {
    lineNumber = value;
  }

  /** Gets or sets column */
  public int getColumn() {
    return column;
  }

  public void setColumn(int value) {
    column = value;
  }

  /**
   * Adds model change listener.
   */
  public void addChangeListener(ModelChangeListener listener) {
    if (modelChangeListeners == null) {
      modelChangeListeners = Lists.newArrayList();
    }
    modelChangeListeners.add(listener);
  }

  /**
   * Removes model change listener.
   */
  public void removeChangeListener(ModelChangeListener listener) {
    if (modelChangeListeners == null) {
      modelChangeListeners = Lists.newArrayList();
    }
    modelChangeListeners.remove(listener);
  }

  private void notifyChangeListeners(ModelProperty property, Object oldValue, Object newValue) {
    if (modelChangeListeners != null) {
      for (ModelChangeListener listener : modelChangeListeners) {
        listener.modelPropertyChanged(property, oldValue, newValue);
      }
    }
  }
}
