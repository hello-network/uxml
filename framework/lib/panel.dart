part of uxml;

/**
* Panel provides a container with a visual state(maximized,minimized) and a
* title.
*
* @author ferhat@ (Ferhat Buyukkokten)
*/
class Panel extends ContentContainer {
  static ElementDef panelElementDef;
  /** Title property definition */
  static PropertyDefinition titleProperty;

  /** ViewState property definition */
  static PropertyDefinition viewStateProperty;

  /** MaximizeEnabled property definition */
  static PropertyDefinition maximizeEnabledProperty;

  /** MinimizeEnabled property definition */
  static PropertyDefinition minimizeEnabledProperty;

  /** MoveEnabled property definition */
  static PropertyDefinition moveEnabledProperty;

  /** Panel moved event definition */
  static EventDef movedEvent;

  // Windowing behaviour:
  // 1- A Panel can be displayed modally using the show method and
  //    closed using the close method.
  //
  // 2- For maximize, minimize, restore operations, the viewState change
  //    is handled by the element hosting the Panel or by the application
  //    itself (for modal top level panels).

  /** ViewState constant for normal view */
  static const int VIEW_STATE_NORMAL = 0;

  /** ViewState constant for maximized view */
  static const int VIEW_STATE_MAXIMIZED = 1;

  /** ViewState constant for maximized view */
  static const int VIEW_STATE_MINIMIZED = 2;

  /**
  * Standard framework id for maximize button.
  */
  static const String MAXIMIZE_BUTTON_ID = "maximizePanelButton";

  /**
   * Standard framework id for minimize button.
   */
  static const String MINIMIZE_BUTTON_ID = "minimizePanelButton";

  /**
  * Standard framework id for maximize button chrome.
  */
  static const String MAXIMIZE_CHROME_ID = "maximizePanelChrome";

  /**
  * Standard framework id for maximize button chrome.
  */
  static const String MINIMIZE_CHROME_ID = "minimizePanelChrome";


  /** Mouse position at time of drag_start */
  Coord _mouseDelta;
  EventArgs _movedEventArgs;

  bool _isMousePressed = false;

  /**
   * Constructor
   */
  Panel() : super() {
  }

  /**
  * Gets or returns title of panel.
  */
  String get title {
    return getProperty(titleProperty);
  }

  set title(String value) {
    setProperty(titleProperty, value);
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    if (moveEnabled) {
      captureMouse();
      _mouseDelta = mouseArgs.getMousePosition(this);
      _isMousePressed = true;
      mouseArgs.handled = true;
    }
    if (parent is UIElementContainer) {
      UIElementContainer container = parent;
      container.bringToFront(this);
    }
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseMove(MouseEventArgs mouseArgs) {
    if (_isMousePressed) {
      Coord mousePosition = mouseArgs.getMousePosition(this.parent);
      Canvas.setChildLeft(this, mousePosition.x - _mouseDelta.x);
      Canvas.setChildTop(this, mousePosition.y - _mouseDelta.y);
    }
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseUp(MouseEventArgs mouseArgs) {
    if (_isMousePressed) {
      _isMousePressed = false;
      releaseMouse();
      if (_movedEventArgs == null) {
        _movedEventArgs = new EventArgs(this);
      }
      notifyListeners(movedEvent, _movedEventArgs);
    }
  }

  /**
   * Activated the panel in modal form.
   */
  void show() {
    Application.current._addModalPanel(this);
  }

  /**
   * Closes panel.
   */
  void close() {
    Application.current._removeModalPanel(this);
    viewState = VIEW_STATE_NORMAL;
    _movedEventArgs = null;
    super.close();
  }

  /**
   * Maximizes panel.
   */
  void maximize() {
    viewState = VIEW_STATE_MAXIMIZED;
  }

  /**
   * Minimizes panel.
   */
  void minimize() {
    viewState = VIEW_STATE_MINIMIZED;
  }

  /**
   * Restores panel.
   */
  void restore() {
    viewState = VIEW_STATE_NORMAL;
  }

  /**
   * Sets or returns view state of panel.
   */
  set viewState(int state) {
    setProperty(viewStateProperty, state);
  }

  int get viewState {
    return getProperty(viewStateProperty);
  }

  /** Gets or sets if panel maximize is enabled */
  bool get maximizeEnabled {
    return getProperty(maximizeEnabledProperty);
  }

  set maximizeEnabled(bool value) {
    setProperty(maximizeEnabledProperty, value);
  }

  /** Gets or sets if panel minimize is enabled */
  bool get minimizeEnabled {
    return getProperty(minimizeEnabledProperty);
  }

  set minimizeEnabled(bool value) {
    setProperty(minimizeEnabledProperty, value);
  }

  /** Gets or sets if panel move is enabled */
  bool get moveEnabled {
    return getProperty(moveEnabledProperty);
  }

  set moveEnabled(bool value) {
    setProperty(moveEnabledProperty, value);
  }

  static void _maxMinEnabledChanged(Object target,
                                    Object property,
                                    Object oldValue,
                                    Object newValue) {
    Panel panel = target;
    UIElement element = panel.getElement(MAXIMIZE_BUTTON_ID);
    if (element != null) {
      element.visible = panel.maximizeEnabled;
    }
    element = panel.getElement(MINIMIZE_BUTTON_ID);
    if (element != null) {
      element.visible = panel.minimizeEnabled;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => panelElementDef;

  /** Registers component. */
  static void registerPanel() {
    titleProperty = ElementRegistry.registerProperty("Title",
        PropertyType.STRING, PropertyFlags.NONE, null, "");
    viewStateProperty = ElementRegistry.registerProperty("ViewState",
        PropertyType.INT, PropertyFlags.NONE, null, VIEW_STATE_NORMAL);
    maximizeEnabledProperty = ElementRegistry.registerProperty(
        "MaximizeEnabled", PropertyType.BOOL, PropertyFlags.NONE,
        _maxMinEnabledChanged, true);
    minimizeEnabledProperty = ElementRegistry.registerProperty(
        "MinimizeEnabled", PropertyType.BOOL, PropertyFlags.NONE,
        _maxMinEnabledChanged, true);
    moveEnabledProperty = ElementRegistry.registerProperty("moveEnabled",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    movedEvent = new EventDef("Moved", Route.DIRECT);
    panelElementDef = ElementRegistry.register("Panel",
        ContentContainer.contentcontainerElementDef,
        [titleProperty, viewStateProperty, maximizeEnabledProperty,
        minimizeEnabledProperty, moveEnabledProperty], [movedEvent]);
    // Override default isFocusGroup property.
    UIElement.isFocusGroupProperty.overrideDefaultValue(panelElementDef,true);

  }
}
