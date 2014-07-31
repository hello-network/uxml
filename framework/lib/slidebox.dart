part of uxml;

/**
 * Scrollable Item strip.
 *
 * Create a layout that shows only a partial view
 * of the items collection. ViewPortCapacity determines how many items are
 * visible, ViewPortMargin determines how much space if any is used by items
 * on the edge of the view. The selected child is always scrolled into view
 * to make it the primary focus.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 * @author midoringo@ (Michael Cheng)
 * @author sanjayc@ (Sanjay Chouksey)
 */
class SlideBox extends UIElementContainer {

  static ElementDef slideboxElementDef;
  /** ViewPortCapacity property definition */
  static PropertyDefinition viewPortCapacityProperty;
  /** ViewPortMargin property definition */
  static PropertyDefinition viewPortMarginProperty;
  /** SelectedIndex property definition. */
  static PropertyDefinition selectedIndexProperty;

  ScheduledTask _layoutTask;
  Map<UIElement, Rect> startLayout;
  Map<UIElement, Rect> finalLayout;
  bool _viewPortFull = false;
  EventHandler _selChangeHandler = null;

  SlideBox() : super() {
    _viewPortFull = false;
    _layoutTask = null;
  }

  /** Gets or sets the view port capacity.*/
  int get viewPortCapacity {
    return getProperty(viewPortCapacityProperty);
  }

  set viewPortCapacity(int value) {
    setProperty(viewPortCapacityProperty, value);
  }

  /** Gets or sets the view port margin.*/
  int get viewPortMargin {
    return getProperty(viewPortMarginProperty);
  }

  set viewPortMargin(int value) {
    setProperty(viewPortMarginProperty, value);
  }

  /** Gets or sets the selected index of child in focus.*/
  int get selectedIndex {
    return getProperty(selectedIndexProperty);
  }

  set selectedIndex(int value) {
    setProperty(selectedIndexProperty, value);
  }

  /** Overrides UIElement.surfaceInitialized. */
  void surfaceInitialized(UISurface surface) {
    // Bind to selection change event if our parent is ItemsContainer.
    ListBase listBase = ListBase.containerFromChild(this);
    if (listBase != null) {
      _selChangeHandler = _listSelectedIndexChanged;
      listBase.addListener(ListBase.selectionChangedEvent, _selChangeHandler);
      // SelectedIndex property's default value is 0. Set it to the item
      // container's selected index if it is greater than 0.
      if (listBase.selectedIndex > 0) {
        selectedIndex = listBase.selectedIndex;
      }
    }
  }

  void _listSelectedIndexChanged(EventArgs event) {
    ListBase listBase = event.source;
      // Layout logic needs selected index >= 0.
    if (listBase.selectedIndex >= 0) {
      selectedIndex = listBase.selectedIndex;
    }
    invalidateLayout();
  }

  /** Overrides UIElementContainer.invalidateSizeForChild. */
  void invalidateSizeForChild(UIElement child) {
    invalidateSize();
    invalidateLayout();
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num xPos = 0.0;
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    UIElement child;
    int selIndex = selectedIndex;
    _viewPortFull = false;
    availableWidth -= viewPortMargin * 2;
    // Determine maximum height required by all children and the totalwidth
    // items inside viewport area.
    int numChildren = childCount;
    for (int childIndex = 0; childIndex < childCount; childIndex++) {
      child = childElements[childIndex];
      child.measure(availableWidth, availableHeight);
      if (viewPortCapacity == -1) {
        if ((xPos + child.measuredWidth) > availableWidth) {
          _viewPortFull = true;
        }
        xPos += child.measuredWidth;
      } else if (childIndex >= (selIndex - 1) &&
        childIndex < (selIndex + viewPortCapacity - 1)) {
        xPos += child.measuredWidth;
      }
      if (child.measuredWidth > maxWidth) {
        maxWidth = child.measuredWidth;
      }
      if (child.measuredHeight > maxHeight) {
        maxHeight = child.measuredHeight;
      }
    }
    if (viewPortCapacity == -1) {
      setMeasuredDimension(xPos, maxHeight);
    } else {
      setMeasuredDimension(maxWidth + (viewPortMargin * 2), maxHeight);
    }
    return false;
  }

  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    if (_layoutTask == null || _layoutTask.completed) {
      startLayout = new Map<UIElement, Rect>();
      finalLayout = new Map<UIElement, Rect>();
    }

