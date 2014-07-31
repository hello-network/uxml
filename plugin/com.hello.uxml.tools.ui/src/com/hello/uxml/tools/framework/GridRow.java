package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a grid row.
 *
 * @author ferhat
 */
public class GridRow extends GridDef {
  /** Height Property Definition */
  public static PropertyDefinition heightPropDef = PropertySystem.register("Height", Double.class,
      GridRow.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridRow) e.getSource()).length = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** MinHeight Property Definition */
  public static PropertyDefinition minHeightPropDef = PropertySystem.register("MinHeight",
      Double.class, GridRow.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridRow) e.getSource()).minLength = ((Double) e.getNewValue()).doubleValue();
        }}));

  /** MaxHeight Property Definition */
  public static PropertyDefinition maxHeightPropDef = PropertySystem.register("MaxHeight",
      Double.class, GridRow.class,
      new PropertyData(Double.NaN, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((GridRow) e.getSource()).maxLength = ((Double) e.getNewValue()).doubleValue();
        }}));

  /**
   * Sets/returns height property.
   */
  public void setHeight(double value) {
    setProperty(heightPropDef, value);
  }

  public double getHeight() {
    return length;
  }

  /**
   * Sets/returns minimum height property.
   */
  public void setMinHeight(double value) {
    setProperty(minHeightPropDef, value);
  }

  public double getMinHeight() {
    return minLength;
  }

  /**
   * Sets/returns maximum height property.
   */
  public void setMaxHeight(double value) {
    setProperty(maxHeightPropDef, value);
  }

  public double getMaxHeight() {
    return maxLength;
  }
}
