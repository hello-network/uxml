part of uxml;

/**
 * Manages application entry point.
 *
 * Users of this class should initialize the application with
 * a window/frame/div element and teardown using shutdown().
 *
 * The root ui element for the application is set using the content property.
 *
 * Application handles the animation loop, input(mouse,keyboard,...) event
 * routing, modal panel management, efficient hit testing.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 * @author michjun@ (Michelle Fang)
 * @author hannung@ (Han-Nung Lin)
 */
class Application extends UxmlElement {

  static bool _registered = false;
  static Application _current = null;
  static FocusManager focusManager;
  static ElementDef applicationElementDef;
  static EventDef mousePreviewEvent;
  static EventDef keyPreviewEvent;
  static UIElement _mouseDownTarget;
  static PropertyDefinition busyProperty;

  // Holds reference to topmost window or div used by platform layer.
  Object _host;
  int _hostWidth;
  int _hostHeight;
  Resources _resources;
  UIElement _rootElement = null;
  UIElement _content;
  UISurface rootSurface;
  AnimationScheduler _scheduler;
  UIElement _mouseCaptureTarget = null;
  // TODO(ferhat): reduce to 60fps for mobile case.
  static const int MOUSE_MOVE_BUFFER_DURATION = 16;
  List<UIElement> _modalElementStack = null;
  Map<UIElement, EventHandler> _modalLayoutHandler = null;
  RectShape _modalTint;
  int _inputTs = 0;
  static const int _IDLE_MIN_TIME_MS = 4000;

  // optimization for mousemove.
  int _lastMouseMoveTime = 0;
  bool _hasPendingMouseMove = false;
  EventDef _pendingEventDef;
  int _pendingStageX;
  int _pendingStageY;
  bool _pendingButtonDown;
  int _pendingButton;

  // Holds new cursor to delay switch until enterframe is called.
  Cursor _newMouseCursor = null;
  UISurface _newMouseSurface = null;
  UISurface _prevMouseSurface = null;
  DragDropManager _dragDropManager = null;
  _ToolTipManager _toolTips = null;

  /**
   * Recyclable mouse event args. mouseDownArgs is separate to be able
   * to calculate correct drag&drop offsets when dragdrop is initiated
   * in mousemove event.
   */
  MouseEventArgs _sharedMouseDownArgs;
  MouseEventArgs _sharedMouseArgs;
  KeyboardEventArgs _keyArgs;

  // List of elements in mouseOver=true state.
  List<UIElement> _mouseOverActiveList;
  // Holds items that have received dragEnter event. Used by
  // Application mouse event router to handle enter/exit.
  List<UIElement> _dragEnterList;
  static bool _cancelTextInput = false;

  // User agent
  static bool isIE = false;
  static bool isFF = false;
  static bool isChrome = false;
  static bool isSafari = false;
  static bool isWebKit = false;
  static bool isMobile = false;
  static bool isAndroid = false;
  static bool isIos = false;
  static num screenPixelRatio = 1.0;
  static int uaVersion = 0;

  static EventDef shutdownEvent = new EventDef("Shutdown", Route.DIRECT);

  Application() : super() {
    if (_registered != true) {
      _registered = true;
      _registerApplication();
      UIPlatform.initialize();
    }

    _current = this;
    _resources = new Resources();
    _keyArgs = new KeyboardEventArgs(0, 0, 0, null);
  }

  /**
   * Starts application with window as root element.
   */
  Application initialize(Object win) {
    _current = this;
    _host = win;
    _sharedMouseDownArgs = new MouseEventArgs(MouseEventArgs.MOUSE_DOWN,
        MouseEventArgs.LEFT_BUTTON, new Coord(0.0, 0.0));
    _sharedMouseArgs = new MouseEventArgs(MouseEventArgs.MOUSE_DOWN,
        MouseEventArgs.LEFT_BUTTON, new Coord(0.0, 0.0));
    _mouseOverActiveList = <UIElement>[];
    _dragEnterList = <UIElement>[];
    focusManager = new FocusManager();
    rootSurface = UIPlatform.createRootSurface(this, win);

    UIPlatform.initializeAppEvents(this);

    if (_content != null) {
      hostContent();
    }

    UIPlatform.scheduleEnterFrame(this);
    return this;
  }

