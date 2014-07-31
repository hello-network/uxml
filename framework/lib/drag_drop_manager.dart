part of uxml;

/**
 * Manages event routing for drag & drop operation.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class DragDropManager {

  bool _dragActive = false;
  ClipboardData _sourceData;
  UIElement _sourceElement;
  UIElement _moveOverlay;
  Coord _dragOffset;
  num DRAG_DROP_OPACITY = 0.5;
  static Map<UIElement, UIElement> dropIndicators;

  /**
   * Holds drag event argument.
   */
  DragEventArgs mouseEventArgs;

  DragDropManager() {
    mouseEventArgs = new DragEventArgs();
    dropIndicators = new Map<UIElement, UIElement>();
  }

  /**
   * Starts drag & drop.
   *
   * @param source Item to start dragging.
   * @param data Data to drop to target.
   * @param moveElementImage will show source element as image during drag.
   */
  void startDragDrop(UIElement source,
                     ClipboardData data,
                     bool moveElementImage) {
    _sourceElement = source;
    _sourceData = data;
    _dragActive = true;
    mouseEventArgs.dragSource = source;
    mouseEventArgs.data = data;
    if (moveElementImage && _sourceElement.hostSurface != null) {
      Image image = new Image();
      image.source = createBitmapFromElement(_sourceElement);
      image.opacity = DRAG_DROP_OPACITY;
      _moveOverlay = image;
      UIElement parent = Application.current.content;
      Coord p = Application.current.getMousePosition(parent);
      _dragOffset = Application.current.getMouseDownPosition(_sourceElement);
      _moveOverlay.transform.translateX = p.x - _dragOffset.x;
      _moveOverlay.transform.translateY = p.y - _dragOffset.y;
      _moveOverlay.mouseEnabled = false;
      DropShadowFilter dropShadow = new DropShadowFilter();
      dropShadow.blurX = 8;
      dropShadow.blurY = 8;
      dropShadow.strength = 0.3;
      _moveOverlay.filters.add(dropShadow);
      parent.addOverlay(_moveOverlay, true);
    }
  }

  static Object createBitmapFromElement(UIElement element) {
    // TODO(ferhat): render element tree to bitmap.
    //    BitmapData bitmapData = new BitmapData(element.layoutRectangle.width,
    //        element.layoutRectangle.height, true, 0x000000);
    //    bitmapData.draw(element.hostSurface as IBitmapDrawable);
    //    return bitmapData;
    return null;
  }

  /**
   * Returns true if drag&drop operation is in progress.
   */
  bool get busy => _dragActive;

  /**
   * Translates mouse event to drag&drop event.
   */
  void routeEvent(DragEventArgs mouseArgs) {
    UIElement target = mouseArgs.source;
    if (mouseArgs.event == UIElement.mouseEnterEvent) {
      mouseArgs.event = UIElement.dragEnterEvent;
    }
    if (mouseArgs.event == UIElement.mouseExitEvent) {
      mouseArgs.event = UIElement.dragLeaveEvent;
    }
    if (mouseArgs.event == UIElement.mouseMoveEvent) {
      mouseArgs.event = UIElement.dragOverEvent;
      if (_moveOverlay != null) {
        Coord p = mouseArgs.getMousePosition(_moveOverlay.parent);
        _moveOverlay.transform.translateX = p.x - _dragOffset.x;
        _moveOverlay.transform.translateY = p.y - _dragOffset.y;
      }
    }
    if (mouseArgs.event == UIElement.mouseUpEvent) {
      if (_moveOverlay != null) {
        Application.current.content.removeOverlay(_moveOverlay);
        _moveOverlay = null;
      }
      _sourceElement.releaseMouse();
      mouseArgs.event = UIElement.dragEndEvent;
      mouseArgs.handled = false;
      _sourceElement.routeEvent(mouseArgs);
      mouseArgs.event = UIElement.dropEvent;
      mouseArgs.handled = false;
      _dragActive = false;
    }
    target.routeEvent(mouseArgs);
  }

  /**
   * Shows outline overlay around drop area for an element.
   */
  static void showDropIndicator(UIElement targetElement, bool show) {
    if (dropIndicators[targetElement] != null) {
      targetElement.removeOverlay(dropIndicators[targetElement]);
      dropIndicators[targetElement] = null;
    }
    if (show) {
      UIElement overlay = createIndicator(targetElement);
      dropIndicators[targetElement] = overlay;
      targetElement.addOverlay(overlay, true);
    }
  }

  static UIElement createIndicator(UIElement targetElement) {
    Object res = targetElement.findResource("focusRingColor");
    Color focusColor = ((res != null) && (res is Color)) ?
        res : Color.fromRGB(0x66b3e1);
    Group group = new Group();
    RectShape blackRect= new RectShape();
    BorderRadius borderRadius;
    if (targetElement.overridesProperty(Control.borderRadiusProperty)) {
      borderRadius = targetElement.getProperty(Control.borderRadiusProperty);
    } else {
      borderRadius = new BorderRadius.uniform(4.0);
    }
    blackRect.borderRadius = borderRadius;
    blackRect.stroke = new SolidPen(focusColor, 2.0);
    blackRect.margins = new Margin(-2, -2, -2, -2);
    group.addChild(blackRect);
    RectShape glowRect = new RectShape();
    glowRect.borderRadius = new BorderRadius.uniform(4.0);
    glowRect.stroke = new SolidPen(focusColor, 2.0);
    glowRect.mouseEnabled = false;
    GlowFilter glowFilter = new GlowFilter();
    glowFilter.blurX = 8.0;
    glowFilter.blurY = 8.0;
    glowFilter.strength = 0.4;
    glowFilter.color = focusColor;
    glowFilter.knockout = true;
    glowRect.filters.add(glowFilter);
    glowRect.margins = new Margin(-2, -2, -2, -2);
    group.addChild(glowRect);
    group.mouseEnabled = false;
    return group;
  }
}
