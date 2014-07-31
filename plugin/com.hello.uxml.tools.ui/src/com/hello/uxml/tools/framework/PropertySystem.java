package com.hello.uxml.tools.framework;

import java.util.ArrayList;
import java.util.List;

/**
 * Stores framework wide PropertyDefinition objects.
 * It is the central location to publish PropertyDefinitions
 * for authoring tools to access properties registered for
 * Element subclasses.
 *
 * @author ferhat
 *
 */
public class PropertySystem {
  private PropertySystem() {
  }
  /**
   * Holds all PropertyDefinition objects hashed on property name.
   */
  private static ArrayList<PropertyDefinition> properties = new ArrayList<PropertyDefinition>();

  /**
   * Holds unique id counter for PropertyDefinition.
   * This is used as hashCode for key, value map in Element
   */
  private static int uniqueIdCounter = 0;

  /**
   * Registers a new PropertyDefinition
   * @param propertyName Name of Property
   * @param ownerClass Class on which Property is defined
   * @param propData Default value and <code>EventListener</code> definition
   * for property
   * @return registered <code>PropertyDefinition</code>
   */
  public static PropertyDefinition register(String propertyName,
      Class<?> dataType,
      Class<? extends UxmlElement> ownerClass,
      PropertyData propData) {
    int id = uniqueIdCounter++;
    PropertyDefinition propDef = new PropertyDefinition(id, propertyName, dataType, ownerClass,
        propData);
    properties.add(propDef);
    if ((propData != null) && propData.getAttached()) {
      // If property is attached, we should enable lookup on base uielement class.
      propDef.addPropData(UIElement.class, new PropertyData(propData.getDefaultValue(),
          propData.getFlags(), propData.propChangeListener));
    }
    return propDef;
  }

  /**
   * Register a new PropertyDefinition with no property data
   */
  public static PropertyDefinition register(String propertyName,
      Class<?> dataType, Class<? extends UxmlElement> ownerClass) {
    return register(propertyName, dataType, ownerClass, new PropertyData());
  }

  /**
   * Unregisters a property definition
   */
  public static void unregister(PropertyDefinition propDef) {
    properties.remove(propDef);
  }

  /**
   * Get all the property definitions for a class.
   */
  public static List<PropertyDefinition> getPropertyDefinitions(
      Class<? extends UxmlElement>ownerClass) {
    Application.getCurrent().verifyClassLoaded(ownerClass);

    // Create list of properties. ! not using Lists.newArrayList on purpose
    ArrayList<PropertyDefinition> list = new ArrayList<PropertyDefinition>();
    for (PropertyDefinition propDef : properties) {
      if (propDef.getPropData(ownerClass) != null) {
        list.add(propDef);
      }
    }
    return list;
  }
}
