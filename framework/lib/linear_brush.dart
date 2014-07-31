part of uxml;

abstract class IGradientBrush {
  void addStop(GradientStop stop);
  List<GradientStop> get stops;
}

/**
 * This class represents a brush with a linear color gradient.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class LinearBrush extends Brush implements IGradientBrush {

  static Coord DEFAULT_START_POINT = null;
  static Coord DEFAULT_END_POINT = null;

  /** list of gradient stops */
  List<GradientStop> _stops;

  /**
   * Sets/returns start point of gradient.
   *
   * The gradient box is 0,0 to 1.0,1.0.
   */
  Coord start;

  /**
   * Sets/returns the end point of gradient.
   *
   * The gradient box is 0,0 o 1.0,1.0.
   */
  Coord end;

  LinearBrush() : super() {
    _type = 1;
    _stops = <GradientStop>[];
    if (DEFAULT_START_POINT == null) {
      DEFAULT_START_POINT = new Coord(0.0, 0.0);
      DEFAULT_END_POINT = new Coord(0.0, 1.0);
    }
    start = DEFAULT_START_POINT;
    end = DEFAULT_END_POINT;
  }

  static LinearBrush fromColors(Color color1, Color color2) {
    LinearBrush br = new LinearBrush();
    br._stops.add(new GradientStop(color1, 0.0));
    br._stops.add(new GradientStop(color2, 1.0));
    return br;
  }

  static LinearBrush create(Coord startP,
                            Coord endP,
                            Color color1,
                            Color color2) {
    LinearBrush br = new LinearBrush();
    br.start = startP;
    br.end = endP;
    br._stops.add(new GradientStop(color1, 0.0));
    br._stops.add(new GradientStop(color2, 1.0));
    return br;
  }

  /**
   * Adds a gradient stop to the brush.
   */
  void addStop(GradientStop stop) {
    _stops.add(stop);
  }

  /**
   * Returns a list of gradient stops.
   */
  List<GradientStop> get stops => _stops;

  Brush clone() {
    LinearBrush cl = new LinearBrush();
    cl.start = new Coord(start.x, start.y);
    cl.end = new Coord(end.x, end.y);
    for (int i = 0; i < _stops.length; i++) {
      cl.addStop(new GradientStop(new Color(_stops[i].color.argb),
          _stops[i].offset));
    }
    return cl;
  }
}
