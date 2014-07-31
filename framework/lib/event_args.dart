part of uxml;

/**
 * Provides base class for event arguments.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class EventArgs {
  EventArgs(Object eventSource) {
    source = eventSource;
    currentSource = eventSource;
    handled = false;
  }

  /** Used to expose source event definition to handlers */
  EventDef event;

  /** Set if event was handled during routing */
  bool handled;

  /** The object that originated this event. */
  Object source;

  /** The object that dispatched this event (in case of event bubbling). */
  Object currentSource;

  /**
   *  For platform level input events although an element marks the
   * event as handled, we need platform to perform default processing.
   * This flag is set by MouseEventArgs._passthrough();
   */
  bool _forceDefault = false;

  /**
   * Initializes arguments so the instance can be reused.
   */
  void reset() {
    handled = false;
    _forceDefault = false;
  }
}

class Route {
  int route;
  Route(this.route);

  static Route DIRECT;
  static Route BUBBLE;
  static Route TUNNEL;

  static void _initRoute() {
    DIRECT = new Route(0);
    BUBBLE = new Route(1);
    TUNNEL = new Route(2);
  }
}

typedef void EventDefHandler(UxmlElement element, EventArgs e);
