part of uxml;

/**
 * Implements a button control that sends click events and exposes
 * isPressed property.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class Button extends ContentContainer {

  /** IsPressed property definition. */
  static PropertyDefinition isPressedProperty;
  /** clickWhenPressed property definition. */
  static PropertyDefinition clickWhenPressedProperty;
  /** updateFocusOnMouseDown property definition. */
  static PropertyDefinition updateFocusOnMouseDownProperty;
  /** Repeat rate property definition. */
  static PropertyDefinition repeatRateProperty;
  /** Repeat delay property definition. */
  static PropertyDefinition repeatDelayProperty;
  /** Click event definition */
  static EventDef clickEvent;
  static ElementDef buttonElementDef;
  EventHandler _previewHandler = null;

  /**
   * Constructor.
   */
  Button() : super() {
    focusEnabled = true;
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    _hostSurface.hitTestMode = UISurfaceImpl.HITTEST_BOUNDS;
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    if (updateFocusOnMouseDown) {
      UIElement focusedElement = Application.focusManager.focusedElement;
      if (focusedElement != this && focusedElement != null) {
        focusedElement.isFocused = false;
      }
    }
    // We need to watch for mouseup events outside the button to correctly
    // reset isPressedProperty.
    _previewHandler = _mousePreviewHandler;
    Application.current.addListener(Application.mousePreviewEvent,
        _previewHandler);
    setProperty(isPressedProperty, true);
    mouseArgs.handled = true;
    Application._mouseDownTarget = this;
    if (clickWhenPressed) {
      onClick(mouseArgs);
    }
  }

  void _mousePreviewHandler(MouseEventArgs e) {
    if (e.event == UIElement.mouseUpEvent) {
      setProperty(isPressedProperty, false);
      if (_previewHandler != null) {
        Application.current.removeListener(Application.mousePreviewEvent,
            _previewHandler);
        _previewHandler = null;
      }
    }
  }

  /** Overrides UIElement.onMouseUp. */
  void onMouseUp(MouseEventArgs mouseArgs) {
    if (Application._mouseDownTarget == this) {
      if (isMouseOver && (clickWhenPressed == false)) {
        onClick(mouseArgs);
      }
    }
  }

  /** Overrides UIElement.onKeyDown. */
  void onKeyDown(KeyboardEventArgs keyArgs) {
    if (isFocused && ((keyArgs.keyCode == KeyboardEventArgs.KEYCODE_ENTER) ||
        (keyArgs.keyCode == KeyboardEventArgs.KEYCODE_SPACE))) {
      keyArgs.handled = true;
      onClick(keyArgs);
    }
  }


  void _raiseClickEvent(EventDef sourceEvent) {
    EventArgs clickArgs = new EventArgs(this);
    clickArgs.event = sourceEvent;
    clickArgs.source = this;
    notifyListeners(clickEvent, clickArgs);
  }

  void onClick(EventArgs sourceEvent) {
    _raiseClickEvent(sourceEvent.event);
    if (repeatRate != 0 && isPressed) {
      UIPlatform.setTimeout(_repeatClick, repeatDelay != 0 ? repeatDelay :
          repeatRate);
    }
  }

  void _repeatClick() {
    if (isPressed) {
      _raiseClickEvent(clickEvent);
      UIPlatform.setTimeout(_repeatClick, repeatRate);
    }
  }

  /**
   * Returns true if button is currently in pressed state.
   */
  bool get isPressed => getProperty(isPressedProperty);

  /**
   * Sets returns if button should fire click event on isPressed
   * instead of default mouseup.
   */
  set clickWhenPressed(bool value) {
    setProperty(clickWhenPressedProperty, value);
  }

  bool get clickWhenPressed => getProperty(clickWhenPressedProperty);

  /**
   * Sets returns time in ms between click events when user keeps button
   * pressed. Setting value to 0 disables repeat.
   */
  set repeatRate(int value) {
    setProperty(repeatRateProperty, value);
  }

  int get repeatRate => getProperty(repeatRateProperty);

  /**
   * Sets returns time delay in ms between first button press and start of
   * repeating click events.
   */
  set repeatDelay(int value) {
    setProperty(repeatDelayProperty, value);
  }

  int get repeatDelay => getProperty(repeatDelayProperty);

  /**
   * Sets returns if button should fire click event on isPressed
   * instead of default mouseup.
   */
  set updateFocusOnMouseDown(bool value) {
    setProperty(updateFocusOnMouseDownProperty, value);
  }

  bool get updateFocusOnMouseDown => getProperty(
      updateFocusOnMouseDownProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => buttonElementDef;

  /** Registers component. */
  static void registerButton() {
    isPressedProperty = ElementRegistry.registerProperty("isPressed",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    clickWhenPressedProperty = ElementRegistry.registerProperty(
        "clickWhenPressed", PropertyType.BOOL, PropertyFlags.NONE, null, false);
    updateFocusOnMouseDownProperty = ElementRegistry.registerProperty(
        "updateFocusOnMouseDown", PropertyType.BOOL, PropertyFlags.NONE, null,
        true);
    repeatRateProperty = ElementRegistry.registerProperty("repeatRate",
        PropertyType.INT, PropertyFlags.NONE, null, 0);
    repeatDelayProperty = ElementRegistry.registerProperty("repeatDelay",
        PropertyType.INT, PropertyFlags.NONE, null, 250);
    clickEvent = new EventDef("Click", Route.DIRECT);
    buttonElementDef = ElementRegistry.register("Button",
        ContentContainer.contentcontainerElementDef,
        [isPressedProperty, clickWhenPressedProperty, repeatRateProperty,
        repeatDelayProperty],
        [clickEvent]);
    // Set default value for cursor on Button instances to HAND
    Cursor.cursorProperty.overrideDefaultValue(buttonElementDef, Cursor.BUTTON);
  }
}