  void shutdown() {
    if (UpdateQueue._requestFrameInFlight) {
      UpdateQueue._frameCallback = () {
        notifyListeners(shutdownEvent, new EventArgs(this));
      };
    } else {
      notifyListeners(shutdownEvent, new EventArgs(this));
    }
    assert(focusManager != null);
    UIPlatform.shutdownAppEvents(this);
    focusManager.cancelFocus();
    focusManager = null;
    if (rootSurface != null) {
      rootSurface.clear();
      rootSurface = null;
    }
    _mouseOverActiveList.clear();
    _dragEnterList.clear();
    _sharedMouseDownArgs = null;
    _sharedMouseArgs = null;
    _keyArgs = null;
    _host = null;
    _resources.clear();
    _rootElement = null;
    _content = null;
    _scheduler = null;
    _mouseCaptureTarget = null;
    if (_modalElementStack != null) {
      _modalElementStack.clear();
    }
    _modalTint = null;
    _newMouseCursor = null;
    _newMouseSurface = null;
    _prevMouseSurface = null;
    _dragDropManager = null;
    _toolTips = null;
  }

  static Application get current => _current;

  EventArgs _routeMouseEvent(int pageX,
                             int pageY,
                             int button,
                             int mouseEventType) {
    EventDef eventDef;
    switch (mouseEventType) {
      case MouseEventArgs.MOUSE_DOWN:
        eventDef = UIElement.mouseDownEvent;
        busy = true;
        break;
      case MouseEventArgs.MOUSE_UP:
        eventDef = UIElement.mouseUpEvent;
        break;
      case MouseEventArgs.MOUSE_MOVE:
        eventDef = UIElement.mouseMoveEvent;
        break;
      default:
        return null;
    }
    bool handled = false;
    if (rootSurface == null) {
      return null;
    }
    if (mouseEventType == MouseEventArgs.MOUSE_DOWN && !Application.isMobile) {
      // reset mousecapture in case a control forgot to call releaseCapture.
      _mouseCaptureTarget = null;
    }
    // Short-circuit to mouse capture target if set.
    if (_mouseCaptureTarget != null) {
      if (mouseEventType == MouseEventArgs.MOUSE_DOWN) {
        _mouseDownTarget = null;
      }
      MouseEventArgs mouseEventArgs = (mouseEventType ==
          MouseEventArgs.MOUSE_DOWN ? _sharedMouseDownArgs : _sharedMouseArgs);
      mouseEventArgs.reset();
      mouseEventArgs.event = eventDef;
      mouseEventArgs.button = button;
      mouseEventArgs.eventType = mouseEventType;
      mouseEventArgs.setMousePosition(pageX, pageY);
      mouseEventArgs.source = _mouseCaptureTarget;
      _mouseCaptureTarget.routeEvent(mouseEventArgs);
      return mouseEventArgs;
    }
    int now = Application.getTimer();
    // if we receive a mouse event other than mouse move, we should
    // commit the latest pending mouse event first.
    if ((mouseEventType != MouseEventArgs.MOUSE_MOVE) && _hasPendingMouseMove) {
      _processPendingMouseMoveEvent();
    }
    // If a mouse move was received within (x)ms of last mouse move
    // buffer it as pending to reduce hit test cpu load.
    if (mouseEventType == MouseEventArgs.MOUSE_MOVE && !isMobile) {
      if ((now - _lastMouseMoveTime) < MOUSE_MOVE_BUFFER_DURATION) {
        _hasPendingMouseMove = true;
        _pendingStageX = pageX;
        _pendingStageY = pageY;
        _pendingButtonDown = (mouseEventType == MouseEventArgs.MOUSE_DOWN);
        _pendingButton = button;
        _pendingEventDef = eventDef;
        return null;
      }
      _lastMouseMoveTime = now;
    }
    UISurface targetSurface = rootSurface.hitTest(pageX, pageY);
    if (KeyboardEventArgs.ctrlKey) {
      KeyboardEventArgs.ctrlKey = false;
    }

    UIElement targetElement = (targetSurface != null) ? targetSurface.target :
        _mouseCaptureTarget;
    // Route mouse events even if targetElement is null, it might mean that the
    // mouse has move outside the screen (or iframe window) and we need to treat
    // that as mouseExit.
    EventArgs resEvent = _routeMouseEventToElement(targetElement, pageX, pageY,
        mouseEventType, button, button != MouseEventArgs.NO_BUTTON,
        eventDef);
    if (targetElement != null) {
      _newMouseSurface = targetElement.hostSurface;
      _newMouseCursor = Cursor.getElementCursor(targetElement);
    } else {
      _newMouseCursor = Cursor.ARROW;
    }
    if (Application.isIE) {
      _updateCursor();
    }
    return resEvent;
  }

