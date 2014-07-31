package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.MouseEventArgs;

import java.util.EnumSet;

/**
 * Implements a button control that maintains mutually exclusive isChecked state
 * among a group.
 *
 * @author ferhat
 */
public class RadioButton extends Button {

  /** IsChecked property definition */
  public static PropertyDefinition isCheckedPropDef = PropertySystem.register("IsChecked",
      Boolean.class, RadioButton.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          RadioButton button = (RadioButton) e.getSource();
          boolean checkValue = (Boolean) e.getNewValue();
          if (checkValue) {
            // We need to uncheck the active radio button in our group
            UIElement activeButton = Application.getCurrent().getRadioButton(button.getGroup());
            if (activeButton != null) {
              activeButton.setProperty(isCheckedPropDef, false);
            }
            Application.getCurrent().setRadioButton(button.getGroup(), button);
          }
        }}));

  /** Group property definition */
  public static PropertyDefinition groupPropDef = PropertySystem.register("Group",
      String.class, RadioButton.class,
      new PropertyData("", EnumSet.of(PropertyFlags.None)));

  /**
   * Sets/returns radio button group key.
   */
  public String getGroup() {
    return (String) getProperty(groupPropDef);
  }

  public void setGroup(String groupName) {
    setProperty(groupPropDef, groupName);
  }

  @Override public void close() {
    // unregister from button app level radiogroups
    if (getIsChecked()) {
      Application.getCurrent().setRadioButton(getGroup(), null);
    }
    super.close();
  }

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
    setIsChecked(true);
    super.onMouseClick(e);
  }
}
