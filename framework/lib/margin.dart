part of uxml;

/**
 * This class represents elements margins and holds the size of its four
 * sides.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Margin {
  /** Empty margins */
  static Margin EMPTY;

  /** Sets or returns left margin value */
  num left = 0.0;

  /** Sets or returns top margin value */
  num top = 0.0;

  /** Sets or returns right margin value */
  num right = 0.0;

  /** Sets or returns bottom margin value */
  num bottom = 0.0;

  /**
   * Constructs an immutable rectangle object with optional initialization
   * of its origin and size.
   */
  Margin(this.left, this.top, this.right, this.bottom) {
  }

  /**
   * Constructs margin object with four equals margins.
   */
  Margin.uniform(num size) {
    left = size;
    top = size;
    right = size;
    bottom = size;
  }

  /**
   * Constructs margin object with top and left margins.
   */
  Margin.topLeft(this.top, this.left) {
  }

  /**
   * Checks equality.
   */
  bool equals(Margin compareMargin) {
    return (compareMargin.left == left) &&
        (compareMargin.top == top) &&
        (compareMargin.right == right) &&
        (compareMargin.bottom == bottom);
   }

  /**
   * Grows a rectangle by margin amount.
   */
  Rect grow(Rect rect) {
    return new Rect(rect.x, rect.y, rect.width + left + right,
        rect.height + top + bottom);
  }

  /**
   * Shrinks a rectangle by margin amount.
   */
  Rect shrink(Rect rect) {
    return new Rect(rect.x, rect.y, rect.width - left - right,
        rect.height - top - bottom);
  }

  /**
   * Inflates a rectangle by margin amount.
   */
  Rect inflate(Rect rect) {
    return new Rect(rect.x - left, rect.y - top, rect.width +
        left + right, rect.height + top + bottom);
  }

  /**
   * Deflates a rectangle by margin amount.
   */
  Rect deflate(Rect rect) {
    return new Rect(rect.x + left, rect.y + top, rect.width -
        left - right, rect.height - top - bottom);
  }

  /**
   * Clones object.
   */
  Margin clone() {
    return new Margin(left, top, right, bottom);
  }

  static void initialize() {
    EMPTY = new Margin(0.0, 0.0, 0.0, 0.0);
  }
}
