part of uxml;

/**
 * Represents a Brush with a single solid color.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class SolidBrush extends Brush {
  /** brush color */
  Color _color;

  /**
   * Constructor.
   */
  SolidBrush(Color color) : super() {
    _type = 0;
    _color = color;
  }

  /**
   * Sets/returns brush color.
   */
  Color get color {
    return _color;
  }

  set color(Color value) {
    _color = value;
  }

  /**
   * Creates a solid brush from rgb value.
   * TODO(ferhat): deprecate, change to dart ctor style.
   */
  static SolidBrush fromRGB(int rgb) {
    return new SolidBrush(Color.fromRGB(rgb));
  }

  /**
   * Clone brush.
   */
  Brush clone() {
    return new SolidBrush(new Color(_color.argb));
  }
}
