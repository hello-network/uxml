part of uxml;

/**
 * Define a line shape.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class LineShape extends Shape {
  static ElementDef lineShapeElementDef;
  /** Start X coordinate property definition */
  static PropertyDefinition xFromProperty;
  /** Start Y coordinate property definition */
  static PropertyDefinition yFromProperty;
  /** End X coordinate property definition */
  static PropertyDefinition xToProperty;
  /** End Y coordinate property definition */
  static PropertyDefinition yToProperty;
  /**
   * Constructor.
   */
  LineShape() : super() {
  }

  /** Sets or returns start x coordinate */
  num get xFrom => getProperty(xFromProperty);

  set xFrom(num value) {
    setProperty(xFromProperty, value);
  }

  /** Sets or returns  start y coordinate */
  num get yFrom => getProperty(yFromProperty);

  set yFrom(num value) {
    setProperty(yFromProperty, value);
  }

  /** Sets or returns  end x coordinate */
  num get xTo => getProperty(xToProperty);

  set xTo(num value) {
    setProperty(xToProperty, value);
  }

  /** Sets or returns  end y coordinate */
  num get yTo => getProperty(yToProperty);

  set yTo(num value) {
    setProperty(yToProperty, value);
  }

  /**
   * Overrides UIElement.onMeasure to return size of path.
   */
  bool onMeasure(num availableWidth, num availableHeight) {
    setMeasuredDimension((xFrom - xTo).abs(), (yFrom - yTo).abs());
    return false;
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    surface.clear();
    surface.drawLine(fill, stroke, xFrom, yFrom, xTo, yTo);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => lineShapeElementDef;

  /** Registers component. */
  static void registerLineShape() {
    xFromProperty = ElementRegistry.registerProperty("XFrom",
        PropertyType.NUMBER, PropertyFlags.REDRAW | PropertyFlags.RESIZE, null,
        0.0);
    yFromProperty = ElementRegistry.registerProperty("YFrom",
        PropertyType.NUMBER, PropertyFlags.REDRAW | PropertyFlags.RESIZE, null,
        0.0);
    xToProperty = ElementRegistry.registerProperty("XTo",
        PropertyType.NUMBER, PropertyFlags.REDRAW | PropertyFlags.RESIZE, null,
        0.0);
    yToProperty = ElementRegistry.registerProperty("YTo",
        PropertyType.NUMBER, PropertyFlags.REDRAW | PropertyFlags.RESIZE, null,
        0.0);
    lineShapeElementDef = ElementRegistry.register("LineShape",
        Shape.shapeElementDef, [xFromProperty, yFromProperty,
        xToProperty, yToProperty], null);
  }
}
