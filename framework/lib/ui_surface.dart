part of uxml;

/**
 * Represents a basic 2D surface for rendering and UI input.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
abstract class UISurface {
  /**
   * Sets the target to be called for input events on the surface.
   */
  set target(UISurfaceTarget target);
  UIElement get target;

  /** Adds a child surface. Returns child. */
  UISurface addChild(UISurface child);
  UISurface insertChild(int index, UISurface child);
  bool removeChild(UISurface child);
  void reparentChild(UISurface child, [int index = -1]);

  // Called by child when a host element is created for surface.
  void _hostElementCreated(UISurface surface);
  void _onInitSurface();

  int get childCount;
  UISurface childAt(int index);

  // Sets the location and size of surface relative to parent.
  void setLocation(int targetX, int targetY, int targetWidth, int targetHeight);

  void setBackground(Brush brush);
  void setBorderRadius(BorderRadius border);
  set clipChildren(bool clip);
  /** Delays updates to add multiple children efficiently. */
  void lockUpdates(bool lock);

  int layoutX;
  int layoutY;
  int layoutW;
  int layoutH;
  // Tag is a value attached to the surface to enable platform
  // specific debugging.
  set tag(String value);
  UITransform renderTransform;
  UITransform get surfaceTransform;
  set surfaceTransform(UITransform surfaceTransform);

  /**
   * Clears graphics surface.
   */
  void clear();

  /**
   * Drawing API.
   */
  void drawPath(VecPath path, Brush brush, Pen pen, Margin nineSlice);
  void drawRect(num x, num y, num width, num height,
      Brush brush, Pen pen, BorderRadius borderRadius);
  void drawEllipse(num x, num y, num width, num height, Brush brush, Pen pen);
  void drawLine(Brush brush, Pen pen, num xFrom,num yFrom, num xTo, num yTo);
  void drawBitmap(Object image, num x, num y, num width, num height, bool tile);
  void maskBitmap(Object image, num x, num y, num width, num height, VecPath mask);
  void drawBitmapTransformColor(Object image, num x, num y, num width,
      num height, bool tile, ColorTransform transform);
  void drawImage(String source);

  set hitTestMode(int mode);
  UISurface hitTest(num mouseX, num mouseY);

  UISurface parentSurface;
  Application root;
  bool mouseEnabled;
  bool get enableHitTesting;
  set enableHitTesting(bool);
  bool get enableChildHitTesting;
  set enableChildHitTesting(bool);
  set opacity(num value);
  set visible(bool value);
  bool get visible;
  bool get hasTransform;
  void applyFilters(Filters filters);
  bool setupTopLevelCursor(Cursor cursor);
  void cursorChanged(Cursor cursor);
  void close();
}

abstract class UITextSurface extends UISurface {
  set text(String value);
  set htmlText(String value);
  set wordWrap(bool value);
  set textAlign(int value);
  set visible(bool value);
  set enableHitTesting(bool value);
  set fontName(String value);
  set fontSize(num value);
  set fontBold(bool value);
  set textColor(Color value);
  set onTextLink(EventHandler handler);
  void measureText(String text, num availWidth, num availHeight,
      bool sizeToBold);
  set selectable(bool value);
  void updateTextView();
  int measuredWidth = 0;
  int measuredHeight = 0;
}

abstract class UIEditSurface extends UISurface {
  set text(String value);
  set htmlText(String value);
  set multiline(bool value);
  set wordWrap(bool value);
  set visible(bool value);
  set enableHitTesting(bool value);
  void enableMouseEvents(bool val);
  set fontName(String value);
  set fontSize(num value);
  set fontBold(bool value);
  set textColor(Color value);
  set onTextLink(EventHandler handler);
  void measureText(String text, num availWidth, num availHeight);
  set promptMessage(String prompt);
  set maxChars(int length);
  void initFocus(bool selectAll);
  void focusChanged(bool isFocused);
  int measuredWidth;
  int measuredHeight;
}
