part of uxml;

/**
 * Provides a container that supports docking of elements to 4 sides of the
 * view.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class DockBox extends UIElementContainer {
  /** Dock Property Definition */
  static PropertyDefinition dockProperty;
  static ElementDef dockboxElementDef;

  DockBox() : super() {
  }

  /**
   * Sets dock property for an element.
   */
  static void setChildDock(UIElement element, int dock) {
    element.setProperty(dockProperty, dock);
  }

  /**
   * Returns dock property for an element.
   */
  static int getChildDock(UIElement element) {
    return element.getProperty(dockProperty);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num maxLeftRight = 0.0;
    num maxTopBottom = 0.0;
    num maxFillAreaWidth = 0.0;
    num maxFillAreaHeight = 0.0;
    num maxDockWidth = 0.0;
    num maxDockHeight = 0.0;
    int numChildren = childCount;
    for (int i = 0; i < numChildren; i++) {
      UIElement child = childAt(i);
      int dockStyle = getChildDock(child);
      if (dockStyle == Dock.NONE) {
        continue;
      }
      child.measure(availableWidth, availableHeight);
      num measuredW = child.measuredWidth;
      num measuredH = child.measuredHeight;
      switch (dockStyle) {
        case Dock.LEFT:
        case Dock.RIGHT:
          if ((measuredH + maxTopBottom) > maxDockHeight) {
            maxDockHeight = measuredH + maxTopBottom;
          }
          maxLeftRight += measuredW;
          availableWidth -= measuredW;
          break;
        case Dock.TOP:
        case Dock.BOTTOM:
          if ((measuredW + maxLeftRight) > maxDockWidth) {
            maxDockWidth = measuredW + maxLeftRight;
          }
          maxTopBottom += measuredH;
          availableHeight -= measuredH;
          break;
      }
    }
    for (int i = 0; i < numChildren; i++) {
      UIElement child = childAt(i);
      int dockStyle = getChildDock(child);
      if (dockStyle != Dock.NONE) {
        continue;
      }
      child.measure(availableWidth, availableHeight);
      num measuredW = child.measuredWidth;
      num measuredH = child.measuredHeight;
      if (measuredW > maxFillAreaWidth) {
        maxFillAreaWidth = measuredW;
      }
      if (measuredH > maxFillAreaHeight) {
        maxFillAreaHeight = measuredH;
      }
    }
    setMeasuredDimension(
        max(maxDockWidth, maxFillAreaWidth + maxLeftRight),
        max(maxDockHeight, maxFillAreaHeight + maxTopBottom));
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    num left = 0.0;
    num top = 0.0;
    num right = targetWidth;
    num bottom = targetHeight;
    List<UIElement> fillList = <UIElement>[];

    // First position items docked to sides
    for (int i = 0; i < childCount; i++) {
      UIElement child = childAt(i);
      if (!child.visible) {
        continue;
      }
      num measuredW = child.measuredWidth;
      var measuredH = child.measuredHeight;
      int dockStyle = getChildDock(child);
      switch (dockStyle) {
        case Dock.NONE:
          fillList.add(child);
          break;
        case Dock.LEFT:
          child.layout(left, top, measuredW, bottom - top);
          left += measuredW;
          break;
        case Dock.RIGHT:
          child.layout(right - measuredW, top, measuredW, bottom - top);
          right -= measuredW;
          break;
        case Dock.TOP:
          child.layout(left, top, right - left, measuredH);
          top += measuredH;
          break;
        case Dock.BOTTOM:
          child.layout(left, bottom - measuredH, right - left, measuredH);
          bottom -= measuredH;
          break;
      }
    }
    // use remaining area for fill (Dock.None)
    for (int f = 0; f < fillList.length; f++) {
      fillList[f].layout(left, top, max(0, right - left),
          max(0, bottom - top));
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => dockboxElementDef;

  /** Registers component. */
  static void registerDockBox() {
    dockProperty = ElementRegistry.registerProperty("Dock",
        PropertyType.DOCK, PropertyFlags.ATTACHED | PropertyFlags.RELAYOUT,
        null, Dock.NONE);
    dockboxElementDef = ElementRegistry.register("DockBox",
        UIElementContainer.uielementcontainerElementDef, [dockProperty], null);
  }
}

abstract class Dock {
  /** Dock option for no docking i.e. fill */
  static const int NONE = 0;
  /** Dock option for left side of container */
  static const int LEFT = 1;
  /** Dock option for top of container */
  static const int TOP = 2;
  /** Dock option for right side of container */
  static const int RIGHT = 3;
  /** Dock option for bottom of container */
  static const int BOTTOM = 4;
}
