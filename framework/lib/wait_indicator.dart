part of uxml;

/**
 * Creates an animated spinner for handling ui for syncronous http requests.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class WaitIndicator extends ProgressControl {
  static ElementDef waitIndicatorElementDef;
  /** Color property definition */
  static PropertyDefinition colorProperty;

  static const int SLICE_COUNT = 12;
  // Amount of gap between slices.
  static const num SLICE_GAP_FACTOR = 0.2;
  // inner radius/outer radius
  static const num INNER_RADIUS_FACTOR = 0.7;
  static const int DEFAULT_START_DELAY_MS = 250;
  static const int FULL_ROTATION_TIME_MS = 1000;
  int _animIndex;


  WaitIndicator() : super() {
    steps = SLICE_COUNT;
    cycleTime = FULL_ROTATION_TIME_MS;
    cycleDelay = DEFAULT_START_DELAY_MS;
    _animIndex = 0;
  }

  /**
   * Sets or returns color if indicator.
   */
  Color get color {
    return getProperty(colorProperty);
  }

  set color(Color value) {
    setProperty(colorProperty, value);
  }

  /** Overrides ProgressControl.onValueChanged. */
  void onValueChanged(num newValue) {
    super.onValueChanged(newValue);
    ++_animIndex;
    invalidateDrawing();
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    surface.clear();
    if ((cycle == false) || (isAnimating == false)) {
      return;
    }

    num angleStep = 360.0 / SLICE_COUNT;
    num arcGapSweep = angleStep * SLICE_GAP_FACTOR;
    num arcSweep = angleStep - arcGapSweep;
    num centerX = layoutWidth / 2;
    num centerY = layoutHeight / 2;
    num outerRadius = min(layoutWidth, layoutHeight) / 2;
    num innerRadius = outerRadius * INNER_RADIUS_FACTOR;
    int sliceIndex = 0;
    for (num angle = 0.0; angle < 360.0; angle += angleStep) {
      num cosStart = cos((angle - (arcSweep / 2)) * PI / 180.0);
      num sinStart = sin((angle - (arcSweep / 2)) * PI / 180.0);
      num cosEnd = cos((angle + (arcSweep / 2)) * PI / 180.0);
      num sinEnd = sin((angle + (arcSweep / 2)) * PI / 180.0);
      num p1x = centerX + (cosStart * outerRadius);
      num p1y = centerY + (sinStart * outerRadius);
      num p2x = centerX + (cosEnd * outerRadius);
      num p2y = centerY + (sinEnd * outerRadius);
      num p3x = centerX + (cosEnd * innerRadius);
      num p3y = centerY + (sinEnd * innerRadius);
      num p4x = centerX + (cosStart * innerRadius);
      num p4y = centerY + (sinStart * innerRadius);
      VecPath path = new VecPath();
      path.moveTo(p1x, p1y);
      path.lineTo(p2x, p2y);
      path.lineTo(p3x, p3y);
      path.lineTo(p4x, p4y);
      path.lineTo(p1x, p1y);
      int alpha = 128;
      for (int i = 0; i < 4; ++i) {
        if (sliceIndex == (_animIndex + i) % SLICE_COUNT) {
          alpha = 255 - ((3 - i) * 25);
          break;
        }
      }
      Color sliceColor = Color.fromARGB(((alpha * color.A ~/ 255) << 24) |
          color.rgb);
      surface.drawPath(path, new SolidBrush(sliceColor), null, null);
      ++sliceIndex;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => waitIndicatorElementDef;

  /** Registers component. */
  static void registerWaitIndicator() {
    colorProperty = ElementRegistry.registerProperty("Color",
        PropertyType.COLOR, PropertyFlags.REDRAW, null,
        Color.fromRGB(0xFFFFFF));
    waitIndicatorElementDef = ElementRegistry.register("WaitIndicator",
        ProgressControl.progresscontrolElementDef, [colorProperty], null);
  }
}
