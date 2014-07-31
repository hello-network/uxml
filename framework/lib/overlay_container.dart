part of uxml;

/**
 * Implements a container for element overlays.
 *
 * The overlaid items live on top of the contained element and are moved
 * in sync with the source element.
 * UIElement.getOverlayContainer returns this container to host overlays.
 * Tooltips and transient popups are implemented using overlay system.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class OverlayContainer extends ContentContainer {

  static ElementDef overlayElementDef;
  static PropertyDefinition locProperty;
  static PropertyDefinition finalLocationProperty;
  // When an overlay doesn't fit on screen, it is contraint to
  // screen size - SAFETY_MARGIN.
  static const num _SAFETY_MARGIN = 5;

  /**
   * Host for overlays.
   */
  Canvas _host = null;

  // Maps targetElement to overlay list for that element.
  Map<UIElement, _OverlayList> _overlayMap = null;

  // Maps an overlay to it's autoresize flag.
  Map<UIElement, bool> _overlayNeedsResize;

  // Maps an element to targetElement array listening to layout changes
  Map<UIElement, _WatchList> _layoutWatchList;

  OverlayContainer() : super() {
    _host = new Canvas();
    insertRawChild(_host, -1);
  }

  /** @see UIElement.getRawChildCount */
  int getRawChildCount() {
    return ((_cachedContent != null) || (chromeTree != null)) ? 2 : 1;
  }

  /** @see UIElement.getRawChild */
  UIElement getRawChild(int index) {
    if (index > 1) {
      return null;
    }
    if (index == 0) {
      if (chromeTree != null) {
        return chromeTree;
      } else if (_cachedContent != null) {
        return _cachedContent;
      }
    }
    return _host;
  }

  /** @see UIElement.initSurface */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    _host._hostSurface.enableHitTesting = false;
    _host._hostSurface.enableChildHitTesting = true;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    super.onLayout(targetX, targetY, targetWidth, targetHeight);
    // Overlaycontainer doesn't participate in onMeasure step since overlay is
    // same size as the container. Therefore we measure and layout in single
    // step.
    _host.measure(targetWidth, targetHeight);
    _host.layout(0.0, 0.0, targetWidth, targetHeight);
  }

  /** Sets or returns location of child. */
  int _getChildLocation(UIElement element) {
    return element.getProperty(OverlayContainer.locProperty);
  }

  void _setChildLocation(UIElement element, int location) {
    element.setProperty(OverlayContainer.locProperty, location);
  }

  /**
   * Returns final location after overlay element layout is completed.
   */
  int getChildFinalLocation(UIElement element) {
    return element.getProperty(OverlayContainer.finalLocationProperty);
  }

  void _setChildFinalLocation(UIElement element, int loc) {
    element.setProperty(OverlayContainer.finalLocationProperty, loc);
  }

  OverlayContainer get overlayContainer => this;

  /**
   * Adds overlay element.
   */
  void add(UIElement targetElement,
           UIElement overlay,
           bool autoResize,
           int location) {
    _OverlayList overlayList = null;
    if (_overlayMap == null) {
      _overlayMap = new Map<UIElement, _OverlayList>();
      _overlayNeedsResize = new Map<UIElement, bool>();
      _layoutWatchList = new Map<UIElement, _WatchList>();
    } else {
      overlayList = _overlayMap[targetElement];
    }
    if (overlayList == null) {
      overlayList = new _OverlayList(targetElement);
      _overlayMap[targetElement] = overlayList;
    }
    overlayList.overlays.add(overlay);
    if (autoResize) {
      _overlayNeedsResize[overlay] = true;
    }
    _setChildLocation(overlay, location);
    _addWatchLayout(targetElement, targetElement, autoResize);
    UIElement parentOfTarget = targetElement.visualParent;
    while ((parentOfTarget != this) && (parentOfTarget != null)) {
      _addWatchLayout(parentOfTarget, targetElement, autoResize);
      parentOfTarget = parentOfTarget.visualParent;
    }

    // TargetElement.visible is in sync with overlay.visible. We watch
    // changes and sync since they have different parents. So at this point
    // overlay.visible should be set to targetElement.visible.
    overlay.visible = targetElement.visible;

    // internalOverlayChild allows addChild without changing logical parent.
    _host._internalOverlayChild(overlay, targetElement);
    overlay.measure(targetElement.layoutWidth, targetElement.layoutHeight);
    Coord containerPos = localToScreen(new Coord(0.0, 0.0));
    Coord targetPos = targetElement.localToScreen(new Coord(0.0, 0.0));
    targetPos.x -= containerPos.x;
    targetPos.y -= containerPos.y;
    _updateElementPosition(targetElement, overlay, containerPos, targetPos,
        true);
    _host.invalidateLayoutForChild(targetElement);
  }

  /**
   * Removes overlay element.
   */
  void remove(UIElement targetElement, UIElement overlay) {
    overlay.setProperty(finalLocationProperty, OverlayLocation.DEFAULT);
    _host.removeChild(overlay);
    _OverlayList overlayList = _overlayMap[targetElement];
    if (overlayList == null || overlayList.hasOverlays == false) return;
    int index = overlayList.overlays.indexOf(overlay, 0);
    if (index != -1) {
      overlayList.overlays.removeAt(index);
      if (!overlayList.hasOverlays) {
        _removeWatchLayout(targetElement, targetElement);
        UIElement parentOfTarget = targetElement.visualParent;
        while ((parentOfTarget != this) && (parentOfTarget != null)) {
          _removeWatchLayout(parentOfTarget, targetElement);
          parentOfTarget = parentOfTarget.visualParent;
        }
      }
    }
  }

  /**
   * Returns or lazily instantiates the layout watchlist of an element.
   */
  _WatchList _watchListOf(UIElement element) {
    _WatchList watchList = _layoutWatchList[element];
    if (watchList == null) {
      watchList = new _WatchList(element);
      _layoutWatchList[element] = watchList;
    }
    return watchList;
  }

  void _addWatchLayout(UIElement element, UIElement targetElement,
      bool resize) {
    _WatchList watchList = _watchListOf(element);

    // If this is a fresh new watchlist, add listener to layout changes
    if (watchList.sizeHandler == null) {
      watchList.sizeHandler = _targetElementLayoutAndSizeChanged;
      element.addListener(UIElement.layoutChangedEvent, watchList.sizeHandler);
      watchList.transformHandler = _targetElementLayoutChanged;
      element.addListener(UIElement.transformChangedEvent,
          watchList.transformHandler);
      watchList.visibilityHandler = _targetVisibilityChanged;
      element.addListener(UIElement.visibleProperty,
          watchList.visibilityHandler);
    }
    if (watchList.observers.indexOf(targetElement, 0) == -1) {
      watchList.observers.add(targetElement);
    }
  }

  void _removeWatchLayout(UIElement element, UIElement targetElement) {
    _WatchList watchList = _watchListOf(element);
    int index = watchList.observers.indexOf(element, 0);
    if (index != -1) {
      watchList.observers.removeAt(index);
    }

    // If this was the last item, we can remove the listener and destroy list.
    if (watchList.observers.length == 0) {
      element.removeListener(UIElement.layoutChangedEvent,
          watchList.sizeHandler);
      element.removeListener(UIElement.transformChangedEvent,
          watchList.transformHandler);
      element.removeListener(UIElement.visibleProperty,
          watchList.visibilityHandler);
      watchList.sizeHandler = null;
      watchList.transformHandler = null;
      watchList.visibilityHandler = null;
      _layoutWatchList[element] = null;
    }
  }

  /** Overrides UIElement.onMouseDown to reset focus. */
  void onMouseDown(MouseEventArgs e) {
    if (isVisualChild(Application.focusManager.focusedElement)) {
      if (e.source is TextEdit) {
        TextEdit textEd = e.source;
        if (textEd.isFocused) {
          return;
        }
      }
      Application.focusManager.focusedElement.isFocused = false;
    }
  }

  /**
   * Returns overlay element by id for an element.
   */
  UIElement findOverlay(UIElement element, String elementId) {
    if (_overlayMap != null) {
      _OverlayList overlayList = _overlayMap[element];
      if (overlayList != null && overlayList.hasOverlays) {
        for (int i = 0; i < overlayList.overlays.length; i++) {
          UIElement overlay = overlayList.overlays[i];
          if (overlay.id == elementId) {
            return overlay;
          }
        }
      }
    }
    return null;
  }

  void _targetElementLayoutChanged(EventArgs e) {
    _applyTargetElementLayoutChange(e, false);
  }

  void _targetElementLayoutAndSizeChanged(EventArgs e) {
    _applyTargetElementLayoutChange(e, true);
  }

  /**
   * Moves overlays to new element location.
   */
  void _applyTargetElementLayoutChange(EventArgs e, bool targetWasResized) {
    if (!(e.source is UIElement)) {
      return;
    }

    Coord containerPos = localToScreen(new Coord(0.0, 0.0));
    // Get a list of targetElements that are affected by source element
    // layout change.
    List<UIElement> observers = _watchListOf(e.source).observers;
    for (int obIndex = 0; obIndex < observers.length; obIndex++) {
      UIElement targetElement = observers[obIndex];
      _OverlayList overlayList = _overlayMap[targetElement];
      Coord targetPos = targetElement.localToScreen(new Coord(0.0, 0.0));
      if (overlayList != null && overlayList.hasOverlays) {
        for (int i = 0; i < overlayList.overlays.length; i++) {
          UIElement overlay = overlayList.overlays[i];
          _updateElementPosition(targetElement, overlay, containerPos,
              targetPos, targetWasResized);
        }
      }
    }
  }

  void _updateElementPosition(UIElement targetElement, UIElement overlay,
      Coord containerPos, Coord targetPos, bool targetWasResized) {

    num targetX = targetPos.x - containerPos.x;
    num targetY = targetPos.y - containerPos.y;
    num targetHeight = targetElement.layoutHeight;
    num targetWidth = targetElement.layoutWidth;
    int location = _getChildLocation(overlay);
    int finalLocation = location;

    if (location == OverlayLocation.CUSTOM) {
      return;
    }

    switch (location & OverlayLocation._VMASK) {
      case OverlayLocation.BOTTOM:
        num newY = targetY + targetHeight;
        if ((location & OverlayLocation._VFLIP_ENABLED) != 0) {
          num spaceBelow = Application.current._hostHeight -
              (newY + overlay.measuredHeight);
          num spaceAbove = targetY - overlay.measuredHeight;
          if ((spaceBelow < 0) && spaceAbove > spaceBelow) {
            // Check for flip overlay up.
            newY = targetY - overlay.measuredHeight;
            finalLocation = OverlayLocation.TOP;
            if (spaceAbove < 0) {
              overlay.maxHeight = newY - _SAFETY_MARGIN;
            }
          } else {
            finalLocation = OverlayLocation.BOTTOM;
            if (spaceBelow < 0) {
              overlay.maxHeight = Application.current._hostHeight -
                  newY - _SAFETY_MARGIN;
            }
          }
        }
        targetY = newY;
        break;
      case OverlayLocation.TOP:
        num spaceBelow = Application.current._hostHeight -
            (targetY + overlay.measuredHeight);
        num spaceAbove = targetY - overlay.measuredHeight;
        num newY = targetY - overlay.measuredHeight;
        if ((location & OverlayLocation._VFLIP_ENABLED) != 0) {
          if (newY < 0 && (spaceBelow > spaceAbove)) {
            // Flip overlay down.
            targetY += targetHeight;
            finalLocation = OverlayLocation.BOTTOM;
            if (spaceBelow < 0) {
              overlay.maxHeight = Application.current._hostHeight - targetY -
                  _SAFETY_MARGIN;
            }
          } else {
            if (spaceAbove < 0) {
              overlay.maxHeight = targetY - _SAFETY_MARGIN;
              targetY -= overlay.maxHeight;
            } else {
              targetY = newY;
            }
            finalLocation = OverlayLocation.TOP;
          }
        } else {
          targetY = newY;
        }
        break;
      case OverlayLocation.BOTTOM_EDGE:
        targetY += (targetHeight - overlay.measuredHeight / 2);
        break;
      case OverlayLocation.TOP_EDGE:
        targetY -= overlay.measuredHeight / 2;
        break;
      case OverlayLocation.VCENTER:
        targetY += (targetHeight - overlay.measuredHeight) / 2;
        break;
      default:
        break;
    }

    switch (location & OverlayLocation._HMASK) {
      case OverlayLocation.LEFT:
        targetX -= overlay.measuredWidth;
        break;
      case OverlayLocation.RIGHT:
        targetX += targetWidth;
        break;
      case OverlayLocation.LEFT_EDGE:
        targetX -= overlay.measuredWidth / 2;
        break;
      case OverlayLocation.RIGHT_EDGE:
        targetX += targetWidth - (overlay.measuredWidth / 2);
        break;
      case OverlayLocation.CENTER:
        targetX += (targetWidth - overlay.measuredWidth) / 2;
        break;
      default:
        break;
    }
    if (_overlayNeedsResize.containsKey(overlay) &&
        _overlayNeedsResize[overlay] == true) {
      Canvas.setChildLeft(overlay, targetX);
      Canvas.setChildTop(overlay, targetY);
      if (targetWasResized) {
        overlay.minWidth = targetWidth;
        overlay.minHeight = targetHeight;
      }
    } else {
      num xOffset = 0.0;
      num yOffset = 0.0;
      int hAlign = overlay.hAlign;
      switch (hAlign) {
        case UIElement.HALIGN_RIGHT:
          xOffset = targetWidth - overlay.measuredWidth;
          break;
        case UIElement.HALIGN_CENTER:
          xOffset = (targetWidth - overlay.measuredWidth) / 2;
          break;
      }
      int vAlign = overlay.vAlign;
      switch (vAlign) {
        case UIElement.VALIGN_BOTTOM:
          yOffset = targetHeight - overlay.measuredHeight;
          break;
        case UIElement.VALIGN_CENTER:
          yOffset = (targetHeight - overlay.measuredHeight) / 2;
          break;
      }
      Canvas.setChildLeft(overlay, targetX + xOffset);
      Canvas.setChildTop(overlay, targetY + yOffset);
      _setChildFinalLocation(overlay, finalLocation);
      if (overlay is Control) {
        Control ct = overlay;
        if (ct.chromeTree != null) {
          ct.chromeTree.setProperty(finalLocationProperty, finalLocation);
        }
      }
    }
  }

  void _targetVisibilityChanged(PropertyChangedEvent e) {
    List<UIElement> observers = _watchListOf(e.source).observers;
    for (int obIndex = 0; obIndex < observers.length; obIndex++) {
      UIElement targetElement = observers[obIndex];
      bool makeOverlaysVisible = e.newValue;
      _OverlayList overlayList = _overlayMap[targetElement];
      if (!overlayList.hasOverlays) continue;
      for (int i = 0; i < overlayList.overlays.length; i++) {
        overlayList.overlays[i].visible = makeOverlaysVisible;
      }
    }
  }

  /** Registers element. */
  static void registerOverlayContainer() {
    locProperty = ElementRegistry.registerProperty("Loc",
        PropertyType.LOCATION, PropertyFlags.ATTACHED, null, 0);
    finalLocationProperty = ElementRegistry.registerProperty("finalLocation",
        PropertyType.LOCATION, PropertyFlags.ATTACHED, null, 0);
    overlayElementDef = ElementRegistry.register("OverlayContainer",
        ContentContainer.contentcontainerElementDef, [locProperty,
        finalLocationProperty], null);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => overlayElementDef;
}

