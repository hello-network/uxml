package com.hello.uxml.tools.codegen.dom;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.hello.uxml.tools.framework.CollectionNode;
import com.hello.uxml.tools.framework.ContentNode;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.PropertySystem;
import com.hello.uxml.tools.framework.UxmlElement;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.codegen.emit.TypeToken;

import java.lang.reflect.Method;
import java.util.List;
import java.util.Map;

/**
 * Holds java classes and reflection cache for ModelParser.
 *
 * @author ferhat
 */
public class ModelReflector {

  /** Maps a class to a cache item */
  private Map<TypeToken, ReflectionCache> typeMap = Maps.newHashMap();

  /** Maps a class name to a cache item */
  private Map<String, ReflectionCache> nameMap = Maps.newHashMap();

  /** Contains list of registered elements. */
  private List<TypeToken> registeredElements = Lists.newArrayList();

  /**
   * Constructor.
   */
  public ModelReflector() {
  }

  /**
   * Registers a class.
   */
  public void register(Class<?> elementClass) {
    ReflectionCache cacheItem = new ReflectionCache(elementClass);
    typeMap.put(cacheItem.getTypeToken(), cacheItem);
    // TODO(ferhat): remove remapping after java codebase moves to new namespace.
    String javaFrameworkPrefix = "com.hello.uxml.tools.framework";
    if (cacheItem.getTypeToken().getFullName().startsWith(javaFrameworkPrefix)) {
      String fullTypeName = cacheItem.getTypeToken().getFullName();
      fullTypeName = "com.hello.uxml" + fullTypeName.substring(javaFrameworkPrefix.length());
      typeMap.put(TypeToken.fromFullName(fullTypeName), cacheItem);
    }
    nameMap.put(elementClass.getSimpleName(), cacheItem);
    registeredElements.add(cacheItem.getTypeToken());
  }

  /**
   * Registers a class with alternate markup name.
   */
  public void register(Class<?> elementClass, String markupName) {
    ReflectionCache cacheItem = new ReflectionCache(elementClass);
    TypeToken type = cacheItem.getTypeToken();
    typeMap.put(type, cacheItem);
    nameMap.put(markupName, cacheItem);
    registeredElements.add(type);
  }

  /**
   * Returns list of registered elements.
   */
  public List<TypeToken> getRegisteredElements() {
    return registeredElements;
  }

  /**
   * Returns type token for element type
   */
  public TypeToken elementTypeToToken(String elementTypeName) {
    ReflectionCache cacheItem = nameMap.get(elementTypeName);
    if (cacheItem == null) {
      return null;
    }
    return cacheItem.getTypeToken();
  }

