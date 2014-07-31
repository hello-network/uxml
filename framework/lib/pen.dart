part of uxml;

/**
 * Provides base class for stroke attributes.
 * Defines thickness of stroke used in rendering lines.
 */
class Pen {
  num _thickness;

  Pen(num thickness) {
    _thickness = thickness;
  }

  /** Returns thickness of pen. */
  num get thickness {
    return _thickness;
  }
}
