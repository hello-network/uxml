package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.effects.AnimateAction;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.EventListener;
import java.util.HashMap;
import java.util.List;

/**
 * Base class for framework objects that use the PropertySystem to store
 * attributes.
 *
 * @author ferhat
 */
public class UxmlElement extends EventNotifier {
  /**
   * Holds unique object that represents an unset value in property system
   */
  public static final Object UNDEFINED_VALUE = new Object();

  /** Id Property Definition */
  public static PropertyDefinition idPropDef = PropertySystem.register("id", String.class,
      UxmlElement.class, new PropertyData(""));

  /** Data Property Definition */
  public static PropertyDefinition dataPropDef = PropertySystem.register("data", Object.class,
      UxmlElement.class, new PropertyData(null, EnumSet.of(PropertyFlags.Inherit)));

  /**
   * Holds the property values hashed by property definition
   */
  private HashMap<PropertyDefinition, Object> propMap = null;

  private List<PropertyBinding> bindings = null;

  /**
   * Holds parent in Element tree
   */
  protected UxmlElement parent = null;

  /**
   * Construct an Element instance
   */
  protected UxmlElement() {
    super();
  }

  /**
   * Returns true if property value was explicitly set on this element.
   */
   public boolean overridesProperty(PropertyDefinition propDef) {
     return (propMap != null) && propMap.containsKey(propDef);
   }

  /**
   * Get the property value given its definition. The function returns the
   * value immediately if it was set before. If the property inherits its
   * value, it walks up the UI parent chain. As last fallback it looks
   * up the default value in the property definition registered to self or
   * any superclass.
   */
  public Object getProperty(PropertyDefinition propDef) {

    // Return value directly if explicitly set in property map
    if ((propMap != null) && propMap.containsKey(propDef)) {
      return propMap.get(propDef);
    }

    PropertyData propData = propDef.getPropData(this.getClass());
    if (propData == null) {
      propData = propDef.getDefaultPropData();
      if (!propData.getAttached()) {
        return UxmlElement.UNDEFINED_VALUE;
      }
    }
    if (propData.getInherits()) {
      // Check if any parent element overrides this property explicitly
      // If not use default value
      UxmlElement parentElm = parent;
      while (parentElm != null) {
        HashMap<PropertyDefinition, Object> parentProperties = parentElm.propMap;
        if ((parentProperties != null) && parentProperties.containsKey(propDef)) {
          return parentProperties.get(propDef);
        }
        parentElm = parentElm.parent;
      }
    }
    return propData.getDefaultValue();
  }

  /**
   * Sets property value for a given property definition.
   */
  public void setProperty(PropertyDefinition propDef, Object value) {
    Object oldValue = getProperty(propDef);
    if (propMap == null) {
      propMap = new HashMap<PropertyDefinition, Object>();
    }
    propMap.put(propDef, value);

    // If value has changed call property change listeners registered on ownerclass.
    if ((oldValue != value) && ((oldValue == null) || (!oldValue.equals(value)))) {
      // call property change to allow overrides derived classes
      onPropertyChanged(propDef, oldValue, value);

      // notify property change listeners
      PropertyChangedEvent propChangedArgs = null;
      if (hasListener(propDef)) {
        if (propChangedArgs == null) {
          propChangedArgs = new PropertyChangedEvent(this, propDef, oldValue, value);
        }
        notifyListeners(propDef, propChangedArgs);
      }
      PropertyData propData = propDef.getPropData(this.getClass());
      if ((propData != null) && (propData.propChangeListener != null)) {
        if (propChangedArgs == null) {
          propChangedArgs = new PropertyChangedEvent(this, propDef, oldValue, value);
        }
        propData.propChangeListener.propertyChanged(propChangedArgs);
      }
    }
  }

  /**
   * Clears the property value.
   */
   public void clearProperty(PropertyDefinition propDef) {
     if (propMap == null) {
       return;
     }
     propMap.remove(propDef);
   }

  /**
   * Overridable function that gets called when an element property changes.
   */
  protected void onPropertyChanged(PropertyDefinition propDef, Object oldValue, Object newValue) {
  }

  /**
   * Returns parent of element.
   */
  public UxmlElement getParent() {
    return parent;
  }

  /** Gets or sets the id of an element */
  public String getId() {
    return (String) getProperty(idPropDef);
  }

  public void setId(String value) {
    setProperty(idPropDef, value);
  }

  /** Gets or sets the data object */
  public Object getData() {
    return getProperty(dataPropDef);
  }

  public void setData(Object value) {
    setProperty(dataPropDef, value);
  }

  /**
   * Returns binding collection for element.
   */
  public List<PropertyBinding> getBindings() {
    if (bindings == null) {
      bindings = new ArrayList<PropertyBinding>();
    }
    return bindings;
  }

  /**
   * Animates a property values to targetValue and calls callback when done.
   */
  public AnimateAction animate(PropertyDefinition property, Object targetValue) {
    return animate(property, targetValue, 250, 0, null);
  }
  /**
   * Animates a property values to targetValue and calls callback when done.
   */
  public AnimateAction animate(PropertyDefinition property, Object targetValue,
      int duration, int delay, EventListener completeCallback) {
    AnimateAction action = new AnimateAction();
    action.setDuration(duration);
    action.setDelay(delay);
    action.setFromValue(getProperty(property));
    action.setToValue(targetValue);
    action.setProperty(property);
    action.setCompleteCallback(completeCallback);
    action.start(this, this);
    return action;
  }

  /**
   * Returns true if this is a child of element.
   */
  public boolean isChildOf(UxmlElement element) {
    UxmlElement p = this;
    while (p != null) {
      if (p.parent == element) {
        return true;
      }
      p = p.parent;
    }
    return false;
  }
}
