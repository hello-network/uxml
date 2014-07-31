part of uxml;

/**
 * Defines a data model for arbitrary entities.
 * It is similar to JSON and provides IKeyValue, IElementEvents to support
 * property binding and notifications.
 */
class Model implements IKeyValue, IElementEvents {
  List<Object> _children = null;
  // TODO(ferhat): remove names
  Map<String, Object> _properties;
  // Maps event type to an array of listeners.
  Map<Object, List<EventHandler>> _listeners = null;
  // Specifies if element is currently calling listeners.
  bool _isCallingListeners = false;
  // If a client listens to all event types using ALL_EVENT_TYPES,
  // this flag is set to true to enable extra post notify lookup.
  bool _hasGlobalListener = false;
  String _name = "";

  Model() {
    _properties = new Map<String, Object>();
  }

  void setChildAt(int index, value) {
    _children[index] = value;
  }

  Model.fromMap(Map m) {
    _properties = new Map<String, Object>();
    _loadMap(m);
  }

  void _loadMap(Map m) {
    m.forEach((String key, Object value) {
        if (value is Map) {
          Model child = new Model.fromMap(value);
          setMember(key, child);
        } else {
          setMember(key, value);
        }
      });
  }

  /** Returns number of children */
  int get length => _children == null ? 0 : _children.length;

  List<Object> get children => _children;

  Object getChildAt(int index) {
    return _children[index];
  }

  /**
   * Sets or returns key for model.
   *
   * These are not getter/setters since
   * model.name is a valid and supported entity property.
   */
  String getName() {
    return _name;
  }

  void setName(String elementName) {
    _name = elementName;
  }

  /**
   * Removes a child from children collection.
   */
  void removeChild(Object child) {
    if (_children == null) {
      return;
    }
    int index = _children.indexOf(child);
    if (index < 0) {
      return;
    }
    _raiseChangedEvent(index, 1, CollectionChangedEvent.CHANGETYPE_REMOVING);
    _children.removeAt(index);
    _raiseChangedEvent(index, 1, CollectionChangedEvent.CHANGETYPE_REMOVE);
  }

  /**
   * Returns children by name. If no children exist, returns empty collection.
   */
  Model getChildrenByName(String name) {
    Model res = getMember(name);
    if (res == null) {
      res = new Model();
    }
    return res;
  }

  /**
   * Gets the index of a given child.
   */
  int indexOf(dynamic child) {
    return _children.indexOf(child);
  }


  /**
   * Add multiple items to the children array at the specified index.
   * @param index The index to insert the children at. If index is -1, the
   * children are appended.
   * @param items The items to add.
   */
  void insertChildren(int index, List items) {
    if (items == null || items.length == 0) {
      return;
    }
    int count = items.length;
    if (_children == null) {
      _children = [];
    }
    if (index == -1) {
      index = _children.length;
    }
    for (int i = 0; i < count; i++) {
      _children.insert(index + i, _toModel(items[i]));
    }
    _raiseChangedEvent(index, count, CollectionChangedEvent.CHANGETYPE_ADD);
  }

  /**
   * Inserts a single item to the children array at the specified index.
   * @param index The index to add the item to. If index is -1, item is
   * added to the end of the array.
   * @param item The item to add.
   */
  void insertChild(int index, Object item) {
    if (_children == null) {
      _children = [];
    }
    if (index == -1) {
      index = _children.length;
    }
    _children.insert(index, _toModel(item));
    _raiseChangedEvent(index, 1, CollectionChangedEvent.CHANGETYPE_ADD);
  }


  void _raiseChangedEvent(int index, int count, int type) {
    if (!hasListener(CollectionChangedEvent.eventDef)) {
     return;
    }

    CollectionChangedEvent event = CollectionChangedEvent.create(
        this, type, index, count);
    notifyListeners(CollectionChangedEvent.eventDef, event);
    CollectionChangedEvent.release(event);
  }

  dynamic operator[](String name) => getMember(name);

  operator[]=(String name, dynamic value) => setMember(name, value);

//  noSuchMethod(Invocation invocation) {
//    final functionName = MirrorSystem.getName(invocation.memberName);
//    List args = invocation.positionalArguments;
//    if (invocation.isSetter) {
//      setMember(functionName.substring(0, functionName.length - 1), args[0]);
//    } else if (invocation.isGetter) {
//      return getMember(functionName);
//    } else if (functionName.startsWith("set:")) {
//      String memberName = functionName.substring(4);
//      // TODO(dgrove): remove when VM supports isSetter
//      setMember(memberName, args[0]);
//    } else if (functionName.startsWith("get:")) {
//      String memberName = functionName.substring(4);
//      // TODO(dgrove): remove when VM supports isGetter
//      return getMember(memberName);
//    } else if (functionName.endsWith("=")) {
//      String memberName = functionName.substring(0, functionName.length - 1);
//      setMember(memberName, args[0]);
//    } else {
//      return getMember(functionName);
//    }
//  }

