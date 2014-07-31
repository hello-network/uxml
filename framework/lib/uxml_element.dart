part of uxml;

/**
 * Element interface for property system.
 */
abstract class IKeyValue {
  void setProperty(Object key, Object value);
  Object getProperty(Object key);
  void clearProperty(Object key);
  bool overridesProperty(Object key);
}

/**
 * Element interface for events.
 */
abstract class IElementEvents {
  void addListener(Object type,
                   EventHandler handler,
                   [bool useCapture = false]);
  void removeListener(Object type, EventHandler handler);
  bool hasListener(Object type);
  void notifyListeners(Object type, EventArgs e);
}

/** Provides common functionality elements. **/
class UxmlElement implements IElementEvents, IKeyValue {
  static PropertyDefinition dataProperty;
  static ElementDef baseElementDef;

  // Maps event type to an array of listeners.
  Map<Object, List<EventHandler>> listeners = null;
  // Maps event type to capture listener for event.
  Map<Object, EventHandler> _captureListeners = null;
  // Reused list of elements for eliminating allocations during bubble/capture
  // event routing.
  static List<UxmlElement> _eventRoute = <UxmlElement>[];

  // Specifies if element is currently calling listeners.
  int callingListenersDepth = 0;
  // If a client listens to all event types using ALL_EVENT_TYPES,
  // this flag is set to true to enable extra post notify lookup.
  bool hasGlobalListener = false;
  // Event type used to listen to all events on element.
  static final Object ALL_EVENT_TYPES = "__allevents__";
  // Contains a map from bindable key to property value.
  Map<Object , Object> _propBag = null;
  UxmlElement parent = null;

  // Constant for null value support.
  static Object _nullValue;

  /**
   * Holds bindings for this elements properties.
   */
  List<PropertyBinding> _bindings = null;

  /**
   * Sets or returns id of element.
   */
  String id;

  UxmlElement() {
  }

  /**
   * Adds a listener for an event on this element.
   */
  void addListener(Object type,
                   EventHandler listener,
                   [bool useCapture = false]) {
    if (useCapture) {
      if (_captureListeners == null) {
        _captureListeners = new Map<Object, EventHandler>();
      } else if (_captureListeners.containsKey(type)) {
        throw new ArgumentError("Capture event already set for this event.");
      }
      _captureListeners[type] = listener;
      return;
    }
    if (listeners == null) {
      listeners = new Map<Object, List<EventHandler>>();
    }
    List<EventHandler> listenersForType = listeners[type];
    if (listenersForType == null) {
      listenersForType = <EventHandler>[];
      listeners[type] = listenersForType;
    }
    if (listenersForType.indexOf(listener) == -1) {
      listenersForType.add(listener);
    }
    if (type == ALL_EVENT_TYPES) {
      hasGlobalListener = true;
    }
  }

  /**
   * Removes a listener for an event on this element.
   */
  void removeListener(Object type, EventHandler listener) {
    if (listeners != null) {
      List<EventHandler> listenersForType = listeners[type];
      if (listenersForType != null) {
        int index = listenersForType.indexOf(listener);
        if (index == -1) {
          print("!!! Removing nonexisting listener1:$listener");
        }
        if (callingListenersDepth > 0) {
          if (index != -1) {
            listenersForType[index] = null;
            return;
          }
        } else {
          if (index != -1) {
            listenersForType.removeAt(index);
            return;
          }
        }
      } else {
        print("!!! Removing nonexisting listener2:$listener");
      }
    }
    if (_captureListeners != null) {
      if (_captureListeners.containsKey(type)) {
        _captureListeners.remove(type);
        if (_captureListeners.length == 0) {
          _captureListeners = null;
        }
      }
    }
  }

  /** Returns true if anyone is listening to an event. */
  bool hasListener(Object type) {
    return (listeners != null) && (listeners[type] != null &&
        (listeners[type].length != 0)) ||
        (_captureListeners != null && _captureListeners.containsKey(type));
  }

