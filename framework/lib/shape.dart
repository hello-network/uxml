part of uxml;

/**
 * Base class for drawings.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Shape extends UIElement {
  static PropertyDefinition fillProperty;
  static PropertyDefinition strokeProperty;
  static PropertyDefinition scaleModeProperty;
  static ElementDef shapeElementDef;

  Shape() : super() {
  }

  /** Sets or returns fill brush */
  Brush get fill {
    return getProperty(fillProperty);
  }

  set fill(Brush value) {
    setProperty(fillProperty, value);
  }

  /** Sets or returns pen to use for stroke */
  Pen get stroke {
    return getProperty(strokeProperty);
  }

  set stroke(Pen value) {
    setProperty(strokeProperty, value);
  }

  /** Sets or returns scaling mode for shape */
  int get scaleMode {
    return getProperty(scaleModeProperty);
  }

  set scaleMode(int mode) {
    setProperty(scaleModeProperty, mode);
  }

  /**
   * Returns size of shape as desired size.
   */
  bool onMeasure(num availableWidth, num availableHeight) {
    setMeasuredDimension((_layoutFlags &
        UIElement._LAYOUTFLAG_WIDTH_CONSTRAINT) != 0 ? width : 0.0,
        (_layoutFlags & UIElement._LAYOUTFLAG_HEIGHT_CONSTRAINT) != 0 ?
        height : 0.0);
    return false;
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => shapeElementDef;

  /** Registers component. */
  static void registerShape() {
    fillProperty = ElementRegistry.registerProperty("fill",
        PropertyType.BRUSH, PropertyFlags.REDRAW, null, null);
    strokeProperty = ElementRegistry.registerProperty("stroke",
        PropertyType.PEN, PropertyFlags.REDRAW, null, null);
    scaleModeProperty = ElementRegistry.registerProperty("scaleMode",
        PropertyType.SCALEMODE, PropertyFlags.REDRAW, null, ScaleMode.NONE);
    shapeElementDef = ElementRegistry.register("Shape", UIElement.elementDef,
        [fillProperty, strokeProperty, scaleModeProperty], null);
  }
}

/** Provides constants for path and image scaling modes. */
abstract class ScaleMode {
  /** Scale mode for unscaled content */
  static const int NONE = 0;
  /** Scale mode for shape that fills layout rectangle */
  static const int FILL = 1;
  /** Scale mode for shape that scales up to layout but keeps aspect ratio*/
  static const int UNIFORM = 2;
  /** Scale mode for shape that fills layout but keeps aspect ratio*/
  static const int ZOOM = 3;
  /**
   * Scale mode for shape that fills layout but keeps aspect ratio and prevents
   * images from upscaling.
   */
  static const int ZOOM_OUT = 4;
}
