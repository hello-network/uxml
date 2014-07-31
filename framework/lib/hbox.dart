part of uxml;

/**
 * Implements a container of UIElement(s) that stacks items horizontally.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */

class HBox extends UIElementContainer {
  static ElementDef hBoxElementDef;
  static PropertyDefinition spacingProperty;

  HBox() {
  }

  /**
   * Sets/returns spacing between elements.
   */
  num get spacing => getProperty(spacingProperty);

  set spacing(num val) {
    setProperty(spacingProperty, val);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num xPos = 0.0;
    num maxHeight = 0.0;
    UIElement child;
    num space = spacing;

    int numChildren = childCount;
    for (int childIndex = 0; childIndex < numChildren; childIndex++) {
      if (xPos != 0 && child.visible) {
        xPos += space;
      }
      child = childElements[childIndex];
      child.measure(availableWidth, availableHeight);
      xPos += child.measuredWidth;
      if (child.measuredHeight > maxHeight) {
        maxHeight = child.measuredHeight;
      }
    }
    setMeasuredDimension(xPos, maxHeight);
    return false;
  }

  /** Returns the number of children that can fit in this container. */
  int estimateCapacity() {
    int numChildren = childCount;
    if (numChildren == 0) {
      return 0;
    }
    num xPos = 0;
    UIElement child;
    num space= spacing;
    num targetWidth = layoutWidth;
    num targetHeight = layoutHeight;
    int capacity = 0;
    int childIndex = 0;
    num childWidth = 0;
    num childHeight = 0;

    while (xPos < targetWidth) {
      if (childIndex != 0) {
        xPos += space;
      }

      if (childIndex < numChildren) {
        child = childElements[childIndex++];
        childWidth = max(child.measuredWidth, childWidth);
        childHeight = max(child.measuredHeight, childHeight);
      }

      if (xPos + childWidth < targetWidth) {
        capacity++;
      }

      xPos += childWidth;
    }
    return capacity;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    num xPos = 0.0;
    UIElement child;
    num space = spacing;
    int numChildren = childCount;

    for (int childIndex = 0; childIndex < numChildren; childIndex++) {
      child = childElements[childIndex];
      if (xPos != 0 && child.visible) {
        xPos += space;
      }
      child.layout(xPos, 0.0, child.measuredWidth, targetHeight);
      xPos += child.measuredWidth;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => hBoxElementDef;

  /** Registers component. */
  static void registerHBox() {
    spacingProperty = ElementRegistry.registerProperty("spacing",
        PropertyType.NUMBER, PropertyFlags.RESIZE | PropertyFlags.RELAYOUT ,
        null, 0.0);
    hBoxElementDef = ElementRegistry.register("HBox",
        UIElementContainer.uielementcontainerElementDef, [spacingProperty],
        null);
  }
}
