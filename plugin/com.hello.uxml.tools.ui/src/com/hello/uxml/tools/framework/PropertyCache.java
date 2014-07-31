package com.hello.uxml.tools.framework;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Caches PropertyDefinition objects of Element derived classes for faster
 * lookup.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class PropertyCache {

  /**
   * Constructor private for utility class.
   */
  private PropertyCache() {
  }

  /**
   * Caches all PropertyDefinition objects for a class.
   */
  private static Map<Class<? extends UxmlElement>, List<PropertyDefinition>> classCache =
      new HashMap<Class<? extends UxmlElement>, List<PropertyDefinition>>();

  /**
   * Cache of name of property of a class to its PropertyDefinition.
   */
  private static Map<String, PropertyDefinition> propDefCache =
      new HashMap<String, PropertyDefinition>();

  /**
   * Gets the PropertyDefinition of a property for a given class.
   */
  public static PropertyDefinition getPropertyDefinition(Class<? extends UxmlElement> ownerClass,
      String propName) {
    // lookup the class definition for this class in the cache. If it does
    // not exist, cache it
    if (!classCache.containsKey(ownerClass)) {
      classCache.put(ownerClass, PropertySystem.getPropertyDefinitions(ownerClass));
    }

    // lookup up the property definition in the cache. If it does not exist,
    // cache it
    String lookupName = ownerClass.getName() + "." + propName.toLowerCase();

    if (!propDefCache.containsKey(lookupName)) {
      List<PropertyDefinition> properties = classCache.get(ownerClass);
      for (PropertyDefinition propDef : properties) {
        propDefCache.put(ownerClass.getName() + "." + propDef.getName().toLowerCase(),
            propDef);
      }
    }
    return propDefCache.get(lookupName);
  }

  /**
   * Clears the PropertyDefinition cache for a class.
   */
  public static void clearCache(Class<? extends UxmlElement> ownerClass) {
    String className = ownerClass.getName();
    for (String key : propDefCache.keySet()) {
      if (key.startsWith(className)) {
        propDefCache.remove(key);
      }
    }
    classCache.remove(ownerClass);
  }
}
