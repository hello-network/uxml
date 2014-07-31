part of uxml;

/**
 * Implements a container of UIElement(s) that stacks items vertically.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */

class VBox extends UIElementContainer {
  static ElementDef vBoxElementDef;
  static PropertyDefinition spacingProperty;

  VBox() {
  }

  /**
   * Sets/returns spacing between elements.
   */
  num get spacing {
    return getProperty(spacingProperty);
  }

  set spacing(num val) {
    setProperty(spacingProperty, val);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num yPos = 0.0;
    num maxWidth = 0.0;
    UIElement child;
    num space = spacing;

    int numChildren = childCount;
    for (int childIndex = 0; childIndex < numChildren; childIndex++) {
      if (childIndex != 0 && child.visible) {
        yPos += space;
      }
      child = childElements[childIndex];
      child.measure(availableWidth, availableHeight);
      yPos += child.measuredHeight;
      if (child.measuredWidth > maxWidth) {
        maxWidth = child.measuredWidth;
      }
    }
    setMeasuredDimension(maxWidth, yPos);
    return false;
  }

  /** Returns the number of children that can fit in this container. */
  int estimateCapacity() {
    int numChildren = childCount;
    if (numChildren == 0) {
      return 0;
    }
    num yPos = 0;
    UIElement child;
    num space = spacing;
    num targetWidth = layoutWidth;
    num targetHeight = layoutHeight;
    int capacity = 0;
    int childIndex = 0;
    num childWidth = 0;
    num childHeight = 0;

    while (yPos < targetHeight) {
      if (childIndex != 0) {
        yPos += space;
      }

      if (childIndex < numChildren) {
        child = childElements[childIndex++];
        childWidth = max(child.measuredWidth, childWidth);
        childHeight = max(child.measuredHeight, childHeight);
      }

      if (yPos + childHeight < targetHeight) {
        capacity++;
      }

      yPos += childHeight;
    }
    return capacity;
  }


  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    num yPos = 0.0;
    UIElement child;
    num space = spacing;
    int numChildren = childCount;

    for (int childIndex = 0; childIndex < numChildren; childIndex++) {
      if (childIndex != 0 && child.visible) {
        yPos += space;
      }
      child = childElements[childIndex];
      child.layout(0.0, yPos, targetWidth, child.measuredHeight);
      yPos += child.measuredHeight;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => vBoxElementDef;

  /** Registers component. */
  static void registerVBox() {
    spacingProperty = ElementRegistry.registerProperty("spacing",
        PropertyType.NUMBER, PropertyFlags.RESIZE | PropertyFlags.RELAYOUT ,
        null, 0.0);
    vBoxElementDef = ElementRegistry.register("VBox",
        UIElementContainer.uielementcontainerElementDef, [spacingProperty],
        null);
  }
}
