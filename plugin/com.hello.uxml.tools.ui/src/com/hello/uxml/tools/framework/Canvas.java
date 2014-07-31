package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements container that allows absolute positioning of children.
 *
 * @author ferhat
 */
public class Canvas extends UIElementContainer {

  /** Left Property Definition */
  public static PropertyDefinition leftPropDef = PropertySystem.register("Left", Double.class,
      Canvas.class,
      new PropertyData(0.0, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();

          // Attached property should be ignored if parent is not a canvas
          if (element.parent instanceof Canvas) {
            Rectangle prevLayout = element.getLayoutRect();
            element.layout(new Rectangle(((Double) e.getNewValue()).doubleValue(), prevLayout.y,
                prevLayout.width, prevLayout.height));
          }
        }}));

  /** Top Property Definition */
  public static PropertyDefinition topPropDef = PropertySystem.register("Top", Double.class,
      Canvas.class,
      new PropertyData(0.0, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();

          // Attached property should be ignored if parent is not a canvas
          if (element.parent instanceof Canvas) {
            Rectangle prevLayout = element.getLayoutRect();
            element.layout(new Rectangle(prevLayout.x, ((Double) e.getNewValue()).doubleValue(),
                prevLayout.width, prevLayout.height));
          }
        }}));

  /** Helper function to set child left */
  public static void setChildLeft(UIElement child, double left) {
    child.setProperty(leftPropDef, left);
  }

  /** Helper function to get child left */
  public static double getChildLeft(UIElement child) {
    return ((Double) child.getProperty(leftPropDef)).doubleValue();
  }

  /** Helper function to set child top */
  public static void setChildTop(UIElement child, double top) {
    child.setProperty(topPropDef, top);
  }

  /** Helper function to get child left */
  public static double getChildTop(UIElement child) {
    return ((Double) child.getProperty(topPropDef)).doubleValue();
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double maxX = 0;
    double maxY = 0;
    for (int i = 0; i < getChildCount(); ++i) {
      UIElement child = getChild(i);
      child.measure(availableWidth, availableHeight);
      double val = getChildLeft(child) + child.getMeasuredWidth();
      if (val > maxX) {
        maxX = val;
      }
      val = getChildTop(child) + child.getMeasuredHeight();
      if (val > maxY) {
        maxY = val;
      }
    }
    setMeasuredDimension(maxX, maxY);
  }

  @Override
  protected void onLayout(Rectangle layoutRectangle) {
    double left;
    double top;
    double width;
    double height;

    for (int i = 0; i < getChildCount(); ++i) {
      UIElement child = getChild(i);
      left = getChildLeft(child);
      top = getChildTop(child);
      width = child.getWidth();
      height = child.getHeight();
      if (!Double.isNaN(width)) {
        width = child.getMeasuredWidth();
      }
      if (!Double.isNaN(height)) {
        height = child.getMeasuredHeight();
      }
      child.layout(new Rectangle(left, top, width, height));
    }
  }
}
