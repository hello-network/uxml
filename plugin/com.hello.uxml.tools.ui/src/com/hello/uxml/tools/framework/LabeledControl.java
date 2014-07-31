package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a control pattern that has content and a text and image used to
 * label(adorn) the control.
 *
 * @author ferhat
 */
public class LabeledControl extends Control {

  /** Content Property Definition */
  public static PropertyDefinition contentPropDef = PropertySystem.register("Content",
      Object.class, LabeledControl.class, new PropertyData(null,
          EnumSet.of(PropertyFlags.Resize)));

  /** Label Property Definition */
  public static PropertyDefinition labelPropDef = PropertySystem.register("Label",
      String.class, LabeledControl.class, new PropertyData(null,
          EnumSet.of(PropertyFlags.Resize)));

  /** Picture Property Definition */
  public static PropertyDefinition picturePropDef = PropertySystem.register("Picture",
      UIElement.class, LabeledControl.class, new PropertyData(null,
          EnumSet.of(PropertyFlags.Resize)));

  /**
   * Sets content of container.
   */
  @ContentNode
  public void setContent(Object content) {
    setProperty(contentPropDef, content);
  }

  /**
   * Returns content.
   */
  public Object getContent() {
    return getProperty(contentPropDef);
  }

  /**
   * Sets or returns label of control.
   */
  public void setLabel(String label) {
    setProperty(labelPropDef, label);
  }

  public String getLabel() {
    return (String) getProperty(labelPropDef);
  }

  /**
   * Sets or returns picture label of control.
   */
  public void setPicture(UIElement picture) {
    setProperty(picturePropDef, picture);
  }

  public UIElement getPicture() {
    return (UIElement) getProperty(picturePropDef);
  }
}
