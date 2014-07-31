part of uxml;

class ScrollBox extends ContentContainer {

  static ElementDef scrollboxElementDef;
  static PropertyDefinition panningEnabledProperty;
  static PropertyDefinition scrollPointXProperty;
  static PropertyDefinition scrollPointYProperty;
  static PropertyDefinition horizontalScrollEnabledProperty;
  static PropertyDefinition verticalScrollEnabledProperty;
  static const String _VSCROLL_PART_ID = "verticalScrollBarPart";
  static const String _HSCROLL_PART_ID = "horizontalScrollBarPart";
  static const String _CONTENT_PART_ID = "scrollBoxContentPart";
  static const int _FADEIN_DURATION_MS = 500;
  static const int _FADEIN_DELAY_MS = 100;

  // Local cache of scrollbars in chrome of scrollbox.
  ScrollBar _vertScroll = null;
  ScrollBar _horizScroll = null;
  Canvas _contentPart = null;
  EventHandler _vertHandler;
  EventHandler _horizHandler;
  EventHandler _contentLayoutHandler;

  ScrollBox() : super() {
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    // MouseWheel events need to be handled by a scrollbox even if
    // parts of it's content area are transparent.
    _hostSurface.hitTestMode = UISurfaceImpl.HITTEST_BOUNDS;
  }

  /**
   * Sets or returns scroll amount on x axis.
   */
  set scrollPointX(num value) {
    setProperty(scrollPointXProperty, value);
  }

  num get scrollPointX => getProperty(scrollPointXProperty);

  /**
   * Sets or returns scroll amount on y axis.
   */
  set scrollPointY(num value) {
    setProperty(scrollPointYProperty, value);
  }

  num get scrollPointY => getProperty(scrollPointYProperty);

  /**
   * Gets the Max horizontal scroll value.
   */
  num get scrollXMaxValue => _horizScroll == null ? 0.0 :
      _horizScroll.maxValue;

  /**
   * Gets the Max vertical scroll value.
   */
  num get scrollYMaxValue => _vertScroll == null ? 0.0 :
      _vertScroll.maxValue;

  /**
   * Sets or returns if panning is enabled.
   */
  set panningEnabled(bool value) {
    setProperty(panningEnabledProperty, value);
  }

  bool get panningEnabled => getProperty(panningEnabledProperty);

  /**
   * Sets or returns if vertical scrollbar is enabled.
   */
  set verticalScrollEnabled(bool value) {
    setProperty(verticalScrollEnabledProperty, value);
  }

  bool get verticalScrollEnabled => getProperty(
      verticalScrollEnabledProperty);

  /**
   * Sets or returns if horizontal scrollbar is enabled.
   */
  set horizontalScrollEnabled(bool value) {
    setProperty(horizontalScrollEnabledProperty, value);
  }

  bool get horizontalScrollEnabled => getProperty(
      horizontalScrollEnabledProperty);

  /** Overrides Control.onChromeChanged. */
  void onChromeChanged(Chrome oldChrome, Chrome newChrome) {
    super.onChromeChanged(oldChrome, newChrome);
    ScrollBar scroll = getElement(_VSCROLL_PART_ID);
    if (_vertScroll != null) {
      _vertScroll.removeListener(ScrollBar.valueChangedEvent, _vertHandler);
    }
    _vertScroll = scroll;
    if (_vertScroll != null) {
      _vertScroll.visible = false;
      _vertHandler = _vertScrollValueChanged;
      _vertScroll.addListener(ScrollBar.valueChangedEvent, _vertHandler);
    }
    if (_horizScroll != null) {
      _horizScroll.removeListener(ScrollBar.valueChangedEvent, _horizHandler);
    }
    scroll = getElement(_HSCROLL_PART_ID);
    _horizScroll = scroll;
    if (_horizScroll != null) {
      _horizScroll.visible = false;
      _horizHandler = _horizontalScrollValueChanged;
      _horizScroll.addListener(ScrollBar.valueChangedEvent, _horizHandler);
    }
    _contentPart = getElement(_CONTENT_PART_ID);
    if (_contentPart != null) {
      _contentPart.sizeToContent = true;
      _contentPart.clipChildren = true;
      if (_cachedContent != null) {
        _contentPart.addChild(_cachedContent);
      }
    }
  }

  /** Overrides ContentContainer.updateContent. */
  void updateContent(Object newContent) {
    if ((_cachedContent != null) && (_contentPart != null)) {
      _cachedContent.removeListener(UIElement.layoutChangedEvent,
          _contentLayoutHandler);
      _contentLayoutHandler = null;
      _contentPart.removeChild(_cachedContent);
    }
    if (newContent != null) {
      _cachedContent = createControlFromContent(newContent);

      if (_contentPart != null) {
        _contentPart.addChild(_cachedContent);
      } else {
        // if content part is not availabe (because chrome is not initialized
        // yet) we are parenting the content directly to the scrollbox so
        // parent chain is available for binding.
        insertRawChild(_cachedContent, -1);
      }
      _contentLayoutHandler = _contentLayoutChanged;
      _cachedContent.addListener(UIElement.layoutChangedEvent,
          _contentLayoutHandler);
    } else {
      _cachedContent = null;
    }
  }

