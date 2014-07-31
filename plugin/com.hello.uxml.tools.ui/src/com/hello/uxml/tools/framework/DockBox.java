package com.hello.uxml.tools.framework;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

/**
 * Implements container that allows children to be docked to the sides of the
 * container.
 *
 * @author ferhat
 */
public class DockBox extends UIElementContainer {

  /** Left Property Definition */
  public static PropertyDefinition dockPropDef = PropertySystem.register("Dock", Dock.class,
      DockBox.class,
      new PropertyData(Dock.None, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          // Attached property should be ignored if parent is not a canvas
          if (element.parent instanceof DockBox) {
            ((UIElement) element.parent).invalidateLayout();
          }
        }}));

  /** Helper function to set child left */
  public static void setChildDock(UIElement child, Dock dockStyle) {
    child.setProperty(dockPropDef, dockStyle);
  }

  /** Helper function to get child left */
  public static Dock getChildDock(UIElement child) {
    return (Dock) child.getProperty(dockPropDef);
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double maxLeftRight = 0;
    double maxTopBottom = 0;
    double maxFillAreaWidth = 0;
    double maxFillAreaHeight = 0;
    for (int i = 0; i < getChildCount(); ++i) {
      UIElement child = getChild(i);
      child.measure(availableWidth, availableHeight);
      Dock dockStyle = getChildDock(child);
      double measuredWidth = child.getMeasuredWidth();
      double measuredHeight = child.getMeasuredHeight();
      switch (dockStyle) {
        case None:
          if (measuredWidth > maxFillAreaWidth) {
            maxFillAreaWidth = measuredWidth;
          }
          if (measuredHeight > maxFillAreaHeight) {
            maxFillAreaHeight = measuredHeight;
          }
          break;
        case Left:
        case Right:
          if (measuredHeight > maxFillAreaHeight) {
            maxFillAreaHeight = measuredHeight;
          }
          maxLeftRight += measuredWidth;
          availableWidth -= measuredWidth;
          break;
        case Top:
        case Bottom:
          if (measuredWidth > maxFillAreaWidth) {
            maxFillAreaWidth = measuredWidth;
          }
          maxTopBottom += measuredHeight;
          availableHeight -= measuredHeight;
          break;
      }
    }
    setMeasuredDimension(maxFillAreaWidth + maxLeftRight, maxFillAreaHeight + maxTopBottom);
  }

  @Override
  protected void onLayout(Rectangle layoutRectangle) {
    double left = 0;
    double top = 0;
    double right = layoutRectangle.width;
    double bottom = layoutRectangle.height;
    List<UIElement> fillList = new ArrayList<UIElement>();

    // First position items docked to sides
    for (int i = 0; i < getChildCount(); ++i) {
      UIElement child = getChild(i);
      double measuredWidth = child.getMeasuredWidth();
      double measuredHeight = child.getMeasuredHeight();
      Dock dockStyle = getChildDock(child);
      switch (dockStyle) {
        case None:
          fillList.add(child);
          break;
        case Left:
          child.layout(new Rectangle(left, top, measuredWidth, bottom - top));
          left += measuredWidth;
          break;
        case Right:
          child.layout(new Rectangle(right - measuredWidth, top, measuredWidth, bottom - top));
          right -= measuredWidth;
          break;
        case Top:
          child.layout(new Rectangle(left, top, right - left, measuredHeight));
          top += measuredHeight;
          break;
        case Bottom:
          child.layout(new Rectangle(left, bottom - measuredHeight, right - left,
              measuredHeight));
          bottom -= measuredHeight;
          break;
      }
    }
    // use remaining area for fill (Dock.None)
    for (UIElement child : fillList) {
      child.layout(new Rectangle(left, top, right - left, bottom - top));
    }
  }
}
