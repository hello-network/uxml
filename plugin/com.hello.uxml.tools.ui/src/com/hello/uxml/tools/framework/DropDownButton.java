package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.MouseEventArgs;

import java.util.EnumSet;

/**
 * Implements button that shows popup as drop down on mouse down.
 *
 * @author ferhat@
 */
public class DropDownButton extends Button {

  /** IsOpen property definition */
  public static PropertyDefinition isOpenPropDef = PropertySystem.register("IsOpen",
      Boolean.class, DropDownButton.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** Popup property definition */
  public static PropertyDefinition popupPropDef = PropertySystem.register("Popup",
      UIElement.class, DropDownButton.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None)));

  /**
   * Returns whether dropdown is open.
   */
  public boolean getIsOpen() {
    return (Boolean) getProperty(isOpenPropDef);
  }

  /**
   * Sets drop down open state.
   */
  public void setIsOpen(boolean value) {
    setProperty(isOpenPropDef, value);
  }

  /**
   * Sets or returns popup element.
   */
  public UIElement getPopup() {
    return (UIElement) getProperty(popupPropDef);
  }

  public void setPopup(UIElement element) {
    setProperty(popupPropDef, element);
  }

  @Override
  protected void onMouseDown(MouseEventArgs e) {
    captureMouse();
    e.setHandled(true);
    setProperty(isPressedPropDef, true);
    setProperty(isOpenPropDef, !getIsOpen());
  }

  @Override
  protected void onMouseUp(MouseEventArgs e) {
    e.setHandled(true);
    setProperty(isPressedPropDef, false);
    releaseMouse();
    if (getIsMouseOver()) {
      onMouseClick(e);
    }
  }
}
