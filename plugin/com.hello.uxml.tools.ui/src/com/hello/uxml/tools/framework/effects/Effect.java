package com.hello.uxml.tools.framework.effects;

import com.hello.uxml.tools.framework.ContentNode;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UxmlElement;

import java.util.ArrayList;
import java.util.List;

/**
 * Holds behaviour information for chrome instances.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Effect extends UxmlElement {
  private List<Action> actions = new ArrayList<Action>();
  private PropertyDefinition property;
  private Object value;
  private Object source;
  private UxmlElement targetElementValue;

  /**
   * Adds an action to effect.
   */
  @ContentNode
  public void addAction(Action action) {
    actions.add(action);
  }

  /**
   * Sets or returns property that triggers actions.
   */
  public void setProperty(PropertyDefinition property) {
    this.property = property;
  }

  public PropertyDefinition getProperty() {
    return property;
  }

  /**
   * Sets or returns source of property that triggers actions.
   */
  public void setSource(Object source) {
    this.source = source;
  }

  public Object getSource() {
    return source;
  }

  /**
   * Sets or returns targetElement for action.
   */
  public void setTargetElement(UxmlElement target) {
    this.targetElementValue = target;
  }

  public UxmlElement getTargetElement() {
    return targetElementValue;
  }

  /**
   * Sets or returns value of property that triggers actions.
   */
  public void setValue(Object value) {
    this.value = value;
  }

  public Object getValue() {
    return value;
  }

  /**
   * Returns list of actions to execute.
   */
  public List<Action> getActions() {
    return actions;
  }
}