/** Manages a list of overlays attached to a targetElement */
class _OverlayList {
  UIElement targetElement;

  _OverlayList(this.targetElement);
  List<UIElement> _overlays = null;

  bool get hasOverlays => _overlays != null && _overlays.length > 0;

  List<UIElement> get overlays {
    if (_overlays == null) {
      _overlays = <UIElement>[];
    }
    return _overlays;
  }
}

/**
 * Manages a list of targetElements listening to the layout change of
 * a view node.
 */
class _WatchList {
  UIElement viewNode;
  List<UIElement> observers;

  _WatchList(this.viewNode) {
    observers = [];
  }

  EventHandler sizeHandler = null;
  EventHandler transformHandler = null;
  EventHandler visibilityHandler = null;
}

/**
 * Provides constants for overlay location settings.
 */
abstract class OverlayLocation {
  static const int DEFAULT = 0;

  static const int _VMASK = 0xFF;
  static const int TOP = 1;
  static const int BOTTOM = 2;
  static const int TOP_EDGE = 4;
  static const int BOTTOM_EDGE = 8;
  static const int VCENTER = 0x10;
  // Locate at bottom of element, if out of space, flip above.
  static const int BOTTOM_OR_TOP = 0x10002;
  // Locate above the element, if out of space flip down.
  static const int TOP_OR_BOTTOM = 0x10001;

  static const int _HMASK = 0xFF00;
  static const int LEFT = 0x0100;
  static const int RIGHT = 0x0200;
  static const int LEFT_EDGE = 0x0400;
  static const int RIGHT_EDGE = 0x0800;
  static const int CENTER = 0x1000;

  static const int _VFLIP_ENABLED= 0x10000;
  // Custom location is used for modal floating elements that should
  // not be repositioned due to container size/location change.
  static const int CUSTOM = 0x40000;
  static const int _TOPLEVEL = 0x80000;
}
