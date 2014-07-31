package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements vertical layout container.
 *
 * @author ferhat
 *
 */
public class VBox extends UIElementContainer {

  /** Spacing Property Definition */
  public static PropertyDefinition spacingPropDef = PropertySystem.register("Spacing", Double.class,
      VBox.class, new PropertyData(0.0, EnumSet.of(PropertyFlags.Resize, PropertyFlags.Relayout)));

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double yPos = 0;
    double maxWidth = 0;
    double spacing = getSpacing();
    UIElement child;

    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      if (childIndex != 0) {
        yPos += spacing;
      }
      child = getChild(childIndex);
      child.measure(availableWidth, availableHeight);
      yPos += child.getMeasuredHeight();
      if (child.getMeasuredWidth() > maxWidth) {
        maxWidth = child.getMeasuredWidth();
      }
    }
    setMeasuredDimension(maxWidth, yPos);
  }

  @Override
  protected void onLayout(Rectangle layoutRect) {
    double yPos = 0;
    double spacing = getSpacing();
    UIElement child;
    Rectangle childRect;
    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      if (childIndex != 0) {
        yPos += spacing;
      }
      child = getChild(childIndex);
      childRect = new Rectangle(0, yPos, layoutRect.width,
          child.getMeasuredHeight());
      child.layout(childRect);
      yPos += childRect.height;
    }
  }

  /**
   * Sets/returns spacing between children.
   */
  public void setSpacing(double value) {
    setProperty(spacingPropDef, value);
  }

  public double getSpacing() {
    return ((Double) getProperty(spacingPropDef)).doubleValue();
  }
}
