package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.effects.Effect;
import com.hello.uxml.tools.framework.events.ChromeHandler;

import java.util.ArrayList;
import java.util.List;

/**
 * Creates element tree for a control's visual look and behaviour.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Chrome extends UxmlElement {

  private Class<?> targetType;
  private List<Effect> effects;
  private ChromeHandler createElementHandler;

  /**
   * Constructor.
   */
  public Chrome() {
  }

  /**
   * Constructor.
   */
  public Chrome(String id, Class<?> targetType, ChromeHandler createElementHandler) {
    this.setId(id);
    this.targetType = targetType;
    this.createElementHandler = createElementHandler;
  }

  /**
   * Sets/returns target type of chrome.
   */
  public Class<?> getTargetType() {
    return targetType;
  }

  public void setTargetType(Class<?> targetType) {
    this.targetType = targetType;
  }

  public List<Effect> getEffects() {
    if (effects == null) {
      effects = new ArrayList<Effect>();
    }
    return effects;
  }

  /**
   * Overridable function that creates the element tree.
   */
  public UIElement apply(UIElement targetElement) {
    if (createElementHandler != null) {
      return createElementHandler.createElements(targetElement);
    }
    ContentContainer contentContainer = new ContentContainer();
    return contentContainer;
  }
}
