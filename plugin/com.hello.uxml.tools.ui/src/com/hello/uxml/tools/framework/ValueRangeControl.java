package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Defines base class for controls that are based on a range of values.
 *
 * @author ferhat
 */
public class ValueRangeControl extends Control {

  /** Value Property Definition */
  public static PropertyDefinition valuePropDef = PropertySystem.register("Value",
      Double.class, ValueRangeControl.class,
      new PropertyData(0.0, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
            ((ValueRangeControl) e.getSource()).onValueChanged(
                ((Double) e.getNewValue()).doubleValue());
        }}));

  /** MinValue Property Definition */
  public static PropertyDefinition minValuePropDef = PropertySystem.register("MinValue",
      Double.class, ValueRangeControl.class,
      new PropertyData(0.0));

  /** MaxValue Property Definition */
  public static PropertyDefinition maxValuePropDef = PropertySystem.register("MaxValue",
      Double.class, ValueRangeControl.class,
      new PropertyData(100.0));

  /** ValueChanged event definition */
  public static EventDefinition valueChangedEvent = EventManager.register(
      "ValueChanged", ValueRangeControl.class, EventArgs.class, ValueRangeControl.class, null);

  private EventArgs eventArgs;

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

  protected void onValueChanged(double newValue) {
    if (newValue < getMinValue()) {
      setValue(getMinValue());
      return;
    }
    if (newValue > getMaxValue()) {
      setValue(getMaxValue());
      return;
    }
    if (hasListener(valueChangedEvent)) {
      if (eventArgs == null) {
        eventArgs = new EventArgs();
        eventArgs.setSource(this);
        eventArgs.setEvent(valueChangedEvent);
      }
      raiseEvent(eventArgs);
    }
  }
}
