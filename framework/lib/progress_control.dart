part of uxml;

/**
 * Implements control for creating progress indicators.
 *
 * For easy layout, percentComplete, percentRemaining properties are exposed
 * for control chrome elements to bind to.
 *
 * For unbounded progress indicators such as a wait indicators, this class
 * provides a cycle property when set to true will cycle the value from min
 * to maxValue.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ProgressControl extends ValueRangeControl {
  final int FPS24 = 41; // approx 24 frames per second

  static ElementDef progresscontrolElementDef;
  // Default amount of time it takes for value to cycle from min to max.
  static const int DEFAULT_CYCLE_TIME_MS = 1000;

  // Default amount of time before value cycling begins.
  static const int DEFAULT_CYCLE_DELAY_MS = 0;

  static const int DEFAULT_STEP_COUNT = 0;

  bool _timerActive = false;
  int _stepValue;

  /** PercentComplete property definition */
  static PropertyDefinition percentCompleteProperty;
  /** PercentRemaining property definition */
  static PropertyDefinition percentRemainingProperty;
  /** PercentFormat property definition */
  static PropertyDefinition percentFormatProperty;
  /** PercentText property definition */
  static PropertyDefinition percentTextProperty;
  /** Cycle property definition */
  static PropertyDefinition cycleProperty;
  /** CycleDelay property definition */
  static PropertyDefinition cycleDelayProperty;
  /** CycleTime property definition */
  static PropertyDefinition cycleTimeProperty;
  /** Steps property definition */
  static PropertyDefinition stepsProperty;
  /** IsAnimating property definition */
  static PropertyDefinition isAnimatingProperty;

  // Keeps track of list of parents for which we are listening to visibility
  // changes since we don't want to animate when we are invisible.
  List<UIElement> _watchList = <UIElement>[];
  EventHandler _visibilityChangedHandler = null;


  ProgressControl() : super() {
    _stepValue = 0;
  }

  /**
   * Returns percent complete.
   */
  num get percentComplete {
    return getProperty(percentCompleteProperty);
  }

  /**
   * Returns percent remaining.
   */
  num get percentRemaining {
    return getProperty(percentRemainingProperty);
  }

  /**
   * Sets/returns if value should cycle in min and max range.
   */
  set cycle(bool value) {
    setProperty(cycleProperty, value);
  }

  bool get cycle {
    return getProperty(cycleProperty);
  }

  /**
   * Sets/returns amount of time (ms) it takes to cycle from min to max.
   */
  set cycleTime(int value) {
    setProperty(cycleTimeProperty, value);
  }

  int get cycleTime {
    return getProperty(cycleTimeProperty);
  }

  /**
   * Sets/returns amount of time (ms) before cycling begins.
   */
  set cycleDelay(int value) {
    setProperty(cycleDelayProperty, value);
  }

  int get cycleDelay {
    return getProperty(cycleDelayProperty);
  }

  /**
   * Sets/returns number of value steps. Set to 0 for no steps.
   */
  set steps(int value) {
    setProperty(stepsProperty, value);
  }

  int get steps {
    return getProperty(stepsProperty);
  }

  /**
   * Returns true when cycledelay elapses and  animation has started.
   */
  bool get isAnimating {
    return getProperty(isAnimatingProperty);
  }

  /**
   * Sets/returns formatting to use for percentText.
   */
  set percentFormat(String value) {
    setProperty(percentFormatProperty, value);
  }

  String get percentFormat {
    return getProperty(percentFormatProperty);
  }

  /**
   * Returns formatted completion percentage.
   */
  String get percentText {
    return getProperty(percentTextProperty);
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    _clearWatchList();
    if (_visibilityChangedHandler != null) {
      removeListener(UIElement.visibleProperty, _visibilityChangedHandler);
      _visibilityChangedHandler = null;
    }
    _stop();
    super.close();
  }

  void onValueChanged(num newValue) {
    super.onValueChanged(newValue);
    num complete = 0.0;
    num range = maxValue - minValue;
    if (!UxmlUtils.nearlyEquals(range, 0.0)) {
      complete = (value - minValue) / range;
    }
    setProperty(percentCompleteProperty, complete);
    setProperty(percentRemainingProperty, 1.0 - complete);
    int percentInt = ((complete * 100) + 0.5).toInt();
    String text = StringUtil.format(percentFormat, [percentInt.toString()]);
    setProperty(percentTextProperty, text);
  }

  static void _cycleChangeHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    ProgressControl control = target;
    if (control.hasSurface) {
      if (newValue) {
        control._start();
      } else {
        control._stop();
      }
    }
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    _visibilityChangedHandler = _visibilityChanged;
    addListener(UIElement.visibleProperty, _visibilityChangedHandler);
    if (cycle && visible) {
      _start();
    }
  }

  void _visibilityChanged(EventArgs e) {
    bool isVisible = visible;
    for (int i = 0; i < _watchList.length; i++) {
      if (_watchList[i].visible == false) {
        isVisible = false;
      }
    }
    if (visible) {
      if (cycle) {
        _start();
      }
    } else {
      _stop();
    }
  }

  void _start() {
    _clearWatchList();
    UIElement elm = this.visualParent;
    while (elm != null) {
      _watchList.add(elm);
      elm.addListener(UIElement.visibleProperty, _visibilityChangedHandler);
      elm = elm.visualParent;
    };

    _stepValue = 0;
    int frameDuration = (cycleTime ~/ steps);
    if (frameDuration < FPS24) {
      frameDuration = FPS24;
    }
    Application.current.scheduler.schedule(frameDuration,
        1, _timerElapsed, this, null);
    _timerActive = true;
  }

  void _clearWatchList() {
    if (_visibilityChangedHandler != null) {
      for (int i = 0; i < _watchList.length; i++) {
        _watchList[i].removeListener(UIElement.visibleProperty,
            _visibilityChangedHandler);
      }
      _visibilityChangedHandler = null;
      _watchList.clear();
    }
  }

  void _timerElapsed(num val, Object tag) {
    if (val == 1.0) {
      _stepValue++;
      if (_stepValue == steps) {
        _stepValue = 0;
      }
      setProperty(isAnimatingProperty, true);
      value = minValue + (_stepValue * ((maxValue - minValue) / steps));
      if (_timerActive) {
        int frameDuration = (cycleTime ~/ steps);
        if (frameDuration < FPS24) {
          frameDuration = FPS24;
        }
        Application.current.scheduler.schedule(frameDuration,
            1, _timerElapsed, this, null);
      }
    }
  }

  void _stop() {
    if (_timerActive) {
      _timerActive = false;
      setProperty(isAnimatingProperty, false);
      invalidateDrawing();
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => progresscontrolElementDef;

  /** Registers component. */
  static void registerProgressControl() {
    percentCompleteProperty = ElementRegistry.registerProperty(
        "percentComplete", PropertyType.NUMBER, PropertyFlags.NONE, null, 0.0);
    percentRemainingProperty = ElementRegistry.registerProperty(
        "percentRemaining", PropertyType.NUMBER, PropertyFlags.NONE, null,
        100.0);
    percentFormatProperty = ElementRegistry.registerProperty("PercentFormat",
        PropertyType.STRING, PropertyFlags.NONE, null, "%{0}");
    percentTextProperty = ElementRegistry.registerProperty("PercentText",
        PropertyType.STRING, PropertyFlags.NONE, null, "");
    cycleProperty = ElementRegistry.registerProperty("Cycle", PropertyType.BOOL,
        PropertyFlags.NONE, _cycleChangeHandler, false);
    cycleDelayProperty = ElementRegistry.registerProperty("CycleDelay",
        PropertyType.INT, PropertyFlags.NONE, null, DEFAULT_CYCLE_DELAY_MS);
    cycleTimeProperty = ElementRegistry.registerProperty("CycleTime",
        PropertyType.INT, PropertyFlags.NONE, null, DEFAULT_CYCLE_TIME_MS);
    stepsProperty = ElementRegistry.registerProperty("Steps",
        PropertyType.INT, PropertyFlags.NONE, null, DEFAULT_STEP_COUNT);
    isAnimatingProperty = ElementRegistry.registerProperty("IsAnimating",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);

    progresscontrolElementDef = ElementRegistry.register("ProgressControl",
        ValueRangeControl.valuerangecontrolElementDef,
        [percentCompleteProperty, percentRemainingProperty,
        percentFormatProperty, percentTextProperty, cycleProperty,
        cycleDelayProperty, cycleTimeProperty, stepsProperty,
        isAnimatingProperty], null);
  }
}
