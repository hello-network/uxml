package com.hello.uxml.tools.framework;

import java.util.EventListener;

/**
 * Defines an interface that transforms values during property binding.
 *
 * @author ferhat
 */
public interface ValueTransform extends EventListener {
  public abstract Object transformValue(Object value, Object transArg);
}
