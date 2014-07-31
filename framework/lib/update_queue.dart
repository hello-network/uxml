part of uxml;

/**
 * Manages system wide layout queuing.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class UpdateQueue {
  // Optimized relayout:
  //
  // If an element size changes after measure, we place it in
  // layoutQueue.
  // If an element size changes we also force a remeasure/layout for it's
  // parent.
  // measure and layout rectangles are cached to eliminate unneccessary
  // onMeasure, onLayout calls.

  /**
   * List of elements that need remeasure based on prior layout
   * dimensions.
   */
  static List<UIElement> measureUpdates = null;
  static Set<UIElement> measureSet;

  /**
   * List of UI elements that need relayout.
   */
  static List<UIElement> layoutUpdates;
  static Set<UIElement> layoutSet;

  /**
   * List of elements that requested repainting due to content or size change.
   */
  static List<UIElement> renderUpdates;
  static Set<UIElement> renderSet;

  /**
   * List of elements that have moved and require their children's
   * absolute locations to be updated since this element has no associated
   * DOM element.
   */
  static List<UISurface> _childLocationUpdates;
  static Set<UISurface> _childLocationSet;

  /**
   * List of elements with filter collection/property updates.
   */
  static List<UIElement> filterUpdates;
  static List locationUpdates;
  static bool busy = false;

  /**
   * List of callbacks to execute before relayout is performed.
   */
  static List<QueueCallbackData> callbacks;
  static Map<Object,bool> callbackActive;
  static bool blockDoLater = false;
  static bool _requestFrameInFlight = false;
  // End of frame callback used by Application to properly send
  // shutdownEvent after queue is finished processing.
  static var _frameCallback = null;

  static void initialize() {
    if (measureUpdates != null) {
      return; // prevent dupl call.
    }
    locationUpdates = [];
    measureUpdates = <UIElement>[];
    measureSet = new Set<UIElement>();
    layoutUpdates = <UIElement>[];
    layoutSet = new Set<UIElement>();
    renderUpdates = <UIElement>[];
    renderSet = new Set<UIElement>();
    _childLocationUpdates = <UISurface>[];
    _childLocationSet = new Set<UISurface>();
    filterUpdates = <UIElement>[];
    callbacks = <QueueCallbackData>[];
    callbackActive = new Map<String,bool>();
    blockDoLater = false;
  }

  /**
   * Adds element to measure queue.
   */
  static void updateMeasure(UIElement element) {
    //print("measureUpdates.length = " + measureUpdates.length);
    if (!measureSet.contains(element)) {
      if (element.parent == null || (!measureSet.contains(element.parent))) {
        measureUpdates.add(element);
        measureSet.add(element);
        _requestAnimationFrame();
      }
    }
  }

  /**
   * Adds element to layout queue.
   */
   static updateLayout(UIElement element) {
     //print("layoutUpdates.length = " + layoutUpdates.length);
     if (!layoutSet.contains(element)) {
       layoutUpdates.add(element);
       layoutSet.add(element);
       _requestAnimationFrame();
     }
   }

  /**
   * Adds element to render queue.
   */
  static updateDrawing(UIElement element) {
    if (!renderSet.contains(element)) {
      renderUpdates.add(element);
      renderSet.add(element);
      _requestAnimationFrame();
    }
  }

  /**
   * Adds element to child location update queue.
   */
  static _updateChildLocations(UISurface surface) {
    if (!_childLocationSet.contains(surface)) {
      _childLocationUpdates.add(surface);
      _childLocationSet.add(surface);
      _requestAnimationFrame();
    }
  }

  /**
   * Adds element to filter update queue.
   */
  static updateFilters(UIElement element) {
    if (filterUpdates.indexOf(element, 0) == -1) {
      filterUpdates.add(element);
      _requestAnimationFrame();
    }
  }

  /**
   * Schedules animation frame request for animation scheduler.
   */
  static updateAnimations() {
    _requestAnimationFrame();
  }

  /**
   * Adds a callback to execute before next layout cycle.
   * The callback is registered using a key to eliminate duplicate calls.
   */
  static void doLater(UpdateQueueHandler callback, Object key, Object data) {
    if (blockDoLater) {
      callbacks = <QueueCallbackData>[];
      blockDoLater = false;
    }
    if (key != null && callbackActive.containsKey(key)) {
      if (callbackActive[key] != true) {
        // duplicate entry, return.
        return;
      }
      callbackActive[key] = true;
    }
    callbacks.add(new QueueCallbackData(callback, key, data));
    _requestAnimationFrame();
  }

  static void flush() {
    _requestFrameInFlight = false;
    if (Application._current == null) {
      return;
    }
    if (busy) {
      //throw new Exception();
      return;
    }
    busy = true;
    int updateCount;
    UIElement element;

    // child element remeasures will trigger layout changes in parents that
    // will cause secondary remeasure/layout on children. Therefore we
    // run the first part of updates twice to optimize the final rendering.
    for (int phase = 0; phase < 2; phase++) {

      // First process measure queue so extra layout updates and redraw
      // updates are queued for processing. Then flush layout queue.
      // int startTime = Application.getTimer();
      // logStatistics();
      //DateTime start = new DateTime.now();

      // Process doLater callbacks before remeasure/layout
      try {
        List<QueueCallbackData> currentCallbacks = callbacks;
        blockDoLater = true;
        int nElem = currentCallbacks.length;
        for (int c = 0; c < nElem; c++) {
          QueueCallbackData callbackData = currentCallbacks[0];
          currentCallbacks.removeRange(0, 1);
          String key = callbackData.key;
          if (key != null) {
            callbackActive.remove(key);
          }
          callbackData.execute();
        }
      } on Exception catch (e) {
          Application.current.error("callback failure ${e.toString()}");
      }
      blockDoLater = false;

      List<UIElement> delayedMeasures = null;
      for (int measureIndex = 0; measureIndex < measureUpdates.length;
          measureIndex++) {
        element = measureUpdates[measureIndex];
        if (element.isMeasureDirty) {
          if (element._remeasure() == false) {
            if (delayedMeasures == null) {
              delayedMeasures = <UIElement>[];
            }
            delayedMeasures.add(element);
          } else {
            measureSet.remove(element);
          }
        } else {
          measureSet.remove(element);
        }
      }
      if (delayedMeasures != null) {
        measureUpdates = delayedMeasures;
      } else {
        measureUpdates.length = 0;
      }

      // Relayout
      updateCount = layoutUpdates.length;
      while (updateCount > 0) {
        // print("up : $updateCount , ${layoutUpdates.length}");
        --updateCount;
        element = layoutUpdates.removeLast();
        layoutSet.remove(element);
        if (element.visible || element.layoutVisible) {
            if (element.isMeasureDirty) {
              element._remeasure();
            }
            if (element.isLayoutInitialized) {
              element.layout(element._prevLayoutX, element._prevLayoutY,
                  element._prevLayoutWidth, element._prevLayoutHeight);
            }
        }
      }

      // Update bitmap filters
      updateCount = filterUpdates.length;
      while (updateCount > 0) {
        --updateCount;
        element = filterUpdates.removeLast();
        // If filters were applied during render loop, skip.
        if ((element._layoutFlags & UIElement._UPDATEFLAG_FILTERS) != 0) {
          element._applyFilters();
        }
      }

      for (int l = 0; l < locationUpdates.length; l++) {
        var item = locationUpdates[l];
        item[0].setLocation(item[1], item[2], item[3], item[4]);
      }
      locationUpdates = [];

      // Final redraw surfaces that marked for redraw
      updateCount = renderUpdates.length;
      for (int u = 0; u < updateCount; u++) {
        element = renderUpdates[u];
        if (element.visible) {
          element._redraw();
        }
      }
      renderUpdates.clear();
      renderSet.clear();

      UISurface s;
      updateCount = _childLocationUpdates.length;
      for (int u = 0; u < updateCount; u++) {
        s = _childLocationUpdates[u];
        UIPlatform._updateChildLocations(s);
      }
      _childLocationUpdates.clear();
      _childLocationSet.clear();
    }
    // Uncomment to see layout stats. TODO(ferhat): move to common logging.
    //    int duration = Application.getTimer() - startTime;
    //    if (duration != 0) {
    //      Application.current.trace(layoutStatLog[layoutStatLog.length - 1] + "(" +
    //         duration + " ms)");
    //    }
    //      Duration delta = new DateTime.now().difference(start);
    //      if (delta.inMilliseconds > 90) {
    //        print("*UpdateQueue total time: ${delta}");
    //      }


    busy = false;
    // If the 2 phase measure/layout/render loop did not stabilize the view
    // yet, we need to schedule the next requestAnimationFrame.
    if (_requestFrameInFlight) {
      UIPlatform.scheduleEnterFrame(Application.current);
    }
    if (_frameCallback != null) {
      _frameCallback();
    }
  }

  static void updateLocation(UISurface s, int targetX,
                             int targetY,
                             int targetWidth,
                             int targetHeight) {
    locationUpdates.add([s, targetX, targetY, targetWidth, targetHeight]);
  }

  static void _requestAnimationFrame() {
    if (!_requestFrameInFlight) {
      _requestFrameInFlight = true;
      if (!busy) {
        // The busy check makes sure we don't call scheduleEnterFrame
        // thousands of times while measure/layout of large views is
        // in progress. We only want to restart requestAnimationFrame loop
        // when there is an async event happening while the update queue
        // is idle.
        UIPlatform.scheduleEnterFrame(Application.current);
      }
    }
  }
}

class QueueCallbackData {
  UpdateQueueHandler _handler;
  Object _key;
  Object _data;

  QueueCallbackData(UpdateQueueHandler handler, Object key, Object data) {
    _handler = handler;
    _key = key;
    _data = data;
  }

  Object get key {
    return _key;
  }

  void execute() {
    _handler(_data);
  }
}

typedef void UpdateQueueHandler(Object data);

