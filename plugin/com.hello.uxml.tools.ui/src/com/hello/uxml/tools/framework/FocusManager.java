package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Manages keyboard focus.
 *
 * @author ferhat@
 */
public class FocusManager {
  private static UIElement focusedElement;

  private FocusManager() {
  }

  /** IsFocused Attached Property Definition */
  public static PropertyDefinition isFocusedPropDef = PropertySystem.register("isFocused",
      Boolean.class, UIElement.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          boolean focusValue = ((Boolean) e.getNewValue()).booleanValue();

          if (focusValue) {
            if (focusedElement != null) {
              focusedElement.setIsFocused(false);
            }
            focusedElement = (UIElement) e.getSource();
          } else {
            if (focusedElement == e.getSource()) {
              focusedElement = null;
            }
          }
        }}));

  /** IsFocusGroup Attached Property Definition */
  public static PropertyDefinition isFocusGroupPropDef = PropertySystem.register("isFocusGroup",
      Boolean.class, UIElement.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached)));
}