  void _processPendingMouseMoveEvent() {
    // process pending mousemove that was delayed.
    _hasPendingMouseMove = false;
    UISurface targetSurface = rootSurface.hitTest(_pendingStageX,
        _pendingStageY);
    if (targetSurface != null) {
      UIElement targetElement = targetSurface.target;
      // Check targetElement to make sure surface wasn't destroyed.
      if (targetElement != null) {
        _routeMouseEventToElement(targetElement, _pendingStageX, _pendingStageY,
            MouseEventArgs.MOUSE_MOVE, _pendingButton, _pendingButtonDown,
            _pendingEventDef);
        _newMouseSurface = targetSurface;
        _newMouseCursor = Cursor.getElementCursor(targetElement);
      }
      _lastMouseMoveTime = getTimer();
    }
  }

  /**
   * Routes mouse wheel event to element tree.
   */
  bool _routeMouseWheelEvent(int delta) {
    UIElement targetElement = elementAt(
        _sharedMouseArgs.getMousePosition(null).x,
        _sharedMouseArgs.getMousePosition(null).y);
    if (targetElement != null) {
      _sharedMouseArgs.reset();
      _sharedMouseArgs.event = UIElement.mouseWheelEvent;
      _sharedMouseArgs.button = MouseEventArgs.NO_BUTTON;
      _sharedMouseArgs.eventType = MouseEventArgs.MOUSE_WHEEL;
      _sharedMouseArgs.deltaY = delta;
      _sharedMouseArgs.source = targetElement;

      notifyListeners(mousePreviewEvent, _sharedMouseArgs);
      if (!_sharedMouseArgs.handled) {
        targetElement.routeEvent(_sharedMouseArgs);
      }
      return _sharedMouseArgs.handled;
    }
    return false;
  }

  /**
   * Routes key down event to element tree.
   */
  bool _keyDownEventHandler(e) {
    busy = true;
    _cancelTextInput   = false;
    if (_sendDomKeyboardEvent(e, KeyboardEventArgs.KEY_DOWN,
        UIElement.keyDownEvent)) {
      _cancelTextInput = true;
    } else {
      // If keydown event was not handled. Check if tab key was pressed.
      if (e.keyCode == KeyboardEventArgs.KEYCODE_TAB) {
        if (Application.isFF) {
          e.handled = true;
        }
        bool back = e.shiftKey;
        Application.focusManager.processTabKey(back);
        _cancelTextInput = true;
      }
    }
    UpdateQueue.flush();
    return _cancelTextInput;
  }

  /**
   * Routes key down event to element tree.
   */
  bool _keyPressEventHandler(e) {
    _cancelTextInput   = false;
    if (_sendDomKeyboardEvent(e, KeyboardEventArgs.KEY_DOWN,
        UIElement.keyDownEvent)) {
      _cancelTextInput = true;
    } else {
      // If keydown event was not handled. Check if tab key was pressed.
      if (e.keyCode == KeyboardEventArgs.KEYCODE_TAB) {
        bool back = e.shiftKey;
        Application.focusManager.processTabKey(back);
        _cancelTextInput = true;
      }
    }
    UpdateQueue.flush();
    return _cancelTextInput;
  }

  /**
   * Routes key up event to element tree.
   */
  bool _keyUpEventHandler(e) {
    _cancelTextInput = false;
    if (_sendDomKeyboardEvent(e, KeyboardEventArgs.KEY_UP,
        UIElement.keyUpEvent)) {
      _cancelTextInput = true;
    }
    UpdateQueue.flush();
    return _cancelTextInput;
  }

  // Cancels text event due to a keyboard event being handled by target.
  // In a textfield this allows any default keyboard action to be cancelled.
  void _onCancelTextInput(e) {
    if (_cancelTextInput) {
      _cancelTextInput = false;
    }
  }

