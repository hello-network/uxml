package com.hello.uxml.tools.framework.events;

/**
* Defines keyboard event arguments.
*
* @author ferhat@
*/
public class KeyboardEventArgs extends EventArgs {

  // Keyboard EventType constants
  public static final int KEY_DOWN = 0;
  public static final int KEY_UP = 1;
  public static final int MOUSE_MOVE = 2;
  public static final int MOUSE_ENTER = 3;
  public static final int MOUSE_EXIT = 4;

  /** Keyboard event type */
  private int eventType;

  private int keyCode;
  private int charCode;

  /**
   * Constructor
   */
  public KeyboardEventArgs() {
  }

  /**
   * Constructor
   */
  public KeyboardEventArgs(int eventType, int keyCode, int charCode) {
    this.eventType = eventType;
    this.keyCode = keyCode;
    this.charCode = charCode;
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
   * Sets or returns key code.
   */
  public int getKeyCode() {
    return keyCode;
  }

  public void setKeyCode(int code) {
    keyCode = code;
  }

  /**
   * Sets or returns character code.
   */
  public int getCharCode() {
    return charCode;
  }

  public void setCharCode(int code) {
    charCode = code;
  }
}
