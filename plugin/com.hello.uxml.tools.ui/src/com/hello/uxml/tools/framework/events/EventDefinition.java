package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.UxmlElement;

import java.util.ArrayList;
import java.util.List;

/**
* Manages event information and tracks static handlers.
*
* @author ferhat@
**/
public class EventDefinition {

  /** Routing constant for directly sending event to element */
  public static final int ROUTE_DIRECT = 0;
  /** Routing constant for bubbling up events */
  public static final int ROUTE_BUBBLE = 1;
  /** Routing constant for tunneling events to child */
  public static final int ROUTE_DRILLDOWN = 2;

  /** Name of event */
  private String name;

  /** Event routing strategy */
  private int route;

  /** Owner of event */
  private Class<?> ownerType;

  /** Argument type for event */
  private Class<?> argumentType;

  /** Holds array of targettype */
  private List<Class<?>> targetTypes = new ArrayList<Class<?>>();
  private List<EventHandler> targetHandlers = new ArrayList<EventHandler>();

  /**
   * Constructor.
   */
  public EventDefinition(String name, Class<?> ownerType, Class<?> argumentType,
      int route) {
    this.name = name;
    this.route = route;
    this.ownerType = ownerType;
    this.argumentType = argumentType;
  }

  /**
   * Constructor.
   */
  public EventDefinition(String name, Class<?> ownerType, Class<?> argumentType) {
    this(name, ownerType, argumentType, ROUTE_BUBBLE);
  }

  /** Returns name of event */
  public String getName() {
    return name;
  }

  /** Returns owner type of event */
  public Class<?> getOwnerType() {
    return ownerType;
  }

  /** Returns argument type of event */
  public Class<?> getArgumentType() {
    return argumentType;
  }

  /** Returns routing strategy */
  public int getRoute() {
    return route;
  }

  /** Adds a handler for a given type */
  public void addHandler(Class<?> targetType, EventHandler handler) {
    targetTypes.add(targetType);
    targetHandlers.add(handler);
  }

  /** callHandler */
  public void callHandler(UxmlElement targetObject, EventArgs arguments) {
    int handlerCount = targetTypes.size();
    for (int i = 0; i < handlerCount; ++i) {
      String targetTypeName = targetTypes.get(i).getName();
      // Can't use isInstance in GWT.
      Class<?> targetClass = targetObject.getClass();
      do {
        if (targetClass.getName().equals(targetTypeName)){
          targetHandlers.get(i).handleEvent(targetObject, arguments);
          return;
        }
        targetClass = targetClass.getSuperclass();
      } while (targetClass != null);
    }
  }
}
