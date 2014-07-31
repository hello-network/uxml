part of uxml;

/**
 * Base class for all brush types.
 */
class Brush extends UxmlElement {
  int _type;
  static final _BRUSH_TYPE_SOLID = 0;
  static final _BRUSH_TYPE_LINEAR = 1;
  static final _BRUSH_TYPE_RADIAL = 2;

  Brush() : super ();

  Brush clone() => null;
}
