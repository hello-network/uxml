package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Scrollable Item strip.
 *
 * Create a layout that shows only a partial view
 * of the items collection. ViewPortCapacity determines how many items are
 * visible, ViewPortMargin determines how much space if any is used by items
 * on the edge of the view. The selected child is always scrolled into view
 * to make it the primary focus.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
public class SlideBox extends UIElementContainer {

  /** ViewPortCapacity Property Definition */
  public static PropertyDefinition viewPortCapacityPropDef = PropertySystem.register(
        "ViewPortCapacity", Integer.class, SlideBox.class,
        new PropertyData(3, EnumSet.of(PropertyFlags.Resize)));

  /** ViewPortMargin Property Definition */
  public static PropertyDefinition viewPortMarginPropDef = PropertySystem.register(
        "ViewPortMargin", Double.class, SlideBox.class,
        new PropertyData(30, EnumSet.of(PropertyFlags.Resize)));

  /** SelectedIndex Property definition. */
  public static PropertyDefinition selectedIndexPropDef = PropertySystem.register("SelectedIndex",
      Integer.class, SlideBox.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.Resize)));

    /** Gets or sets the view port capacity.*/
  public int getViewPortCapacity() {
    return ((Integer) getProperty(viewPortCapacityPropDef));
  }

  public void setViewPortCapacity(int value) {
    setProperty(viewPortCapacityPropDef, value);
  }

  /** Gets or sets the view port margin.*/
  public int getViewPortMargin() {
    return ((Integer) getProperty(viewPortMarginPropDef));
  }

  public void setViewPortMargin(int value) {
    setProperty(viewPortMarginPropDef, value);
  }

  /** Gets or sets the selected index of child in focus.*/
  public int getSelectedIndex() {
    return ((Integer) getProperty(selectedIndexPropDef));
  }

  public void setSelectedIndex(int value) {
    setProperty(selectedIndexPropDef, value);
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double xPos = 0;
    double maxWidth = 0;
    double maxHeight = 0;
    UIElement child;
    int selIndex = getSelectedIndex();

    availableWidth -= getViewPortMargin() * 2;
    // Determine maximum height required by all children and the total width
    // items inside viewport area.
    int numChildren = getChildCount();
    for (int childIndex = 0; childIndex < numChildren; ++childIndex) {
      child = getChild(childIndex);
      child.measure(availableWidth, availableHeight);
      if (getViewPortCapacity() == -1) {
        xPos += child.getMeasuredWidth();
      } else if (childIndex >= (selIndex - 1) &&
        childIndex < (selIndex + getViewPortCapacity() - 1)) {
        xPos += child.getMeasuredWidth();
      }
      if (child.getMeasuredWidth() > maxWidth) {
        maxWidth = child.getMeasuredWidth();
      }
      if (child.getMeasuredHeight() > maxHeight) {
        maxHeight = child.getMeasuredHeight();
      }
    }
    if (getViewPortCapacity() == -1) {
      setMeasuredDimension(xPos, maxHeight);
    } else {
      setMeasuredDimension(maxWidth + (getViewPortMargin() * 2), maxHeight);
    }
  }

  @Override
  protected void  onLayout(Rectangle layoutRect) {
    int selIndex = getSelectedIndex();
    double availWidth = layoutRect.width - (2 * getViewPortMargin());
    double xPos = getViewPortCapacity() == -1 ? 0 : -selIndex * availWidth;

    for (int childIndex = 0; childIndex < getChildCount(); childIndex++) {
      UIElement child = getChild(childIndex);
      double finalX = layoutRect.x + xPos;
      if (getViewPortCapacity() != -1) {
        finalX += getViewPortMargin();
      }
      double childWidth = getViewPortCapacity() == -1 ? child.getMeasuredWidth() : availWidth;
      child.layout(finalX, layoutRect.y, childWidth, layoutRect.height);
      xPos += childWidth;
    }
  }
}