  bool _sendDomKeyboardEvent(domEvent, int eventType, EventDef eventDef) {
    KeyboardEventArgs.shiftKey = domEvent.shiftKey;
    KeyboardEventArgs.ctrlKey = domEvent.ctrlKey;
    KeyboardEventArgs.altKey = domEvent.altKey;
    KeyboardEventArgs.metaKey = domEvent.metaKey;
    int keyCode = domEvent.keyCode;
    int charCode = domEvent.charCode;
    return sendKeyboardEvent(keyCode, charCode, eventType, eventDef);
  }

  /**
   * Sends a keyboard event to an element.
   * Returns true if key event was handled.
   */
  bool sendKeyboardEvent(int keyCode,
                         int charCode,
                         int eventType,
                         EventDef eventDef) {
    if (rootSurface == null) {
      false;
    }
    UIElement targetElement = this.content;
    if (hasListener(keyPreviewEvent)) {
      _keyArgs.reset();
      _keyArgs.event = eventDef;
      _keyArgs.eventType = eventType;
      _keyArgs.keyCode = keyCode;
      _keyArgs.charCode = charCode;
      _keyArgs.source = targetElement;
      notifyListeners(keyPreviewEvent, _keyArgs);
      if (_keyArgs.handled) {
        return true;
      }
    }
    if (Application.focusManager.focusedElement != null) {
      targetElement = Application.focusManager.focusedElement;
      if (_routeKeyboardEventToElement(targetElement, keyCode, charCode,
        eventType, eventDef)) {
        // event handled by focused element so return.
        return true;
      }
    }
    // TODO(ferhat): port modalStackElement handling.
    if (this.content != null) {
      return _routeKeyboardEventToElement(this.content, keyCode, charCode,
          eventType, eventDef);
    }
    return false;
  }

  bool _routeKeyboardEventToElement(UIElement targetElement,
                                    int keyCode,
                                    int charCode,
                                    int keyEventType,
                                    EventDef eventDef) {
    if (targetElement != null) {
      _keyArgs.reset();
      _keyArgs.event = eventDef;
      _keyArgs.eventType = keyEventType;
      _keyArgs.keyCode = keyCode;
      _keyArgs.charCode = charCode;
      _keyArgs.source = targetElement;
      targetElement.routeEvent(_keyArgs);
    }
    return _keyArgs.handled;
  }


  /**
   * Returns visible UIElement under mouseX, mouseY coordinates.
   *
   * @param mouseX Absolute X coordinate.
   * @param mouseY Absolute Y coordinate.
   * @return returns element at coordinates or null if no element exists.
   */
  UIElement elementAt(int mouseX, int mouseY) {
    UISurface targetSurface = rootSurface.hitTest(mouseX, mouseY);
    return (targetSurface != null) ? targetSurface.target : null;
  }

  /** Sends a mouse event to target element. */
  void sendMouseEvent(UIElement target,
                      int mouseX,
                      int mouseY,
                      EventDef eventDef) {
    int mouseEventType;
    if (eventDef == UIElement.mouseDownEvent) {
      mouseEventType = MouseEventArgs.MOUSE_DOWN;
    } else if (eventDef == UIElement.mouseUpEvent) {
      mouseEventType = MouseEventArgs.MOUSE_UP;
    } else if (eventDef == UIElement.mouseMoveEvent) {
      mouseEventType = MouseEventArgs.MOUSE_MOVE;
    } else {
      throw "Unknown mouse event";
    }
    // Convert mouseX, mouseY to stage coordinates.
    Coord absoluteMouse = target.localToScreen(new Coord(mouseX, mouseY));
    UISurface targetSurface = rootSurface.hitTest(absoluteMouse.x,
        absoluteMouse.y);
    target = (targetSurface != null) ? targetSurface.target :
        _mouseCaptureTarget;
    _routeMouseEventToElement(target, absoluteMouse.x.toInt(),
        absoluteMouse.y.toInt(), mouseEventType, MouseEventArgs.LEFT_BUTTON,
        (mouseEventType == MouseEventArgs.MOUSE_DOWN), eventDef);
  }

