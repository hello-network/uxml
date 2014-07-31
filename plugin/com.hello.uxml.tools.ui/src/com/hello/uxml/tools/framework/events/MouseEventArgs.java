package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.UIElement;

/**
* Defines mouse event arguments.
*
* @author ferhat@
*/
public class MouseEventArgs extends EventArgs {

  // MouseButton constants
  public static final int LEFT_BUTTON = 0;
  public static final int RIGHT_BUTTON = 1;

  // Mouse EventType constants
  public static final int MOUSE_DOWN = 0;
  public static final int MOUSE_UP = 1;
  public static final int MOUSE_MOVE = 2;
  public static final int MOUSE_ENTER = 3;
  public static final int MOUSE_EXIT = 4;

  /** Mouse event type */
  private int eventType;

  /** Mouse button */
  private int button;

  /** Stage relative mouse position */
  private Point pos;

  /**
   * Constructor
   */
  public MouseEventArgs() {
    pos = new Point(0, 0);
  }

  /**
   * Constructor
   */
  public MouseEventArgs(int eventType, int button, Point position) {
    this.eventType = eventType;
    this.button = button;
    this.pos = position;
  }

  /**
   * Initializes arguments so the instance can be reused.
   */
  public void reset() {
    handled = false;
  }

  /**
   * Sets or returns mouse event type.
   */
  public int getEventType() {
    return eventType;
  }

  public void setEventType(int eventType) {
    this.eventType = eventType;
  }

  /**
   * Sets or returns mouse button.
   */
  public int getButton() {
    return button;
  }

  public void setButton(int button) {
    this.button = button;
  }

  /**
   * Returns mouse position relative to an element.
   */
  public Point getMousePosition(UIElement element) {
    return element.screenToLocal(pos);
  }

  /** Sets stage relative mouse position */
  public void setMousePosition(double x, double y) {
    pos.x = x;
    pos.y = y;
  }
}
