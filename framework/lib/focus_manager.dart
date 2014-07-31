part of uxml;

/**
 * Manages input focus for UIElements.
 *
 * author ferhat@ (Ferhat Buyukkokten)
 */
class FocusManager extends UxmlElement {
  static ElementDef focusElementDef;
  static const String _UPDATE_FOCUS_KEY = "focusAsync";
  /** Focus changed event definition */
  static EventDef focusChangedEvent;
  EventHandler _focusHandler = null;

  /**
   * RedirectFocusChrome property definition.
   * Used to change the focusChrome target for an element. Example:
   * TextBox asks it's TextEdit redirect focus chrome to itself.
   */
  static PropertyDefinition redirectFocusChromeProperty;

  // Element that has input focus.
  UIElement _focusTarget;

  // Active focusRing on focusTarget
  UIElement _focusOverlay;

  // Recycled event arg for FocusChangedEvent
  FocusEventArgs _focusEventArg;

  FocusManager() : super () {
  }

  /**
   * Returns element that has focus.
   */
  UIElement get focusedElement => _focusTarget;

  /**
   * Moves focus to next or prior element.
   * Called my application when tab/shift-tab is not handled by
   * any other view element.
   */
  void processTabKey(bool back) {
    UIElement modalElement = Application.current._modalElement;
    bool usingModalElement = false;
    if ((modalElement != null) && (_focusTarget != null) &&
      (!modalElement.isVisualChild(_focusTarget))) {
      // If a modal panel is up and the prior _focusTarget is not a child of
      // the modal panel, we should use modalPanel instead of prior focus
      // target.
      _focusTarget = modalElement;
      usingModalElement = true;
    }
    FocusScopeData focusData = FocusScopeData.findFocusGroup(_focusTarget);
    UIElement prevFocus = _focusTarget;
    UIElement newFocus;
    if (back) {
      newFocus = focusData.getPrevTabStop(_focusTarget);
    } else {
      newFocus = focusData.getNextTabStop(_focusTarget);
    }
    if (newFocus != null) {
      if ((modalElement != null) && (newFocus != null) &&
        (!modalElement.isVisualChild(newFocus))) {
        if (usingModalElement) {
          return;
        } else {
          // we have moved out of modalElement, send focus inside.
          if (back) {
            newFocus = focusData.getPrevTabStop(modalElement);
          } else {
            newFocus = focusData.getNextTabStop(modalElement);
          }
          if (newFocus == null) {
            return; // Nothing in the modal panel can get focus, just return.
          }
        }
      }
      newFocus.setFocus();
      // Detect case when a parent is programatically setting focus to one of
      // it's children. In that case we can't simply call setfocus on
      // prevtabstop instead we need to set focus to prevTabStop(parent)
      if ((_focusTarget != newFocus) && back && (_focusTarget == prevFocus)) {
        newFocus = focusData.getPrevTabStop(newFocus);
        newFocus.setFocus();
        newFocus.scrollIntoView();
      }
      // Now that we have set tab stop to new element, a lostfocus handler
      // might have modified the view to make the element invisible or
      // collapsed. Check and remove focus in that case. Adding listeners
      // to complete parent chain is too expensive. This is more efficient.
      if (!FocusScopeData._isValidTabStop(newFocus)) {
        newFocus.isFocused = false;
      }
    }
  }

  // Handles UIElement IsFocused changed.
  void _focusChangedHandler(Object target,
                            PropertyDefinition propDef,
                            Object oldValue,
                            Object newValue) {
    bool focusValue = newValue;
    bool skippedFocusRemoval = false;
    if (_focusEventArg == null) {
      _focusEventArg = new FocusEventArgs(null, null);
    }
    _focusEventArg.oldElement = _focusTarget;
    if (focusValue) {
      skippedFocusRemoval = (_focusTarget != null) &&
          (_focusTarget == target);
      // Turn isFocused off for currently focused element
      if ((_focusTarget != null) && (_focusTarget != target)) {
        // Remove focus off stage (example: when textedit loses focus)
        if (_focusTarget._hostSurface != null &&
            _focusTarget._hostSurface is UIEditSurface) {
          (_focusTarget._hostSurface as UIEditSurface).focusChanged(false);
        }
        _removeFocusRing();
        if (_focusTarget != null) {
          _focusTarget.isFocused = false;
        }
        // Setting isFocused false will set focusTarget to null, don't
        // use focusTarget below this line.
      }
      _focusTarget = target;
      _focusEventArg.newElement = _focusTarget;
    } else {
      if (_focusTarget != null) {
        _removeFocusRing();
        _focusTarget = null;
      }
    }
    // See optimization above that skips removal of old focus ring if
    // focusTarget == target. Therefore we need to check here again
    // to make sure we don't create multiple focus rings for same object
    // which prevents multiple rings from getting cleaned up and hanging in
    // the air.
    if (!skippedFocusRemoval) {
      if (_focusTarget != null) {
        if (_focusTarget.hasSurface) {
          _createFocusRingForElement(_focusTarget);
        } else {
          UpdateQueue.doLater(_addFocusOverlayAsync, _UPDATE_FOCUS_KEY,
              _focusTarget);
        }
        _focusHandler = _onFocusedElementClosed;
        _focusTarget.addListener(UIElement.closedEvent, _focusHandler);
      }
      notifyListeners(focusChangedEvent, _focusEventArg);
    }
  }