  /** Calls all instance listeners on the event. */
  void notifyListeners(Object type, EventArgs e) {
    if (listeners != null) {
      List<EventHandler> listenersForType = listeners[type];
      if (listenersForType != null) {
        int len = listenersForType.length;
        for (int i = 0; i < len; i++) {
          if (listenersForType[i] == null) {
            listenersForType.removeAt(i);
            --i;
            --len;
          } else {
            ++callingListenersDepth;
            listenersForType[i](e);
            --callingListenersDepth;
          }
        }
      }
      if (hasGlobalListener) {
        listenersForType = listeners[ALL_EVENT_TYPES];
        if (listenersForType == null) {
          return;
        }
        for (int i = 0; i < listenersForType.length; i++) {
          EventHandler listener = listenersForType[i];
          if (listener == null && (callingListenersDepth == 0)) {
            listenersForType.removeAt(i);
            --i;
          } else {
            callingListenersDepth++;
            listener(e);
            callingListenersDepth--;
          }
        }
      }
    }
    if (_captureListeners != null) {
      EventHandler captureHandler = _captureListeners[type];
      if (captureHandler != null) {
        captureHandler(e);
      }
    }
  }

  /**
   * Routes an event starting at this element based on routing strategy.
   */
  void routeEvent(EventArgs eventArgs) {
    EventDef event = eventArgs.event;
    if (event.route != Route.BUBBLE) {
      _raiseEvent(eventArgs);
      return;
    }
    // Build route from parent down to node.
    int routeLength = 0;
    int maxRoute = _eventRoute.length;
    UxmlElement node = this;
    do {
      if (routeLength >= maxRoute) {
        _eventRoute.add(node);
      } else {
        _eventRoute[routeLength] = node;
      }
      ++routeLength;
      node = node.parent;
    } while (node != null);

    // Now check if any parent on route wants to capture event.
    for (int r = routeLength - 1; r >= 0; r--) {
      node = _eventRoute[r];
      if (node._captureListeners != null &&
          node._captureListeners.containsKey(event)) {
        node._captureListeners[event](eventArgs);
        if (eventArgs.handled) {
          return;
        }
        // Remove the node from event route so that it is not fired in bubble
        // phase.
        _eventRoute.remove(node);
        routeLength--;
      }
    }
    for (int r = 0; r < routeLength; r++) {
      _eventRoute[r]._raiseEvent(eventArgs);
      if (eventArgs.handled) {
        return;
      }
    }
  }

  /** Calls all instance and static listeners on an event. */
  void _raiseEvent(EventArgs eventArgs) {
    eventArgs.currentSource = this;
    eventArgs.event.callHandler(this, eventArgs);
    notifyListeners(eventArgs.event, eventArgs);
  }

  /**
   * Sets a property value. It store the value in the
   * propBag map and triggers callbacks and handlers registered
   * for property.
   */
  void setProperty(Object key, Object value) {
    Object oldValue = getProperty(key);

    if (_propBag == null) {
      _propBag = new Map<Object, Object>();
    }

    // Store null values as _nullValue in propertyBag. So we don't have to do
    // 2 lookups (map.contains(key) + map[key]) to determine override.
    _propBag[key] = value == null ? _nullValue : value;

    if (identical(oldValue, value)) {
      return;
    }

    PropertyChangeHandler changeHandler = null;
    PropertyDefinition prop;
    if (key is PropertyDefinition) {
      prop = key;
      changeHandler = prop.getCallback(getDefinition());
    }
    if (changeHandler != null) {
      changeHandler(this, key, oldValue, value);
    }
    // Call property change to allow subclasses such as Model to override
    // and observe all changes.
    onPropertyChanged(key, oldValue, value);

    // notify property change listeners
    if (hasListener(key)) {
      PropertyChangedEvent propEvent = PropertyChangedEvent.create(
        this, key, oldValue, value);
      notifyListeners(key, propEvent);
      PropertyChangedEvent.release(propEvent);
    }
  }

