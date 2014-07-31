package com.hello.uxml.tools.codegen.dom;

import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.events.EventDefinition;

/**
 * Exposes a single property for a model item.
 *
 * @author ferhat
 */
public class ModelProperty {

  /** Name of property */
  private final String name;

  /** Holds property value */
  protected Object value;

  /** Target field name of property */
  private String targetName;

  /**
   * If property is member of an Element subclass, this field holds
   * the property definition. Otherwise dataType is used to define value.
   */
  private PropertyDefinition propDef;

  /**
   * If property is member of an Element subclass, this field holds
   * the event definition.
   */
  private EventDefinition eventDef;

  /** Data type of property */
  private Class<?> dataType;

  public ModelProperty(String name, String value) {
    this.name = name;
    this.value = value;
    this.targetName = name;
  }

  /**
   * Sets property definition. This is typically called from
   * ModelParser.
   */
  public void setPropDef(PropertyDefinition propDef) {
    this.propDef = propDef;
    dataType = propDef.getDataType();
  }

  /**
   * Returns property definition.
   */
  public PropertyDefinition getPropDef() {
    return propDef;
  }

  /**
  * Sets event definition. This is typically called from
  * ModelParser.
  */
  public void setEventDef(EventDefinition eventDef) {
   this.eventDef = eventDef;
  }
  /**
   * Returns event definition.
   */
  public EventDefinition getEventDef() {
    return eventDef;
  }

  /** Gets or returns data type of property */
  public void setDataType(Class<?> dataType) {
    this.dataType = dataType;
  }

  public Class<?> getDataType() {
    return dataType;
  }

  /**
   * Returns name of property.
   */
  public String getName() {
    return name;
  }

  /**
   * Sets or returns value of property.
   */
  public Object getValue() {
    return value;
  }

  public void setValue(Object value) {
    this.value = value;
  }

  /**
   * Returns target field name.
   */
  public String getTargetName() {
    return targetName;
  }

  /**
   * Sets target field name. Used for attached properties.
   */
  public void setTargetName(String target) {
    targetName = target;
  }
}
