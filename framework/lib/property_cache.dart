part of uxml;

/**
 * Caches PropertyDefinition objects of Element derived classes for faster
 * lookup.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class PropertyCache {
  /**
   * Caches all PropertyDefinition objects for a class.
   */
  static Map<ElementDef, List<PropertyDefinition>> classCache;

  /**
   * Cache of name of property of a class to its PropertyDefinition.
   */
  static Map<String, PropertyDefinition> propDefCache;

  /**
   * Gets the PropertyDefinition of a property for a given class.
   */
  static PropertyDefinition getPropertyDefinition(ElementDef ownerClass,
                                                  String propName) {
    // Lookup the class definition for this class and parent chain in the cache.
    // If it does not exist, cache it.
    do {
      if (!classCache.containsKey(ownerClass)) {
        classCache[ownerClass] = ownerClass.properties;
      }

      // lookup up the property definition in the cache. If it does not exist,
      // cache it.
      String lookupName = "${ownerClass.name}.${propName.toLowerCase()}";

      if (!propDefCache.containsKey(lookupName)) {
        List<PropertyDefinition> properties = classCache[ownerClass];
        if (properties != null) {
          for (int i = 0; i < properties.length; i++) {
            PropertyDefinition propDef = properties[i];
            String name = "${ownerClass.name}.${propDef.name.toLowerCase()}";
            propDefCache[name] = propDef;
          }
        }
      } else {
        return propDefCache[lookupName];
      }
      if (propDefCache.containsKey(lookupName)) {
        return propDefCache[lookupName];
      }
      ownerClass = ownerClass.parentDef;
    } while (ownerClass != null);
    return null;
  }

  /**
   * Clears the PropertyDefinition cache for a class.
   */
  static void clearCache(ElementDef ownerClass) {
    if ((classCache == null) || (!classCache.containsKey(ownerClass))) {
      return; // quickly return if class is not in cache.
    }
    String clsName = ownerClass.name;
    // Removes all keys that start with ownerClass.
    List<String> delList = [];
    propDefCache.forEach((String key, PropertyDefinition prop) {
        if (key.indexOf(clsName, 0) == 0) {
          delList.add(key);
        }
      });
    for (int i = delList.length - 1; i >=0; --i) {
      propDefCache.remove(delList[i]);
    }
    classCache.remove(ownerClass);
  }

  // Initializes global cache. Called by ElementRegistry.
  static void _registerPropertyCache() {
    classCache = new Map<ElementDef, List<PropertyDefinition>>();
    propDefCache = new Map<String, PropertyDefinition>();
  }
}
