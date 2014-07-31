part of uxml;

/**
 * This class represents coordinates of a mutable Rectangle.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class Rect {

  /** Left coordinate of rectangle */
  num x;

  /** Top coordinate of rectangle */
  num y;

  /** Width of rectangle */
  num width;

  /** Height of rectangle */
  num height;

  /**
   * Constructs a rectangle object with optional initialization of its origin
   * and size.
   */
  Rect(this.x, this.y, this.width, this.height);

  /**
   * Returns bottom of rectangle
   */
  num get bottom => y + height;

  /**
   * Returns right coordinate of rectangle
   */
  num get right => x + width;

  /** Returns true if rectangles are equal. */
  bool equals(Rect compareRect) {
    return (compareRect.width == width) &&
        (compareRect.height == height) &&
        (compareRect.x == x) && (compareRect.y == y);
   }


  /**
   * Grow rectangle to include point P.
   */
  void add(num px, num py) {
    if (px < x) {
      width += x - px;
      x = px;
    }
    if (py < y) {
      height += y - py;
      y = py;
    }
    if (px > (x + width)) {
      width = px - x;
    }
    if (py > (y + height)) {
      height = py - y;
    }
  }

  /**
   * Grow rectangle to fit union.
   */
  void addRect(Rect unionRect) {
    width = max(width, unionRect.right - x);
    height = max(height, unionRect.bottom - y);
    x = min(x, unionRect.x);
    y = min(y, unionRect.y);
  }

  /**
   * Returns union of two rectangles
   */
  Rect union(Rect unionRect) {
      num left = min(x, unionRect.x);
      num top = min(y, unionRect.y);
      return new Rect(left, top,
          max(right - left, unionRect.right - left),
          max(bottom - top, unionRect.bottom - top));
  }

  /**
   * Returns true if point is within rectangle.
   */
  bool containsPoint(num px, num py) {
    return (px >= x) && (px < (x + width)) &&
        (py >= y) && (py < (y + height));
  }

  String toString() {
    return "rect($x,$y,$width,$height)";
  }
}

