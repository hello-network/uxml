part of uxml;

/**
* Implements a scrollbar control.
*
* @author:ferhat@ (Ferhat Buyukkokten)
*/
class ScrollBar extends Control {
  static ElementDef scrollbarElementDef;
  /** Orientation property definition */
  static PropertyDefinition orientationProperty;
  /** Value property definition */
  static PropertyDefinition valueProperty;
  /** MinValue property definition */
  static PropertyDefinition minValueProperty;
  /** MaxValue property definition */
  static PropertyDefinition maxValueProperty;

  /** ValueChanged event definition */
  static EventDef valueChangedEvent;

  /** recycled valuechange event argument */
  static EventArgs _valueChangedArg = null;
  /**
   * Constructor.
   */
  ScrollBar() : super() {
  }

  /**
   * Sets or returns orientation: UIElement.HORIZONTAL, UIElement.VERTICAL.
   */
  int get orientation {
    return getProperty(orientationProperty);
  }

  set orientation(int value) {
    setProperty(orientationProperty, value);
  }

  /**
   * Sets or return value of slider.
   */
  num get value {
    return getProperty(valueProperty);
  }

  set value(num value) {
    setProperty(valueProperty, value);
  }

  /**
   * Sets or returns minimum value.
   */
  num get minValue {
    return getProperty(minValueProperty);
  }

  set minValue(num value) {
    setProperty(minValueProperty, value);
  }

  /**
   * Sets or returns maximum value.
   */
  num get maxValue {
    return getProperty(maxValueProperty);
  }

  set maxValue(num value) {
    setProperty(maxValueProperty, value);
  }

  /**
   * Returns true if orientation is horizontal.
   */
  bool get isHorizontal {
    return orientation == UIElement.HORIZONTAL;
  }

  static void _valueChangedHandler(Object target, PropertyDefinition propDef,
      Object oldValue, Object newValue) {
    if (_valueChangedArg == null) {
      _valueChangedArg = new EventArgs(null); // reuse instance
    }
    ScrollBar scrollBar = target;
    _valueChangedArg.source = scrollBar;
    scrollBar.notifyListeners(ScrollBar.valueChangedEvent, _valueChangedArg);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => scrollbarElementDef;

  /** Registers component. */
  static void registerScrollBar() {
    orientationProperty = ElementRegistry.registerProperty("Orientation",
        PropertyType.ORIENTATION, PropertyFlags.RELAYOUT | PropertyFlags.RESIZE,
        null, UIElement.VERTICAL);
    valueProperty = ElementRegistry.registerProperty("Value",
        PropertyType.NUMBER, PropertyFlags.RELAYOUT, _valueChangedHandler, 0.0);
    minValueProperty = ElementRegistry.registerProperty("MinValue",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.0);
    maxValueProperty = ElementRegistry.registerProperty("MaxValue",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 100.0);
    valueChangedEvent = new EventDef("ValueChanged", Route.DIRECT);
    scrollbarElementDef = ElementRegistry.register("ScrollBar",
      Control.controlElementDef,
      [orientationProperty, valueProperty, minValueProperty, maxValueProperty],
      [valueChangedEvent]);
  }
}