  EventArgs _routeMouseEventToElement(UIElement targetElement,
      int mouseX, int mouseY, int mouseEventType, int button, bool buttonDown,
      EventDef eventDef) {
    if (_mouseCaptureTarget != null && (dragDropActive == false)) {
      targetElement = _mouseCaptureTarget;
    }

    MouseEventArgs mouseEventArgs = dragDropActive ?
        dragDropManager.mouseEventArgs : (mouseEventType ==
        MouseEventArgs.MOUSE_DOWN ? _sharedMouseDownArgs : _sharedMouseArgs);

    List<UIElement> mouseOverList = dragDropActive ? _dragEnterList :
        _mouseOverActiveList;

    // Manage mouse enter/exit list.
    // For each item in watch list, if mouse is not over the item anymore
    // call onMouseExit.
    int mouseOverListCount = mouseOverList.length;
    for (int m = mouseOverListCount - 1; m >= 0; m--) {
      UIElement item = mouseOverList[m];
      // first check bounding box (cheaper)
      bool movedOut = false;
      if ((item.hasSurface == false) || // if item surface has been destroyed
          (item.hitTestBoundingBox(mouseX.toDouble(),
          mouseY.toDouble()) == false)) {
        movedOut = true;
      }

      if (!movedOut) {
        // secondary more expensive check.
        UIElement elementUnderMouse = elementAt(mouseX, mouseY);
        if (elementUnderMouse != null &&
            (!item.isVisualChild(elementUnderMouse)) &&
            (item != elementUnderMouse)) {
          if (!item._isOverlayChild(elementUnderMouse)) {
            movedOut = true;
          }
        }
      }

      if (movedOut) {
        mouseEventArgs.reset();
        mouseEventArgs.event = UIElement.mouseExitEvent;
        mouseEventArgs.button = buttonDown ? MouseEventArgs.LEFT_BUTTON :
            MouseEventArgs.NO_BUTTON;
        mouseEventArgs.eventType = MouseEventArgs.MOUSE_EXIT;
        mouseEventArgs.setMousePosition(mouseX, mouseY);
        mouseEventArgs.source = item;
        if (dragDropActive) {
          dragDropManager.routeEvent(mouseEventArgs);
        } else {
          item.routeEvent(mouseEventArgs);
          // By default exit events are marked handled before dispatching.
          // If a control decides that mouse is inside a popup/overlay of the
          // element and should continue tracking, it can cancel the event
          // by setting handled to false.
          if (mouseEventArgs.handled) {
            item.setProperty(UIElement.isMouseOverProperty, false);
          }
        }
        mouseOverList.removeAt(m);
      }
    }

    // For targetElement and all parents call onMouseEnter if item is
    // not already in watch list
    UIElement element = targetElement;
    bool hitTestResult = element == null ? false :
        element.hitTestBoundingBox(mouseX, mouseY);
    if (hitTestResult) {
      while (element != null) {
        if (mouseOverList.indexOf(element) == -1) {
          mouseOverList.add(element);
          mouseEventArgs.reset();
          mouseEventArgs.event = UIElement.mouseEnterEvent;
          mouseEventArgs.button = buttonDown ? MouseEventArgs.LEFT_BUTTON :
              MouseEventArgs.NO_BUTTON;
          mouseEventArgs.eventType = MouseEventArgs.MOUSE_ENTER;
          mouseEventArgs.setMousePosition(mouseX, mouseY);
          mouseEventArgs.source = element;
          if (dragDropActive) {
            dragDropManager.routeEvent(mouseEventArgs);
          } else {
            element.routeEvent(mouseEventArgs);
            if (mouseEventArgs.handled) {
              element.setProperty(UIElement.isMouseOverProperty, true);
            }
          }
        }
        // If element we are over has a different view hierarchy than
        // it's visual hierarchy, we should not propagate.
        if (element.visualParent != element.parent) {
          break;
        }
        element = element.parent;
      }
    }
    if (targetElement != null && (hitTestResult ||
        (targetElement == _mouseCaptureTarget))) {
      if (mouseEventType == MouseEventArgs.MOUSE_DOWN) {
        _mouseDownTarget = null;
      }
      mouseEventArgs.reset();
      mouseEventArgs.event = eventDef;
      mouseEventArgs.button = buttonDown ? MouseEventArgs.LEFT_BUTTON :
          MouseEventArgs.NO_BUTTON;
      mouseEventArgs.eventType = mouseEventType;
      mouseEventArgs.setMousePosition(mouseX, mouseY);
      mouseEventArgs.source = targetElement;
      if (dragDropActive) {
        dragDropManager.routeEvent(mouseEventArgs);
      } else {
        notifyListeners(mousePreviewEvent, mouseEventArgs);
        if (!mouseEventArgs.handled) {
          targetElement.routeEvent(mouseEventArgs);
        }
      }
    } else {
      // If hit test doesn't return a valid target, we still need to
      // fire mousePreviewEvent for popup's/dropdowns to function.
      notifyListeners(mousePreviewEvent, mouseEventArgs);
    }
    return mouseEventArgs;
  }

