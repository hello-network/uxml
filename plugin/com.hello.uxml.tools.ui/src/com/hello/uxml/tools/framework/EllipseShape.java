package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.UISurface;

/**
 * Defines an elliptical shape.
 *
 * @author ferhat@
 *
 */
public class EllipseShape extends Shape {

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    setMeasuredDimension(getWidth(), getHeight());
  }

  @Override
  protected void onRedraw(UISurface surface) {
    surface.drawEllipse(getFill(), getStroke(), new Rectangle(0, 0, getWidth(), getHeight()));
  }
}