  /** Returns value of a named member. */
  Object getMember(String name) {
    if (name.indexOf(".", 0) == -1) {
      if (_properties.containsKey(name)) {
        return _properties[name];
      }
      Model collection = null;
      if (_children != null) {
        for (int c = 0; c < _children.length; c++) {
          Object child = _children[c];
          if (child is Model) {
            Model childModel = child;
            if (childModel.getName() == name) {
              if (collection == null) {
                collection = new Model();
              }
              collection.addChild(childModel);
            }
          }
        }
      }
      return collection;
    } else {
      List<String> parts = name.split(".");
      Model m = this;
      for (int p = 0; p < (parts.length - 1); p++) {
        m = m.getMember(parts[p]);
      }
      return m.getMember(parts[parts.length -1]);
    }
  }

  bool hasProperty(String name) {
    return _properties.containsKey(name);
  }

  /**
   * Convert a map or list into a Model.
   */
  static Model fromObject(Object obj) {
    Model model = new Model();
    _readObject(obj, model);
    return model;
  }

  /**
   * Clears all properties and children of model.
   */
  void clear() {
    _children = null;
    _properties = new Map<String, Object>();
    if (_listeners != null) {
      _listeners.clear();
    }
  }

  /**
   * Reads a map or list into this model.
   */
  void loadFromObject(Object obj) {
    clear();
    _readObject(obj, this);
  }

  static void _readObject(Object obj, Model target) {
    if (obj is Map) {
      _loadFromMap(obj, target);
      return;
    }
    if (obj is List) {
      List list = obj;
      int len = list.length;
      for (int i = 0; i < len; i++) {
        Object member = list[i];
        target.addChild(_toModel(member));
      }
      return;
    }
  }

  static Object _toModel(value) {
    if (value is Map) {
      Model mapNode = new Model();
      Map map = value;
      for (Object key in map.keys) {
        Object val = map[key];
        Object res = _toModel(val);
        mapNode.setChildByName(key, res);
      }
      return mapNode;
    }
    if (value is List) {
      List list = value;
      int len = list.length;
      Model listNode = new Model();
      for (int i = 0; i < len; i++) {
        Object member = _toModel(list[i]);
        listNode.addChild(member);
      }
      return listNode;
    }
    return value;
  }

  static void _loadFromMap(Map map, Model target) {
    for (Object key in map.keys) {
      Object val = map[key];
      Object res = _toModel(val);
      target.setChildByName(key, res);
    }
  }

  /**
   * Creates a new named child.
   */
  void setMember(String name, Object value) {
    if (name.indexOf(".", 0) != -1) {
      throw new ArgumentError(
          "Model name = $name not supported yet.");
    }
    Object oldValue = _properties[name];
    setChildByName(name, value);
    if (hasListener(name)) {
      PropertyChangedEvent propEvent = PropertyChangedEvent.create(
          this, name, oldValue, value);
      notifyListeners(name, propEvent);
      PropertyChangedEvent.release(propEvent);
    }
  }

  /**
   * Creates a new named child. TODO(ferhat):deprecate.
   */
  void setChildByName(String name, Object value) {
    if (value is Model) {
      Model m = value;
      m._name = name;
    }
    if (_properties[name] != null) {
      removeChild(_properties[name]);
    }
    if (value is Map) {
      value = Model.fromObject(value);
    }
    _properties[name] = value;
    if (name != "_repeatable_") {
      if (_children == null) {
        _children = [];
      }
      _children.add(value);
    }
  }

  /**
   * Adds a child model.
   */
  void addChild(Object model) {
    if (_children == null) {
      _children = [];
    }
    _children.add(model);

    _raiseChangedEvent(_children.length - 1, 1,
        CollectionChangedEvent.CHANGETYPE_ADD);
  }

  /**
   * Removes items from the children array at the specified index.
   * @param index The index from where to remove the item.
   * @param count The number of items removed. If count is -1, all items
   * after index are removed.
   */
  void removeChildren(int index, int count) {
    if (_children == null) {
      return;
    }

    if (index >= 0 && index < _children.length) {
      if (count < 0) {
        count = _children.length - index;
      }
      _children.removeRange(index, index + count);
      _raiseChangedEvent(index, count,
          CollectionChangedEvent.CHANGETYPE_REMOVE);
    }
  }

  /** @see IKeyValue. */
  void setProperty(Object key, Object value) {
    setMember(key, value);
  }