  void _vertScrollValueChanged(EventArgs e) {
    scrollPointY = _vertScroll.value;
  }

  void _horizontalScrollValueChanged(EventArgs e) {
    scrollPointX = _horizScroll.value;
  }

  /** Provides override for subclasses to handle scroll point change. */
  void scrollPointChanged() {
    if (_cachedContent != null) {
      _cachedContent.transform.translateX = -scrollPointX;
      _cachedContent.transform.translateY = -scrollPointY;
    }
    if (_vertScroll != null) {
      _vertScroll.value = scrollPointY;
    }
    if (_horizScroll != null) {
      _horizScroll.value = scrollPointX;
    }
  }

  /** Overrides UIElement.onMouseWheel to scroll contents. */
  void onMouseWheel(MouseEventArgs mouseArgs) {
    bool scrollHandled = false;
    if (_vertScroll != null) {
      // TODO(ferhat): add support for querying item height at target to
      // adjust delta.
      num newValue = _vertScroll.value - (20 * mouseArgs.deltaY);
      if (newValue < _vertScroll.minValue) {
        newValue = _vertScroll.minValue;
      }
      if (newValue > _vertScroll.maxValue) {
        newValue = _vertScroll.maxValue;
      }
      if (newValue != _vertScroll.value) {
        _vertScroll.value = newValue;
      }
    }
    mouseArgs.handled = scrollHandled;
  }

  static void _scrollPointChangedHandler(Object target,
                                         PropertyDefinition propDef,
                                         Object oldValue,
                                         Object newValue) {
    ScrollBox sb = target;
    sb.scrollPointChanged();
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    return super.onMeasure(availableWidth, availableHeight);
  }

  void _contentLayoutChanged(EventArgs e) {
    _updateScrollRanges(layoutWidth, layoutHeight, false);
    invalidateSize();
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY,
      num targetWidth, num targetHeight) {
    onMeasure(targetWidth, targetHeight);
    _updateScrollRanges(targetWidth, targetHeight, true);
    super.onLayout(targetX, targetY, targetWidth, targetHeight);
  }

  // TODO(ferhat): Update from flash version. fixes made to measure oscillation
  void _updateScrollRanges(num availableWidth, num availableHeight,
      bool commitLayout) {
    num contentWidth;
    num contentHeight;
    num viewPortWidth = availableWidth;
    num viewPortHeight = availableHeight;
    bool horizScrollVisible = false;
    bool vertScrollVisible = false;
    bool scrollBarVisibilityChanged = false;
    bool vertScrollWasVisible = false;

    if (_cachedContent != null) {
      // Assume visible vertscroll will stay visible.
      // This will prevent cachedContent measure to be oscillated.
      if (_vertScroll != null && verticalScrollEnabled && _vertScroll.visible) {
        if (_vertScroll.isMeasureDirty == false) {
          viewPortWidth -= _vertScroll.measuredWidth;
        }
        vertScrollWasVisible = true;
      }
      _cachedContent.measure(viewPortWidth, availableHeight);
      contentWidth = _cachedContent.measuredWidth;
      contentHeight = _cachedContent.measuredHeight;
      if ((contentHeight > availableHeight) &&
        (_vertScroll != null) && verticalScrollEnabled) {
        if (!vertScrollWasVisible) {
          viewPortWidth -= _vertScroll.measuredWidth;
        }
        vertScrollVisible = true;
      } else if (vertScrollWasVisible) {
        // Not visible anymore.
        viewPortWidth += _vertScroll.measuredWidth;
        _cachedContent.measure(viewPortWidth, availableHeight);
        vertScrollVisible = false;
      }

      if ((contentWidth > availableWidth) &&
        (_horizScroll != null) && horizontalScrollEnabled) {
        horizScrollVisible = true;
        viewPortHeight -= _horizScroll.measuredHeight;
      }
    }
    if (_vertScroll != null && commitLayout) {
      if (!vertScrollVisible) {
        scrollPointY = 0;
      } else if (scrollPointY > (contentHeight - viewPortHeight)) {
        // if scrollbox height expands or contentHeight shrinks and
        // scrollPointY is too large correct scroll position
        scrollPointY = contentHeight - viewPortHeight;
      }
      if (_vertScroll.visible != vertScrollVisible) {
        if (vertScrollVisible) {
          _vertScroll.opacity = 0.0;
          _vertScroll.animate(UIElement.opacityProperty, 1.0,
              duration:_FADEIN_DURATION_MS, delay:_FADEIN_DELAY_MS);
        }
        _vertScroll.visible = vertScrollVisible;
        scrollBarVisibilityChanged = true;
      }
      if (vertScrollVisible) {
        _vertScroll.maxValue = contentHeight - viewPortHeight;
      } else {
        _vertScroll.maxValue = _vertScroll.minValue;
      }
    }
    if (_horizScroll != null && commitLayout) {
      if (!horizScrollVisible) {
        scrollPointX = 0;
      } else if (scrollPointX > (contentWidth - viewPortWidth)) {
        // if scrollbox width expands or contentWidth shrinks and
        // scrollPointX is too large, correct scroll position
        scrollPointX = contentWidth - viewPortWidth;
      }
      if (_horizScroll.visible != horizScrollVisible) {
        if (horizScrollVisible) {
          _horizScroll.opacity = 0.0;
          _horizScroll.animate(UIElement.opacityProperty, 1.0,
              duration:_FADEIN_DURATION_MS, delay:_FADEIN_DELAY_MS);
        }
        _horizScroll.visible = horizScrollVisible;
        scrollBarVisibilityChanged = true;
      }
      if (horizScrollVisible) {
        _horizScroll.maxValue = contentWidth - viewPortWidth;
      } else {
        _horizScroll.maxValue = _horizScroll.minValue;
      }
    }
    if (scrollBarVisibilityChanged) {
      invalidateSize();
      invalidateLayout();
    }
  }

