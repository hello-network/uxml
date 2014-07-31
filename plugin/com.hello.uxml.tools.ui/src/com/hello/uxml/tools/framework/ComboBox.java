package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Implements a combobox control.
 *
 * @author ferhat
 */
public class ComboBox extends ListBase {
  // Base Items functionality is in ListControl.
  // Typical chrome is a listbox inside a popup bound to IsOpen property.
  // A combobox that has editing enabled will display a textbox instead of a
  // ContentContainer and manage editing of Content.

   /** IsOpen property definition */
  public static PropertyDefinition isOpenPropDef = PropertySystem.register("IsOpen",
      Boolean.class, ComboBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** Editable property definition */
  public static PropertyDefinition editablePropDef = PropertySystem.register("Editable",
      Boolean.class, ComboBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** Text property definition */
  public static PropertyDefinition textPropDef = PropertySystem.register("Text",
      String.class, ComboBox.class,
      new PropertyData("", EnumSet.of(PropertyFlags.None, PropertyFlags.Localizable)));

  /** TextChanged event definition */
  public static EventDefinition textChangedEvent = EventManager.register(
      "TextChanged", ComboBox.class, EventArgs.class, ComboBox.class, null);

  /** MaxDropDownHeight property definition */
  public static PropertyDefinition maxDropDownHeightPropDef = PropertySystem.register(
      "MaxDropDownHeight", Double.class, ComboBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Returns text.
   */
  public String getText() {
    return (String) getProperty(textPropDef);
  }

  /**
   * Sets text.
   */
  public void setText(String text) {
    setProperty(textPropDef, text);
  }

  /**
   * Sets or return text in editable combobox.
   */
  public boolean getEditable() {
    return (Boolean) getProperty(editablePropDef);
  }

  /**
   * Sets if combobox content is editable
   */
  public void setEditable(boolean value) {
    setProperty(editablePropDef, value);
  }

  /**
   * Returns whether combobox dropdown is open.
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
   * Sets or returns maximum height of combobox dropdown.
   */
  public double getMaxDropDownHeight() {
    return ((Double) getProperty(maxDropDownHeightPropDef)).doubleValue();
  }

  public void setMaxDropDownHeight(double value) {
    setProperty(maxDropDownHeightPropDef, value);
  }
}
