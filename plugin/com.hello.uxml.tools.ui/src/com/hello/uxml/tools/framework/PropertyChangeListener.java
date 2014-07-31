package com.hello.uxml.tools.framework;

import java.util.EventListener;

/**
 * Defines interface for value change listeners registered with PropertySystem.
 *
 * @author ferhat
 */
public interface PropertyChangeListener extends EventListener {
  public abstract void propertyChanged(PropertyChangedEvent e);
}
