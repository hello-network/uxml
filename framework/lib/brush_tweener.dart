part of uxml;

/**
 * This class implements tweening between two brushes. It can handle tweening
 * between different brush types: i.e., Solid -> Linear, Linear -> Radial
 * etc.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class BrushTweener {

  /** Starting brush for the tween. */
  Brush _startBrush;

  /** Ending brush for the tween. */
  Brush _endBrush;

  /** Brush holding the tween value */
  Brush _tweenBrush;

  /** The current tween value */
  num _tweenValue = 0.0;

  /** The brush used at the start of the tween (0.0) */
  Brush _startTweenBrush;

  /** The brush used at the end of the tween (1.0) */
  Brush _endTweenBrush;

  /** The tween function that calculates the tween. */
  TweenFunction _updateTween;

  /**
   * Constructs the tweener with two brush objects.
   */
  BrushTweener(Brush startBrush, Brush endBrush) {
    // hold on to the start and end brush. we return this for tween values of
    // 0.0 and 1.0 respectively
    _startBrush = startBrush;
    _endBrush = endBrush;
    _setupTweener(_startBrush, _endBrush);
  }

  /**
   * Gets the tweened brush.
   */
  Brush get brush {
    if (_tweenValue == 0.0) {
      return _startBrush;
    }

    if (_tweenValue == 1.0) {
      return _endBrush;
    }

    return _tweenBrush;
  }

  /**
   * Gets or Sets the tween value. This updates the tween brush  to a state
   * between the start brush and end brush depending upon the value passed to
   * the function.
   */
  num get tween => _tweenValue;

  set tween(num value) {
    if (_tweenValue == value) {
      return;
    }
    _tweenValue = value;

    // We don't need to update the tween brush if the value is 0.0 or 1.0.
    if (value == 0.0 || value == 1.0) {
      return;
    }

    // call the tween function to perform the tween
    _updateTween(value);
  }

  /**
   * Sets up the tweener based on the start and end brush types.
   *
   * @param startBrush The brush to convert from.
   * @param endBrush The brush to convert to.
   */
  void _setupTweener(Brush startBrush, Brush endBrush) {
    SolidBrush sb;
    if (startBrush == null) {
      Color color;
      if (endBrush is SolidBrush) {
        sb = endBrush;
        color = Color.fromARGB(sb.color.argb & 0xFFFFFFFF);
      } else {
        color = Color.fromARGB(0xFFFFFF);
      }
      _startBrush = new SolidBrush(color);
    }
    if (endBrush == null) {
      Color endColor;
      if (startBrush is SolidBrush) {
        sb = startBrush;
        endColor = Color.fromARGB(sb.color.argb & 0xFFFFFFFF);
      } else {
        endColor = Color.fromARGB(0xFFFFFF);
      }
      _endBrush = new SolidBrush(endColor);
    }

    if (startBrush == null) {
      Color endColor;
      if (endBrush is SolidBrush) {
        endColor = endBrush.color;
      } else {
        endColor = Color.BLACK;
      }
      Color alphaZero = Color.fromARGB(0x00FFFFFF & endColor.argb);
      startBrush = new SolidBrush(alphaZero);
    }

    if (endBrush == null) {
      Color startColor;
      if (startBrush is SolidBrush) {
        startColor = (endBrush as SolidBrush).color;
      } else {
        startColor = Color.BLACK;
      }
      Color alphaZero = Color.fromARGB(0x00FFFFFF & startColor.argb);
      endBrush = new SolidBrush(alphaZero);
    }

    // Setup an optimal case where both brushes are solid.
    if ((startBrush is SolidBrush) && (endBrush is SolidBrush)) {
      _setupSolidTweener(startBrush, endBrush);
      return;
    }

    // Setup radial brush tweener before linear brush tweener.
    if (startBrush is RadialBrush || endBrush is RadialBrush) {
      _setupRadialTweener(startBrush, endBrush);
      return;
    }

    if (startBrush is LinearBrush || endBrush is LinearBrush) {
      _setupLinearTweener(startBrush, endBrush);
      return;
    }
    throw new Error();
  }

  void _setupSolidTweener(Brush startBrush, Brush endBrush) {
    _startTweenBrush = startBrush.clone();
    _endTweenBrush = endBrush.clone();
    _tweenBrush = _startTweenBrush.clone();
    _updateTween = _tweenSolidBrushes;
  }

  void _setupLinearTweener(Brush startBrush, Brush endBrush) {
    _startTweenBrush = _convertBrushToLinearBrush(startBrush);
    _endTweenBrush = _convertBrushToLinearBrush(endBrush);
    LinearBrush br1 = _startTweenBrush;
    LinearBrush br2 = _endTweenBrush;
    _mergeGradientStops(br1, br2);
    _tweenBrush = _startTweenBrush.clone();
    _updateTween = _tweenLinearBrushes;
  }

  void _setupRadialTweener(Brush startBrush, Brush endBrush) {
    _startTweenBrush = _convertBrushToRadialBrush(startBrush);
    _endTweenBrush = _convertBrushToRadialBrush(endBrush);
    RadialBrush br1 = _startTweenBrush;
    RadialBrush br2 = _endTweenBrush;
    _mergeGradientStops(br1, br2);
    _tweenBrush = _startTweenBrush.clone();
    _updateTween = _tweenRadialBrushes;
  }

  Brush _convertBrushToLinearBrush(Brush brush) {

    // if brush is already linear, we return a copy
    if (brush is LinearBrush) {
      return brush.clone();
    }

    // this brush should only be SolidBrush
    if (brush is SolidBrush) {
      SolidBrush sb = brush;
      return LinearBrush.create(new Coord(0.0, 0.0), new Coord(1.0, 1.0),
          sb.color, sb.color);
    }
    return null;
  }

  Brush _convertBrushToRadialBrush(Brush brush) {
    // if brush is already radial, we return a copy
    if (brush is RadialBrush) {
      return brush.clone();
    }

    if (brush is SolidBrush) {
      SolidBrush br = brush;
      return RadialBrush.create(new Coord(0.0, 0.0),
                                new Coord(1.0, 1.0),
                                new Coord(1.0, 1.0),
                                br.color,
                                br.color);
    }

    if (brush is LinearBrush) {
      LinearBrush lb = brush;
      return RadialBrush.create(lb.start, lb.end, new Coord(1.0, 1.0),
          lb.stops[0].color.clone(), lb.stops[1].color.clone());
    }
    return null;
  }

  void _mergeGradientStops(IGradientBrush startBrush, IGradientBrush endBrush) {
    List<GradientStop> startStops;
    List<GradientStop> endStops;
    GradientStop tmpStop;
    // indexes into startStops and endStops array
    // initialized to a stop after the first stop at 0 offset
    int i = 1;
    int j = 1;

    startStops = startBrush.stops;
    endStops = endBrush.stops;

    // make sure there is a gradient stop at 0.0 and 1.0
    if (startStops[0].offset != 0.0) {
      startStops.insert(0, new GradientStop(startStops[0].color, 0.0));
    }
    if (startStops[startStops.length - 1].offset != 1.0) {
      startStops.add(new GradientStop(
          startStops[startStops.length - 1].color, 1.0));
    }
    if (endStops[0].offset != 0.0) {
      endStops.insert(0, new GradientStop(startStops[0].color, 0.0));
    }
    if (endStops[endStops.length - 1].offset != 1.0) {
      endStops.add(new GradientStop(endStops[endStops.length - 1].color, 1.0));
    }

    GradientStop startStop;
    GradientStop endStop;
    while (i < startStops.length || j < endStops.length) {
      startStop = startStops[i].clone();
      endStop = endStops[j].clone();

      num tweenVal;
      if (startStop.offset < endStop.offset) {

        // compute interpolated color tween for the new gradient offset
        tweenVal = (startStop.offset - endStops[j - 1].offset) /
            (endStops[j].offset - endStops[j - 1].offset);
        TweenUtils.tweenColor(endStops[j - 1].color,
                              endStops[j].color,
                              startStop.color,
                              tweenVal);

        // insert into endstops
        endStops.insert(j, startStop);
      } else if (startStop.offset > endStop.offset) {
        // compute color tween
        tweenVal = (endStop.offset - startStops[i - 1].offset) /
            (startStops[i].offset - startStops[i - 1].offset);
        TweenUtils.tweenColor(startStops[i - 1].color,
                              startStops[i].color,
                              endStop.color,
                              tweenVal);

        // insert into startstops
        startStops.insert(i, endStop);
      }

      // increment the indexes but stop at the end
      if (i < startStops.length) {
        i++;
      }
      if (j < endStops.length) {
        j++;
      }
    }
  }

  num _tweenSolidBrushes(num value) {
    SolidBrush startBr = _startTweenBrush;
    SolidBrush endBr = _endTweenBrush;
    SolidBrush tweenBr = _tweenBrush;
    TweenUtils.tweenColor(startBr.color,
                          endBr.color,
                          tweenBr.color,
                          value);
  }

  num _tweenLinearBrushes(num value) {
    LinearBrush linearStart = _startTweenBrush;
    LinearBrush linearEnd = _endTweenBrush;
    LinearBrush linearBrush = _tweenBrush;

    // tween start
    TweenUtils.tweenPoint(linearStart.start,
                          linearEnd.start,
                          linearBrush.start,
                          value);

    // tween end
    TweenUtils.tweenPoint(linearStart.end, linearEnd.end,
        linearBrush.end, value);

    // tween stops
    for (int i = 0; i < linearBrush.stops.length; i++) {
      _tweenGradientStop(linearStart.stops[i],
                         linearEnd.stops[i],
                         linearBrush.stops[i],
                         value);
    }
  }

  num _tweenRadialBrushes(num value) {
    RadialBrush radialStart = _startTweenBrush;
    RadialBrush radialEnd = _endTweenBrush;
    RadialBrush radialTween = _tweenBrush;
    // tween origin
    TweenUtils.tweenPoint(radialStart.origin,
                          radialEnd.origin,
                          radialTween.origin,
                          value);

    // tween center

    TweenUtils.tweenPoint(radialStart.center,
                          radialEnd.center,
                          radialTween.center,
                          value);

    // tween radius
    TweenUtils.tweenPoint(radialStart.radius,
                          radialEnd.radius,
                          radialTween.radius,
                          value);

    // tween stops
    for (int i = 0; i < radialStart.stops.length; i++) {
      _tweenGradientStop(radialStart.stops[i],
                         radialEnd.stops[i],
                         radialTween.stops[i],
                         value);
    }
  }

  void _tweenGradientStop(GradientStop start,
                         GradientStop end,
                         GradientStop result,
                         num tween) {
    TweenUtils.tweenColor(start.color, end.color, result.color, tween);
    result.offset = TweenUtils.tweenNumber(start.offset,
                                           end.offset,
                                           tween);
  }
}