  // Scroll to place child into view.
  static _scrollChildHandler(Object target, EventArgs e) {
    ScrollBox sb = target;
    if (sb._scrollChildIntoView(e.source)) {
      e.handled = true;
    }
  }

  bool _scrollChildIntoView(UIElement child) {
    bool handled = false;
    if (!UpdateQueue.busy) {
      UpdateQueue.flush();
    }
    // Calc relative location of child to host canvas.
    if (_contentPart == null) {
      return false;
    }
    Coord childCoord = child.localToScreen(new Coord(0, 0));
    Coord canvasRelative = _contentPart.screenToLocal(childCoord);
    if (horizontalScrollEnabled && (_horizScroll != null)) {
      num viewPortWidth = layoutWidth - ((_vertScroll != null &&
          _vertScroll.visible && verticalScrollEnabled) ?
          _vertScroll.measuredWidth : 0);
      num newX = scrollPointX;
      if ((canvasRelative.x + child.layoutWidth) > (viewPortWidth +
          scrollPointX)) {
        num deltaX =  canvasRelative.x - viewPortWidth + child.layoutWidth;
        newX = min(_horizScroll.maxValue, scrollPointX + deltaX);
        if ((canvasRelative.x - deltaX) < 0) {
          // scrolled left out of view. correct.
          newX = scrollPointX - canvasRelative.x;
        }
      } else if (canvasRelative.x < 0) {
        newX = max(0, canvasRelative.x + scrollPointX);
      }
      if (newX != scrollPointX) {
        animate(scrollPointXProperty, newX, duration: 100);
        handled = true;
      }
    }
    if (verticalScrollEnabled && (_vertScroll != null)) {
      num viewPortHeight = layoutHeight - ((_horizScroll != null &&
          _horizScroll.visible &&
          horizontalScrollEnabled) ? _horizScroll.measuredHeight : 0);
      num newY = scrollPointY;
      if ((canvasRelative.y + child.layoutHeight) > viewPortHeight) {
        // scroll up.
        num deltaY = canvasRelative.y - viewPortHeight + child.layoutHeight;
        newY = min(_vertScroll.maxValue, scrollPointY + deltaY);
        if ((canvasRelative.y - deltaY) < 0) {
          // scrolled top out of view. correct.
          newY = scrollPointY - canvasRelative.y;
        }
      } else if (canvasRelative.y < 0) {
        // scroll down to reveal item.
        newY = max(0, canvasRelative.y + scrollPointY);
      }
      if (newY != scrollPointY) {
        animate(scrollPointYProperty, newY, duration:100);
        handled = true;
      }
    }
    return handled;
  }

  /** Registers component. */
  static void registerScrollBox() {
    horizontalScrollEnabledProperty = ElementRegistry.registerProperty(
        "horizontalScrollEnabled", PropertyType.BOOL, PropertyFlags.NONE, null,
        true);
    verticalScrollEnabledProperty = ElementRegistry.registerProperty(
        "verticalScrollEnabled", PropertyType.BOOL, PropertyFlags.NONE, null,
        true);
    panningEnabledProperty = ElementRegistry.registerProperty("panningEnabled",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    scrollPointXProperty = ElementRegistry.registerProperty("scrollPointX",
        PropertyType.NUMBER, PropertyFlags.NONE, _scrollPointChangedHandler,
        0.0);
    scrollPointYProperty = ElementRegistry.registerProperty("scrollPointY",
        PropertyType.NUMBER, PropertyFlags.NONE, _scrollPointChangedHandler,
        0.0);
    scrollboxElementDef = ElementRegistry.register("ScrollBox",
        ContentContainer.contentcontainerElementDef,
        [horizontalScrollEnabledProperty, panningEnabledProperty,
        verticalScrollEnabledProperty, scrollPointXProperty,
        scrollPointYProperty], null);
    UIElement.scrollIntoViewEvent.addHandler(scrollboxElementDef,
        _scrollChildHandler);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => scrollboxElementDef;
}
