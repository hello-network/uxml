part of uxml;

/**
 * Manages visibility of tooltip overlays.
 *
 * The tooltip is displayed if the mouse stays stable over the element area
 * within GRAVITY distance for more than WAIT_TIME. When using a pen
 * the GRAVITY bounds is important since due to sensitivity the coordinates
 * might jitter about a pixel or two and cause tooltip to not show up
 * unless absolutely still which will strain user.
 *
 * The tooltip layout bounds are based on the owner of the tooltip. To
 * override tooltip location, use Canvas.setLeft/Top in toolTipOpened event
 * on the tooltip owner element.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class _ToolTipManager {
  // Maps element to _ToolTipState.
  Map<UIElement, _ToolTipState> watchMap;
  List<_ToolTipState> watchList;

  // 3x3 pixels gravity area.
  static const int GRAVITY = 3;
  // Defines time elapsed before tooltip is shown in ms.
  static const int WAIT_TIME = 500;
  // Defines time elapsed when another tooltip is already active.
  static const int SHORT_WAIT_TIME = 150;

  // - unless a second tooltip is about to be shown, when mouse leaves control
  // DECAY_TIME is used to wait for dismissal. Within decay_time, mouse
  // might move back into control area. Ideally this should be lessequal
  // to SHORT_WAIT_TIME so we don't get 2 tooltips shown at the same time.
  static const int DECAY_TIME = 150;
  Timer timer;
  UIElement currentToolTip = null;
  /** Tooltip opened event definition */
  static EventDef toolTipOpenedEvent = null;
  EventHandler previewListener;

  _ToolTipManager() {
    if (toolTipOpenedEvent == null) {
      toolTipOpenedEvent = new EventDef("TooltipOpened", Route.DIRECT);
    }
  }

  /**
   * Registers element as tooltip source and starts watching mouse events
   * for element to display tooltip.
   */
  void add(UIElement element) {
    _ToolTipState state = new _ToolTipState(element, WAIT_TIME);
    state.destroyListener = elementDestroyed;
    element.addListener(UIElement.closedEvent, state.destroyListener);
    state.enterListener = mouseEnter;
    element.addListener(UIElement.mouseEnterEvent, state.enterListener);
    state.exitListener = mouseExit;
    element.addListener(UIElement.mouseExitEvent, state.exitListener);
    state.moveListener = mouseMove;
    element.addListener(UIElement.mouseMoveEvent, state.moveListener);
    if (watchList == null) {
      watchList = <_ToolTipState>[];
      watchMap = new Map<UIElement, _ToolTipState>();
    }
    watchMap[element] = state;
    watchList.add(state);
    if (watchList.length == 1) {
      // Very first item. Start listening to all mouse events.
      previewListener = mousePreviewHandler;
      Application.current.addListener(Application.mousePreviewEvent,
          previewListener);
    }
  }

  /**
   * Unregisters element as tooltip source.
   */
  void remove(UIElement element) {
    _ToolTipState state = watchMap[element];
    if (state == null) {
      return;
    }

    // Hide the tooltip if still visible.
    _showTip(state, false);
    watchMap.remove(element);
    watchList.removeAt(watchList.indexOf(state));
    releaseTimerIfPossible();

    element.removeListener(UIElement.closedEvent, state.destroyListener);
    element.removeListener(UIElement.mouseMoveEvent, state.moveListener);
    element.removeListener(UIElement.mouseExitEvent, state.exitListener);
    element.removeListener(UIElement.mouseEnterEvent, state.enterListener);

    if (watchList.length == 0) {
      Application.current.removeListener(Application.mousePreviewEvent,
          previewListener);
    }
  }

  void elementDestroyed(EventArgs e) {
    remove(e.source);
  }

  _ToolTipState mouseEventToState(MouseEventArgs e) {
    UIElement elm = e.source;
    if (elm.tooltip == null || elm.tooltip.enabled == false) {
      return null; // Don't track/show tooltips that are disabled.
    }
    return watchMap[elm];
  }

  void mouseEnter(MouseEventArgs e) {
    _ToolTipState state = mouseEventToState(e);
    if (state == null) {
      return;
    }
    state.enterTime = _getTimer();
    state.moveTime = state.enterTime;
    state.mousePos = e.getMousePosition(state.element);
    state.isInside = true;
    state.waitTime = currentToolTip == null ? WAIT_TIME : SHORT_WAIT_TIME;
    if (timer == null) {
      timer = new Timer(new Duration(milliseconds: min(DECAY_TIME, WAIT_TIME)),
          () {
            tooltipTimerElapsed();
            timer = new Timer.periodic(new Duration(milliseconds: WAIT_TIME),
                (Timer repeating) {
                  tooltipTimerElapsed();
                });
          });
    }
  }

  int _getTimer() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  void mouseMove(MouseEventArgs e) {
    _ToolTipState state = mouseEventToState(e);
    if (state == null) {
      return;
    }
    state.mousePos = e.getMousePosition(state.element);
    state.moveTime = _getTimer();
    state.isInside = true;
  }

  void mouseExit(MouseEventArgs e) {
    // Can't call mouseEventToState here since tooltip might have been
    // disabled while active. So we check watchMap directly.
    UIElement elm = e.source;
    _checkMouseExit(elm);
  }

  void _checkMouseExit(UIElement elm) {
    if (elm.tooltip == null) {
      return;
    }
    _ToolTipState state = watchMap[elm];
    if (state == null) {
      return;
    }
    // element.isMouseOver is now false, if the user is on the tooltip
    // we should still keep isInside = true.
    state.isInside = elm.tooltip.isMouseOver;
    state.exitTime = _getTimer();
  }

  void tooltipTimerElapsed() {
    int ts = _getTimer();
    for (int i = watchList.length - 1; i >= 0; i--) {
      _ToolTipState state = watchList[i];
      if (state == null) {
        continue;
      }
      if (state.isInside) {
        if ((ts - state.moveTime) >= state.waitTime) {
          // open tooltip.
          _showTip(state, true);
        }
      } else if (state.isOpen) {
        // if mouse stays outside > decay time, close tooltip.
        if ((ts - state.exitTime) >= DECAY_TIME) {
          // close tooltip.
          _showTip(state, false);
          releaseTimerIfPossible();
        }
      }
    }
  }

  void releaseTimerIfPossible() {
    // Check if any elements are active otherwise stop timer
    for (int i = watchList.length - 1; i >= 0; i--) {
      _ToolTipState state = watchList[i];
      if (state != null && state.isInside == true) {
        return;
      }
    }
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  void _showTip(_ToolTipState state, bool show) {
    UIElement element = state.element;
    ToolTip tooltip = element.tooltip;
    if (show) {
      if (state.isOpen == false) {
        state.isOpen = true;
        currentToolTip = tooltip;
        element.addOverlay(tooltip, false, tooltip.location);
        Coord p = element.localToScreen(state.mousePos);
        if (element.hasListener(toolTipOpenedEvent)) {
          MouseEventArgs mouseArgs = new MouseEventArgs(
              MouseEventArgs.MOUSE_MOVE, MouseEventArgs.LEFT_BUTTON, p);
          element.notifyListeners(toolTipOpenedEvent, mouseArgs);
        }
        state.tooltipMouseOverListener = _toolTipMouseOverChanged;
        tooltip.addListener(UIElement.isMouseOverProperty,
            state.tooltipMouseOverListener);
      }
    } else if (state.isOpen) {
      state.isOpen = false;
      num prevOpacity = tooltip.opacity;
      tooltip.animate(UIElement.opacityProperty, 0.0, duration:100,
          callback:(Action target, Object data) {
            element.removeOverlay(tooltip);
            if (tooltip == currentToolTip) {
              currentToolTip = null;
            }
            tooltip.opacity = prevOpacity;
          });
      tooltip.removeListener(UIElement.isMouseOverProperty,
          state.tooltipMouseOverListener);
    }
  }

  void _toolTipMouseOverChanged(EventArgs e) {
    ToolTip tooltip = e.source;
    if (tooltip != null && tooltip.parent != null) {
      _checkMouseExit(tooltip.parent);
    }
  }

  /* Hides active tooltips when user clicks on any element. */
  void mousePreviewHandler(MouseEventArgs e) {
    UIElement mouseEventTarget = e.source;
    if (e.eventType != MouseEventArgs.MOUSE_DOWN) {
      return;
    }
    for (int i = watchList.length - 1; i >= 0; i--) {
      _ToolTipState state = watchList[i];
      if (state.element is UIElement) {
        // Don't dismiss tooltip if user clicked inside the tooltip.
        // Example: scrollbox with lots of text inside a tooltip.
        if (mouseEventTarget != null &&
            mouseEventTarget.isChildOf(state.element)) {
          return;
        }
      }
      _showTip(state, false);
    }
  }

  /** Shows/hides tooltip for element. */
  void showToolTip(UIElement element, bool show) {
    _ToolTipState data = watchMap[element];
    if (data != null) {
      _showTip(data, show);
    }
  }
}

/** Keeps track of state for active tooltips.*/
class _ToolTipState {

  _ToolTipState(this.element, this.waitTime);

  UIElement element;

  // Enter/move/exit Time is time when mouse event occurs on element.
  int enterTime = 0;
  int moveTime = 0;
  int exitTime = 0;

  // waitTime is updated by mouseEnter. If a tooltip is already open,
  // the waitTime is reduced so user can quickly scan through containers
  // such as toolbars.
  int waitTime;
  // True if mouse is inside element.
  bool isInside = false;
  // isOpen indicates if tooltip was activated.
  bool isOpen = false;
  // Coordinate at which mouseEnter event was sent to element.
  Coord mousePos;

  EventHandler destroyListener;
  EventHandler enterListener;
  EventHandler moveListener;
  EventHandler exitListener;
  EventHandler tooltipMouseOverListener;
}
