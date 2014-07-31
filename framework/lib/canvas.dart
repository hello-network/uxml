part of uxml;

/**
 * Implements container that allows absolute positioning of children.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Canvas extends UIElementContainer {

  /** Left Property Definition */
  static PropertyDefinition leftProperty;

  /** Top Property Definition */
  static PropertyDefinition topProperty;

  /** Sets/returns if size of canvas is updated when children change bounds. */
  bool sizeToContent = false;
  static ElementDef _canvasElementDef;
  // TODO(ferhat): deprecate.
  bool forceMeasureEmpty = false;

  Canvas() : super() {
  }

  /**
   * Sets child element Left property.
   */
  static void setChildLeft(UIElement element, num left) {
    element.setProperty(leftProperty, left);
  }

  /**
   * Returns child element Left property.
   */
  static num getChildLeft(UIElement element) {
    return element.getProperty(leftProperty);
  }

  /**
   * Sets child element Top property.
   */
  static void setChildTop(UIElement element, num top) {
    element.setProperty(topProperty, top);
  }

  /**
   * Returns child element Top property.
   */
  static num getChildTop(UIElement element) {
    return element.getProperty(topProperty);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num maxX = 0.0;
    num maxY = 0.0;
    bool relayoutRequired = false;
    int numChildren = childCount;
    for (int i = 0; i < numChildren; i++) {
      UIElement child = childElements[i];
      num prevMeasuredW = child.measuredWidth;
      num prevMeasuredH = child.measuredHeight;
      child.measure(availableWidth, availableHeight);
      if (prevMeasuredW != child.measuredWidth ||
          prevMeasuredH != child.measuredHeight) {
        // Signal to remeasure that we will have to relayout canvas when
        // a child changes size although it doesn't change canvas itself.
        relayoutRequired = true;
      }
      num val = getChildLeft(child) + child.measuredWidth;
      if (val > maxX) {
        maxX = val;
      }
      val = getChildTop(child) + child.measuredHeight;
      if (val > maxY) {
        maxY = val;
      }
    }
    if (forceMeasureEmpty) {
      maxX = 0.0;
      maxY = 0.0;
    }
    setMeasuredDimension(maxX, maxY);
    return relayoutRequired;
  }

  /**
   * Invalidate size override for containers that optimize progressive layout.
   */
  void invalidateSizeForChild(UIElement child) {
    if (sizeToContent) {
      super.invalidateSizeForChild(child);
    }
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    num left;
    num top;
    num width;
    num height;
    int numChildren = childCount;
    // TODO(ferhat) : remove scrollbox special case.
    if (id == "scrollBoxContentPart") {
      for (int i = 0; i < numChildren; i++) {
        UIElement child = childElements[i];
        left = getChildLeft(child);
        top = getChildTop(child);
        UIElement p = visualParent;
        while ((p != null) && (!(p is ScrollBox))) {
          p = p.visualParent;
        }
        num finalWidth = targetWidth;
        num finalHeight = targetHeight;
        if (p != null) {
          if (p is ScrollBox) {
            ScrollBox scrollBox = p;
            if (scrollBox.verticalScrollEnabled) {
              finalHeight = max(finalHeight, child.measuredHeight);
            }
            if (scrollBox.horizontalScrollEnabled) {
              finalWidth = max(finalWidth, child.measuredWidth);
            }
          }
        }
        child.layout(left, top, finalWidth, finalHeight);
      }
    } else {
      for (int childIndex = 0; childIndex < numChildren; ++childIndex) {
        UIElement element = childElements[childIndex];
        left = getChildLeft(element);
        top = getChildTop(element);
        element.layout(left, top, element.measuredWidth,
            element.measuredHeight);
      }
    }
  }

  static void _leftChangedHandler(IKeyValue target, Object property,
      Object oldValue, Object newValue) {
    UIElement element = target;
    // Attached property should be ignored if parent is not a canvas
    if (element.visualParent is Canvas) {
      if (element._hasPrevLayoutData()) {
        element.layout(newValue, element._prevLayoutY,
            element._prevLayoutWidth, element._prevLayoutHeight);
      }
    }
  }

  static void _topChangedHandler(IKeyValue target, Object property,
      Object oldValue, Object newValue) {
    UIElement element = target;
    // Attached property should be ignored if parent is not a canvas
    if (element.visualParent is Canvas) {
      if (element._hasPrevLayoutData()) {
        element.layout(element._prevLayoutX, newValue,
            element._prevLayoutWidth, element._prevLayoutHeight);
      }
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => _canvasElementDef;

  /** Registers component. */
  static void registerCanvas() {
    leftProperty = ElementRegistry.registerProperty("Left",
        PropertyType.NUMBER, PropertyFlags.ATTACHED, _leftChangedHandler, 0.0);
    topProperty = ElementRegistry.registerProperty("Top",
        PropertyType.NUMBER, PropertyFlags.ATTACHED, _topChangedHandler, 0.0);
    _canvasElementDef = ElementRegistry.register("Canvas",
        UIElementContainer.uielementcontainerElementDef,
        [leftProperty, topProperty], null);
  }
}
