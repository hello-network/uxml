part of uxml;

/**
* Implements a container that hosts it's content as an
* overlay when IsOpen property is set to true.

* @author:ferhat@ (Ferhat Buyukkokten)
*/
class Popup extends ContentContainer {
  static ElementDef popupElementDef;
  /** IsOpen property definition */
  static PropertyDefinition isOpenProperty;
  /** AutoFocus property definition */
  static PropertyDefinition autoFocusProperty;
  static PropertyDefinition locationProperty;
  static PropertyDefinition finalLocationProperty;
  static UIElement _mouseOverLockValue;
  UIElement _overlayElement = null;

  // Holds a stack of active popups. When user clicks on an element
  // that is not a visual child of any active popup or it's containing
  // element, the popup is closed.
  static List<Popup> _activePopups;
  // Holds globalfocuschanged closure.
  EventHandler _focusClosure = null;
  EventHandler _previewClosure;

  /**
   * Constructor.
   */
  Popup() : super() {
  }

  /**
   * Sets/returns open state.
   */
  bool get isOpen {
    return getProperty(isOpenProperty);
  }

  set isOpen(bool value) {
    return setProperty(isOpenProperty, value);
  }

  /**
   * Sets or returns whether popup should focus on contents when opened.
   */
  bool get autoFocus {
    return getProperty(autoFocusProperty);
  }

  set autoFocus(bool value) {
    setProperty(autoFocusProperty, value);
  }

  /**
   * Sets or gets the location of popup relative to the container.
   */
  int get location {
    return getProperty(locationProperty);
  }

  set location(int value) {
    setProperty(locationProperty, value);
  }

  /** Returns final location of Popup */
  int get finalLocation => getProperty(finalLocationProperty);

  /**
   * Provides override for subclasses to handle popup isOpen state change.
   */
  void isOpenChanged(bool value) {
    if (_overlayElement != null) {
      if (value) {
        // Popup is open, add an overlay on top of Popup element.
        // If Popup.location is default or toplevel flag has been enabled,
        // add the overlay on top of all surfaces (combo dropdown would
        // in this case not be clipped against parent containers.
        int loc = location;
        if (overridesProperty(locationProperty) &&
            ((loc & OverlayLocation._TOPLEVEL) == 0)) {
          addOverlay(_overlayElement, false, loc);
        } else {
          _addTopLevelOverlay(_overlayElement, true, loc);
        }
        _overlayElement.minWidth = layoutWidth;
        if (autoFocus) {
          _overlayElement.setFocus();
          _removeFocusListener();
          _focusClosure = _globalFocusChanged;
          Application.focusManager.addListener(FocusManager.focusChangedEvent,
              _focusClosure);
        }
        if (_activePopups.length == 0) {
          _previewClosure = _mousePreviewHandler;
          Application.current.addListener(Application.mousePreviewEvent,
              _previewClosure);
        }
        _activePopups.add(this);
      } else {
        _removeFocusListener();
        removeOverlay(_overlayElement);
        int index = _activePopups.indexOf(this, 0);
        if (index != -1) {
          _activePopups.removeAt(index);
        }
        if (_activePopups.length == 0) {
          Application.current.removeListener(Application.mousePreviewEvent,
              _previewClosure);
          _previewClosure = null;
        }
      }
    }
  }

  void _removeFocusListener() {
    if (_focusClosure != null) {
      Application.focusManager.removeListener(
          FocusManager.focusChangedEvent, _focusClosure);
      _focusClosure = null;
    }
  }

  void _overlayLayoutChanged(EventArgs e) {
    UIElement element = e.source;
    num height = element.layoutHeight;
    Coord screenP = element.localToScreen(new Coord(0.0, height));
    num bottomOfScreen = Application.current.content.layoutHeight;
    if (screenP.y > bottomOfScreen) {
      // exceeding bottom of screen.
      Coord adjustedPoint = overlayContainer.screenToLocal(
          new Coord(0.0, bottomOfScreen - height));
      Canvas.setChildTop(element, adjustedPoint.y);
    }
  }

