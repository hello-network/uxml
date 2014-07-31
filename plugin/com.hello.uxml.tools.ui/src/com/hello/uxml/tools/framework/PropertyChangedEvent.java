package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;

/**
 * Encapsulates property change details for listeners.
 *
 * @author ferhat
 */
public class PropertyChangedEvent extends EventArgs {

  @SuppressWarnings("unused")
  private static final long serialVersionUID = 0;

  private PropertyDefinition propDef;
  private Object oldValue;
  private Object newValue;

  /**
   * Constructs <code>PropertyChangeEvent</code> object
   * @param source Source of property change event
   * @param propDef property definition
   * @param oldValue Old property value
   * @param newValue New property value
   */
  public PropertyChangedEvent(Object source, PropertyDefinition propDef, Object oldValue,
      Object newValue) {
    super(source, null);
    this.propDef = propDef;
    this.oldValue = oldValue;
    this.newValue = newValue;
  }

  /**
   * Returns property that was changed.
   */
  public PropertyDefinition getProperty() {
    return propDef;
  }

  /**
   * Returns value of property before the change.
   */
  public Object getOldValue() {
    return oldValue;
  }

  /**
   * Returns value of property after the change.
   */
  public Object getNewValue() {
    return newValue;
  }
}
