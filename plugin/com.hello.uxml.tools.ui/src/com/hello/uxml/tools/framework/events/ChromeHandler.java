package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.UIElement;

import java.util.EventListener;

/**
 * Defines interface for handling chrome tree generation
 *
 * @author ferhat
 */
public interface ChromeHandler extends EventListener {
  public abstract UIElement createElements(UIElement targetElement);
}