  /**
   * Get the property value given its definition. The function returns the
   * value immediately if it was set before. If the property inherits its
   * value, it walks up the UI parent chain. As last fallback it looks
   * up the default value in the property definition registered for the
   * ElementDef or owner of property.
   */
  Object getProperty(Object key) {
    if (_propBag != null) {
      Object res = _propBag[key];
      if (identical(res, _nullValue)) {
        return null;
      }
      if (res != null) {
        return res;
      }
    }
    // If value is inherited. Walk up the chain of elements to get possible
    // override.
    if (key is String) {
      return null;
    }
    if (key is PropertyDefinition) {
      PropertyDefinition property = key;
      if ((property.flags & PropertyFlags.INHERIT) != 0) {
        UxmlElement p = parent;
        while (p != null) {
          if (p._propBag != null) {
            Object parentVal = p._propBag[property];
            if (identical(parentVal, _nullValue)) {
              return null;
            }
            if (parentVal != null) {
              return parentVal;
            }
          }
          p = p.parent;
        }
      }
      if ((property.flags & PropertyFlags.CREATE_ON_DEMAND) != 0) {
        Object res = createOnDemand(property);
        if (_propBag == null) {
          _propBag = new Map<Object, Object>();
        }
        _propBag[key] = res;
        // Call class listeners.
        PropertyChangeHandler changeHandler = property.getCallback(
            getDefinition());
        if (changeHandler != null) {
          changeHandler(this, property, null, res);
        }
        return res;
      }
      // no explicit value found anywhere, use defaults
      return property.getDefaultValue(getDefinition());
    }
    return null;
  }

  void clearProperty(Object key) {
    if (_propBag != null) {
      if (_propBag.containsKey(key)) {
        Object oldValue = _propBag[key];
        _propBag.remove(key);
        Object newValue = getProperty(key);
        if ((oldValue != newValue) && (key is PropertyDefinition)) {
          PropertyDefinition property = key;
          PropertyChangeHandler handler = property.getCallback(
              getDefinition());
          if (handler != null) {
            handler(this, property, oldValue, newValue);
          }
          onPropertyChanged(key, oldValue, newValue);
          if (hasListener(key)) {
            PropertyChangedEvent propEvent = PropertyChangedEvent.create(
                this, key, oldValue, newValue);
            notifyListeners(key, propEvent);
            PropertyChangedEvent.release(propEvent);
          }
        }
      }
    }
  }

  /**
   * Returns true if property value is explicitly set on this element.
   */
  bool overridesProperty(Object key) {
    return (_propBag != null) && _propBag.containsKey(key);
  }

  void onPropertyChanged(Object propertyKey, Object oldVal, Object newVal) {
  }

  /**
   * Sets or return data model for element.
   */
  Model get data {
    return getProperty(dataProperty);
  }

  void set data(Model value) {
    setProperty(dataProperty, value);
  }

  /**
   * Animates a property values to targetValue and calls callback when done.
   */
  AnimateAction animate(Object propertyKey,
                        Object targetValue,
                        {int duration: 250,
                        TaskCompleteCallback callback : null,
                        int delay: 0}) {
    AnimateAction action = new AnimateAction();
    action.duration = duration;
    action.delay = delay;
    action.fromValue = getProperty(propertyKey);
    action.toValue = targetValue;
    action.property = propertyKey;
    action.completeCallback = callback;
    action.start(this, this);
    return action;
  }

  /**
   * Returns true if this is a child of element.
   */
  bool isChildOf(UxmlElement element) {
    UxmlElement p = this;
    while (p != null) {
      if (p.parent == element) {
        return true;
      }
      p = p.parent;
    }
    return false;
  }

  bool get hasBindings {
    return _bindings != null;
  }

  List<PropertyBinding> get bindings {
    if (_bindings == null) {
      _bindings = <PropertyBinding>[];
    }
    return _bindings;
  }

  /** Creates a property value on demand when accessed. */
  Object createOnDemand(PropertyDefinition property) {
    return null;
  }

  /**
   * Returns element definition for a class of elements. Properties and
   * event reflection is provided through the definition.
   */
  ElementDef getDefinition() => baseElementDef;

  /** Registers component. */
  static void registerElement() {
    if (baseElementDef != null) {
      return;
    }
    PropertyDefaults._initDefaults();
    _nullValue = PropertyDefaults.NULL_VALUE;
    dataProperty = ElementRegistry.registerProperty("data",
        PropertyType.DATA, PropertyFlags.INHERIT, null, null);
    baseElementDef = ElementRegistry.register("UxmlElement", null,
        [dataProperty], null);
  }
}

typedef void EventHandler(EventArgs e);
typedef void TaskCompleteCallback(Action action, Object data);