    int selIndex = selectedIndex;
    num availWidth = targetWidth - (2 * viewPortMargin);
    int itemsInView = viewPortCapacity - 2; // 2 = (left and right items)
    num xPos = viewPortCapacity == -1 ? 0 : -selIndex * availWidth;
    for (int childIndex = 0; childIndex < childCount; childIndex++) {
        UIElement child = childElements[childIndex];
        num finalX = targetX + xPos;
        if (viewPortCapacity != -1) {
          finalX += viewPortMargin;
        }
        num childWidth = viewPortCapacity == -1 ? child.measuredWidth :
            availWidth;
        if (child.isLayoutInitialized) {
          bool isAnimating = _layoutTask != null && _layoutTask.completed ==
              false;
          if (!isAnimating) {
            _layoutTask = Application.current.scheduler.schedule(0, 250,
                _layoutAnimation, this, null);
          }
          Rect r = new Rect(child.layoutX, child.layoutY,
              child.layoutWidth, child.layoutHeight);
          if (isAnimating == false || (!startLayout.containsKey(child))) {
            startLayout[child] = new Rect(r.x, r.y, r.width, r.height);
          }
          finalLayout[child] = new Rect(finalX, targetY, childWidth,
              targetHeight);
        } else {
          // Handle the new Child added into the List, if its index is 0, it is
          // added to the head as the result of prevItem; if its index i 2,
          // it is added to the tail as the result of nextItem.
          if (childIndex == 0 && selIndex != 0) {
            startLayout[child] = new Rect(finalX - childWidth, targetY,
                childWidth, targetHeight);
            finalLayout[child] = new Rect(finalX, targetY, childWidth,
                targetHeight);
          } else if (childIndex == 2) {
            startLayout[child] = new Rect(finalX + childWidth, targetY,
                childWidth, targetHeight);
            finalLayout[child] = new Rect(finalX, targetY, childWidth,
                targetHeight);
          } else {
            child.layout(finalX, targetY, childWidth, targetHeight);
          }
        }
        xPos += childWidth;
      }
    }

  void _layoutAnimation(num tweenValue, Object tag) {
    // TODO(ferhat): change to finalRect. remove for each. */
    finalLayout.forEach((UIElement child, Rect r ) {
      Rect firstRect = startLayout[child];
      Rect finalRect = finalLayout[child];
      UIElement element = child;
      element.layout(firstRect.x + ((finalRect.x - firstRect.x) * tweenValue),
          firstRect.y + ((finalRect.y - firstRect.y) * tweenValue),
          firstRect.width + ((finalRect.width - firstRect.width) * tweenValue),
          firstRect.height + ((finalRect.height - firstRect.height) *
              tweenValue));
    });
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    if (_layoutTask != null) {
      Application.current.scheduler.cancel(_layoutTask);
      _layoutTask = null;
    }
    ListBase listBase = ListBase.containerFromChild(this);
    if (listBase != null) {
      listBase.removeListener(ListBase.selectionChangedEvent,
          _selChangeHandler);
    }
    super.close();
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => slideboxElementDef;

  /** Registers component. */
  static void registerSlideBox() {
    viewPortCapacityProperty = ElementRegistry.registerProperty(
        "viewPortCapacity", PropertyType.INT, PropertyFlags.RESIZE |
        PropertyFlags.RELAYOUT , null, 3);
    viewPortMarginProperty = ElementRegistry.registerProperty("viewPortMargin",
        PropertyType.NUMBER, PropertyFlags.RESIZE | PropertyFlags.RELAYOUT ,
        null, 30);
    selectedIndexProperty = ElementRegistry.registerProperty("selectedIndex",
        PropertyType.INT, PropertyFlags.NONE , null, 0);
    slideboxElementDef = ElementRegistry.register("SlideBox",
        UIElementContainer.uielementcontainerElementDef,
        [viewPortCapacityProperty, viewPortMarginProperty,
        selectedIndexProperty], null);
  }
}
