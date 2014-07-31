package com.hello.uxml.tools.framework.events;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Defines an event notification class. It allows adding and removing event
 * listeners.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class EventNotifier extends Object {

  /** Hash map of event listeners by event type. */
  private Map<Object, List<EventHandler>> listeners = new HashMap<Object, List<EventHandler>>();

  /**
   * Constructor.
   */
  public EventNotifier() {
  }

  /**
   * Adds an event listener function for an event type.
   *
   * @param type The event type. It can be a string or any object.
   * @param listener The function that gets called.
   */
  public void addListener(Object type, EventHandler listener) {
    List<EventHandler> handlerList = listeners.get(type);
    if (handlerList == null) {
      handlerList = new ArrayList<EventHandler>();
      listeners.put(type, handlerList);
    }
    if (!handlerList.contains(listener)) {
      handlerList.add(listener);
    }
  }

  /**
   * Removes an event listener function for an event type.
   *
   * @param type The event type. It can be a string or any object.
   * @param listener The function that gets called.
   */
  public void removeListener(Object type, EventHandler listener) {
    List<EventHandler> handlerList = listeners.get(type);
    if (handlerList == null) {
      return;
    }
    handlerList.remove(listener);
  }

  /** Checks if there are listeners for a type of event. */
  public boolean hasListener(Object type) {
    return (listeners.get(type) != null);
  }

  /**
   * Notifies all listeners for a type of event.
   *
   * @param type The event type.
   * @param event The event object that is sent to all listeners.
   */
  public void notifyListeners(Object type, EventArgs event) {
    List<EventHandler> handlerList = listeners.get(type);
    if (handlerList == null) {
      return;
    }
    for (EventHandler handler : handlerList) {
      handler.handleEvent(this, event);
    }
  }
}

