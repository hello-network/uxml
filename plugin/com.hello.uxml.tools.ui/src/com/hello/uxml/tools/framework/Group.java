package com.hello.uxml.tools.framework;

/**
 * Implements a stack container for elements.
 *
 * @author ferhat
 */
public class Group extends UIElementContainer {
  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    int childCount = getChildCount();
    if (childCount == 0) {
      setMeasuredDimension(0, 0);
    } else {
      UIElement child = getChild(0);
      child.measure(availableWidth, availableHeight);
      double maxWidth = child.getMeasuredWidth();
      double maxHeight = child.getMeasuredHeight();
      for (int c = 1; c < childCount; ++c) {
        child = getChild(c);
        child.measure(availableWidth, availableHeight);
        if (child.getMeasuredWidth() > maxWidth) {
          maxWidth = child.getMeasuredWidth();
        }
        if (child.getMeasuredHeight() > maxHeight) {
          maxHeight = child.getMeasuredHeight();
        }
      }
      setMeasuredDimension(maxWidth, maxHeight);
    }
  }

  @Override
  protected void onLayout(Rectangle layoutRect) {
    int childCount = getChildCount();
    Rectangle childRect = new Rectangle(0, 0, layoutRect.width, layoutRect.height);
    for (int c = 0; c < childCount; ++c) {
      getChild(c).layout(childRect);
    }
  }
}
