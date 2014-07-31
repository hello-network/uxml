package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.MouseEventArgs;

import java.util.EnumSet;

/**
 * Implements a button control that toggles a checked state when pressed.
 *
 * @author ferhat
 */
public class CheckBox extends Button {

  /** IsChecked property definition */
  public static PropertyDefinition isCheckedPropDef = PropertySystem.register("IsChecked",
      Boolean.class, CheckBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Returns whether button is in checked state.
   */
  public boolean getIsChecked() {
    return (Boolean) getProperty(isCheckedPropDef);
  }

  /**
   * Sets button checked state.
   */
  public void setIsChecked(boolean value) {
    setProperty(isCheckedPropDef, value);
  }

  @Override
  protected void onMouseClick(MouseEventArgs e) {
    setIsChecked(!getIsChecked());
    super.onMouseClick(e);
  }
}
