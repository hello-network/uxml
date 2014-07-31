part of uxml;

/**
* Defines mouse event arguments.
*
* @author ferhat@ (Ferhat Buyukkokten)
*/
class MouseEventArgs extends EventArgs {
  // MouseButton constants
  // NO_BUTTON is used when button is in up state during mouse move
  static const int NO_BUTTON = 0;
  static const int LEFT_BUTTON = 1;
  static const int RIGHT_BUTTON = 2;
  static const int MIDDLE_BUTTON = 4;

  // Mouse EventType constants
  static const int MOUSE_DOWN = 0;
  static const int MOUSE_UP = 1;
  static const int MOUSE_MOVE = 2;
  static const int MOUSE_ENTER = 3;
  static const int MOUSE_EXIT = 4;
  static const int MOUSE_WHEEL = 5;

  /** Mouse event type */
  int _eventType;

  /** Mouse button */
  int _button;

  /** Stage relative mouse position */
  int posX;
  int posY;

  /** Sets/returns mouse wheel delta */
  int deltaY;

  // Due to cost of allocating MouseEventArgs and Coord, Application loop
  // maintains only a few instances of MouseEventArgs it recycles. Therefore
  // we allocate localPoint once and reuse it on every getMousePosition call
  // downstream.
  Coord localPoint;

  /**
   * Constructor
   */
  MouseEventArgs(int eventType, int button, Coord position) : super(null) {
    localPoint = new Coord(0.0, 0.0);
    _eventType = eventType;
    _button = button;
    if (position != null) {
      posX = position.x.toInt();
      posY = position.y.toInt();
    } else {
      posX = 0;
      posY = 0;
    }
  }

  /**
   * Creates a left mouse down event argument.
   */
  MouseEventArgs.leftMouseDown() : super(null) {
    localPoint = new Coord(0.0, 0.0);
    _eventType = MouseEventArgs.MOUSE_DOWN;
    _button = MouseEventArgs.LEFT_BUTTON;
    posX = 0;
    posY = 0;
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

  /**
   * Sets or returns mouse button.
   */
  int get button {
    return _button;
  }

  set button(int value) {
    _button = value;
  }

  /**
   * Returns mouse position relative to an element.
   */
  Coord getMousePosition(UIElement element) {
    if (element == null) {
      localPoint.x = posX;
      localPoint.y = posY;
      return localPoint;
    }
    element.screenToLocalInternal(posX, posY, localPoint);
    return localPoint;
  }

  /** Sets stage relative mouse position */
  void setMousePosition(int x, int y) {
    posX = x;
    posY = y;
  }

  // For platform level input events although an element marks the
  // event as handled, we need platform to perform default processing.
  // Used by TextBox and TextEdit.
  void _passthrough() {
    _forceDefault = true;
  }
}

/**
 * Defines drag and drop event arguments.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class DragEventArgs extends MouseEventArgs {

  DragEventArgs() : super(MouseEventArgs.MOUSE_DOWN,
      MouseEventArgs.LEFT_BUTTON, new Coord(0.0, 0.0)) {
  }
  /**
   * Sets/returns drag & drop source element.
   */
  UIElement dragSource;

  /**
   * Sets/returns data source for drag & drop.
   */
  ClipboardData data;
}
