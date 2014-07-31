part of uxml;

/**
 * Manages location and size of thumb element inside a track.
 *
 * Unless the thumb element specifies min/max/width constraints,
 * the thumb will be scaled to layoutHeight/range.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class Slider extends ValueRangeControl {
  /** Orientation property definition */
  static PropertyDefinition orientationProperty;
  /** Number of tick marks property definition */
  static PropertyDefinition ticksProperty;
  /** Thumb property definition */
  static PropertyDefinition thumbProperty;
  /** Thumb pressed property definition */
  static PropertyDefinition thumbPressedProperty;
  /** ThumbSize property definition */
  static ElementDef sliderElementDef;

  bool _thumbPressed;
  num _thumbStartPos;
  num _moveStartValue;

  // Name of optional track part.
  static const String TRACK_PART_ID = "trackPart";

  Slider() : super() {
    _thumbPressed = false;
    _thumbStartPos = 0.0;
    _moveStartValue = 0.0;
  }

  /**
   * Sets or returns orientation.
   */
  int get orientation {
    return getProperty(orientationProperty);
  }

  set orientation(int value) {
    setProperty(orientationProperty, value);
  }

  /**
   * Sets or returns thumb element.
   */
  UIElement get thumb {
    return getProperty(thumbProperty);
  }

  set thumb(UIElement element) {
    setProperty(thumbProperty, element);
  }

  /**
   * Returns true if thumb is currently in pressed state.
   */
  bool get isPressed => getProperty(thumbPressedProperty);

  /**
   * Sets or returns number of tick marks on slider.
   */
  int get ticks => getProperty(ticksProperty);

  set ticks(int value) {
    setProperty(ticksProperty, value);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    if (chromeTree != null) {
      chromeTree.measure(availableWidth, availableHeight);
      maxWidth = chromeTree.measuredWidth;
      maxHeight = chromeTree.measuredHeight;
    }

    UIElement thumbElement = thumb;
    if (thumbElement != null) {
      thumbElement.measure(availableWidth, availableHeight);
      if (thumbElement.measuredWidth > maxWidth) {
        maxWidth = thumbElement.measuredWidth;
      }
      if (thumbElement.measuredHeight > maxHeight) {
        maxHeight = thumbElement.measuredHeight;
      }
    }
    setMeasuredDimension(maxWidth, maxHeight);
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    UIElement thumbElement = thumb;
    if (chromeTree != null) {
      chromeTree.layout(0.0, 0.0, targetWidth, targetHeight);
    }
    if (thumbElement == null) {
      return;
    }
    if (orientation == UIElement.VERTICAL) {
      thumbElement.opacity = (targetHeight >= thumbElement.measuredHeight) &&
          (thumbElement.measuredHeight != 0) ? 1.0 : 0.0;
      thumbElement.layout(0.0, (value - minValue) * _valueScaleFactor, max(
          thumbElement.measuredWidth, targetWidth), _thumbSize);
    } else {
      thumbElement.layout((value - minValue) * _valueScaleFactor, 0.0,
          _thumbSize, max(thumbElement.measuredHeight, targetHeight));
    }
  }

  /**
   * Returns scale factor for value to coordinate translation.
   */
  num get _valueScaleFactor {
    if ((maxValue - minValue).abs() < 0.000001) {
      return 0.0;
    }
    if (orientation == UIElement.VERTICAL) {
      return (layoutHeight - _thumbSize) / (maxValue - minValue);
    } else {
      return (layoutWidth - _thumbSize) / (maxValue - minValue);
    }
  }

  num get _thumbSize {
    // maxValue - minValue is the scroll range (contentSize - viewportSize).
    // to scale thumb, we need to compute visiblecontextsize/viewportsize.
    num s;
    if (orientation == UIElement.VERTICAL) {
      if (thumb.overridesProperty(UIElement.heightProperty) == false &&
          thumb.overridesProperty(UIElement.minHeightProperty)) {
        if ((layoutHeight + maxValue - minValue).abs() < 0.000001) {
          return layoutHeight;
        }
        s = max(thumb.minHeight, layoutHeight * (layoutHeight /
            (layoutHeight + maxValue - minValue)));
      } else {
        s = thumb.measuredHeight;
      }
    } else {
      if (thumb.overridesProperty(UIElement.widthProperty) == false &&
          thumb.overridesProperty(UIElement.minWidthProperty)) {
        if ((layoutWidth + maxValue - minValue).abs() < 0.000001) {
          return layoutHeight;
        }
        s = max(thumb.minWidth, layoutWidth * (layoutWidth /
            (layoutWidth + maxValue - minValue)));
      } else {
        s = thumb.measuredWidth;
      }
    }
    return s;
  }

  // Resize thumb when maxValue constraint changes.
  void _applyConstraints() {
    super._applyConstraints();
    if (thumb == null) {
      return;
    }
    if (orientation == UIElement.VERTICAL) {
      if (thumb.overridesProperty(UIElement.heightProperty) == false &&
          thumb.overridesProperty(UIElement.minHeightProperty)) {
        invalidateLayout();
      }
    } else if (thumb.overridesProperty(UIElement.widthProperty) == false &&
        thumb.overridesProperty(UIElement.minWidthProperty)) {
      invalidateLayout();
    }
  }

  static void _thumbChangedHandler(Object target,
                                   PropertyDefinition propDef,
                                   Object oldValue,
                                   Object newValue) {
    Slider slider = target;
    slider._thumbChanged(oldValue, newValue);
  }

  static void _ticksChangedHandler(Object target,
                                   PropertyDefinition propDef,
                                   Object oldValue,
                                   Object newValue) {
    if (newValue != 0) {
      Cursor.setElementCursor(target, Cursor.BUTTON);
    }
  }

  /** Override UIElement.getRawChildCount. */
  int getRawChildCount() {
    return ((chromeTree != null) ? 1 : 0) + ((thumb != null) ? 1: 0);
  }

  /** Override UIElement.getRawChild. */
  UIElement getRawChild(int index) {
    return ((index == 0) && (chromeTree != null)) ? chromeTree : thumb;
  }

  void _thumbChanged(UIElement prevThumb, UIElement newThumb) {
    if (prevThumb != null) {
      prevThumb.removeListener(UIElement.mouseDownEvent, _handleThumbMouseDown);
      removeRawChild(prevThumb);
    }
    if (newThumb != null) {
      insertRawChild(newThumb, -1);
      newThumb.addListener(UIElement.mouseDownEvent, _handleThumbMouseDown);
    }
  }

  void _handleThumbMouseDown(MouseEventArgs args) {
    captureMouse();
    _moveStartValue = value;
    _thumbStartPos = (orientation == UIElement.VERTICAL) ?
        args.getMousePosition(this).y : args.getMousePosition(this).x;
    _thumbPressed = true;
    args.handled = true;
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs args) {
    UIElement trackElement = getElement(TRACK_PART_ID);
    if (trackElement != null) {
      num trackPos = 0.0;
      if (orientation == UIElement.VERTICAL) {
        num trackHeight = trackElement.layoutHeight;
        if (trackHeight == 0) {
          return;
        }
        trackPos = args.getMousePosition(trackElement).y / trackHeight;
        trackPos = (trackPos * (maxValue - minValue)) + minValue;
      } else {
        // horizontal slider
        num trackWidth = trackElement.layoutWidth;
        if (trackWidth == 0) {
          return;
        }
        trackPos = args.getMousePosition(trackElement).x / trackWidth;
        trackPos = (trackPos * (maxValue - minValue)) + minValue;
      }
      trackPos = normalizeTrackPos(trackPos);
      animate(ValueRangeControl.valueProperty, trackPos, duration: 150);
    }
    args.handled = true;
    captureMouse();
  }

  /**
   * Normalizes the track position by checking for min/max limits and
   * ticks setting.
   */
  num normalizeTrackPos(num trackPos) {
    if (ticks != 0) {
      trackPos = (trackPos - minValue) / (maxValue - minValue); // 0..1
      trackPos = ((((trackPos + (0.5 / ticks)) * ticks).toInt() / ticks) *
          (maxValue - minValue)) + minValue;
    }
    if (trackPos < minValue) {
      trackPos = minValue;
    }
    if (trackPos > maxValue) {
      trackPos = maxValue;
    }
    return trackPos;
  }

  /** Overrides UIElement.onMouseUp. */
  void onMouseUp(MouseEventArgs args) {
    if (ticks != 0) {
      num prevValue = value;
      num newValue = normalizeTrackPos(value);
      if (newValue != prevValue) {
        value = newValue;
      }
    }
    releaseMouse();
    _thumbPressed = false;
    args.handled = true;
  }

  /** Overrides UIElement.onMouseMove. */
  void onMouseMove(MouseEventArgs args) {
    if (_thumbPressed) {
      num newPos = (orientation == UIElement.VERTICAL) ?
          args.getMousePosition(this).y : args.getMousePosition(this).x;
      num newValue = _moveStartValue + ((newPos - _thumbStartPos)) /
          _valueScaleFactor;
      value = normalizeTrackPos(newValue);
      args.handled = true;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => sliderElementDef;

  /** Registers component. */
  static void registerSlider() {
    orientationProperty = ElementRegistry.registerProperty("Orientation",
        PropertyType.ORIENTATION, PropertyFlags.RELAYOUT | PropertyFlags.RESIZE,
        null, UIElement.HORIZONTAL);
    ticksProperty = ElementRegistry.registerProperty("Ticks",
        PropertyType.INT, PropertyFlags.NONE, _ticksChangedHandler, 0);
    thumbProperty = ElementRegistry.registerProperty("Thumb",
        PropertyType.UIELEMENT, PropertyFlags.NONE, _thumbChangedHandler, null);
    thumbPressedProperty = ElementRegistry.registerProperty("isPressed",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    sliderElementDef = ElementRegistry.register("Slider",
        ValueRangeControl.valuerangecontrolElementDef,
        [orientationProperty, ticksProperty, thumbProperty,
        thumbPressedProperty], null);
  }
}
