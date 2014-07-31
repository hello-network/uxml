package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements horizontal layout container.
 *
 * @author ferhat
 */
public class HBox extends UIElementContainer {

  /** Spacing Property Definition */
  public static PropertyDefinition spacingPropDef = PropertySystem.register("Spacing", Double.class,
      HBox.class, new PropertyData(0.0, EnumSet.of(PropertyFlags.Resize, PropertyFlags.Relayout)));

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double xPos = 0;
    double maxHeight = 0;
    double spacing = getSpacing();
    UIElement child;

    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      if (childIndex != 0) {
        xPos += spacing;
      }
      child = getChild(childIndex);
      child.measure(availableWidth, availableHeight);
      xPos += child.getMeasuredWidth();
      if (child.getMeasuredHeight() > maxHeight) {
        maxHeight = child.getMeasuredHeight();
      }
    }
    setMeasuredDimension(xPos, maxHeight);
  }

  @Override
  protected void onLayout(Rectangle layoutRect) {
    double xPos = 0;
    double spacing = getSpacing();
    UIElement child;
    Rectangle childRect;
    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      if (childIndex != 0) {
        xPos += spacing;
      }
      child = getChild(childIndex);
      childRect = new Rectangle(xPos, 0, child.getMeasuredWidth(),
          layoutRect.height);
      child.layout(childRect);
      xPos += childRect.width;
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
