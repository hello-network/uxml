part of uxml;

/**
 * Defines a binding of a target object's property to a chain of properties
 * starting from a source object.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class PropertyBinding {

  IKeyValue _targetObject;          // target object for this binding.
  IKeyValue _source;                // root source object.
  Object _targetProp;               // target property.
  List<Object> _propChain;          // property chain for this binding.
  List<Object> _sources;            // source objects we are listening to.
  BindingTransform _valueTransform; // transforms value during binding.
  String _transformArg;             // optional arg to transform function.
  Map<Object, EventHandler> sourceListeners;

  /**
   * Constructs a binding of source object to target object. For example, the
   * following code fragment:
   *    <code>textbox.text = album.metainfo.sizeinfo.duration;</code>
   * or markup:
   *    <textbox text="{album.metainfo.sizeinfo.duration}"/>
   *
   * results in:
   *    targetObject = textbox
   *    targetProp = textPropDef
   *    source = album
   *    propChain = ["metainfo", "sizeinfo", "duration"]
   *
   * The following types of source objects are supported:
   *    1. Classes derived from <code>UxmlElement</code>
   *    2. Objects of type <code>Model</code>
   *    3. Readonly mode: IKeyValue, read/sync: IElementEvents
   *
   * @param target The object to which this binding applies.
   * @param targetProp The property definition or string name of property.
   *                   This can be a dotted property name.
   * @param source The object to which the target is bound to.
   * @param propChain The chain of properties originating from the source.
   */
  PropertyBinding(IKeyValue target, Object targetProperty, IKeyValue source,
      List<Object> propertyChain, [BindingTransform valueTransform = null,
      String transformArg = null]) {
    _targetObject = target;
    _targetProp = targetProperty;
    if ((_targetProp is String) && (_targetObject is UxmlElement)) {
      String targetPath = _targetProp;
      if (targetPath.indexOf('.') == -1) {
        UxmlElement elm = _targetObject;
        PropertyDefinition propDef = elm.getDefinition().findProperty(
            _targetProp);
        if (propDef != null) {
          _targetProp = propDef;
        } else {
          String propName = _targetProp;
          Application.current.log("Find property failed on elementDef "
              "${elm.getDefinition().name} searching for $propName");
        }
      }
    }
    _source = source;
    _propChain = propertyChain;
    _valueTransform = valueTransform;
    _transformArg = transformArg;
    _sources = <IKeyValue>[];
    sourceListeners = new Map<Object, EventHandler>();

    String propName;

    // If source property chain is prefixed with parent. , bind
    // to parent element.
    if (propertyChain.length > 0 && propertyChain[0] is String) {
      propName = propertyChain[0];
      if (propName == "parent" && (source is UxmlElement)) {
        UxmlElement sourceElement = source;
        source = sourceElement.parent;
        propertyChain.removeAt(0);
      }
    }

    if (target == source) {
      if (propertyChain.length > 0 &&
          (propertyChain[0] is PropertyDefinition)) {
        PropertyDefinition targetProp = propertyChain[0];
        if ((targetProp != null) && ((targetProp.flags &
            PropertyFlags.INHERIT) != 0) &&
            targetProp == _targetProp) {
          UxmlElement sourceElement = source;
          source = sourceElement.parent;
          _source = source;
        }
      }
    }

    // initialize the source chain with root source.
    _sources.add(_source);

    // recursively walk the source chain to listen for property change
    // events and compute the initial value
    _bind(source, 0);
  }

  /**
   * Clear all bindings and remove all property change event listeners.
   */
  void clear() {
    _unbind(0);
    _targetObject = null;
    _targetProp = null;
    _source = null;
    _propChain = null;
  }

  /**
   * Recursively binds to the source and listens for property change
   * event on it.
   *
   * @param source The object to listen for property change event.
   * @param propChainIndex Index into chain of properties starting
   *   from source.
   */
  void _bind(Object source, int propChainIndex) {
    if (_propChain.length == 0) {
      _setTargetProperty(source);
      return;
    }
    // now read the first property in the chain
    Object propKey = _propChain[propChainIndex];

    // convert propName to source's property definition.
    if ((propKey is String) && (source is UxmlElement)) {
      UxmlElement elem = source;
      PropertyDefinition property = elem.getDefinition().findProperty(propKey);
      if (property == null) {
        print("Could not locate property $propKey on element type $elem");
      }
      _propChain[propChainIndex] = property;
      propKey = property;
    }

    // add event listener for property change and collection change events
    if (source is IElementEvents) {
      IElementEvents elementEvents = source;
      EventHandler closureVal = _onPropChange;
      if (sourceListeners[propChainIndex] != null) {
        elementEvents.removeListener(propKey, sourceListeners[propChainIndex]);
      }
      sourceListeners[propChainIndex] = closureVal;
      elementEvents.addListener(propKey, closureVal);
    }

    // now get the property value
    Object propValue;
    IKeyValue kv = source;
    try {
      propValue = kv.getProperty(propKey);

      if ((propKey is PropertyDefinition) && kv is UxmlElement) {
        UxmlElement src = kv;
        PropertyDefinition srcProp = propKey;
      }
    } on Exception catch (e) {
      propValue = null;
    }
    if (propValue == null) {
      // TODO(ferhat) this code makes sure that source does have a property by
      // propName, but it is needed for two-way binding to avoid turning both
      // source and target to null or undefined.
      if (kv != null && kv.overridesProperty(propKey) &&
          propChainIndex == (_propChain.length - 1)) {
        _setTargetProperty(propValue);
      }
      return;
    }

    // if there are more items in prop chain, keep going
    if (propChainIndex < (_propChain.length - 1)) {
      // store this source object in sourceChain
      _sources.add(propValue);
      _bind(propValue, propChainIndex + 1);
    } else {
      if (!(identical(propValue, PropertyDefaults.NO_DEFAULT))) {
        _setTargetProperty(propValue);
      }
    }
  }

  /**
   * Removes the binding for all source objects starting from specified index.
   * This removes the event listener for property change and also the object
   * from the source chain.
   */
  void _unbind(int index) {
    if (index >= _sources.length) {
      return;
    }
    // remove event listeners from sources starting from this index
    for (int i = index; i < _sources.length; i++) {
      Object valueSource = _sources[i];
      Object propKey = _propChain[i];

      if (valueSource is IElementEvents) {
        IElementEvents elementEvents = valueSource;
        elementEvents.removeListener(propKey, sourceListeners[i]);
        sourceListeners[i] = null;
      }
    }
    // remove all objects starting from this source
    _sources.removeRange(index, _sources.length);
  }

  /**
   * Handles property change events by rebinding all source objects under the
   * object firing the event.
   */
  void _onPropChange(EventArgs event) {
    if (!(event is PropertyChangedEvent)) {
      return;
    }
    PropertyChangedEvent propChangeEvent = event;

    // find the source object in sourceChain that fired this event
    int index = _sources.indexOf(event.source);
    if (index < 0 || index >= _sources.length) {
      // this should never happen
      List<IKeyValue> s = _sources;
      List<Object> pchain = _propChain;
      Application.current.log("warning: onChange: source not found matching "
          "the event target. ${event.source}");
      return;
    }

    // check if the source has changed (event.property == null) or
    // check if this property exists in our property chain
    if (propChangeEvent.property != null &&
        _propChain.indexOf(propChangeEvent.property, 0) < 0) {
      return;
    } // this should never happen

    // if this is the last prop in the chain, just update its value
    if (index == (_propChain.length - 1)) {
      _setTargetProperty(propChangeEvent.newValue);
    } else {
      // all objects underneath this source are dirty, unbind them
      _unbind(index + 1);
      // now re-bind to all new objects starting from this source
      _bind(event.source, index);
    }
  }

  void _setTargetProperty(Object propValue) {
    if (_valueTransform != null) {
      if (_transformArg != null) {
        propValue = _valueTransform(propValue, _transformArg);
      } else {
        propValue = _valueTransform(propValue, null);
      }
    }
    // set the value of the target.
    if (_targetProp is String) {
      String destPath = _targetProp;
      int pos = destPath.indexOf(".");
      int startPos = 0;
      IKeyValue target = _targetObject;
      PropertyDefinition propDef;
      while (pos != -1) {
        String pathElem = destPath.substring(startPos, pos);
        startPos = pos + 1;
        propDef = null;
        if (target is UxmlElement) {
          UxmlElement targetElm = target;
          propDef = targetElm.getDefinition().findProperty(pathElem);
        }
        if (propDef != null) {
          target = target.getProperty(propDef);
          if (target == null) {
            // Destination is not bound yet.
            // TODO(ferhat): should we listen to target being ready and
            // set property afterwards ?
            return; // Can't set property on nonexisting target.
          }
        } else {
          target = target.getProperty(pathElem);
          if (target == null) {
            // TODO(ferhat): see above.
            return;
          }
        }
        pos = destPath.indexOf(".", startPos);
      }
      if (target != null) {
        target.setProperty(destPath.substring(startPos), propValue);
      }
    } else {
      _targetObject.setProperty(_targetProp, _implicitConv(_targetProp,
          propValue));
    }
  }

  // Performs implicit type conversions.
  Object _implicitConv(PropertyDefinition prop, Object value) {
    if (prop != null) {
      switch(prop.dataType) {
        case PropertyType.STRING:
          if (!(value is String)) {
            return value == null ? "" : value.toString();
          }
          break;
        case PropertyType.INT:
          if (value is int) {
            return value;
          }
          if (value is String) {
            return int.parse(value);
          } else if (value is num) {
            num n = value;
            return n.toInt();
          } else if (value is bool) {
            bool b = value;
            return b ? 1 : 0;
          }
          break;
        case PropertyType.NUMBER:
          if (value is num) {
            return value;
          }
          if (value is String) {
            return double.parse(value);
          } else if (value is bool) {
            bool b = value;
            return b ? 1 : 0;
          }
          break;
        case PropertyType.BOOL:
          if (value is bool) {
            return value;
          }
          if (value is String) {
            String sVal = value;
            return !(sVal == "0" || sVal == "false");
          } else if (value is num) {
            num n = value;
            return n == 0 ? false : true;
          }
          break;
      }
    }
    return value;
  }

  /** BuiltIn value transform for boolean negate. */
  static Object negateBoolean(Object value, String transformArg) {
    bool boolVal = value;
    return !boolVal;
  }
}

typedef Object BindingTransform(Object value, String argument);
