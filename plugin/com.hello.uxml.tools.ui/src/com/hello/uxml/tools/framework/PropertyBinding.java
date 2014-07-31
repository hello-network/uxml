package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Defines a binding of a target object's property to a chain of properties
 * starting from a source object.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat
 */
public class PropertyBinding {
  private Object targetObject;
  private Object targetProperty;
  private List<Object> sourceChain = new ArrayList<Object>();
  private Object[] propChain;
  private EventHandler listener;
  private ValueTransform valueTransform;
  private String transformArg;
  private static final String ERROR_MSG_NO_MATCHING_TARGET =
      "onChange: can't find source matching the event target.";
  private static final Logger logger = Logger.getLogger(PropertyBinding.class.getName());
  public static ValueTransform negateBoolean = new NegateBooleanTransform();

  /**
   * Constructor.
   */
  public PropertyBinding(UxmlElement targetObject, Object targetProperty,
      Object sourceObject, Object[] propertyChain) {
    this(targetObject, targetProperty, sourceObject, propertyChain, null);
  }

  /**
   * Constructor.
   */
  public PropertyBinding(UxmlElement targetObject, Object targetProperty,
      Object sourceObject, Object[] propertyChain, ValueTransform transform) {
    this(targetObject, targetProperty, sourceObject, propertyChain, transform, null);
  }

  /**
   * Constructor.
   */
  public PropertyBinding(UxmlElement targetObject, Object targetProperty,
      Object sourceObject, Object[] propertyChain, ValueTransform transform, String transformArg) {
    this.targetObject = targetObject;
    this.targetProperty = targetProperty;
    sourceChain.add(sourceObject);
    propChain = new Object[propertyChain.length];
    for (int i = 0; i < propertyChain.length; i++) {
      propChain[i] = propertyChain[i];
    }
    valueTransform = transform;
    this.transformArg = transformArg;
    bind(sourceObject, 0);
  }

  /**
   * Returns target object.
   */
  public Object getTargetObject() {
    return targetObject;
  }

  /**
   * Recursively binds to the source and listens for property change
   * event on it.
   *
   * @param source The object to listen for property change event.
   * @param propChainIndex Chain of properties starting from source.
   */
  private void bind(Object source, int propChainIndex) {

    // now read the first property in the chain
    Object propName = propChain[propChainIndex];

    // add event listener for property change and collection change events
    if (source instanceof EventNotifier) {
      EventNotifier notifier = (EventNotifier) source;
      PropertyDefinition propDef = null;
      // use propdefs if source is Element
      if (propName instanceof PropertyDefinition) {
        propDef = (PropertyDefinition) propName;
      } else {
        propDef = PropertyCache.getPropertyDefinition(
              ((UxmlElement) source).getClass(), (String) propName);
        if (propDef != null) {
          propChain[propChainIndex] = propDef;
        }
        propName = propDef;
      }

      // listen for change event on propName
      listener = new EventHandler() {
        @Override
        public void handleEvent(EventNotifier target, EventArgs e) {
          onPropChange((PropertyChangedEvent) e);
        }
      };
      notifier.addListener(propName, listener);

      //  TODO(ferhat) if source is model, also listen for collection change events
      //  if (source is Model) {
      //    notifier.addListener(CollectionChangedEvent.eventDef, onCollChange);
      //  }
    }

    // now get the property value
    Object prop = null;
    prop = getProperty(source, propName);
    if (prop == null) {
      setProperty(prop);
      return;
    }

    // if there are more items in prop chain, keep going
    if (propChainIndex < propChain.length - 1) {
      // store this source object in sourceChain
      sourceChain.add(prop);
      bind(prop, propChainIndex + 1);
    } else {
      // set the value of the target
      setProperty(prop);
    }
  }

  /**
   * Clear all bindings and remove all property change event listeners.
   */
  public void clear() {
    targetObject = null;
    targetProperty = null;
    sourceChain = null;
    propChain = null;
    unbind(0);
  }

