package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a container that discloses it's contents with
 * transitions.
 *
 * @author ferhat
 */
public class DisclosureBox extends UIElementContainer {

  /** IsOpen property definition */
  public static PropertyDefinition isOpenPropDef = PropertySystem.register("IsOpen",
      Boolean.class, DisclosureBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None),
          new PropertyChangeListener() {
            @Override
            public void propertyChanged(PropertyChangedEvent e) {
              ((DisclosureBox) e.getSource()).isOpenChanged(
                  ((Boolean) e.getNewValue()).booleanValue());
            }
      }));

  /** Fade property definition */
  public static PropertyDefinition fadePropDef = PropertySystem.register("Fade",
      Boolean.class, DisclosureBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None),
          new PropertyChangeListener() {
            @Override
            public void propertyChanged(PropertyChangedEvent e) {
              DisclosureBox box = (DisclosureBox) e.getSource();
              box.setOpacity(box.getFade() ? (box.getIsOpen() ? 1.0 : 0.0) : 1.0);
            }
      }));

  /** Transition Property Definition */
  public static PropertyDefinition transitionPropDef = PropertySystem.register("Transition",
      Transition.class, UIElement.class, new PropertyData(Transition.RevealHeight,
      EnumSet.of(PropertyFlags.None)));

  private static final int DEFAULT_DURATION = 150;

  /** Duration Property Definition */
  public static PropertyDefinition durationPropDef = PropertySystem.register("Duration",
      Integer.class, DisclosureBox.class, new PropertyData(DEFAULT_DURATION));

  /**
   * Sets or returns whether content is visible on screen.
   */
  public boolean getIsOpen() {
    return ((Boolean) getProperty(isOpenPropDef)).booleanValue();
  }

  public void setIsOpen(boolean value) {
    setProperty(isOpenPropDef, value);
  }

  /**
   * Sets or returns whether fading is enabled.
   */
  public boolean getFade() {
    return ((Boolean) getProperty(fadePropDef)).booleanValue();
  }

  public void setFade(boolean value) {
    setProperty(fadePropDef, value);
  }

  /**
   * Sets or returns transition.
   */
  public Transition getTransition() {
    return (Transition) getProperty(transitionPropDef);
  }

  public void setTransition(Transition value) {
    setProperty(transitionPropDef, value);
  }

  /**
   * Sets or returns duration of transition in milliseconds.
   */
  public int getDuration() {
    return ((Integer) getProperty(durationPropDef)).intValue();
  }

  public void setDuration(int value) {
    setProperty(durationPropDef, value);
  }

  protected void isOpenChanged(boolean value) {
    // TODO(ferhat): schedule task for animation.
  }
}
