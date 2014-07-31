part of uxml;

// @author ferhat@ (Ferhat Buyukkokten)

/**
 * ElementDef defines an uxml element, it's properties and list of events.
 */
class ElementDef {
  String name;
  ElementDef parentDef;
  List<PropertyDefinition> properties;
  List<EventDef> _events;

  ElementDef(String elementName, ElementDef parentElement) {
    name = elementName;
    parentDef = parentElement;
  }

  /** Adds a property to an element. */
  PropertyDefinition addProperty(PropertyDefinition prop) {
    if (prop._ownerType == null) {
      prop._ownerType = this;
    }
    if (properties == null) {
      properties = <PropertyDefinition>[];
    }
    properties.add(prop);
    PropertyCache.clearCache(this);
    return prop;
  }

  /** Adds an event to an element. */
  EventDef addEvent(EventDef event) {
    if (_events == null) {
      _events = <EventDef>[];
    }
    _events.add(event);
    return event;
  }

  /**
   * Returns a list of properties for an element.
   */
  List<PropertyDefinition> getPropertyDefinitions({bool composite: false}) {
    if (composite && (parentDef != null)) {
      // Return all properties including super classes and
      // attached properties applicable to control.
      ElementDef elm = this;
      List<PropertyDefinition> allProps = <PropertyDefinition>[];
      while (elm != null) {
        if (elm.properties != null) {
          allProps.addAll(properties);
        }
        elm = elm.parentDef;
      }
      return allProps;
    }
    return properties;
  }

  /**
   * Finds a property definition by name.
   */
  PropertyDefinition findProperty(String propertyName) {
    return PropertyCache.getPropertyDefinition(this, propertyName);
  }

  /**
   * Returns list of events the element raises.
   */
  List<EventDef> get events => _events;

  int get hashCode {
    return name.hashCode;
  }
}

/**
 * Defines an element property and associated behaviour when
 * value change is triggered.
 */
class PropertyDefinition {
  String name;
  int flags;
  int dataType;
  Object _defaultValue;
  ElementDef _ownerType;
  PropertyChangeHandler _changeCallback;

  // Holds default value overrides by element type (ElementDef).
  Map<ElementDef,Object> _defaultOverrides = null;
  // Holds callback overrides by element type (ElementDef).
  Map<String,PropertyChangeHandler> _callbackOverrides = null;

  PropertyDefinition(String name,
                     int type,
                     int propertyFlags,
                     PropertyChangeHandler handler,
                     Object defaultVal) {
    this.name = name;
    _ownerType = null;
    dataType = type;
    flags = propertyFlags;
    _defaultValue = defaultVal;
    _changeCallback = handler;
  }

  PropertyDefinition overrideCallback(ElementDef def,
                                      PropertyChangeHandler handler) {
    if (_callbackOverrides == null) {
      _callbackOverrides = new Map<String,PropertyChangeHandler>();
    }
    _callbackOverrides[def.name] = handler;
    return this;
  }

  PropertyDefinition overrideDefaultValue(ElementDef def, Object value) {
    if (_defaultOverrides == null) {
      _defaultOverrides = new Map<ElementDef,Object>();
    }
    _defaultOverrides[def] = value;
    return this;
  }

  Object getDefaultValue(ElementDef def) {
    if (_defaultOverrides == null) {
      return _defaultValue;
    }
    return _defaultOverrides.containsKey(def) ? _defaultOverrides[def] :
        _defaultValue;
  }

  PropertyChangeHandler getCallback(ElementDef def) {
    if ((_callbackOverrides != null) &&
        _callbackOverrides.containsKey(def.name)) {
      return _callbackOverrides[def.name];
    }
    return _changeCallback;
  }

  int get hashCode => name.hashCode;
}

/**
 * Keeps a list of all registered uxml element classes.
 * Since we don't have a type system, ElementDef's provide a way
 * to do reflection on element properties and events.
 */
class ElementRegistry {
  static Map<String, ElementDef> _elements = null;

  static ElementDef register(String elementName,
                             ElementDef parentElement,
                             List<PropertyDefinition> properties,
                             List<EventDef> eventList) {
    if (_elements == null) {
      // First time initialization of element registry.
      Route._initRoute();
      PropertyDefaults._initDefaults();
      PropertyCache._registerPropertyCache();
      _elements = new Map<String, ElementDef>();
    }
    ElementDef def;
    def = new ElementDef(elementName, parentElement);
    if (properties != null) {
      for (int p = 0; p < properties.length; p++) {
        def.addProperty(properties[p]);
      }
    }
    if (eventList != null) {
      for (int e = 0; e < eventList.length; e++) {
        def.addEvent(eventList[e]);
      }
    }
    _elements[elementName] = def;
    return def;
  }