  void _enterFrame(time) {
    int now = new DateTime.now().millisecondsSinceEpoch;
    if ((((now - _inputTs) > _IDLE_MIN_TIME_MS) || (now < _inputTs)) &&
        (_modalElementStack == null || _modalElementStack.isEmpty)) {
      setProperty(busyProperty, false);
    }
    if (_hasPendingMouseMove && rootSurface != null) {
      int now = Application.getTimer();
      if ((now - _lastMouseMoveTime) > MOUSE_MOVE_BUFFER_DURATION) {
        _processPendingMouseMoveEvent();
      }
    }
    if (_scheduler != null) {
      _scheduler.enterFrame();
    }
    UpdateQueue.flush();
    _updateCursor();
    if (_scheduler != null && _scheduler.hasTasks) {
      UIPlatform.scheduleEnterFrame(this);
    }
  }

  void _updateCursor() {
    if (_newMouseCursor != null) {
      if (_prevMouseSurface != null) {
        _prevMouseSurface.cursorChanged(null);
        _prevMouseSurface = null;
      }
      Cursor.setCursor(_newMouseCursor);
      if (_newMouseSurface != null) {
        _newMouseSurface.cursorChanged(_newMouseCursor);
        _prevMouseSurface = _newMouseSurface;
      }
      _newMouseCursor = null;
    }
  }

  void setHostSize(int width, int height) {
    _hostWidth = width;
    _hostHeight = height;
    relayoutRoot();
  }

  int get hostWidth => _hostWidth;

  int get hostHeight => _hostHeight;

  /**
   * Setup root content.
   */
  void hostContent() {
    if (rootSurface == null) {
      return;
    }
    if (_rootElement == null) {
      OverlayContainer overlayCont = new OverlayContainer();
      _rootElement = overlayCont;
      overlayCont.content = _content;
      _rootElement.initSurface(rootSurface);
    } else {
      OverlayContainer c = _rootElement;
      c.content = _content;
    }
    if (_content != null) {
      relayoutRoot();
      UpdateQueue.flush();
    }
  }

  /**
   * Sets or returns root ui element of application.
   */
  set content(UIElement value) {
    if (_content != value) {
      _content = value;
      hostContent();
    }
  }

  UIElement get content {
    return _content;
  }

  void relayoutRoot() {
    if (_modalTint != null) {
      _modalTint.width = _hostWidth;
      _modalTint.height = _hostHeight;
    }
    if (_rootElement == null) {
      return;
    }
    _rootElement.measure(_hostWidth, _hostHeight);
    num w = _rootElement.measuredWidth;
    num h = _rootElement.measuredHeight;
    bool disableScrollBars = (h <= _hostHeight && w <= _hostWidth);
    _rootElement.measuredWidth = max(_hostWidth, w);
    _rootElement.measuredHeight = max(_hostHeight, h);
    UIPlatform.relayoutRoot(rootSurface, disableScrollBars);
    _rootElement.layout(0.0, 0.0, _rootElement.measuredWidth,
        _rootElement.measuredHeight);
  }

  /**
   * Override for Application subclasses.
   */
  void onRootSurfaceCreated() {
  }

  /**
   * Returns resources collection.
   */
  Resources get resources {
    return _resources;
  }

  /**
   * Finds resource in current application.
   */
  static Object findResource(Object key, String interfaceName) {
    Application currentApp = Application.current;
    if (interfaceName != null) {
      Resources res = currentApp._resources.getResource(interfaceName);
      if (res != null) {
        Object r = res.getResource(key);
        if (r != null) {
          return r;
        }
      }
    }
    return currentApp._resources.getResource(key);
  }