  /** @see IKeyValue. */
  Object getProperty(Object key) {
    return getMember(key);
  }

  /** @see IKeyValue. */
  void clearProperty(Object key) {
    _properties.remove(key);
  }

  /** @see IKeyValue. */
  bool overridesProperty(Object key) {
    if (key is String) {
      String strKey = key;
      return _properties.containsKey(key);
    }
    return false;
  }

  /** @see IElementEvents. */
  void addListener(Object type,
                   EventHandler listener,
                   [bool useCapture = false]) {
    if (useCapture) {
      throw new UnsupportedError("Capture is not support for model events");
    }
    if (_listeners == null) {
      _listeners = new Map<Object, List<EventHandler>>();
    }
    List<EventHandler> listenersForType = _listeners[type];
    if (listenersForType == null) {
      listenersForType = <EventHandler>[];
      _listeners[type] = listenersForType;
    }
    if (listenersForType.indexOf(listener) == -1) {
      listenersForType.add(listener);
    }
    if (type == UxmlElement.ALL_EVENT_TYPES) {
      _hasGlobalListener = true;
    }
  }

  /** @see IElementEvents. */
  void removeListener(Object type, EventHandler listener) {
    if (_listeners == null) {
      return;
    }
    List<EventHandler> listenersForType = _listeners[type];
    if (listenersForType != null) {
      int index = listenersForType.indexOf(listener);
      if (_isCallingListeners) {
        if (index != -1) {
          listenersForType[index] = null;
        }
      } else {
        if (index != -1) {
          listenersForType.removeAt(index);
        }
      }
    }
  }

  /** @see IElementEvents. */
  bool hasListener(Object type) {
    return (_listeners != null) && (_listeners[type] != null &&
        (_listeners[type].length != 0));
  }

  /** @see IElementEvents. */
  void notifyListeners(Object type, EventArgs e) {
    if (_listeners == null) {
      return;
    }
    List<EventHandler> listenersForType = _listeners[type];
    _isCallingListeners = true;
    if (listenersForType != null) {
      int len = listenersForType.length;
      for (int i = 0; i < len; i++) {
        EventHandler listener = listenersForType[i];
        if (listener == null) {
          listenersForType.removeAt(i);
          --i;
          --len;
        } else {
          listener(e);
        }
      }
    }
    if (_hasGlobalListener) {
      listenersForType = _listeners[UxmlElement.ALL_EVENT_TYPES];
      if (listenersForType == null) {
        return;
      }
      for (int i = 0; i < listenersForType.length; i++) {
        EventHandler listener = listenersForType[i];
        if (listener == null) {
          listenersForType.removeAt(i);
          --i;
        } else {
          listener(e);
        }
      }
    }
    _isCallingListeners = false;
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    return _modelToString(sb, 0);
  }

  String _modelToString(StringBuffer sb, int depth) {
    if (depth == 0) {
      sb.write("Model ");
    } else {
      for (int t = 0; t < depth; t++) {
        sb.write("  ");
      }
    }
    sb.write(_name);
    sb.write(" {\n");
    Iterable<String> propKeys = _properties.keys;
    for (String key in propKeys) {
      if (key == "_repeatable_") {
        continue;
      }
      Object val = _properties[key];
      if (val is Model) {
        Model child = val;
        child._modelToString(sb, depth + 1);
      } else {
        for (int t = 0; t < (depth + 1); t++) {
          sb.write("  ");
        }
        sb.write(key);
        sb.write(" : ");
        sb.write(val);
        sb.write("\n");
      }
    }

    if (_children != null) {
      for (int c = 0; c < _children.length; c++) {
        if (_children[c] is Model) {
          Model child = _children[c];
          if (!_properties.containsValue(child)) {
            child._modelToString(sb, depth + 1);
          }
        }
      }
    }

    for (int i = 0; i < propKeys.length; i++) {
      String key = propKeys.elementAt(i);
      if (key != "_repeatable_") {
        continue;
      }
      Object val = _properties[propKeys.elementAt(i)];
      if (val is Model) {
        Model child = val;
        child._modelToString(sb, depth + 1);
      } else {
        for (int t = 0; t < (depth + 1); t++) {
          sb.write("  ");
        }
        sb.write(key);
        sb.write(" : ");
        sb.write(val);
        sb.write("\n");
      }
    }
    for (int t = 0; t < depth; t++) {
      sb.write("  ");
    }
    sb.write("}\n");
    return sb.toString();
  }

  /** Returns a copy of this model. */
  Model clone() {
    return new Model.fromMap(_properties);
  }

  /** Applies function f to each property member in model. */
  void forEach(Function f) {
    _properties.forEach(f);
  }
}

