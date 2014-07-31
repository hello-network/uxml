package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a grid column.
 *
 * @author ferhat
 */
public class GridColumn extends GridDef {

  /** Width Property Definition */
  public static PropertyDefinition widthPropDef = PropertySystem.register("Width", Double.class,
      GridColumn.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridColumn) e.getSource()).length = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** MinWidth Property Definition */
  public static PropertyDefinition minWidthPropDef = PropertySystem.register("MinWidth",
      Double.class, GridColumn.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridColumn) e.getSource()).minLength = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** MaxWidth Property Definition */
  public static PropertyDefinition maxWidthPropDef = PropertySystem.register("MaxWidth",
      Double.class, GridColumn.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridColumn) e.getSource()).maxLength = ((Double) e.getNewValue()).doubleValue();
        }}));

  /**
   * Sets/returns width property.
   */
  public void setWidth(double value) {
    setProperty(widthPropDef, value);
  }

  public double getWidth() {
    return length;
  }

  /**
   * Sets/returns minimum width property.
   */
  public void setMinWidth(double value) {
    setProperty(minWidthPropDef, value);
  }

  public double getMinWidth() {
    return minLength;
  }

  /**
   * Sets/returns maximum width property.
   */
  public void setMaxWidth(double value) {
    setProperty(maxWidthPropDef, value);
  }

  public double getMaxWidth() {
    return maxLength;
  }
}