  void _addFocusOverlayAsync(Object data) {
    UIElement newFocusTarget = data;
    if (newFocusTarget.isFocused) { // If items is still focused create ring ui.
      if (_focusTarget == newFocusTarget) {
        _createFocusRingForElement(_focusTarget);
      }
    }
  }

  static UIElement _getFocusRingTarget(UIElement target) {
    while (target != null && target.overridesProperty(redirectFocusChromeProperty)) {
      target = target.getProperty(redirectFocusChromeProperty);
    }
    return target;
  }

  void _createFocusRingForElement(UIElement target) {
    target = _getFocusRingTarget(target);
    if (target.overridesProperty(UIElement.focusChromeProperty)) {
      Chrome focusChrome = target.focusChrome;
      if (focusChrome != null) {
        _focusOverlay = focusChrome.applyToTarget(target);
        if (_focusOverlay != null) {
          target.addOverlay(_focusOverlay, true);
        }
      }
    } else {
      _focusOverlay = _createDefaultFocusRing(target);
      target.addOverlay(_focusOverlay, true);
    }
  }

  // Creates UI to use as overlay for indicating focus.
  UIElement _createDefaultFocusRing(UIElement focusTarget) {
    // TODO(ferhat): Future enhancements:
    // 1- Reuse element by reparenting to new target.
    // 2- When user clicks on a radio button/checkbox etc.. we should
    // record a hint for the focusmanager to use for tab key next item.
    Object res = focusTarget.findResource("focusRingColor");
    Color focusColor = ((res != null) && (res is Color)) ?
        res : Color.fromRGB(0x66b3e1);
    Group group = new Group();
    RectShape blackRect = new RectShape();
    blackRect.borderRadius = new BorderRadius.uniform(4.0);
    blackRect.stroke = new SolidPen(focusColor, 2.0);
    blackRect.margins = new Margin(-2.0, -2.0, -2.0, -2.0);
    group.addChild(blackRect);
    RectShape glowRect = new RectShape();
    glowRect.borderRadius = new BorderRadius.uniform(4.0);
    glowRect.stroke = new SolidPen(focusColor, 2.0);
    glowRect.mouseEnabled = false;
    GlowFilter glowFilter = new GlowFilter();
    glowFilter.blurX = 8.0;
    glowFilter.blurY = 8.0;
    glowFilter.strength = 0.7;
    glowFilter.color = focusColor;
    glowFilter.knockout = true;
    glowRect.filters.add(glowFilter);
    glowRect.margins = new Margin(-2.0, -2.0, -2.0, -2.0);
    group.addChild(glowRect);
    group.mouseEnabled = false;
    return group;
  }

  void _removeFocusRing() {
    if (_focusHandler != null) {
      _focusTarget.removeListener(UIElement.closedEvent, _focusHandler);
      _focusHandler = null;
    }
    if (_focusOverlay != null) {
      _getFocusRingTarget(_focusTarget).removeOverlay(_focusOverlay);
      _focusOverlay = null;
    }
  }

  /**
   * Removes focus from all elements.
   */
  void cancelFocus() {
    if (_focusTarget != null) {
      _focusTarget.isFocused = false;
    }
  }

  void _onFocusedElementClosed(EventArgs e) {
    UIElement element = e.source;
    if (_focusHandler != null) {
      element.removeListener(UIElement.closedEvent, _focusHandler);
      _focusHandler = null;
    }
    element.isFocused = false;
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => focusElementDef;

  /**
   * Overrides the focusChrome target for the element.
   */
  static void redirectFocusChrome(UIElement from, UIElement to) {
    from.setProperty(redirectFocusChromeProperty, to);
  }

  /** Registers component. */
  static void registerFocusManager() {
    FocusScopeData.focusScopeProperty = ElementRegistry.registerProperty(
        "focusScope", PropertyType.OBJECT, PropertyFlags.NONE, null, null);
    redirectFocusChromeProperty = ElementRegistry.registerProperty(
        "RedirectFocusChrome", PropertyType.OBJECT, PropertyFlags.ATTACHED,
        null, null);
    focusChangedEvent = new EventDef("FocusChanged", Route.DIRECT);
    focusElementDef = ElementRegistry.register("FocusManager",
        null, [], [focusChangedEvent]);
  }
}
