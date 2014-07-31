package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.UxmlElement;

import java.util.ArrayList;
import java.util.List;

/**
 * Manages event registration.
 *
 * @author ferhat@
 */
public class EventManager {

  /**
   * Global event list.
   */
  private static List<EventDefinition> eventList = new ArrayList<EventDefinition>();

  /**
   * Constructor.
   */
  private EventManager() {
  }

  /**
   * Registers an event.
   */
  public static EventDefinition register(String eventName, Class<?> ownerType,
      Class<?> argumentType) {
    return register(eventName, ownerType, argumentType, null, null);
  }

  /**
   * Registers an event.
   */
  public static EventDefinition register(String eventName, Class<?> ownerType,
      Class<?> argumentType, Class<?> handlerType, EventHandler handler) {

    // Create new event
    EventDefinition eventDef = new EventDefinition(eventName, ownerType, argumentType);

    // Add handler
    if ((handlerType != null) && (handler != null)) {
      eventDef.addHandler(handlerType, handler);
    }
    eventList.add(eventDef);
    return eventDef;
  }

  /**
   * Get all the property definitions for a class.
   */
  public static List<EventDefinition> getEventDefinitions(
      Class<? extends UxmlElement>ownerClass) {
    Application.getCurrent().verifyClassLoaded(ownerClass);

    // Create list of properties. ! not using Lists.newArrayList on purpose
    ArrayList<EventDefinition> list = new ArrayList<EventDefinition>();
    for (EventDefinition eventDef : eventList) {
      if (eventDef.getOwnerType().isAssignableFrom(ownerClass)) {
        list.add(eventDef);
      }
      Class<?> cls = ownerClass;
      Class<?> eventOwnerClass = eventDef.getOwnerType();
      while (cls != null) {
        if (cls == eventOwnerClass) {
          list.add(eventDef);
        }
        cls = cls.getSuperclass();
      }
    }
    return list;
  }
}