  /**
   * Returns {@link PropertyDefinition} for a token type.
   */
  public PropertyDefinition getPropDef(TypeToken type, String propertyName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return null;
    }
    return cacheItem.getPropDef(propertyName);
  }

  /**
   * Returns {@link EventDefinition} for a token type.
   */
  public EventDefinition getEventDef(TypeToken type, String eventName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return null;
    }
    return cacheItem.getEventDef(eventName);
  }

  /**
   * Returns data type of a property.
   */
  public Class<?> getDataType(TypeToken type, String propertyName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return null;
    }
    return cacheItem.getDataType(propertyName);
  }

  /**
   * Returns true if a property is a collection.
   */
  public boolean isCollectionField(TypeToken type, String propertyName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return false;
    }
    return cacheItem.isCollection(propertyName);
  }

  /**
   * Returns true if a property is a collection and preallocated.
   */
  public boolean isCollectionFieldPreAllocated(TypeToken type, String propertyName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return false;
    }
    return cacheItem.isCollectionPreAllocated(propertyName);
  }

  /**
   * Returns whether a type exposes a given property.
   */
  public boolean hasProperty(TypeToken type, String propertyName) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return false;
    }
    return cacheItem.hasProperty(propertyName);
  }

  /**
   * Returns contentnode type.
   */
  public ContentNodeType getContentNodeType(TypeToken type) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return ContentNodeType.None;
    }
    return cacheItem.getContentNodeType();
  }

  /**
   * Returns contentnode name.
   */
  public String getContentNodeName(TypeToken type) {
    ReflectionCache cacheItem = typeMap.get(type);
    if (cacheItem == null) {
      return null;
    }
    return cacheItem.getContentNodeName();
  }

  /**
   * Returns true if class is marked with a CollectionNode attribute.
   */
  public boolean isCollectionNode(Class<?> dataType) {
    CollectionNode node = dataType.getAnnotation(CollectionNode.class);
    return node != null;
  }

  /**
   * Caches PropertyDefinitions for a class on demand.
   */
  static class ReflectionCache {
    private Class<?> source;
    private TypeToken typeToken;
    private List<PropertyDefinition> propDefList;
    private Map<String, PropertyDefinition> propNameMap = Maps.newHashMap();
    private List<EventDefinition> eventDefList;
    private Map<String, EventDefinition> eventNameMap = Maps.newHashMap();
    private boolean propertiesCached = false;
    private boolean eventsCached = false;
    private boolean contentNodeTypeCached = false;
    private ContentNodeType contentNodeType;
    private String contentNodeName;
    private boolean preAllocated = true;

    /**
     * Constructor.
     */
    public ReflectionCache(Class<?> source) {
      this.source = source;
    }

    /** Returns cached typetoken for class */
    public TypeToken getTypeToken() {
      if (typeToken == null) {
        typeToken = new TypeToken(source.getPackage().getName(), source.getSimpleName());
      }
      return typeToken;
    }

    /** Returns property definition for a class */
    public PropertyDefinition getPropDef(String name) {
      cachePropDefList();
      return (propDefList == null)
          ? null : propNameMap.get(name.toLowerCase());
    }

    /** Returns property definition for a class */
    public EventDefinition getEventDef(String name) {
      cacheEventDefList();
      return (eventDefList == null)
          ? null : eventNameMap.get(name.toLowerCase());
    }

    /**
     * Returns data type of a class member
     **/
    public Class<?> getDataType(String name) {
      PropertyDefinition propDef = getPropDef(name);
      if (propDef != null) {
        return propDef.getDataType();
      }
      String fieldName = name.substring(0, 1).toUpperCase() + name.substring(1);
      try {
        Method method = source.getMethod("get" + fieldName, new Class<?>[] {});
        return method.getReturnType();
      } catch (NoSuchMethodException e) {
        // Try lower case version
        try {
          Method method = source.getMethod("get" + name, new Class<?>[] {});
          return method.getReturnType();
        } catch (NoSuchMethodException e2) {
          return String.class; // Default to string type.s
        }
      }
    }

    /**
     * Returns true if property is collection.
     **/
    public boolean isCollection(String name) {
      String fieldName = name.substring(0, 1).toUpperCase() + name.substring(1);
      try {
        Method method = source.getMethod("get" + fieldName, new Class<?>[] {});
        CollectionNode node = method.getAnnotation(CollectionNode.class);
        if (node != null) {
          return true;
        }
      } catch (NoSuchMethodException e) {
        // Get method not found. Try setter below.
      }
      String setterName = "set" + fieldName;
      Method[] methods = source.getMethods();
      for (int i = 0; i < methods.length; i++) {
        if (methods[i].getName().equals(setterName)) {
          CollectionNode node = methods[i].getAnnotation(CollectionNode.class);
          return node != null;
        }
      }
      return false;
    }

    /**
     * Returns true if property is preallocated collection.
     **/
    public boolean isCollectionPreAllocated(String name) {
      String fieldName = name.substring(0, 1).toUpperCase() + name.substring(1);
      try {
        Method method = source.getMethod("get" + fieldName, new Class<?>[] {});
        CollectionNode node = method.getAnnotation(CollectionNode.class);
        if (node != null) {
          return node.isPreAllocated();
        }
      } catch (NoSuchMethodException e) {
        // Get method not found. Try setter below.
      }
      String setterName = "set" + fieldName;
      Method[] methods = source.getMethods();
      for (int i = 0; i < methods.length; i++) {
        if (methods[i].getName().equals(setterName)) {
          CollectionNode node = methods[i].getAnnotation(CollectionNode.class);
          return node == null ? false : node.isPreAllocated();
        }
      }
      return false;
    }

    /**
     * Checks if a class contains a member.
     **/
    public boolean hasProperty(String name) {
      if (name.length() == 0) {
        return false;
      }
      PropertyDefinition propDef = getPropDef(name);
      if (propDef != null) {
        return true;
      }
      String fieldName = name.substring(0, 1).toUpperCase() + name.substring(1);
      try {
        source.getMethod("get" + fieldName, new Class<?>[] {});
        return true;
      } catch (NoSuchMethodException e) {
        // Try lower case version
        try {
          source.getMethod("get" + name, new Class<?>[] {});
          return true;
        } catch (NoSuchMethodException e2) {
          return false;
        }
      }
    }

    /**
     * Returns type of member that is marked with ContentNode attribute.
     */
    public ContentNodeType getContentNodeType() {
      cacheContentNodeType();
      return contentNodeType;
    }

    private void cacheContentNodeType() {
      if (contentNodeTypeCached == false) {
        contentNodeType = ContentNodeType.None;
        contentNodeTypeCached = true;
        Class<?> cls = source;
        while (cls != Object.class) {
          Method[] methods = source.getMethods();
          for (Method m : methods) {
            ContentNode node = m.getAnnotation(ContentNode.class);
            if (node != null) {
              if (m.getName().startsWith("set")) {
                contentNodeType = ContentNodeType.Field;
                contentNodeName = m.getName().substring(3);
              } else {
                contentNodeType = ContentNodeType.CollectionMethod;
                contentNodeName = m.getName();
              }
              return;
            }
            CollectionNode collNode = m.getAnnotation(CollectionNode.class);
            if (collNode != null) {
              if (m.getName().startsWith("get")) {
                contentNodeType = ContentNodeType.CollectionMethod;
                contentNodeName = m.getName().substring(3);
                preAllocated = collNode.isPreAllocated();
              }
            }
          }
          cls = cls.getSuperclass();
        }
      }
    }

    /**
     * Returns name of member that is marked with ContentNode attribute.
     */
    public String getContentNodeName() {
      cacheContentNodeType();
      return contentNodeName;
    }

    /**
     * Returns true of collection node is preallocated.
     */
    public boolean isPreAllocated() {
      return preAllocated;
    }

    private void cachePropDefList() {
      if (!propertiesCached) {
        propertiesCached = true;
        Class<? extends UxmlElement> sourceElement = null;
        try {
          sourceElement = source.asSubclass(UxmlElement.class);
        } catch (ClassCastException e) {
          // If class doesn't derive from Element, don't do anything (empty propList).
        }
        if (sourceElement != null) {
          propDefList = PropertySystem.getPropertyDefinitions(sourceElement);
          for (int i = 0; i < propDefList.size(); ++i) {
            PropertyDefinition propDef = propDefList.get(i);
            propNameMap.put(propDef.getName().toLowerCase(), propDef);
          }
        }
      }
    }

    private void cacheEventDefList() {
      if (!eventsCached) {
        eventsCached = true;
        Class<? extends UxmlElement> sourceElement = null;
        try {
          sourceElement = source.asSubclass(UxmlElement.class);
        } catch (ClassCastException e) {
          // If class doesn't derive from Element, don't do anything (empty propList).
        }
        if (sourceElement != null) {
          eventDefList = EventManager.getEventDefinitions(sourceElement);
          for (int i = 0; i < eventDefList.size(); ++i) {
            EventDefinition eventDef = eventDefList.get(i);
            eventNameMap.put(eventDef.getName().toLowerCase(), eventDef);
          }
        }
      }
    }
  }
}
