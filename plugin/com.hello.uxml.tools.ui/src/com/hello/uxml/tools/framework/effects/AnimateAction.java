package com.hello.uxml.tools.framework.effects;

import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UxmlElement;

import java.util.EventListener;

/**
 * Holds animation information.
 *
 * @author ferhat
 */
public class AnimateAction extends Action {
  private static final int DEFAULT_DURATION = 250;

  private String target;
  private UxmlElement targetValue;
  private PropertyDefinition property;
  /** Start value of animation. Current value of property is used if null. */
  public Object fromValue;
  public Object toValue;
  private boolean isActive;
  private Object startValue;
  private int duration = DEFAULT_DURATION;
  private int delay;
  private EventListener callback;

  /**
  * Starts the action.
  */
  @Override
  public void start(UxmlElement chromeRoot, UxmlElement control) {
    if (!isActive) {
      targetValue = ((target != null) && (chromeRoot instanceof UIElement)) ?
          ((UIElement) chromeRoot).getElement(target) : control;
      startValue = targetValue.getProperty(property);
      isActive = true;
      targetValue.setProperty(property, toValue);
    }
}

  /**
  * Reverses the action.
  */
  @Override
  public void reverse(UxmlElement control) {
    if (isActive) {
      targetValue.setProperty(property, startValue);
      isActive = false;
    }
  }

  /**
   * Sets or returns duration of animation in miliseconds.
   */
  public void setDuration(int duration) {
    this.duration = duration;
  }

  public int getDuration() {
    return duration;
  }

  /**
   * Sets or returns start delay of animation in miliseconds.
   */
  public void setDelay(int delay) {
    this.delay = delay;
  }

  public int getDelay() {
    return delay;
  }

  /**
   * Sets or returns start value of property.
   */
  public void setFromValue(Object value) {
    fromValue = value;
  }

  public Object getFromValue() {
    return fromValue;
  }

  /**
   * Sets or returns end value of property.
   */
  public void setToValue(Object value) {
    toValue = value;
  }

  public Object getToValue() {
    return toValue;
  }

  /**
   * Sets or returns property to be animated.
   */
  public void setProperty(PropertyDefinition value) {
    property = value;
  }

  public PropertyDefinition getProperty() {
    return property;
  }

  /**
   * Sets or returns the target element to animate.
   */
  public void setTarget(String id) {
    target = id;
  }

  public String getTarget() {
    return target;
  }

  /**
   * Sets or returns listener to be notified when animation completes.
   */
  public void setCompleteCallback(EventListener listener) {
    callback = listener;
  }

  public EventListener getCompleteCallback() {
    return callback;
  }
}