  /**
   * Removes the binding for all source objects starting from specified index.
   * This removes the event listener for property change and also the object
   * from the source chain.
   */
  private void unbind(int index) {
    // remove event listeners from sources starting from this index
    for (int i = index; i < sourceChain.size(); i++) {
      Object source = sourceChain.get(i);
      String propName = (String) propChain[i];

      if (!(source instanceof EventNotifier)) {
        continue;
      }

      EventNotifier notifier = (EventNotifier) source;

      notifier.removeListener(propName, listener);
      listener = null;

      // TODO(ferhat) implement unbind for Model
      // if (source is Model) {
      //   notifier.removeListener(CollectionChangedEvent.eventDef, onCollChange);
      // }
    }
    // remove all objects starting from this source
    sourceChain.remove(index);
  }

  /**
   * Handles property change events by rebinding all source objects under the
   * object firing the event.
   */
  private void onPropChange(PropertyChangedEvent event) {
    // find the source object in sourceChain that fired this event
    int index = sourceChain.indexOf(event.getSource());
    if (index < 0 || index >= sourceChain.size()) {
      // this should never happen
      logger.log(Level.WARNING, ERROR_MSG_NO_MATCHING_TARGET);
      return;
    }

    // check if this property exists in our property chain
    if (!propChain[index].equals(event.getProperty())) {
        return; // this should never happen
    }

    // if this is the last prop in the chain, just update its value
    if (index == (sourceChain.size() - 1)) {
      setProperty(event.getNewValue());
    } else {
      // all objects underneath this source are dirty, unbind them
      unbind(index);

      // now re-bind to all new objects starting from this source
      bind(event.getSource(), index);
    }
  }

  // TODO(ferhat): implement Model rebinding
  //  /**
  //   * Handles collection change events by rebinding all source objects under
  //   * the object firing the event.
  //   */
  //  public void onCollChange(event:CollectionChangedEvent):void {
  //    // find the source object in sourceChain that fired this event
  //    var sourceIndex:int = sourceChain.indexOf(event.source);
  //  if (sourceIndex < 0 || sourceIndex >= sourceChain.length) {
  //    // this should never happen
  //    trace("WARN", "onChange: source not found matching the event target.");
  //    return;
  //  }
  //
  //  // check if this property exists in our property chain
  //  if (propChain[sourceIndex] != event.index.toString())
  //    return; // this should never happen
  //
  //  // all objects underneath this source are dirty, unbind them
  //  unbind(sourceIndex);
  //
  //  // now re-bind to all new objects starting from this source
  //  bind(event.source, sourceIndex);
  //  }

  /**
   * Gets the property on a source object.
   */
  private Object getProperty(Object source, Object propName) {
    // if source is Element, use propDefs to access the property
    if (source instanceof UxmlElement) {
      // check if propName is PropertyDefinition
      PropertyDefinition propDef = (PropertyDefinition) propName;

      if (propDef != null) {
        return ((UxmlElement) source).getProperty(propDef);
      } else {
      return null;
    }
    // TODO(ferhat):Model
    //} else if (source is Model) {
    //  return Model(source).getProperty(propName as String);
    } else {
      return Application.getCurrent().readDynamicValue(source, (String) propName);
    }
  }

  /** Sets the property on the target object to the specified value. */
  private void setProperty(Object value) {
    if (valueTransform != null) {
      value = valueTransform.transformValue(value, transformArg);
    }
    // if target object is Element, use propDefs to set the property
    if (targetObject instanceof UxmlElement) {

      // if targetPropDef is not cached, do so now
      if (targetProperty instanceof String) {
        targetProperty = PropertyCache.getPropertyDefinition(
            ((UxmlElement) targetObject).getClass(), (String) targetProperty);
      }
      if (targetProperty != null) {
        ((UxmlElement) targetObject).setProperty((PropertyDefinition) targetProperty, value);
      }
      // TODO(ferhat): Add model support for PropertyBinding.setProperty
      //    } else if (targetObject is Model) {
      //
      //      // if targetProp is numeric, it is an index otherwise a property
      //      var index:int = parseInt(targetProp as String);
      //    if (isNaN(index))
      //      Model(targetObject).setProperty(targetProp as String, value);
      //    else
      //      Model(targetObject).setItemAt(index, value);
    } else {
      Application.getCurrent().writeDynamicValue(targetObject, (String) targetProperty, value);
    }
  }

  /**
   * Implements negate boolean value transform for bindings.
   */
  public static class NegateBooleanTransform implements ValueTransform {
    @Override
    public Object transformValue(Object value, Object transArg) {
      if (value instanceof Boolean) {
        return !((Boolean) value);
      }
      return !Boolean.valueOf(String.valueOf(value));
    }
  }
}
