part of uxml;

/**
 * This class represents a brush with a radial color gradient.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class RadialBrush extends Brush implements IGradientBrush {

  /**
   * Sufficiently small number
   */
  static const num EPSILON = 0.00000001;

  /**
   * Standard flash gradient matrix scalars
   */
  static const int GRADIENT_MATRIX_SCALE = 0x4000;
  static const int UNITS_PER_PIXEL = 20;

  static Coord _DEFAULT_CONFIG_POINT = null;

  /**
   * The location of the focal point that defines the start of the gradient.
   * The value can range from (0,0) to (1-1), (0.5,0.5) is the default.
   */
  Coord _origin;

  /**
   * The center of the outermost circle of the radial gradient. The value can
   * range from (0,0) - (1,1), (0.5,0.5) being the default center.
   */
  Coord _center;

  /**
   * The radius of the outermost circle of the radial gradient. The value can
   * range from (0,0) - (1,1), (0.5,0.5) being the default radius.
   */
  Coord _radius;

  /**
   * Array of GradientStop objects.
   */
  List<GradientStop> _stops;

  /**
   * Transformation matrix for gradient.
   */
  Matrix _transform = null;

  /**
   * Construct an empty radial gradient.
   */
  RadialBrush() : super() {
    _type = 2;
    if (_DEFAULT_CONFIG_POINT == null) {
      _DEFAULT_CONFIG_POINT = new Coord(0.5, 0.5);
    }
    _origin = _DEFAULT_CONFIG_POINT;
    _center = _DEFAULT_CONFIG_POINT;
    _radius = _DEFAULT_CONFIG_POINT;
    _stops = <GradientStop>[];
  }

  /**
   * Constructs a radial gradient brush with optional start and end points
   * with gradient stops.
   */
  static RadialBrush create(Coord origin,
                            Coord center,
                            Coord radius,
                            Color startColor,
                            Color endColor) {
    RadialBrush newBrush = new RadialBrush();
    newBrush._origin = (origin != null ? origin : _DEFAULT_CONFIG_POINT);
    newBrush._center = (center != null ? center : _DEFAULT_CONFIG_POINT);
    newBrush._radius = (radius != null ? radius : _DEFAULT_CONFIG_POINT);
    newBrush._stops = [new GradientStop(startColor, 0.0),
                       new GradientStop(endColor, 1.0)];
    return newBrush;
  }

  /**
   * Gets or sets the location of the focal point that defines the start of
   * the gradient.
   */
  Coord get origin {
    return _origin;
  }

  set origin(Coord value) {
    _origin = value;
  }

  /**
   * Gets or sets the center of the outermost circle of the radial gradient.
   */
  Coord get center {
    return _center;
  }

  set center(Coord value) {
    _center = value;
  }

  /**
   * Gets or sets the radius of the outermost circle of the radial gradient.
   */
  Coord get radius {
    return _radius;
  }

  set radius(Coord value) {
    _radius = value;
  }

  /**
   * Gets or sets the array of GradientStop objects.
   */
  List<GradientStop> get stops {
    return _stops;
  }

  set stops(List<GradientStop> value) {
    _stops = value;
  }

  /**
   * Add gradient stop.
   */
  void addStop(GradientStop stop) {
    _stops.add(stop);
  }

  /**
   * Gets or sets the gradient transform.
   */
  Matrix get transform {
    return _transform;
  }

  set transform(Matrix value) {
    _transform = value;
  }

  /**
   * Creates a new brush that is the clone of this brush.
   */
  Brush clone() {
    List<GradientStop> clonedStops = <GradientStop>[];
    for (int i = 0; i < _stops.length; i++) {
      clonedStops.add(_stops[i].clone());
    }
    RadialBrush radialBrush = RadialBrush.create(
        new Coord(_origin.x, _origin.y),
        new Coord(_center.x, _center.y),
        new Coord(_radius.x, _radius.y), null, null);
    radialBrush._stops = clonedStops;
    if (_transform != null) {
      radialBrush._transform = _transform.clone();
    }
    return radialBrush;
  }
}
