part of uxml;

/**
 * Implements container that reveals it's contents when
 * isOpen property is set using transitions.
 */
class DisclosureBox extends UIElementContainer {

  // Property Definitions.
  static ElementDef disclosureboxElementDef;
  static PropertyDefinition isOpenProperty;
  static PropertyDefinition fadeProperty;
  static PropertyDefinition transitionProperty;
  static PropertyDefinition durationProperty;

  // Transition style constants.
  static const int TRANSITION_NONE = 0;
  static const int TRANSITION_REVEAL_HEIGHT = 1;
  static const int TRANSITION_REVEAL_WIDTH = 2;
  static const int TRANSITION_REVEAL = 3;
  static const int TRANSITION_SCROLL_UP = 4;
  static const int TRANSITION_SCROLL_DOWN = 5;
  static const int TRANSITION_SCROLL_LEFT = 6;
  static const int TRANSITION_SCROLL_RIGHT = 7;
  static const int TRANSITION_SLIDE_UP = 8;
  static const int TRANSITION_SLIDE_DOWN = 9;
  static const int TRANSITION_SLIDE_LEFT = 10;
  static const int TRANSITION_SLIDE_RIGHT = 11;
  static const int TRANSITION_ZOOM = 12;
  static const int TRANSITION_GROW = 13;

  static const int TRANSITION_MASK_FADEIN = 0x100;

  static const int STATE_IDLE = 0;
  static const int STATE_OPENING = 1;
  static const int STATE_CLOSING = 2;
  // Duration of transition between open/close states.
  static const int DEFAULT_DURATION = 150;

  int openTransition = TRANSITION_REVEAL;
  int transitionState = STATE_IDLE;
  ScheduledTask _currentTask;

  num _animStep = 0.0;
  bool _justStarted = true;

  num _measuredMaxWidth;
  num _measuredMaxHeight;

  DisclosureBox() : super() {
  }

  /**
   * Sets/returns open state.
   */
  bool get isOpen => getProperty(isOpenProperty);

  set isOpen(bool value) {
    return setProperty(isOpenProperty, value);
  }

  /**
   * Sets/returns if fading is enabled.
   */
  bool get fade => getProperty(fadeProperty);

  set fade(bool value) {
    setProperty(fadeProperty, value);
  }

  /**
   * Sets returns transition type.
   */
  int get transition => getProperty(transitionProperty);

  set transition(int value) {
    setProperty(transitionProperty, value);
  }

  /**
   * Sets returns duration of animation.
   */
  int get duration => getProperty(durationProperty);

  set duration(int value) {
    setProperty(durationProperty, value);
  }

  void surfaceInitialized(UISurface surface) {
    clipChildren = true;
    if (isOpen) {
      _isOpenChanged(true);
    }
  }

  void _animateOpenHandler(num tweenValue, Object tag) {
    _animStep = tweenValue;
    if (fade) {
      opacity = _animStep;
    }
    switch (openTransition) {
      case TRANSITION_ZOOM:
      case TRANSITION_GROW:
        this.transform.scaleX = (_animStep * 0.9) + 0.1;
        this.transform.scaleY = (_animStep * 0.9) + 0.1;
        break;
      default:
        break;
    }
    switch (openTransition) {
      case TRANSITION_SCROLL_UP:
      case TRANSITION_SCROLL_DOWN:
      case TRANSITION_SCROLL_LEFT:
      case TRANSITION_SCROLL_RIGHT:
        invalidateLayout();
        break;
      case TRANSITION_ZOOM:
        break;
      default:
        invalidateSize();
        break;
    }
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    int numChildren = childCount;
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    for (int i = 0; i < numChildren; ++i) {
      UIElement child = childElements[i];
      child.measure(availableWidth, availableHeight);
      if (child.measuredWidth > maxWidth) {
        maxWidth = child.measuredWidth;
      }
      if (child.measuredHeight > maxHeight) {
        maxHeight = child.measuredHeight;
      }
    }
    _measuredMaxHeight = maxHeight;
    _measuredMaxWidth = maxWidth;

    switch (openTransition) {
      case TRANSITION_REVEAL:
      case TRANSITION_REVEAL_HEIGHT:
      case TRANSITION_GROW:
      case TRANSITION_SLIDE_UP:
      case TRANSITION_SLIDE_DOWN:
        num currentHeight = ((maxHeight * _animStep) + .5).toInt();
        setMeasuredDimension(maxWidth, currentHeight);
        break;
      case TRANSITION_REVEAL_WIDTH:
      case TRANSITION_SLIDE_LEFT:
      case TRANSITION_SLIDE_RIGHT:
        num currentWidth = ((maxWidth * _animStep) + .5).toInt();
        setMeasuredDimension(currentWidth, maxHeight);
        break;
      case TRANSITION_ZOOM:
      case TRANSITION_SCROLL_UP:
      case TRANSITION_SCROLL_DOWN:
      case TRANSITION_SCROLL_LEFT:
      case TRANSITION_SCROLL_RIGHT:
        setMeasuredDimension(maxWidth, maxHeight);
        break;
    }

    if ((openTransition == TRANSITION_ZOOM) ||
        (openTransition == TRANSITION_GROW)) {
      if (_justStarted && transitionState == STATE_OPENING) {
        if (fade) {
          opacity = 0.0;
        }
        transform.scaleX = 0.1;
        transform.scaleY = 0.1;
      }
    }
    _justStarted = false;
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    int i;
    int numChildren = childCount;
    num finalWidth = min(_measuredMaxWidth, targetWidth);
    num finalHeight = min(_measuredMaxHeight, targetHeight);
    for (i = 0; i < numChildren; ++i) {
      UIElement child = childAt(i);
      switch (openTransition) {
        case TRANSITION_SCROLL_UP:
        case TRANSITION_SLIDE_UP:
          child.layout(0, (1 - _animStep) * finalHeight, targetWidth,
              finalHeight);
          break;
        case TRANSITION_SCROLL_DOWN:
        case TRANSITION_SLIDE_DOWN:
          child.layout(0, - (1 - _animStep) * finalHeight, targetWidth,
              finalHeight);
          break;
        case TRANSITION_SCROLL_LEFT:
        case TRANSITION_SLIDE_LEFT:
          child.layout((1 - _animStep) * finalWidth, 0,
              finalWidth, targetHeight);
          break;
        case TRANSITION_SCROLL_RIGHT:
        case TRANSITION_SLIDE_RIGHT:
          child.layout(- (1 - _animStep) * finalWidth, 0,
              finalWidth, targetHeight);
          break;
        case TRANSITION_GROW:
        case TRANSITION_REVEAL:
        case TRANSITION_REVEAL_HEIGHT:
        case TRANSITION_ZOOM:
          child.layout(0, 0, targetWidth, finalHeight);
          break;
        case TRANSITION_REVEAL_WIDTH:
          child.layout(0, 0, finalWidth, targetHeight);
          break;
      }
    }
  }

