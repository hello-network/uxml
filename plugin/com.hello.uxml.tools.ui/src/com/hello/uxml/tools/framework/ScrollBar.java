package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Implements a scrollbar control.
 *
 * @author ferhat
 */
public class ScrollBar extends Control {

  /** Orientation Property Definition */
  public static PropertyDefinition orientationPropDef = Slider.orientationPropDef.addPropData(
      ScrollBar.class, new PropertyData(Orientation.Vertical, EnumSet.of(PropertyFlags.Resize)));

  /** Value Property Definition */
  public static PropertyDefinition valuePropDef = PropertySystem.register("Value",
      Double.class, ScrollBar.class,
      new PropertyData(0.0));

  /** MinValue Property Definition */
  public static PropertyDefinition minValuePropDef = PropertySystem.register("MinValue",
      Double.class, ScrollBar.class,
      new PropertyData(0.0));

  /** MaxValue Property Definition */
  public static PropertyDefinition maxValuePropDef = PropertySystem.register("MaxValue",
      Double.class, ScrollBar.class,
      new PropertyData(100.0));


  /** ValueChanged event definition */
  public static EventDefinition valueChangedEvent = EventManager.register(
      "ValueChanged", ScrollBar.class, EventArgs.class, ScrollBar.class, null);

  /**
   * Sets or returns scrollbar orientation.
   */
  public void setOrientation(Orientation orientation) {
    setProperty(orientationPropDef, orientation);
  }

  public Orientation getOrientation() {
    return (Orientation) getProperty(orientationPropDef);
  }

  /**
   * Sets or returns value of slider.
   */
  public void setValue(double value) {
    setProperty(valuePropDef, value);
  }

  public double getValue() {
    return ((Double) getProperty(valuePropDef)).doubleValue();
  }

  /**
   * Sets or returns minValue of slider.
   */
  public void setMinValue(double value) {
    setProperty(minValuePropDef, value);
  }

  public double getMinValue() {
    return ((Double) getProperty(minValuePropDef)).doubleValue();
  }

  /**
   * Sets or returns maxValue of slider.
   */
  public void setMaxValue(double value) {
    setProperty(maxValuePropDef, value);
  }

  public double getMaxValue() {
    return ((Double) getProperty(maxValuePropDef)).doubleValue();
  }
}
