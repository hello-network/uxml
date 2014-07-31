part of uxml;

/**
 * Manages UIElement resources that are keyed by name or class.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Resources {
  Map<Object, Object> _resources;
  List<Object> _list;

  Resources() {
    clear();
  }

  /**
   * Adds a resource.
   */
  void add(Object key, Object value) {
    if (value == null) {
      throw new ArgumentError("Invalid resource value for key");
    }
    _resources[key] = value;
    _list.add(key);
  }

  /**
   * Adds all resources from collection and overwrites existing ones.
   */
  void addResources(Resources value) {
    int resCount = value._resources.length;
    for (int i = 0; i < resCount; i++) {
      Object key = value._list[i];
      add(key, value._resources[key]);
    }
  }

  /**
   * Adds all resources from collection that don't exist already.
   */
  void addNewResources(Resources value) {
    int resCount = value._resources.length;
    for (int i = 0; i < resCount; i++) {
      Object key = value._list[i];
      if (!_resources.containsKey(key)) {
        add(key, value._resources[key]);
      }
    }
  }

  /**
   * Returns resource by name or class.
   */
  Object getResource(Object key) {
    return _resources[key];
  }

  /**
   * Returns resource by name and optional interface.
   */
  Object findResource(Object key, [String interfaceName = null]) {
    Object obj;
    if (interfaceName == null) {
      obj = _resources[key];
      if (obj != null) {
        return obj;
      }
    }
    if (interfaceName != null && (!_resources.containsKey(interfaceName))) {
      Resources intf = _resources[interfaceName];
      if (intf != null) {
        obj = intf.findResource(key);
        if (obj != null) {
          return obj;
        }
      }
    }
    return Application.findResource(key, interfaceName);
  }

  /**
   * Removes all items from collection.
   */
  void clear() {
    _resources = new Map<Object, Object>();
    _list = [];
  }
}
