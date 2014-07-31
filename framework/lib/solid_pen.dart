part of uxml;

/**
 * This class represents a pen with one solid color.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class SolidPen extends Pen {

  /** The color of the brush. */
  Color _color;

  /**
   * Constructs a solid color brush.
   */
  SolidPen(Color color, num thickness) : super(thickness) {
    _color = (color == null ? Color.BLACK : color);
  }

  /**
   * Gets or sets the color value.
   */
  Color get color {
    return _color;
  }

  set color(Color value) {
    if (value == null) {
      throw new ArgumentError("Invalid color value");
    }
    _color = value;
  }

  /**
   * Creates a new pen that is the clone of this pen.
   */
  Pen clone() {
    return new SolidPen(color, _thickness);
  }
}
