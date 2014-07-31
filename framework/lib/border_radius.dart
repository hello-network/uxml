part of uxml;

/**
 * This class represents immutable border radius for a control.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class BorderRadius {
  /** Empty radius */
  static BorderRadius EMPTY;

  /** Sets or returns left top radius value */
  num topLeft;

  /** Sets or returns right top value */
  num topRight;

  /** Sets or returns bottom right value */
  num bottomRight;

  /** Sets or returns bottom left value */
  num bottomLeft;


  /**
   * Constructs an immutable border radius.
   */
  BorderRadius(this.topLeft, this.topRight, this.bottomRight, this.bottomLeft);

  /**
   * Constructs corner radius four equals radii.
   */
  BorderRadius.uniform(num size) {
    topLeft = size;
    topRight = size;
    bottomLeft = size;
    bottomRight = size;
  }

  /**
   * Checks equality.
   */
  bool equals(BorderRadius value) {
    return (value.topLeft == topLeft) &&
        (value.topRight == topRight) &&
        (value.bottomLeft == bottomLeft) &&
        (value.bottomRight == bottomRight);
  }

  /**
   * Returns true if all edges have same radius.
   */
  bool isUniform() {
    return (topLeft == topRight) && (bottomLeft == bottomRight) &&
        (topLeft == bottomLeft);
  }

  static void initialize() {
    EMPTY = new BorderRadius.uniform(0.0);
  }
}