  /**
   * Returns element definition by class name.
   */
  static ElementDef getElement(String name) {
    return _elements[name];
  }

  /**
   * Registers a property.
   */
  static PropertyDefinition registerProperty(String name, int dataType,
      int propertyFlags, PropertyChangeHandler handler, Object defaultValue) {
    PropertyDefinition propDef = new PropertyDefinition(name, dataType,
        propertyFlags, handler, defaultValue);
    if ((propertyFlags & PropertyFlags.ATTACHED) != 0) {
      UxmlElement.baseElementDef.addProperty(propDef);
    }
    return propDef;
  }

  /**
   * Registers a property with no default value.
   */
  static PropertyDefinition registerPropertyNoDefault(String name,
      int dataType, int propertyFlags, PropertyChangeHandler handler) {
    return new PropertyDefinition(name, dataType, propertyFlags, handler,
        PropertyDefaults.NO_DEFAULT);
  }
}

/**
 * Provides system wide constants for special property values.
 */
class PropertyDefaults {
  static Object NO_DEFAULT;
  static Object NULL_VALUE;

  static void _initDefaults() {
    if (NO_DEFAULT == null) {
      NO_DEFAULT = [];
      NULL_VALUE = [];
    }
  }
}

/**
 * Defines an element event.
 */
class EventDef {

  /** Returns name of event. */
  final String name;

  /** Returns routing style of event. */
  final Route route;

  EventDef(this.name, this.route) {
  }

  /** Holds array of targettype */
  List<ElementDef> targetTypes = null;
  List<EventDefHandler> targetHandler = null;

  /** Adds a handler for a given type */
  void addHandler(ElementDef targetType, EventDefHandler handler) {
    if (targetTypes == null) {
      targetTypes = <ElementDef>[];
      targetHandler = <EventDefHandler>[];
    }
    targetTypes.add(targetType);
    targetHandler.add(handler);
  }

  /** Calls all global event handlers defined on the event definition itself. */
  void callHandler(IKeyValue targetObject, EventArgs arguments) {
    if (targetTypes == null) {
      return;
    }
    int handlerCount = targetTypes.length;
    UxmlElement targetElement = targetObject;
    ElementDef def = targetElement.getDefinition();
    while (def != null) {
      for (int i = 0; i < handlerCount; i++) {
        if (def == targetTypes[i]) {
          targetHandler[i](targetObject, arguments);
        }
      }
      def = def.parentDef;
    }
  }

  int get hashCode => name.hashCode;
}

/** Defines constants for property flags. */
class PropertyFlags {
  static const int NONE = 0;
  static const int INHERIT = 0x0001;
  static const int ATTACHED = 0x0002;
  static const int REDRAW = 0x0004;
  static const int RESIZE = 0x0008;
  static const int RELAYOUT = 0x0010;
  static const int PARENT_RESIZE = 0x0020;
  static const int PARENT_RELAYOUT = 0x0040;
  static const int CREATE_ON_DEMAND = 0x0100;
  static const int LOCALIZABLE = 0x1000;
}

/** Defines constants for semantic property types. */
class PropertyType {
  static const int OBJECT = 0;
  static const int STRING = 1;
  static const int INT = 2;
  static const int NUMBER = 3;
  static const int BOOL = 4;
  static const int UIELEMENT = 5;
  static const int COLOR = 6;
  static const int BRUSH = 7;
  static const int PEN = 8;
  static const int BORDERRADIUS = 9;
  static const int MARGIN = 9;
  static const int CHROME = 10;
  static const int DOCK = 11;
  static const int SCALEMODE = 12;
  // UIElement.HORIZONTAL/VERTICAL.
  static const int ORIENTATION = 13;
  static const int LOCATION = 14;
  // Data Model Object.
  static const int DATA = 15;
  static const int IELEMENTEVENTS = 16;
  static const int APPCONTEXT = 17;
}

typedef void PropertyChangeHandler(IKeyValue element,
                                   Object property,
                                   Object oldValue,
                                   Object newValue);
