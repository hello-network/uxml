package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.ArrayList;
import java.util.List;

/**
 * Manages system wide layout queuing, caches layout
 * changes in UIElement tree.
 *
 * @author ferhat
 */
public class UpdateQueue {

  // Optimized relayout:
  //
  // If an element size changes after measure, we place it in
  // layoutQueue.
  // If an element size changes we also force a remeasure/layout for it's
  // parent.
  // measure and layout rectangles are cached to eliminate unneccessary
  // onMeasure, onLayout calls.
  /** Holds dirty state of update queue */
  private static boolean isDirty = true;
  /**
   * List of UI elements that need relayout.
   */
  private static List<UIElement> layoutUpdates = new ArrayList<UIElement>();
  /**
   * List of elements that need remeasure based on prior layout
   * dimensions.
   */
  private static List<UIElement> measureUpdates = new ArrayList<UIElement>();

  /**
   * List of elements that need to be rerendered.
   */
  private static List<UIElement> renderUpdates = new ArrayList<UIElement>();

  private static ArrayList<CallbackData> callbacks = new ArrayList<CallbackData>();

  /**
   * Adds element to layout queue.
   */
  public static void updateLayout(UIElement element) {
    layoutUpdates.add(element);
    isDirty = true;
  }

  /**
   * Add element to measure queue.
   */
  public static void updateMeasure(UIElement element) {
    measureUpdates.add(element);
    isDirty = true;
  }

  /**
   * Add element to render queue.
   */
  public static void updateDrawing(UIElement element) {
    renderUpdates.add(element);
    isDirty = true;
  }

  /**
   * Adds element to queue for filter updates.
   */
  public static void updateFilters(UIElement element) {
    // TODO(ferhat): filters processing.
  }

  /**
   * Adds a callback to execute before next layout cycle.
   * The callback is registered using a key to eliminate duplicate calls.
   */
  public static void doLater(EventHandler callback, Object key, Object data) {
    callbacks.add(new CallbackData(callback, key, data));
  }

  /**
   * Processes all updates.
   */
  public static void flush() {

    for (int i = 0; i < callbacks.size(); i++) {
      CallbackData callData = callbacks.get(i);
      callData.getHandler().handleEvent((EventNotifier) callData.getSource(), callData);
      callbacks.remove(i);
      // TODO(ferhat): remove trace.
      Application.getCurrent().trace("dolater executed");
    }

    // First process measure queue so extra layout updates and redraw updates
    // are queued for processing. Then flush layout queue.
    int updateCount = measureUpdates.size();
    UIElement element;

    while (updateCount > 0) {
      --updateCount;
      element = measureUpdates.remove(0);
      remeasure(element);
    }

    // Relayout
    updateCount = layoutUpdates.size();
    while (updateCount > 0) {
      --updateCount;
      element = layoutUpdates.remove(0);
      if (element.getVisible() || element.getLayoutVisible()) {
        element.relayout();
      }
    }

    // Final redraw surfaces that marked for redraw
    updateCount = renderUpdates.size();
    while (updateCount > 0) {
      --updateCount;
      element = renderUpdates.remove(0);
      if (element.getVisible()) {
        element.redraw();
      }
    }
    isDirty = false;
  }

  private static void remeasure(UIElement element) {
    double prevWidth = element.getMeasuredWidth();
    double prevHeight = element.getMeasuredHeight();
    element.remeasure();
    if (prevWidth != element.getMeasuredWidth() ||
        prevHeight != element.getMeasuredHeight()) {

      // Element size changed so update layout and invalidate drawing area
      element.invalidateLayout();
      element.invalidateDraw();

      // Parent size/layout may have changed so propagate updates up.
      UIElement parent = element.getParent();
      if (parent != null) {
        remeasure(parent);
        parent.invalidateLayout();
      } else {

        // Root level relayout
        if (Application.getCurrent() != null) {
          Application.getCurrent().relayoutRoot();
        }
      }
    }
  }

  /**
   * Returns true if update queue is empty.
   */
  public static boolean isEmpty() {
    if (isDirty) {
      isDirty = false;
      return false;
    }
    return true;
  }

  /**
   * Clears updateQueue when an application is launched.
   */
  public static void clear() {
    measureUpdates.clear();
    layoutUpdates.clear();
    renderUpdates.clear();
    isDirty = false;
  }

  /**
   * Keeps track of callback data and handler for UpdateQueue.doLater impl.
   */
  public static class CallbackData extends EventArgs {
    private Object data;
    private EventHandler handler;

    public CallbackData(EventHandler handler, Object key, Object data){
      super(key, null);
      this.handler = handler;
      this.data = data;
    }

    public Object getData() {
      return data;
    }

    public EventHandler getHandler() {
      return handler;
    }
  }
}
