package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a container that hosts it's content as an
 * overlay when IsOpen property is set to true.
 *
 * @author ferhat
 */
public class Popup extends ContentContainer {

  private UIElement overlayElement;

  /** IsOpen property definition */
  public static PropertyDefinition isOpenPropDef = PropertySystem.register("IsOpen",
      Boolean.class, Popup.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None),
          new PropertyChangeListener() {
            @Override
            public void propertyChanged(PropertyChangedEvent e) {
              ((Popup) e.getSource()).isOpenChanged(((Boolean) e.getNewValue()).booleanValue());
            }
      }));

  /** AutoFocus property definition */
  public static PropertyDefinition autoFocusPropDef = PropertySystem.register("AutoFocus",
      Boolean.class, Popup.class, new PropertyData(true));

  /** Location Property Definition */
  public static PropertyDefinition locationPropDef = PropertySystem.register("Location",
      OverlayLocation.class, DisclosureBox.class, new PropertyData(0));

  /**
   * Sets or returns whether popup content is visible on screen.
   */
  public boolean getIsOpen() {
    return ((Boolean) getProperty(isOpenPropDef)).booleanValue();
  }

  public void setIsOpen(boolean value) {
    setProperty(isOpenPropDef, value);
  }

  private void isOpenChanged(boolean open) {
    if (overlayElement != null) {
      if (open) {
        addOverlay(overlayElement);
      } else {
        removeOverlay(overlayElement);
      }
    }
  }

  @Override
  protected void updateContent(Object newContent) {
    if (getIsOpen() && overlayElement != null) {
      removeOverlay(overlayElement);
    }

    overlayElement = createControlFromContent(newContent);
    if (getIsOpen() && overlayElement != null) {
      addOverlay(overlayElement);
    }
  }

  /**
   * Sets or returns location of popup relative to it's target.
   */
  public OverlayLocation getLocation() {
    return (OverlayLocation) getProperty(locationPropDef);
  }

  public void setLocation(OverlayLocation value) {
    setProperty(locationPropDef, value);
  }
}
