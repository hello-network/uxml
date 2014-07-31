part of uxml;

/** Provides browser history services. */
class BrowserHistory extends UxmlElement {
  // Holds current browser url state (exluding # character).
  String _state;
  bool _isTracking;
  bool _isFirstEvent;
  var _browserStateChangedClosure;
  bool _inChangeState = false;
  StreamSubscription<Event> _popupStateSub = null;

  static EventDef changedEvent = new EventDef("changed",
      Route.DIRECT);

  /** Navigates to a url. */
  static void navigateTo(String url, [String target = null]) {
    url = UIPlatform.rewriteUrl(url);
    if (target != null) {
      window.open(url, target);
      return;
    }
    // Firefox doesn't have window.location.origin.
    if (Application.isFF) {
      window.location.href = (UIPlatform.interceptor == null) ?
          "${window.location.protocol}//${window.location.host}/${url}" : url;
    } else {
      window.location.href = (UIPlatform.interceptor == null) ?
          "${window.location.origin}/${url}" : url;
    }
  }

  /** Navigates back in browser history. */
  static void navigateBack() {
    window.history.back();
  }

  BrowserHistory() : super() {
    _state = "";
    _isTracking = false;
  }

  void startTracking() {
    stopTracking();
    _browserStateChangedClosure = _browserStateChanged;
    _popupStateSub = window.onPopState.listen(_browserStateChangedClosure);
    _isFirstEvent = true;
    _isTracking = true;
    _state = window.location.hash;
    if (_state.startsWith('#')) {
      _state = _state.substring(1);
    }
    if (Application.isFF) {
      _browserStateChanged(null);
    }
  }

  void stopTracking() {
    if (_isTracking) {
      _popupStateSub.cancel();
      _popupStateSub = null;
      _isTracking = false;
    }
  }

  void _browserStateChanged(event) {
    _inChangeState = true;
    _changeStateTo(window.location.hash);
    _inChangeState = false;
  }

  void _changeStateTo(String newState) {
    if (newState.startsWith('#')) {
      newState = newState.substring(1, newState.length);
    }
    if (newState == _state && !_isFirstEvent) {
      return;
    }
    BrowserHistoryEventArgs eventArg = new BrowserHistoryEventArgs(this,
        newState, _isFirstEvent);
    notifyListeners(changedEvent, eventArg);
    if (eventArg.state != newState) {
      window.history.replaceState(null, document.title, "#${eventArg.state}");
    } else {
      _state = newState;
    }
    _isFirstEvent = false;
  }

  /** Returns current state in browser history. */
  String get state => _state;

  /** Pushes a state onto the browser history stack */
  set state(String newState) {
    if (!_isTracking) {
      throw 'history tracking not started';
    }
    String newFrag = "#$newState";
    if (_inChangeState && newFrag == window.location.hash) {
      return;
    }
    if (newState != _state) {
      window.history.pushState(null, document.title, newFrag);
      _state = newState;
    }
  }
}

class BrowserHistoryEventArgs extends EventArgs{
  bool _isFirst;
  String _state;
  BrowserHistoryEventArgs(Object source,
                          String state,
                          bool isFirst) : super(source) {
    _state = state;
    _isFirst = isFirst;
  }

  /**
   * Returns new browser state.
   */
  String get state => _state;

  /**
   * Asks the browser to replace the existing browser state.
   */
  void replaceState(String state) {
    _state = state;
  }

  /** Returns true if this is the very first browser state event. */
  bool get isFirst => _isFirst;
}
