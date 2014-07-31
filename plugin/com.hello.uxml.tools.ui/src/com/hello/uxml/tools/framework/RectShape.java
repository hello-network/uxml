package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Defines a rectangle shape.
 *
 * @author ferhat@
 *
 */
public class RectShape extends Shape {

  /** Border radius Property Definition */
  public static PropertyDefinition borderRadiusPropDef = PropertySystem.register("BorderRadius",
      BorderRadius.class, RectShape.class,
      new PropertyData(BorderRadius.EMPTY, EnumSet.of(PropertyFlags.Redraw)));

  /**
   * Sets/returns border radius.
   */
  public void setBorderRadius(BorderRadius value) {
    setProperty(borderRadiusPropDef, value);
  }

  public BorderRadius getBorderRadius() {
    return (BorderRadius) getProperty(borderRadiusPropDef);
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double width = getWidth();
    double height = getHeight();
    setMeasuredDimension(Double.isNaN(width) ? 0 : width,
        Double.isNaN(height) ? 0 : height);
  }

  @Override
  protected void onRedraw(UISurface surface) {
    if (overridesProperty(borderRadiusPropDef)) {
      surface.drawRect(getFill(), getStroke(), new Rectangle(0, 0, getWidth(), getHeight()),
          getBorderRadius());
    } else {
      surface.drawRect(getFill(), getStroke(), new Rectangle(0, 0, getWidth(), getHeight()));
    }
  }
}
