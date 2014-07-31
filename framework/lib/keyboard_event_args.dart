part of uxml;

/**
* Defines mouse event arguments.
*
* @author ferhat@ (Ferhat Buyukkokten)
*/
class KeyboardEventArgs extends EventArgs {

  // Mouse EventType constants
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  static const int KEYCODE_ENTER = 13;
  static const int KEYCODE_SPACE = 32;
  static const int KEYCODE_DOWN = 40;
  static const int KEYCODE_UP = 38;
  static const int KEYCODE_LEFT = 37;
  static const int KEYCODE_RIGHT = 39;
  static const int KEYCODE_TAB = 9;

  static bool shiftKey = false;
  static bool ctrlKey = false;
  static bool altKey = false;
  static bool metaKey = false;

  /** Keyboard event type */
  int _eventType;

  /** key code */
  int keyCode;

  /** character code */
  int charCode;

  /**
   * Constructor
   */
  KeyboardEventArgs(int eventType,
      int key, int character, UxmlElement source) : super(source) {
    _eventType = eventType;
    keyCode = key;
    charCode = character;
  }

  /**
   * Sets or returns mouse event type.
   */
  int get eventType {
    return _eventType;
  }

  set eventType(int eventType) {
    _eventType = eventType;
  }
}
