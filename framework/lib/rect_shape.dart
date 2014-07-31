part of uxml;

/**
 * Define a rectangular shape.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class RectShape extends Shape {
  static ElementDef rectshapeElementDef;
  /** Border radius property definition */
  static PropertyDefinition borderRadiusProperty;

  RectShape() :super() {
  }

  /**
   * Sets or returns border radius.
   */
  BorderRadius get borderRadius {
    return getProperty(borderRadiusProperty);
  }

  void set borderRadius(BorderRadius value) {
    setProperty(borderRadiusProperty, value);
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    // TODO(ferhat): abstract away the use of setBackground vs drawRect
    // inside ui surfaces instead of redraw.
    bool requiresCanvas = false;
    if (hasFilters) {
      Filters f = filters;
      if (f._innerShadow != null && f._innerShadow.knockout) {
        requiresCanvas = true;
      } else if (f._dropShadow != null && f._dropShadow.knockout) {
        requiresCanvas = true;
      }
    }
    if (stroke != null || requiresCanvas) {
      surface.clear();
      if (fill != null) {
        surface.drawRect(0.0, 0.0, layoutWidth, layoutHeight, fill, stroke,
            borderRadius);
      }
    } else {
      surface.setBorderRadius(borderRadius);
      surface.setBackground(fill);
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => rectshapeElementDef;

  /** Registers component. */
  static void registerRectShape() {
    borderRadiusProperty = ElementRegistry.registerProperty("borderRadius",
        PropertyType.BORDERRADIUS, PropertyFlags.REDRAW, null, null);
    rectshapeElementDef = ElementRegistry.register("RectShape",
        Shape.shapeElementDef, [borderRadiusProperty], null);
  }
}
