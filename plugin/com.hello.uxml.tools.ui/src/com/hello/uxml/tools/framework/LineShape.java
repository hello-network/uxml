package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Defines a line shape
 *
 * @author ferhat@
 */
public class LineShape extends Shape {

  /** Start x axis coordinate */
  public static PropertyDefinition xFromPropDef = PropertySystem.register("XFrom",
      Double.class, LineShape.class, new PropertyData(0.0, null, EnumSet.of(
          PropertyFlags.Resize)));

  /** Start y axis coordinate */
  public static PropertyDefinition yFromPropDef = PropertySystem.register("XFrom",
      Double.class, LineShape.class, new PropertyData(0.0, null, EnumSet.of(
          PropertyFlags.Resize)));

  /** End x axis coordinate */
  public static PropertyDefinition xToPropDef = PropertySystem.register("XTo",
      Double.class, LineShape.class, new PropertyData(0.0, null, EnumSet.of(
          PropertyFlags.Resize)));

  /** End y axis coordinate */
  public static PropertyDefinition yToPropDef = PropertySystem.register("YTo",
      Double.class, LineShape.class, new PropertyData(0.0, null, EnumSet.of(
          PropertyFlags.Resize)));

  /**
   * Sets or returns start x coordinate.
   */
  public double getXFrom() {
    return ((Double) getProperty(xFromPropDef)).doubleValue();
  }

  public void setXFrom(double value) {
    setProperty(xFromPropDef, value);
  }

  /**
   * Sets or returns start y coordinate.
   */
  public double getYFrom() {
    return ((Double) getProperty(yFromPropDef)).doubleValue();
  }

  public void setYFrom(double value) {
    setProperty(yFromPropDef, value);
  }

  /**
   * Sets or returns end x coordinate.
   */
  public double getXTo() {
    return ((Double) getProperty(xToPropDef)).doubleValue();
  }

  public void setXTo(double value) {
    setProperty(xToPropDef, value);
  }

  /**
   * Sets or returns end y coordinate.
   */
  public double getYTo() {
    return ((Double) getProperty(yToPropDef)).doubleValue();
  }

  public void setYTo(double value) {
    setProperty(yToPropDef, value);
  }

  /**
   * Returns size of line bounds.
   */
  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    setMeasuredDimension(Math.abs(getXFrom() - getXTo()), Math.abs(getYFrom() - getYTo()));
  }

  @Override
  protected void onRedraw(UISurface surface) {
    surface.drawLine(getStroke(), getXFrom(), getYFrom(), getXTo(), getYTo());
  }
}
