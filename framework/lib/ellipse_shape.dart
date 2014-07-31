part of uxml;

/**
 * Defines an elliptical shape.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class EllipseShape extends Shape {

  static ElementDef ellipseElementDef;

  EllipseShape() : super() {
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    surface.clear();
    if (fill != null || stroke != null) {
      surface.drawEllipse(0.0, 0.0, layoutWidth, layoutHeight, fill, stroke);
    }
  }

  /** Registers component. */
  static void registerEllipseShape() {
    ellipseElementDef = ElementRegistry.register("EllipseShape",
        Shape.shapeElementDef, null, null);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => ellipseElementDef;
}
