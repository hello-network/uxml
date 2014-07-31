part of uxml;

class UxmlUtils {
  /**
   * Tests whether the two values are equal to each other, within a certain
   * tolerance to adjust for floating point errors.
   * The optional [tolerance] value d Defaults to 0.000001. If specified,
   * it should be greater than 0.
   * Returns whether [a] and [b] are nearly equal.
   */
  static bool nearlyEquals(num a, num b, [num tolerance = 0.000001]) {
    return (a - b).abs() <= tolerance;
  }

  static final num PI2 = 1.57079632679489661923; // pi/2
}
