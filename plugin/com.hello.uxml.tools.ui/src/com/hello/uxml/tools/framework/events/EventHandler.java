package com.hello.uxml.tools.framework.events;

import java.util.EventListener;

/**
 * Defines interface for event handlers.
 *
 * @author ferhat
 */
public interface EventHandler extends EventListener {
  public abstract void handleEvent(EventNotifier targetObject, EventArgs e);
}
