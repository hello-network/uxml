package com.hello.uxml.tools.framework.effects;

import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UxmlElement;

/**
 * Implements a property setter declaration for effects
 *
 * @author ferhat
 */
public class PropertyAction extends Action {
  private String target;
  private PropertyDefinition property;
  private Object value;
  private int delay;

  /**
   * Constructor.
   */
  public PropertyAction() {
  }

  /**
   * Sets or returns target element name.
   */
  public String getTarget() {
    return  target;
  }

  public void setTarget(String target) {
    this.target = target;
  }

  /**
   * Sets or returns property definition.
   */
  public PropertyDefinition getProperty() {
    return property;
  }

  public void setProperty(PropertyDefinition property) {
    this.property = property;
  }

  /**
   * Sets or return target value of action.
   */
  public Object getValue() {
    return value;
  }

  public void setValue(Object value) {
    this.value = value;
  }

  /**
   * Sets or return delay time in ms of action.
   */
  public int getDelay() {
    return delay;
  }

  public void setDelay(int delay) {
    this.delay = delay;
  }

  /**
  * Starts the action.
  */
  @Override
  public void start(UxmlElement chromeRoot, UxmlElement control) {
    ActionData data = getActionData(control);
    // TODO(ferhat): implement delay
    if (data.getActionState() != ActionData.ACTION_ACTIVE) {
      data.setTargetElement((target != null && chromeRoot instanceof UIElement) ?
          ((UIElement) control).getElement(target) : control);
      data.setStartValue(data.getTargetElement().getProperty(property));
      data.setActionState(ActionData.ACTION_ACTIVE);
      data.getTargetElement().setProperty(property, value);
    }
  }

  /**
  * Reverses the action.
  */
  @Override
  public void reverse(UxmlElement control) {
    ActionData data = getActionData(control);
    if (data.getActionState() == ActionData.ACTION_ACTIVE) {
      data.getTargetElement().setProperty(property, data.getStartValue());
      data.setActionState(ActionData.ACTION_IDLE);
    }
  }
}