  /**
   * Logs a message.
   */
  void log(String message) {
    UIPlatform.writeToConsole(message);
  }

  /**
   * Logs a warning message.
   */
  void warn(String message) {
    UIPlatform.writeToConsole(message);
  }

  /**
   * Logs an error message.
   */
  void error(String message) {
    UIPlatform.writeToConsole(message);
  }

  static int getTimer() => new DateTime.now().millisecondsSinceEpoch;

  AnimationScheduler get scheduler {
    if (_scheduler == null) {
      _scheduler = new AnimationScheduler();
    }
    return _scheduler;
  }

  void setMouseCapture(UIElement captureTarget) {
    _mouseCaptureTarget = captureTarget;
  }

  void releaseMouseCapture() {
    _mouseCaptureTarget = null;
  }

  /**
   * Attaches element to root container and redirects all ui calls to it.
   * Called by Panel.show. Don't call directly! unless creating a new panel
   * type.
   */
  void _addModalPanel(UIElement element) {
    busy = true;
    if (_modalElementStack == null) {
      _modalElementStack = <UIElement>[];
      _modalLayoutHandler = new Map<UIElement, EventHandler>();
    }
    _modalElementStack.add(element);
    OverlayContainer root = _rootElement;
    if (_modalTint == null) {
      _modalTint = new RectShape();
      _modalTint.width = _hostWidth;
      _modalTint.height = _hostHeight;
      _modalTint.fill = new SolidBrush(Color.fromARGB(0x90FFFFFF));
      root.addOverlay(_modalTint);
    }
    root.addOverlay(element, false, OverlayLocation.CUSTOM);
    UpdateQueue.flush(); // force item measure so we can center below
    if (element.visible == false) {
      // If popup is not visible yet, we listen for it to become visible
      // and then for layout to change (resizing of popup to contents.
      EventHandler handler = (EventArgs e) {
          element.removeListener(UIElement.visibleProperty,
              _modalLayoutHandler[element]);
          element.measure(_hostWidth, _hostHeight);
          Canvas.setChildLeft(element, (root.layoutWidth -
              element.measuredWidth) / 2);
          Canvas.setChildTop(element, (root.layoutHeight -
              element.measuredHeight) / 2);
          _modalLayoutHandler[element] = _centerModal;
          element.addListener(UIElement.layoutChangedEvent,
              _modalLayoutHandler[element]);
        };
      _modalLayoutHandler[element] = handler;
      element.addListener(UIElement.visibleProperty, handler);
    }
    Canvas.setChildLeft(element, (root.layoutWidth -
        element.measuredWidth) / 2);
    Canvas.setChildTop(element, (root.layoutHeight -
        element.measuredHeight) / 2);
  }

  void _centerModal(EventArgs e) {
    UIElement element = e.source;
    Canvas.setChildLeft(element, (_hostWidth - element.measuredWidth) / 2);
    Canvas.setChildTop(element, (_hostHeight - element.measuredHeight) / 2);
  }

  /**
   * Called by Panel.close. Don't use the api unless overriding close function
   * in custom element implementation.
   */
  void _removeModalPanel(UIElement element) {
    if (_modalElementStack == null) {
      return;
    }
    int index = _modalElementStack.indexOf(element, 0);
    if (index == -1) {
      return;
    }
    _modalElementStack.removeAt(index);
    OverlayContainer root = _rootElement;
    if (_modalElementStack.length == 0) {
      root.removeOverlay(_modalTint);
      _modalTint = null;
      _modalElementStack = null;
    }
    if (_modalLayoutHandler.containsKey(element)) {
      element.removeListener(UIElement.layoutChangedEvent,
          _modalLayoutHandler[element]);
      _modalLayoutHandler[element] = null;
    }
    root.removeOverlay(element);
  }

  /**
  * Returns drag&drop manager.
  */
  DragDropManager get dragDropManager {
    if (_dragDropManager == null) {
      _dragDropManager = new DragDropManager();
      _dragEnterList = [];
    }
    return _dragDropManager;
  }

