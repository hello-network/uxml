package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Holds additional information about a property for a specific owner-type.
 * This class also defined constants for property flags.
 *
 * @author ferhat
 */
public class PropertyData {

  /**
   * Holds the default Value for a property.
   * This value is returned by Element.getProperty if no
   * override is found in property bag of element
   */
  private Object defaultValue = UxmlElement.UNDEFINED_VALUE;

  /**
   * Holds Property flags
   */
  private EnumSet<PropertyFlags> flags = EnumSet.noneOf(PropertyFlags.class);

  /**
   * Holds event listener to be called when property changes
   */
  PropertyChangeListener propChangeListener;

  /**
   * Holds owner class.
   */
  private Class<? extends UxmlElement> ownerClass;

  /**
   * Constructor.
   */
  public PropertyData() {
  }

  /**
   * Constructor.
   */
  public PropertyData(Object defaultValue,
      EnumSet<PropertyFlags> flags,
      PropertyChangeListener listener) {
    super();
    this.defaultValue = defaultValue;
    this.flags = flags;
    this.propChangeListener = listener;
  }

  /**
   * Constructor.
   */
  public PropertyData(Object defaultValue) {
    this.defaultValue = defaultValue;
  }

  /**
   * Constructor.
   */
  public PropertyData(EnumSet<PropertyFlags> flags) {
    this.flags = flags;
  }

  /**
   * Constructor.
   */
  public PropertyData(Object defaultValue, EnumSet<PropertyFlags> flags) {
    this.defaultValue = defaultValue;
    this.flags = flags;
  }

  /**
   * Constructor.
   */
  public PropertyData(PropertyChangeListener propertyChangeListener) {
    this.propChangeListener = propertyChangeListener;
  }

  /**
   * Constructor.
   */
  public PropertyData(Object defaultValue, PropertyChangeListener propertyChangeListener) {
    this(defaultValue, propertyChangeListener, EnumSet.noneOf(PropertyFlags.class));
  }

  /**
   * Constructor.
   */
  public PropertyData(Object defaultValue, PropertyChangeListener propertyChangeListener,
      EnumSet<PropertyFlags> flags) {
    this.defaultValue = defaultValue;
    this.propChangeListener = propertyChangeListener;
    this.flags = flags;
  }

  /**
   * Returns true if property has a default value.
   */
  public boolean hasDefaultValue() {
    return defaultValue != UxmlElement.UNDEFINED_VALUE;
  }

  /**
   * Returns default value of a property for an owner class
   */
  public Object getDefaultValue() {
    return defaultValue;
  }

  /**
   * Returns property data flags.
   */
  public EnumSet<PropertyFlags> getFlags() {
    return flags;
  }

  /**
   * Returns whether property inherits values from parent elements.
   */
  public boolean getInherits() {
    return flags.contains(PropertyFlags.Inherit);
  }

  /**
   * Returns whether property inherits values from parent elements.
   */
  public boolean getAttached() {
    return flags.contains(PropertyFlags.Attached);
  }

  /**
   * Returns owner of property data.
   */
  public Class<? extends UxmlElement> getOwnerClass() {
    return ownerClass;
  }

  /**
   * Sets owner of property data.
   */
  public void setOwner(Class<? extends UxmlElement> owner) {
    ownerClass = owner;
  }
}
