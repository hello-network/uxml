part of uxml;

/**
 * Manages cursor or UIElement.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class Cursor {
  static Cursor ARROW;
  static Cursor BUTTON;
  static Cursor HAND;
  static Cursor IBEAM;
  static Cursor WAIT;
  static Cursor CROSSHAIR;

  /**
   * Cursor Property Definition.
   */
  static PropertyDefinition cursorProperty;

  static Cursor _activeCursor = null;
  static Object host = null;
  String name;

  Cursor(this.name) {
  }

  /**
  * Called from Application to initialize cursors.
  */
  void initialize(Object window) {
    _activeCursor = ARROW;
    host = window;
  }

  /**
   * Sets cursor for an element.
   */
  static void setElementCursor(UIElement element, Cursor cursor) {
    element.setProperty(cursorProperty, cursor);
  }

  static Cursor getElementCursor(UIElement element) {
    while (element != null) {
      Cursor cursor = element.getProperty(cursorProperty);
      if (cursor != null) {
        return cursor;
      }
      element = element.visualParent;
    }
    return ARROW;
  }

  /**
   * Sets system wide cursor.
   */
  static void setCursor(Cursor cursor) {
    if (_activeCursor != cursor) {
      UISurface surface = Application.current.rootSurface;
      if (surface != null) {
        if (surface.setupTopLevelCursor(cursor)) {
          _activeCursor = cursor;
        }
      }
    }
  }

  /** Registers component. */
  static void registerCursor() {
    ARROW = new Cursor("default");
    BUTTON = new Cursor("pointer");
    HAND = new Cursor("hand");
    IBEAM = new Cursor("text");
    WAIT = new Cursor("wait");
    CROSSHAIR = new Cursor("crosshair");
    cursorProperty = ElementRegistry.registerProperty("Cursor",
        PropertyType.STRING, PropertyFlags.ATTACHED, null, null);
  }
}
