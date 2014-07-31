part of uxml;

/**
 * Groups UIElement's as a stack.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Group extends UIElementContainer {
  static ElementDef groupElementDef;

  Group() : super() {
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    int numChildren = childCount;
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    for (int i = 0; i < numChildren; i++) {
      UIElement child = childElements[i];
      child.measure(availableWidth, availableHeight);
      if (child.measuredWidth > maxWidth) {
        maxWidth = child.measuredWidth;
      }
      if (child.measuredHeight > maxHeight) {
        maxHeight = child.measuredHeight;
      }
    }
    setMeasuredDimension(maxWidth, maxHeight);
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    int numChildren = childCount;
    for (int i = 0; i < numChildren; i++) {
      childAt(i).layout(0.0, 0.0, targetWidth, targetHeight);
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => groupElementDef;

  /** Registers component. */
  static void registerGroup() {
    groupElementDef = ElementRegistry.register("Group",
        UIElementContainer.uielementcontainerElementDef, null, null);
  }
}