  void _globalFocusChanged(FocusEventArgs e) {
    if (_overlayElement != null) {
      if ((!isVisualChild(e.newElement)) &&
          (!_overlayElement.isVisualChild(e.newElement))) {
        // New focus is not our visual child, close.
        isOpen = false;
      }
    }
  }

  void _mousePreviewHandler(MouseEventArgs e) {
    UIElement mouseEventTarget = e.source;
    if (e.eventType != MouseEventArgs.MOUSE_DOWN &&
        e.eventType != MouseEventArgs.MOUSE_WHEEL) {
      return;
    }
    for (int i = 0; i < _activePopups.length; ++i) {
      Popup popup = _activePopups[i];
      UIElement parentElement = popup.parent;
      UIElement overlay = popup._overlayElement;
      if (overlay.isVisualChild(mouseEventTarget) ||
          (popup == mouseEventTarget) || (overlay == mouseEventTarget) ||
          parentElement.isVisualChild(mouseEventTarget)) {
        if (e.eventType == MouseEventArgs.MOUSE_WHEEL) {
          // Sends mouse wheel event to target. If not handled shutdown
          // popup since it will bubble up to parents that will scroll.
          _routeEventFromTo(e, mouseEventTarget, popup);
          if (e.handled) {
            return;
          }
        } else {
          return;
        }
      }
    }
    // The mouse event is being sent to an item that is not a visual
    // child of popups or owner of popups, so close active popups
    for (int c = 0; c < _activePopups.length; c++) {
      Popup activePopup = _activePopups[c];
      activePopup.isOpen = false;
    }
  }

  // Routes event from a node up to a specific parent.
  void _routeEventFromTo(EventArgs e, UIElement start,
      UIElement end) {
    start._raiseEvent(e);
    UIElement parentElement = start.parent;
    while ((parentElement != end) && (e.handled == false) &&
        (parentElement != null)) {
      parentElement._raiseEvent(e);
      parentElement = parentElement.parent;
    }
  }

  /**
   * Overrides UIElement.close(). to close active popup.
   */
  void close() {
    isOpen = false;
    super.close();
  }

  /** Overrides UIElement.getElement. */
  UIElement getElement(String elementId) {
    if (this.id == elementId) {
      return this;
    }
    if (_overlayElement == null) {
      return null;
    }
    return _overlayElement.getElement(elementId);
  }

  /** Overrides ContentContainer.updateContent. */
  void updateContent(Object newContent) {
    if (isOpen && _overlayElement != null) {
      removeOverlay(_overlayElement);
    }
    _overlayElement = createControlFromContent(newContent);
    if (isOpen && (_overlayElement != null)) {
      addOverlay(_overlayElement, true);
    }
  }

  static void _isOpenChangedHandler(Object target,
                                    PropertyDefinition propDef,
                                    Object oldValue,
                                    Object newValue) {
    Popup popup = target;
    popup.isOpenChanged(newValue);
  }

  static void _mouseOverLockHandler(Object target,
                                    PropertyDefinition propDef,
                                    Object oldValue,
                                    Object newValue) {
    _mouseOverLockValue = newValue;
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => popupElementDef;

  /** Registers component. */
  static void registerPopup() {
    _activePopups = <Popup>[];
    isOpenProperty = ElementRegistry.registerProperty("isOpen",
        PropertyType.BOOL, PropertyFlags.NONE, _isOpenChangedHandler, false);
    autoFocusProperty = ElementRegistry.registerProperty("autoFocus",
        PropertyType.BOOL, PropertyFlags.NONE, null, true);
    locationProperty = ElementRegistry.registerProperty(
        "Location", PropertyType.LOCATION, PropertyFlags.NONE, null, 0);
    finalLocationProperty = OverlayContainer.finalLocationProperty;
    popupElementDef = ElementRegistry.register("Popup",
        ContentContainer.contentcontainerElementDef, [isOpenProperty,
        autoFocusProperty, locationProperty, finalLocationProperty], null);
  }
}
