package com.hello.uxml.tools.framework;

import java.util.HashMap;
import java.util.Map;

/**
 * Manages UIElement resources that are keyed by name or class.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Resources {
  private Map<String, Object> namedResources = new HashMap<String, Object>();
  private Map<Class<?>, Object> classMap = new HashMap<Class<?>, Object>();

  /**
   * Adds a named resource.
   */
  public void add(String name, Object resource) {
    namedResources.put(name, resource);
  }

  /**
   * Adds a named resource.
   */
  public void add(Class<?> type, Object resource) {
    classMap.put(type, resource);
  }

  /**
   * Adds all resources from collection.
   */
  public void add(Resources value) {
    add(value, true);
  }

  /**
   * Adds all resources from collection.
   */
  public void add(Resources value,
                               boolean override) {
    for (String key : value.namedResources.keySet()) {
      if ((override == true) || (findResource(key) == null)) {
        add(key, value.findResource(key));
      }
    }

    for (Class<?> classKey : value.classMap.keySet()) {
      if ((override == true) || (findResource(classKey) == null)) {
        add(classKey, value.findResource(classKey));
      }
    }
  }

  /**
   * Returns resource by name.
   */
  public Object findResource(String name) {
    Object obj = namedResources.get(name);
    if (obj != null) {
      return obj;
    }
    return Application.findResource(name);
  }

  /**
   * Returns resource by name.
   */
  public Object findResource(String name, String interfaceName) {
    Object obj;
    if (interfaceName == null) {
      obj = namedResources.get(name);
      if (obj != null) {
        return obj;
      }
    } else {
      Resources intf = (Resources) namedResources.get(interfaceName);
      if (intf != null) {
        obj = intf.findResource(name);
        if (obj != null) {
          return obj;
        }
      }
    }
    return Application.findResource(name, interfaceName);
  }

  /**
   * Used by Application.
   */
  Object getResource(Class<?> type) {
    return classMap.get(type);
  }

  /**
   * Used by Application.
   */
  Object getResource(String name) {
    return namedResources.get(name);
  }

  /**
   * Returns resource by class.
   */
  public Object findResource(Class<?> type) {
    Object obj = classMap.get(type);
    if (obj != null) {
      return obj;
    }
    return Application.findResource(type);
  }
}
