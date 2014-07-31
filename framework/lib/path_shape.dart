part of uxml;

/**
 * Defines a geometric shape based on a path.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class PathShape extends Shape {
  static ElementDef pathShapeElementDef;
  /** Svg path data for shape */
  static PropertyDefinition contentProperty;
  static PropertyDefinition nineSliceProperty;

  PathShape() : super();

  /**
   * Gets or sets path of shape
   */
  VecPath get content => getProperty(contentProperty);

  set content(VecPath value) {
    setProperty(contentProperty, value);
  }

  /**
   * Gets or sets margins to use for nine slice of path.
   */
  Margin get nineSlice => getProperty(nineSliceProperty);

  set nineSlice(Margin value) {
    setProperty(nineSliceProperty, value);
  }

  /**
   * Returns size of path as desired size.
   */
  bool onMeasure(num availableWidth, num availableHeight) {
    VecPath path = content;
    if (path == null) {
      setMeasuredDimension(0.0, 0.0);
    } else {
      Rect bounds = path.getBounds();
      // Use ceil since path needs to fit inside canvas area to draw. Otherwise
      // we'll get subpixel clipping near boundary.
      setMeasuredDimension(bounds.width.ceil(), bounds.height.ceil());
    }
    return false;
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    surface.clear();
    int mode = scaleMode;
    VecPath path = content;
    if (path != null) {
      Rect bounds = path.getBounds();
      // Why -bounds.x :
      // If path is a rect -100,-100,200,200 and we place it into a VBOX,
      // -100 needs to be at VBOX 0. So we draw it at -100--100 = 0
      num offsetX = -bounds.x;
      num offsetY = -bounds.y;
      if (mode != ScaleMode.NONE) {
        num boundsWidth = bounds.width.ceil();
        num boundsHeight = bounds.height.ceil();
        num sx = layoutWidth / boundsWidth;
        num sy = layoutHeight / boundsHeight;
        if (mode == ScaleMode.UNIFORM) {
          // Scale uniformly to fill layoutRect
          offsetX *= sx;
          offsetY *= sy;
          if (sx < sy) {
            sy = sx;
            offsetY += (layoutHeight - (boundsHeight * sy)) / 2;
          } else {
            sx = sy;
            offsetX += (layoutWidth - (boundsWidth * sx)) / 2;
          }
        } else if (mode == ScaleMode.FILL) {
          // scale offsets
          offsetX *= sx;
          offsetY *= sy;
        }
        // Fill layoutRect with shape
        UITransform t = new UITransform();
        t.scaleX = sx;
        t.scaleY = sy;
        t.translateX = offsetX;
        t.translateY = offsetY;
        surface.renderTransform = t;
      }
      else {
        UITransform t = new UITransform();
        t.translateX = -bounds.x;
        t.translateY = -bounds.y;
        surface.renderTransform = t;
      }
      surface.drawPath(content, fill, stroke, nineSlice);
      surface.renderTransform = null;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => pathShapeElementDef;

  /** Registers component. */
  static void registerPathShape() {
    contentProperty = ElementRegistry.registerProperty("content",
        PropertyType.OBJECT, PropertyFlags.REDRAW | PropertyFlags.RESIZE,
        null, null);
    nineSliceProperty = ElementRegistry.registerProperty("nineSlice",
        PropertyType.MARGIN, PropertyFlags.REDRAW,
        null, null);
    pathShapeElementDef = ElementRegistry.register("PathShape",
        Shape.shapeElementDef, [contentProperty, nineSliceProperty], null);
  }
}