  /** Overrides UIElement.close. */
  void close() {
    transitionState = STATE_IDLE;
    isOpen = false;
    super.close();
  }

  static void _isOpenChangedHandler(Object target,
                                    PropertyDefinition propDef,
                                    Object oldValue,
                                    Object newValue) {
    DisclosureBox box = target;
    box._isOpenChanged(newValue);
  }

  void _isOpenChanged(bool opening) {
    if (!hasSurface) {
      return;
    }

    AnimationScheduler scheduler = Application.current.scheduler;
    num startStep;
    if (_currentTask != null) {
      startStep = _animStep;
      scheduler.cancel(_currentTask);
    } else {
      _justStarted = true;
      startStep = opening ? 0.0 : 1.0;
    }
    if (opening) {
      transitionState = STATE_OPENING;
      _currentTask = scheduler.scheduleInRange(0, duration * (1 - startStep),
          _animateOpenHandler, this, null, startStep, 1.0);
    } else {
      transitionState = STATE_CLOSING;
      _currentTask = scheduler.scheduleInRange(0, duration * startStep,
          _animateOpenHandler, this, null, startStep, 0.0);
    }
  }

  static void _fadeChangedHandler(Object target,
                                  PropertyDefinition propDef,
                                  Object oldValue,
                                  Object newValue) {
    DisclosureBox box = target;
    box.opacity = newValue ? (box.isOpen ? 1.0 : 0.0) : 1.0;
  }

  static void _transitionChangedHandler(Object target, PropertyDefinition propDef, Object oldValue,
      Object newValue) {
    DisclosureBox box = target;
    box.openTransition = newValue;
    box.transform.scaleX = 1.0;
    box.transform.scaleY = 1.0;
    box.transform.translateY = 0;
    box.invalidateSize();
  }

  /** Registers component. */
  static void registerDisclosureBox() {
    isOpenProperty = ElementRegistry.registerProperty("IsOpen",
        PropertyType.BOOL, PropertyFlags.NONE, _isOpenChangedHandler, false);
    fadeProperty = ElementRegistry.registerProperty("Fade",
        PropertyType.BOOL, PropertyFlags.NONE,
        _fadeChangedHandler, false);
    transitionProperty = ElementRegistry.registerProperty("Transition",
        PropertyType.INT, PropertyFlags.NONE, _transitionChangedHandler,
        TRANSITION_REVEAL_HEIGHT);
    durationProperty = ElementRegistry.registerProperty("Duration",
        PropertyType.INT, PropertyFlags.NONE, null, DEFAULT_DURATION);
    disclosureboxElementDef = ElementRegistry.register("DisclosureBox",
        UIElementContainer.uielementcontainerElementDef, [isOpenProperty,
        fadeProperty], null);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => disclosureboxElementDef;
}

/** TODO(ferhat): deprecate by changing codegen serializer. */
class Transition {
  static const int SCROLLRIGHT = DisclosureBox.TRANSITION_SCROLL_RIGHT;
  static const int SLIDELEFT = DisclosureBox.TRANSITION_SLIDE_LEFT;
  static const int SLIDEDOWN = DisclosureBox.TRANSITION_SLIDE_DOWN;
}