  /**
  * Returns true if a drag drop operation is in progress.
  */
  bool get dragDropActive {
    return (_dragDropManager != null) && _dragDropManager.busy;
  }

  /**
   * Returns current mouse position relative to an element.
   */
  Coord getMousePosition(UIElement element) {
    return _sharedMouseArgs.getMousePosition(element);
  }

  /**
   * Returns last mouse down position relative to an element.
   */
  Coord getMouseDownPosition(UIElement element) {
    return _sharedMouseDownArgs.getMousePosition(element);
  }

  /**
   * Returns tooltip manager.
   */
  _ToolTipManager get _toolTipManager {
    if (_toolTips == null) {
      _toolTips = new _ToolTipManager();
    }
    return _toolTips;
  }

  /**
   * Returns topmost modal element.
   */
  UIElement get _modalElement {
    if ((_modalElementStack == null) || (_modalElementStack.isEmpty)) {
      return null;
    }
    return _modalElementStack[_modalElementStack.length - 1];
  }

  /**
   * Sets busy state of application. Notification style ui's can call
   * this function to override busy behaviour.
   */
  set busy(bool value) {
    if (value) {
      _inputTs = new DateTime.now().millisecondsSinceEpoch;
    }
    setProperty(busyProperty, value);
  }
  /**
   * Return true if application has received input in the last
   * IDLE_MIN_TIME_MS.
   */
  bool get busy => getProperty(busyProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => applicationElementDef;

  static void _registerApplication() {
    mousePreviewEvent = new EventDef("MousePreviewEvent", Route.DIRECT);
    keyPreviewEvent = new EventDef("KeyPreviewEvent", Route.DIRECT);
    CollectionChangedEvent.initCollectionChangedEvent();
    ElementCollection.initElementCollection();
    PropertyChangedEvent.initPropertyChangedEvent();

    Color.initialize();
    Margin.initialize();
    BorderRadius.initialize();
    Items.registerItems();
    UxmlElement.registerElement();
    Cursor.registerCursor();
    FocusManager.registerFocusManager();
    ClipboardData.registerClipboardData();
    Controller.registerController();
    Filter.registerFilter();
    BevelFilter.registerBevelFilter();
    DropShadowFilter.registerDropShadowFilter();

    GlowFilter.registerGlowFilter();
    UITransform.registerTransform();

    UIElement.registerUIElement();
    Shape.registerShape();
    LineShape.registerLineShape();
    RectShape.registerRectShape();
    EllipseShape.registerEllipseShape();
    PathShape.registerPathShape();

    Control.registerControl();
    Label.registerLabel();
    LabeledControl.registerLabeledControl();
    Image.registerImage();
    TextEdit.registerTextEdit();
    TextBox.registerTextBox();

    ContentContainer.registerContentContainer();
    OverlayContainer.registerOverlayContainer();
    Panel.registerPanel();
    Popup.registerPopup();
    Item.registerItem();
    ItemsContainer.registerItemsContainer();
    ValueRangeControl.registerValueRangeControl();
    ProgressControl.registerProgressControl();
    WaitIndicator.registerWaitIndicator();
    Slider.registerSlider();
    ScrollBar.registerScrollBar();
    ScrollBox.registerScrollBox();

    Button.registerButton();
    CheckBox.registerCheckBox();
    RadioButton.registerRadioButton();
    DropDownButton.registerDropDownButton();

    ListBase.registerListBase();
    ListBox.registerListBox();
    ComboBox.registerComboBox();
    TabControl.registerTabControl();

    UIElementContainer.registerUIElementContainer();
    Group.registerGroup();
    PageControl.registerPageControl();
    HBox.registerHBox();
    VBox.registerVBox();
    Canvas.registerCanvas();
    DockBox.registerDockBox();
    GridRow.registerGridRow();
    GridColumn.registerGridColumn();
    Grid.registerGrid();
    SlideBox.registerSlideBox();
    WrapBox.registerWrapBox();

    DisclosureBox.registerDisclosureBox();
    ToolTip.registerToolTip();

    Command.registerCommand();

    busyProperty = ElementRegistry.registerProperty("busy",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);

    applicationElementDef = ElementRegistry.register("Application", null,
        [busyProperty], [mousePreviewEvent, keyPreviewEvent]);

    UpdateQueue.initialize();
  }
}
