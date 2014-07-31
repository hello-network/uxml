part of uxml;

/**
 * Defines base class for controls that have are based on a range of values.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ValueRangeControl extends Control {
  static ElementDef valuerangecontrolElementDef;
  /** MinValue property definition */
  static PropertyDefinition minValueProperty;
  /** MaxValue property definition */
  static PropertyDefinition  maxValueProperty;
  /** Value property definition */
  static PropertyDefinition valueProperty;
  /** ValueChanged event definition */
  static EventDef valueChangedEvent;

  static EventArgs _valueChangedArg = null;

  ValueRangeControl() : super() {
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

  static void _valueChangedHandler(Object target,
      Object propDef, Object oldValue, Object newValue) {
    ValueRangeControl control = target;
    control.onValueChanged(newValue);
    if (_valueChangedArg == null) {
      _valueChangedArg = new EventArgs(control); // reuse instance
    }
    _valueChangedArg.source = control;
    control.notifyListeners(valueChangedEvent, _valueChangedArg);
  }

  void onValueChanged(num newValue) {
    invalidateLayout();
  }

  static void _constraintValueChangedHandler(Object target,
      Object propDef, Object oldValue, Object newValue) {
    ValueRangeControl control = target;
    control._applyConstraints();
  }

  void _applyConstraints() {
    if (value < minValue && (!minValue.isNaN)) {
      value = minValue;
    }

    if (maxValue < minValue) {
      maxValue = minValue;
    }

    if (value > maxValue && (!maxValue.isNaN)) {
      value = maxValue;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => valuerangecontrolElementDef;

  /** Registers component. */
  static void registerValueRangeControl() {
    minValueProperty = ElementRegistry.registerProperty("minvalue",
        PropertyType.NUMBER, PropertyFlags.NONE, _constraintValueChangedHandler,
        0.0);
    maxValueProperty = ElementRegistry.registerProperty("maxvalue",
        PropertyType.NUMBER, PropertyFlags.NONE, _constraintValueChangedHandler,
        100.0);
    valueProperty = ElementRegistry.registerProperty("value",
        PropertyType.NUMBER, PropertyFlags.NONE, _valueChangedHandler, 0.0);
    valueChangedEvent = new EventDef("ValueChanged", Route.DIRECT);
    valuerangecontrolElementDef = ElementRegistry.register("ValueRangeControl",
        Control.controlElementDef, [valueProperty, minValueProperty,
        maxValueProperty], [valueChangedEvent]);
  }
}
