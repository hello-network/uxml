part of uxml;

/**
 * The root class of user interface elements.
 *
 * Adds rendering and layout to base UxmlElement.
 *
 * LAYOUT SYSTEM DETAILS:
 *
 * Layout is performed in 2 passes. The first pass is measuring the size
 * of an element, second pass is layout of children.
 *
 * layoutFlags determines if an element needs remeasuring or relayout.
 * InitSurface marks an element's measure and layout dirty. Until
 * an element has it's surface initialized (hostSurface == null), it can't
 * be measured.
 *
 * app.content = element triggers the top level hostContent, measure/layout
   cycle.
 *
 * PROGRESSIVE LAYOUT
 * Once all elements have been measured and layout completes, the following
 * actions trigger a progressive layout:

 * 1- A property of an element changes that causes invalidateSize call.
 *    invalidateSize will mark the element as potentially changing size.
 *    Once the updateQueue remeasures the item and finds out that it's size
 *    did indeed change, it will invalidate the size of it's parent by
 *    calling invalidSizeForChild(child). The default implementation calls
 *    invalidateSize and causes full remeasure/potential relayout.
 *    invalidateSizeForChild is provided to allow for form layout type
 *    containers such as Canvas to optimize for progressive layout.
 *
 * 2- When the Visible or LayoutVisible property of an element changes,
 *    it will invalidate it's size. Since measure and layout
 *    has never been called on this element we have to make sure that
 *    the parent will layout this item in case layout had never been called.
 *
 * 3- H/VAlignment changes don't actually cause a size change but will
 *    trigger a layout change for the parent. The parent will calculate the
 *    new location of the element according to new alignment and call
 *    layout.
 *
 * When updateQueue processes an item and determines that it's size has
 * changed, it will invalidate it's layout and drawing to force a redraw.
 *
 * NOTES:
 * - element.measure will return cached measuredWidth/Height if not dirty
 * - element.layout should not do anything if the layout rectangle is same
 *   as in a prior call to prevent unnecessary UISurface(DOM) updates.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 * @author michjun@ (Michelle Fang)
 * @author hannung@ (Han-Nung Lin)
 */
class UIElement extends UxmlElement implements UISurfaceTarget {
  static ElementDef elementDef;
  // Property Definitions
  static PropertyDefinition visibleProperty;
  static PropertyDefinition clipChildrenProperty;
  static PropertyDefinition opacityProperty;
  static PropertyDefinition widthProperty;
  static PropertyDefinition heightProperty;
  static PropertyDefinition hAlignProperty;
  static PropertyDefinition vAlignProperty;
  static PropertyDefinition minWidthProperty;
  static PropertyDefinition maxWidthProperty;
  static PropertyDefinition minHeightProperty;
  static PropertyDefinition maxHeightProperty;
  static PropertyDefinition marginsProperty;
  static PropertyDefinition maskProperty;
  static PropertyDefinition stateProperty;
  static PropertyDefinition filtersProperty;
  static PropertyDefinition isFocusGroupProperty;
  static PropertyDefinition isFocusedProperty;
  static PropertyDefinition transformProperty;
  static PropertyDefinition layoutVisibleProperty;
  static PropertyDefinition mouseEnabledProperty;
  static PropertyDefinition enabledProperty;
  static PropertyDefinition isMouseOverProperty;
  /** FocusChrome property definition */
  static PropertyDefinition focusChromeProperty;
  static PropertyDefinition tooltipProperty;
  static bool _inRemeasure = false;

  // Event Definitions
  /** Closed event definition. */
  static EventDef closedEvent;
  /** MouseDown event definition */
  static EventDef mouseDownEvent;
  /** MouseUp event definition */
  static EventDef mouseUpEvent;
  /** MouseMove event definition */
  static EventDef mouseMoveEvent;
  /** MouseEnter event definition */
  static EventDef mouseEnterEvent;
  /** MouseExit event definition */
  static EventDef mouseExitEvent;
  /** MouseWheel event definition */
  static EventDef mouseWheelEvent;
  /** KeyDown event definition */
  static EventDef keyDownEvent;
  /** KeyUp event definition */
  static EventDef keyUpEvent;
  /** DragStart event definition */
  static EventDef dragStartEvent;
  /** Drag event definition */
  static EventDef dragEvent;
  /** DragEnd event definition */
  static EventDef dragEndEvent;
  /** DragEnter event definition */
  static EventDef dragEnterEvent;
  /** DragLeave event definition */
  static EventDef dragOverEvent;
  /** DragLeave event definition */
  static EventDef dragLeaveEvent;
  /** Drag drop event definition */
  static EventDef dropEvent;
  /** LayoutChanged event definition */
  static EventDef layoutChangedEvent;
  /** TransformChanged event definition */
  static EventDef transformChangedEvent;
  /** Event to bubble up to parent containers for handling scrollIntoView. */
  static EventDef scrollIntoViewEvent;
  /** State changed event definition */
  static EventDef stateChangedEvent;

  // Horizontal alignment constants
  static const int HALIGN_FILL = 0;
  static const int HALIGN_LEFT = 1;
  static const int HALIGN_CENTER = 2;
  static const int HALIGN_RIGHT = 3;

  // Vertical alignment constants
  static const int VALIGN_FILL = 0;
  static const int VALIGN_TOP = 1;
  static const int VALIGN_CENTER = 2;
  static const int VALIGN_BOTTOM = 3;

  // Orientation constants
  static const int HORIZONTAL = 0;
  static const int VERTICAL = 1;

  /** Layout flag constants */
  static const int _UPDATEFLAG_SIZE_DIRTY = 0x1;
  static const int _UPDATEFLAG_NEEDS_REDRAW = 0x2;
  static const int _UPDATEFLAG_NEEDS_RELAYOUT = 0x4;
  static const int _UPDATEFLAG_NEEDS_INITLAYOUT = 0x8;
  static const int _UPDATEFLAG_FILTERS = 0x10;

  // Set when MinWidth or MaxWidth are set to reduce getProperty cost.
  static const int _LAYOUTFLAG_MINWIDTH_CONSTRAINT = 0x80;
  static const int _LAYOUTFLAG_MAXWIDTH_CONSTRAINT = 0x100;

  // Set when MinHeight or MaxHeight properties are set.
  static const int _LAYOUTFLAG_MINHEIGHT_CONSTRAINT = 0x200;
  static const int _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT = 0x400;

  static const int _LAYOUTFLAG_WIDTH_CONSTRAINT = 0x800;
  static const int _LAYOUTFLAG_HEIGHT_CONSTRAINT = 0x1000;

  static const int _LAYOUTFLAG_CACHE_AS_BITMAP = 0x2000;
  static const int _LAYOUTFLAG_SHUTDOWN = 0x4000;

  /** Cached boolean element data */
  static const int _ELEM_FLAG_VISIBLE = 0x1;
  static const int _ELEM_FLAG_LAYOUT_VISIBLE = 0x2;
  static const int _ELEM_FLAG_MOUSE_ENABLED = 0x4;
  static const int _ELEM_FLAG_CLIP_CHILDREN = 0x8;
  static const int _ELEM_FLAG_ENABLED = 0x10;
  static const int _ELEM_FLAG_FOCUS_ENABLED = 0x20;
  static const int _ELEM_FLAG_HAS_FILTERS = 0x40;
  static EventArgs _sharedLayoutArgs = null;

  int _elementFlags;

  UISurface _hostSurface;
  Application app;
  num measuredWidth = 0.0;
  num measuredHeight = 0.0;
  num layoutX = 0;
  num layoutY = 0;
  num layoutWidth = 0;
  num layoutHeight = 0;
  /** Holds layout invalidation flags */
  int _layoutFlags;
  num _prevLayoutWidth = 0.0;
  num _prevLayoutHeight = 0.0;
  num _prevLayoutX = 0.0;
  num _prevLayoutY = 0.0;
  num _prevMeasureAvailableWidth = 0.0;
  num _prevMeasureAvailableHeight = 0.0;
  num _internalWidth = 0.0;
  num _internalHeight = 0.0;
  Margin _margins;
  List<Effect> _effects;
  UIElement _mask;
  Coord sharedP;
  Resources _resources;

  UIElement() : super() {
    _hostSurface = null;
    _layoutFlags = _UPDATEFLAG_NEEDS_INITLAYOUT;
    _elementFlags = _ELEM_FLAG_VISIBLE | _ELEM_FLAG_MOUSE_ENABLED |
        _ELEM_FLAG_ENABLED;
    _margins = Margin.EMPTY;
    sharedP = new Coord(0.0, 0.0);
    measuredWidth = 0.0;
    measuredHeight = 0.0;
    _internalWidth = 0.0;
    _internalHeight = 0.0;
    _effects = null;
  }

  List<Effect> get effects {
    if (_effects == null) {
      _effects = <Effect>[];
    }
    return _effects;
  }

  void _initSurfaceStart(UISurface parentSurface) {
    _prevMeasureAvailableWidth = 0;
    _prevMeasureAvailableHeight = 0;
    _prevLayoutWidth = -1.0;
    _prevLayoutHeight = -1.0;
    measuredWidth = 0;
    measuredHeight = 0;
    _layoutFlags &= 0xFFFFFFFF ^ _LAYOUTFLAG_SHUTDOWN;
    if (_hostSurface != null && _hostSurface.parentSurface != parentSurface) {
      _layoutFlags |= _UPDATEFLAG_SIZE_DIRTY | _UPDATEFLAG_NEEDS_RELAYOUT |
          _UPDATEFLAG_NEEDS_REDRAW | _UPDATEFLAG_NEEDS_INITLAYOUT;
    }
  }

  /**
   * Initializes surface for rendering element and handling events.
   */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    _initSurfaceStart(parentSurface);

    bool reparenting = false;
    // Check if we reparenting.
    if (_hostSurface != null && _hostSurface.parentSurface != parentSurface) {
      if (_hostSurface.parentSurface != null) {
        _hostSurface.parentSurface.removeChild(_hostSurface);
      }
      parentSurface.reparentChild(_hostSurface);
      if (parent != null) {
        UISurface prevHostSurface = _hostSurface;
        if (parent is UIElementContainer) {
          UIElementContainer container = parent;
          container.removeChild(this);
        } else {
          UIElement parentElm = parent;
          parentElm.removeRawChild(this, reparenting:true);
        }
        _hostSurface = prevHostSurface;
      }
      reparenting = true;
    } else {
      _hostSurface = parentSurface.insertChild(index,
          UIPlatform.createSurface());
    }
    _hostSurface.target = this;
    _hostSurface.visible = _getElementFlag(_ELEM_FLAG_VISIBLE);
    bool elementEnabled = _getElementFlag(_ELEM_FLAG_ENABLED);
    _hostSurface.enableHitTesting = elementEnabled && mouseEnabled;
    _hostSurface.enableChildHitTesting = elementEnabled;
    if (_getElementFlag(_ELEM_FLAG_CLIP_CHILDREN)) {
      _hostSurface.clipChildren = true;
    }
    if (overridesProperty(opacityProperty)) {
      num op = opacity;
      if (op != 1.0) { // dont generate unneccessary CSS
        _hostSurface.opacity = op;
      }
    }
    if (!reparenting) {
      int childCount = getRawChildCount();
      if (childCount > 2) {
        _hostSurface.lockUpdates(true);
      }
      for (int i = 0; i < childCount; i++) {
        UIElement child = getRawChild(i);
        if (child.parent != this) {
          child.parent = this;
          child.onParentChanged();
        }
        child.initSurface(_hostSurface);
      }
      if (childCount > 2) {
        _hostSurface.lockUpdates(false);
      }
    }

    if (mask != null) {
      _invalidateMask();
    }
    UpdateQueue.updateDrawing(this);
    if (_getElementFlag(_ELEM_FLAG_HAS_FILTERS)) {
      UpdateQueue.updateFilters(this);
    }
    applyEffects();
    surfaceInitialized(_hostSurface);
  }

  void surfaceInitialized(UISurface surface) {
    // We are now fully attached to DOM tree, notify children of controller.
    if (hasListener(Controller.controllerProperty)) {
      // TODO(ferhat): find efficient way of doing this for all inherited
      // properties we are listening on.
      PropertyChangedEvent propEvent = PropertyChangedEvent.create(
          this, Controller.controllerProperty, null,
          Controller.getTargetController(this));
      notifyListeners(Controller.controllerProperty, propEvent);
      PropertyChangedEvent.release(propEvent);
    }
    if (hasListener(UxmlElement.dataProperty)) {
      PropertyChangedEvent propEvent2 = PropertyChangedEvent.create(
          this, UxmlElement.dataProperty, null, this.data);
      notifyListeners(UxmlElement.dataProperty, propEvent2);
      PropertyChangedEvent.release(propEvent2);
    }
  }

  /**
   * Sets or returns visibility of element.
   */
  bool get visible {
    return _getElementFlag(_ELEM_FLAG_VISIBLE);
  }

  set visible(bool value) {
    setProperty(visibleProperty, value);
  }

  set cursor(String cursorName) {
    Cursor.setElementCursor(this, new Cursor(cursorName));
  }

  /**
   * Sets or returns whether the element is enabled.
   */
  bool get enabled {
    return _getElementFlag(_ELEM_FLAG_ENABLED);
  }

  set enabled(bool value) {
    setProperty(enabledProperty, value);
  }

  /** Gets or Sets the state property. */
  String get state => getProperty(stateProperty);

  set state(String value) {
    setProperty(stateProperty, value);
  }

  /**
   * Sets or returns opacity of element.
   */
  num get opacity {
    return getProperty(opacityProperty);
  }

  set opacity(num value) {
    setProperty(opacityProperty, value);
  }

  /**
   * Sets or returns if children are clipped against border of element.
   */
  bool get clipChildren {
    return _getElementFlag(_ELEM_FLAG_CLIP_CHILDREN);
  }

  set clipChildren(bool value) {
    setProperty(clipChildrenProperty, value);
  }

  /**
   * Sets returns width constraint of element.
   */
  set width(num value) {
    setProperty(widthProperty, value);
  }

  num get width {
    return getProperty(widthProperty);
  }

  /** Sets or returns horizontal alignment */
  int get hAlign {
    return getProperty(hAlignProperty);
  }

  set hAlign(int alignment) {
    setProperty(hAlignProperty, alignment);
  }

  /** Sets or returns vertical alignment */
  int get vAlign {
    return getProperty(vAlignProperty);
  }

  set vAlign(int alignment) {
    setProperty(vAlignProperty, alignment);
  }

  /**
   * Sets returns height constraint of element.
   */
  set height(num value) {
    setProperty(heightProperty, value);
  }

  num get height {
    return getProperty(heightProperty);
  }

  /** Gets or sets the minimum width of element */
  num get minWidth => getProperty(minWidthProperty);

  set minWidth(num value) {
    setProperty(minWidthProperty, value);
  }

  /** Gets or sets the maximum width of element */
  num get maxWidth => getProperty(maxWidthProperty);

  set maxWidth(num value) {
    setProperty(maxWidthProperty, value);
  }

  /** Gets or sets the minimum height of element */
  num get minHeight => getProperty(minHeightProperty);

  set minHeight(num value) {
    setProperty(minHeightProperty, value);
  }

  /** Gets or sets the maximum height of element */
  num get maxHeight => getProperty(maxHeightProperty);

  set maxHeight(num value) {
    setProperty(maxHeightProperty, value);
  }

  /** Gets or sets the margins of an element */
  Margin get margins {
    return _margins;
  }

  set margins(Margin value) {
    setProperty(marginsProperty, value);
  }

  /**
   * Called when surface initializes and parent has changed.
   */
  void onParentChanged() {
  }

  /** Destroys element and all children. */
  void close() {
    if ((_layoutFlags & _LAYOUTFLAG_SHUTDOWN) != 0) {
      return; // prevent recursive shutdown.
    }
    _layoutFlags |= _LAYOUTFLAG_SHUTDOWN;
    int childCount = getRawChildCount();
    for (int i = 0; i < childCount; ++i) {
      UIElement child = getRawChild(i);
      removeRawChild(child);
    }
    if (_hostSurface != null) {
      _hostSurface.close();
      _hostSurface.target = null;
      _hostSurface = null;
    }
    _layoutFlags |= _UPDATEFLAG_SIZE_DIRTY | _UPDATEFLAG_NEEDS_RELAYOUT |
        _UPDATEFLAG_NEEDS_REDRAW | _UPDATEFLAG_NEEDS_INITLAYOUT;
    if (hasListener(closedEvent)) {
      EventArgs e = new EventArgs(this);
      e.event = closedEvent;
      _raiseEvent(e);
    }
  }

  bool surfaceFocusChanged(bool hasFocus) {
    return false;
  }

  void surfaceTextChanged(String text) {
  }

  /**
   * Returns raw child count.
   *
   * Subclasses should override to expose visible children.
   */
  int getRawChildCount() {
    return 0;
  }

  /**
   * Returns raw child collection.
   *
   * Subclassess should override to expose visible children.
   */
  UIElement getRawChild(int index) {
    return null;
    // throw new IndexOutOfBoundsException();
  }

  /**
   * Adds a visible child.
   */
  void addRawChild(UIElement child) {
    insertRawChild(child, -1);
  }

  /**
   * Inserts a visible child.
   */
  void insertRawChild(UIElement child, int index) {
    if (child.parent != null && child.parent != this) {
      // TODO(ferhat): reparenting code
    } else {
      child.parent = this;
    }
    child.onParentChanged();
    if (_hostSurface != null) {
      child.initSurface(_hostSurface);
    }
    invalidateSize();
    invalidateLayout();
  }

  /** Adds a child with explicit parent (used for overlays) */
  void _internalAddRawChild(UIElement element, UIElement parentElement) {
    if (element.parent != parentElement) {
      element.parent = parentElement;
      element.onParentChanged();
    }
    if (_hostSurface != null) {
      if (element._hostSurface == null) {
        // create UI surface
        element.initSurface(_hostSurface);
      } else {
        // reparent
        _hostSurface.reparentChild(element._hostSurface);
      }
      invalidateSizeForChild(element);
    }
  }

  /**
   * Removes a visible child.
   */
  void removeRawChild(UIElement child, {bool reparenting: false}) {
    if (child._hostSurface != null) {
      if (!reparenting) {
        if (hostSurface.removeChild(child.hostSurface)) {
          child.close();
          child._hostSurface = null;
        }
      }
    } else if (!reparenting) {
      child.close();
    }
    invalidateSizeForChild(child);
    invalidateLayoutForChild(child);
  }

  bool measure(num availableWidth, num availableHeight) {
    bool parentRelayoutRequired = false;
    bool layoutChanged = false;
    bool isDirty = ((_layoutFlags & _UPDATEFLAG_SIZE_DIRTY) != 0);
    // Optimization: If size is not dirty and we are querying
    // with prior size just return previous result.
    if (isDirty || (availableWidth != _prevMeasureAvailableWidth) ||
        (availableHeight != _prevMeasureAvailableHeight)) {
      num prevWidth = measuredWidth;
      num prevHeight = measuredHeight;
      _prevMeasureAvailableWidth = availableWidth;
      _prevMeasureAvailableHeight = availableHeight;
      if ((visible == false) && (layoutVisible == false)) {
        measuredWidth = 0.0;
        measuredHeight = 0.0;
      } else {
        bool isWidthDefined = (_layoutFlags &
              _LAYOUTFLAG_WIDTH_CONSTRAINT) != 0;
        bool isHeightDefined = (_layoutFlags &
              _LAYOUTFLAG_HEIGHT_CONSTRAINT) != 0;
        if (_margins != Margin.EMPTY && _margins != null) {
          availableWidth -= _margins.left + _margins.right;
          availableHeight -= _margins.top + _margins.bottom;
        }

        if (isWidthDefined) {
          availableWidth = _internalWidth;
        }
        if (isHeightDefined) {
          availableHeight = _internalHeight;
        }

        _layoutFlags &= 0xFFFFFFFF ^ _UPDATEFLAG_SIZE_DIRTY;

        if ((_layoutFlags & _LAYOUTFLAG_MAXWIDTH_CONSTRAINT) != 0) {
          if (availableWidth > maxWidth) {
            availableWidth = maxWidth;
          }
        }

        if ((_layoutFlags & _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT) != 0) {
          if (availableHeight > maxHeight) {
            availableHeight = maxHeight;
          }
        }

        parentRelayoutRequired = onMeasure(availableWidth, availableHeight);

        if (isWidthDefined) {
          measuredWidth = _internalWidth;
        }
        if (isHeightDefined) {
          measuredHeight = _internalHeight;
        }

        if (((_layoutFlags & _LAYOUTFLAG_MINWIDTH_CONSTRAINT) != 0) &&
            (measuredWidth < minWidth)) {
          measuredWidth = minWidth;
        }

        if (((_layoutFlags & _LAYOUTFLAG_MAXWIDTH_CONSTRAINT) != 0) &&
            (measuredWidth > maxWidth)) {
          measuredWidth = maxWidth;
        }

        if (((_layoutFlags & _LAYOUTFLAG_MINHEIGHT_CONSTRAINT) != 0) &&
          (measuredHeight < minHeight)) {
          measuredHeight = minHeight;
        }

        if (((_layoutFlags & _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT) != 0) &&
          (measuredHeight > maxHeight)) {
          measuredHeight = maxHeight;
        }

        if (_margins != Margin.EMPTY && _margins != null) {
          measuredWidth += _margins.left + _margins.right;
          measuredHeight += _margins.top + _margins.bottom;
        }

        if (prevWidth != measuredWidth) {
          int halign = hAlign;
          // Check alignment since if we are not topleft anchored,
          // the parent needs to relayout to correctly reposition this element.
          // Otherwise we can optimize by stopping layout update propagation
          // going up the view hierarchy.
          if (halign != HALIGN_LEFT && hAlign != HALIGN_FILL) {
            parentRelayoutRequired = true;
          } else {
            // Don't propagate up.
            layoutChanged = true;
          }
        }

        if (prevHeight != measuredHeight) {
          int valign= vAlign;
          if (valign != VALIGN_TOP && vAlign != VALIGN_FILL) {
            parentRelayoutRequired = true;
          } else {
            // Don't propagate up.
            layoutChanged = true;
          }
        }
        if (layoutChanged) {
          invalidateLayout();
        }
        if (parentRelayoutRequired) {
          if (parent != null && _inRemeasure) {
            UIElement parentEl = parent;
            parentEl.invalidateLayoutForChild(this);
          }
        }
      }
    }
    return parentRelayoutRequired;
  }

  /**
   * Subclasses should override this function to provide custom
   * size information to layout system.
   */
  bool onMeasure(num availableWidth, num availableHeight) {
    measuredWidth = 0.0;
    measuredHeight = 0.0;
    return false;
  }

  /** Performs final layout of element into target rectangle */
  void layout(num targetX, num targetY, num targetWidth, num targetHeight) {
    if (!visible) {
      return;
    }

    bool isDirty = (_layoutFlags &
        (_UPDATEFLAG_NEEDS_RELAYOUT | _UPDATEFLAG_NEEDS_INITLAYOUT)) != 0;
    // Check if target layout rectangle has changed since last call.
    bool targetRectDirty = (targetWidth != _prevLayoutWidth) ||
        (targetHeight != _prevLayoutHeight) ||
        (targetX != _prevLayoutX) ||
        (targetY != _prevLayoutY);

    num alignOffsetX = 0.0;
    num alignOffsetY = 0.0;

    if (isDirty || targetRectDirty) {
      // Cache layout size
      _prevLayoutWidth = targetWidth;
      _prevLayoutHeight = targetHeight;
      _prevLayoutX = targetX;
      _prevLayoutY = targetY;

      layoutWidth = measuredWidth;
      // horizontal alignment
      if (targetWidth != measuredWidth) {
        int halign = hAlign;
        switch (halign) {
          case HALIGN_LEFT:
            break;
          case HALIGN_CENTER:
            alignOffsetX = (targetWidth - measuredWidth) / 2;
            break;
          case HALIGN_RIGHT:
            alignOffsetX = targetWidth - measuredWidth;
            break;
          default:
            if ((_layoutFlags & _LAYOUTFLAG_WIDTH_CONSTRAINT) == 0) {
              layoutWidth = targetWidth; // fill area.
            }
            break;
        }
      }
      layoutHeight = measuredHeight;
      // vertical alignment
      if (targetHeight != measuredHeight) {
        int valign = vAlign;
        switch (valign) {
          case VALIGN_TOP:
            break;
          case VALIGN_CENTER:
            alignOffsetY = (targetHeight - measuredHeight) / 2;
            break;
          case VALIGN_BOTTOM:
            alignOffsetY = targetHeight - measuredHeight;
            break;
          default:
            if ((_layoutFlags & _LAYOUTFLAG_HEIGHT_CONSTRAINT) == 0) {
              layoutHeight = targetHeight;
            }
            break;
        }
      }

      if (_margins != Margin.EMPTY && _margins != null) {
        alignOffsetX += _margins.left;
        alignOffsetY += _margins.top;
        layoutWidth -= _margins.left + _margins.right;
        layoutHeight -= _margins.top + _margins.bottom;
      }

      bool realign = false;

      // Now check constraints.
      if ((_layoutFlags & _LAYOUTFLAG_MINWIDTH_CONSTRAINT) != 0) {
        if (layoutWidth < minWidth) {
          layoutWidth = minWidth;
          realign = true;
        }
      }

      if ((_layoutFlags & _LAYOUTFLAG_MAXWIDTH_CONSTRAINT) != 0) {
        if (layoutWidth > maxWidth) {
          layoutWidth = maxWidth;
          realign = true;
        }
      }

      if ((_layoutFlags & _LAYOUTFLAG_MINHEIGHT_CONSTRAINT) != 0) {
        if (layoutHeight < minHeight) {
          layoutHeight = minHeight;
          realign = true;
        }
      }

      if ((_layoutFlags & _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT) != 0) {
        if (layoutHeight > maxHeight) {
          layoutHeight = maxHeight;
          realign = true;
        }
      }

      if (realign) {
        // horizontal alignment
        if (targetWidth != layoutWidth) {
          switch (hAlign) {
            case HALIGN_CENTER:
              alignOffsetX = (targetWidth - layoutWidth) / 2;
              break;
            case HALIGN_RIGHT:
              alignOffsetX = targetWidth - layoutWidth;
              break;
            default:
              alignOffsetX = 0.0;
              break;
          }
          if (_margins != Margin.EMPTY && _margins != null) {
            alignOffsetX += _margins.left;
          }
        }
        // vertical alignment
        if (targetHeight != layoutHeight) {
          switch (vAlign) {
            case VALIGN_CENTER:
              alignOffsetY = (targetHeight - layoutHeight) / 2;
              break;
            case VALIGN_BOTTOM:
              alignOffsetY = targetHeight - layoutHeight;
              break;
            default:
              alignOffsetY = 0.0;
              break;
          }
          if (_margins != Margin.EMPTY && _margins != null) {
            alignOffsetY += _margins.top;
          }
        }
      }

      targetX += alignOffsetX;
      targetY += alignOffsetY;
      layoutX = targetX;
      layoutY = targetY;

      if (_hostSurface != null) {
        _hostSurface.setLocation(targetX.toInt(), targetY.toInt(),
            layoutWidth.toInt(), layoutHeight.toInt());
        if (overridesProperty(transformProperty)) {
          onTransformChanged(transform);
        }
        if (targetRectDirty) {
          if (mask != null) {
            mask.measure(layoutWidth, layoutHeight);
            mask.layout(0.0, 0.0, layoutWidth, layoutHeight);
          }
          invalidateDrawing();
        }
      }
      onLayout(targetX, targetY, layoutWidth, layoutHeight);
      if (targetRectDirty && hasListener(layoutChangedEvent)) {
        if (_sharedLayoutArgs == null) {
          _sharedLayoutArgs = new EventArgs(this);
        }
        _sharedLayoutArgs.event = layoutChangedEvent;
        _sharedLayoutArgs.source = this;
        notifyListeners(layoutChangedEvent, _sharedLayoutArgs);
      }
    }
    _layoutFlags &= 0xFFFFFFFF ^ (_UPDATEFLAG_NEEDS_RELAYOUT |
        _UPDATEFLAG_NEEDS_INITLAYOUT);
  }

  // Overridable for containers to do layout of children.
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
  }

  /**
   * Remeasure element using last call params. This is called by UpdateQueue.
   */
  bool _remeasure() {
    if ((_layoutFlags & _UPDATEFLAG_SIZE_DIRTY) == 0) {
      return true;
    }
    if (((_layoutFlags & _UPDATEFLAG_SIZE_DIRTY) == 0) &&
        visualParent != null) {
      return false;
    }
    if (_hostSurface == null) {
      return true;
    }

    num prevWidth = measuredWidth;
    num prevHeight = measuredHeight;
    _inRemeasure = true;
    bool relayoutRequired = measure(_prevMeasureAvailableWidth,
        _prevMeasureAvailableHeight);
    _inRemeasure = false;
    if (parent == null) {
      measuredWidth = prevWidth;
      measuredHeight = prevHeight;
    }
    if ((prevWidth != measuredWidth) || (prevHeight != measuredHeight)) {
      // Parent size/layout may have changed so propagate updates up.
      if (visualParent != null) {
        visualParent.invalidateSizeForChild(this);
        visualParent.invalidateLayoutForChild(this);
      }

      // Element size changed so update layout and invalidate drawing area
      invalidateLayout();
      invalidateDrawing();

    } else if (relayoutRequired) {
      invalidateLayout();
    }
    return true;
  }

  void _redraw() {
    if (hostSurface == null) {
      return;
    }
    if ((_layoutFlags & _UPDATEFLAG_NEEDS_REDRAW) == 0) {
      return;
    }
    if (((_layoutFlags & _UPDATEFLAG_NEEDS_INITLAYOUT) == 0)) {
      onRedraw(_hostSurface);
      _layoutFlags &= 0xFFFFFFFF ^ _UPDATEFLAG_NEEDS_REDRAW |
          _UPDATEFLAG_FILTERS;
    }
  }

  /**
   * Provides override for subclasses to render contents of element to surface.
   */
  void onRedraw(UISurface surface) {
  }

  bool get isMeasureDirty => (_layoutFlags & _UPDATEFLAG_SIZE_DIRTY) != 0;

  /** Returns whether layout has been initialized. */
  bool get isLayoutInitialized => (_layoutFlags &
      _UPDATEFLAG_NEEDS_INITLAYOUT) == 0;

  /** Gets or sets layout visibility of element */
  bool get layoutVisible => _getElementFlag(_ELEM_FLAG_LAYOUT_VISIBLE);

  set layoutVisible(bool value) {
    setProperty(layoutVisibleProperty, value);
  }

  /**
   * Returns filters collection.
   */
  Filters get filters {
    Filters f = getProperty(filtersProperty);
    if (f == null) {
      f = new Filters();
      f.owner = this;
      setProperty(filtersProperty, f);
    }
    return f;
  }

  set filters(Filters value) {
    value.owner = this;
    setProperty(filtersProperty, value);
  }

  /**
   * Returns true if mouse is over the element.
   */
  bool get isMouseOver => getProperty(isMouseOverProperty);

  /**
   * Sets or returns chrome to use when element has input focus.
   */
  Chrome get focusChrome => getProperty(focusChromeProperty);

  set focusChrome(Chrome chrome) {
    setProperty(focusChromeProperty, chrome);
  }

  /**
   * Sets or return if input focus is enabled for this element.
   */
  bool get focusEnabled => _getElementFlag(_ELEM_FLAG_FOCUS_ENABLED);

  set focusEnabled(bool value) {
    setElementFlag(_ELEM_FLAG_FOCUS_ENABLED, value);
  }

  /**
   * Returns/sets if element has input focus.
   */
  bool get isFocused => getProperty(UIElement.isFocusedProperty);

  set isFocused(bool value) {
    setProperty(UIElement.isFocusedProperty, value);
  }

  /**
   * Sets or return if child elements form a focus(tab) group.
   */
  bool get isFocusGroup => getProperty(isFocusGroupProperty);

  set isFocusGroup(bool value) {
    setProperty(isFocusGroupProperty, value);
  }

  /** Sets input focus to element */
  void setFocus() {
    isFocused = true;
  }

  void setElementFlag(int flag, bool value) {
    _elementFlags = (_elementFlags & (0xFFFFFFFF ^ flag));
    if (value) {
      _elementFlags |= flag;
    }
  }

  bool _getElementFlag(int flag) => (_elementFlags & flag) != 0;

  /**
   * Sets element's measured dimensions at the end of a onMeasure call.
   */
  void setMeasuredDimension(num w, num h) {
    measuredWidth = w;
    measuredHeight = h;
  }

  UIElement get visualParent {
    if ((_hostSurface == null) || (_hostSurface.parentSurface == null)) {
      return null;
    }
    return _hostSurface.parentSurface.target;
  }

  void invalidateSize() {
    _layoutFlags |= _UPDATEFLAG_SIZE_DIRTY;
    if (_hostSurface != null) {
      UpdateQueue.updateMeasure(this);
    }
  }

  void invalidateLayout() {
    _layoutFlags |= _UPDATEFLAG_NEEDS_RELAYOUT;
    UpdateQueue.updateLayout(this);
  }

  void invalidateDrawing() {
    _layoutFlags |= _UPDATEFLAG_NEEDS_REDRAW;
    UpdateQueue.updateDrawing(this);
  }

  /**
   * Invalidate size override for containers that optimize progressive layout.
   */
   void invalidateSizeForChild(UIElement child) {
     invalidateSize();
   }

   /**
   * Invalidate layout override for containers that optimize progressive
   * layout.
   */
   void invalidateLayoutForChild(UIElement child) {
     invalidateLayout();
   }

   // Property change handlers.
   static void _widthChangedHandler(UIElement target,
                                    PropertyDefinition property,
                                    Object oldValue,
                                    Object newValue) {
     if (newValue == PropertyDefaults.NO_DEFAULT) {
       target._layoutFlags &= 0xFFFFFFFF ^ _LAYOUTFLAG_WIDTH_CONSTRAINT;
       target._internalWidth = 0.0;
     } else {
       target._layoutFlags |= _LAYOUTFLAG_WIDTH_CONSTRAINT;
       target._internalWidth = newValue;
     }
   }

   static void _heightChangedHandler(UIElement target,
                                     PropertyDefinition property,
                                     Object oldValue,
                                     Object newValue) {
     if (newValue == PropertyDefaults.NO_DEFAULT) {
       target._layoutFlags &= 0xFFFFFFFF ^ _LAYOUTFLAG_HEIGHT_CONSTRAINT;
       target._internalHeight = 0.0;
     } else {
       target._layoutFlags |= _LAYOUTFLAG_HEIGHT_CONSTRAINT;
       target._internalHeight = newValue;
     }
   }

   static void _filtersChangeHandler(Object target,
                                     PropertyDefinition property,
                                     Object oldValue,
                                     Object newValue) {
     UIElement elem = target;
     if (newValue != null) {
       Filters filters = newValue;
       elem.setElementFlag(_ELEM_FLAG_HAS_FILTERS, true);
     }
     elem._invalidateFilters();
   }

   /** Returns true if element has filters collection. */
   bool get hasFilters => _getElementFlag(_ELEM_FLAG_HAS_FILTERS);

   /** Gets or sets whether mouse events are enabled for element.*/
   bool get mouseEnabled {
     return _getElementFlag(_ELEM_FLAG_MOUSE_ENABLED);
   }

   set mouseEnabled(bool value) {
     setProperty(mouseEnabledProperty, value);
   }


  /**
   * Finds child element with id.
   */
  UIElement getElement(String elementId) {
     UIElement res;
     int i;
     if (elementId == id) {
       return this;
     }
     int rawChildCount = getRawChildCount();
     for (i = 0; i < rawChildCount; ++i) {
       res = getRawChild(i);
       if (res.id == elementId) {
         return res;
       }
     }
     for (i = 0; i < rawChildCount; ++i) {
       res = getRawChild(i);
       res = res.getElement(elementId);
       if (res != null) {
         return res;
       }
     }
     return null;
  }

   void applyEffects() {
     // Initialize effects
     if (effects != null && effects.length != 0) {
       for (int effectIndex = 0; effectIndex < effects.length; effectIndex++) {
         Effect effect = effects[effectIndex];
         UIElement targetElement = this;
         if (effect.source == null) {
           targetElement.addListener(effect.property, _onEffectPropertyChanged);
         } else {
           if (!(effect.source is UxmlElement)) {
             effect.source = getElement(effect.source);
             effect.targetElement = targetElement;
           }
           if (effect.source != null) {
             UIElement s = effect.source;
             s.addListener(effect.property, _onEffectPropertyChanged);
           }
         }
         // run actions that are valid at initialization.
         UIElement source = effect.source != null ? effect.source :
           targetElement;
         if (source.getProperty(effect.property) == effect.value) {
           for (int actionIndex = 0; actionIndex < effect.actions.length;
             ++actionIndex) {
             effect.actions[actionIndex].start(targetElement, source);
           }
         }
       }
     }
   }

   void _tearDownEffects() {
     // TODO(ferhat): remove listeners.
   }

   void _onEffectPropertyChanged(PropertyChangedEvent e) {
     _processEffectPropertyChange(effects, e);
   }

   // Runs effect actions based on property changes.
   static _processEffectPropertyChange(List<Effect> effectsColl,
       PropertyChangedEvent e) {
     UxmlElement source = e.source;
     Object newValue = source.getProperty(e.property);
     // ! effectColl can change inside loop. Don't cache effectsColl.length.
     for (int i = 0; i < effectsColl.length; i++) {
       Effect effect = effectsColl[i];
       if (effect.property == e.property) {
         if (effect.actions.length == 0) {
           continue;
         }
         // if source is specified, check for it.
         if (effect.source != null && effect.source != e.currentSource) {
           continue;
         }

         List<Action> actions = effect.actions;
         int actionCount = actions.length;
         if (effect.value == newValue) {
           for (int actionIndex = 0; actionIndex < actionCount; ++actionIndex) {
             actions[actionIndex].start(effect.targetElement == null ?
                 source : effect.targetElement, source);
           }
         } else if (actionCount > 0 && actions[0].getIsActive(e.source)) {
           for (int reverseIndex = 0; reverseIndex < actionCount;
                 ++reverseIndex) {
             Action action = actions[reverseIndex];
             if (action.reversible) {
               action.reverse(source);
             } else {
               action.reset(source);
             }
           }
         }
       }
     }
   }

  void onPropertyChanged(PropertyDefinition property,
                         Object oldValue,
                         Object newValue) {
    int flags = property.flags;
    if (flags == PropertyFlags.NONE) {
      return;
    }
    if ((flags & PropertyFlags.REDRAW) != 0) {
      invalidateDrawing();
    }
    if ((flags & PropertyFlags.RESIZE) != 0) {
      invalidateSize();
    }
    if ((flags & PropertyFlags.RELAYOUT) != 0) {
      invalidateLayout();
    }
    if ((flags & PropertyFlags.PARENT_RELAYOUT) != 0 &&
        (visualParent != null)) {
      visualParent.invalidateLayout();
    }
    if ((flags & PropertyFlags.INHERIT) != 0) {
      onChildPropertyChanged(property, oldValue, newValue);
    }
  }

  void onChildPropertyChanged(PropertyDefinition property,
                              Object oldValue,
                              Object newValue) {
    int rawChildCount = getRawChildCount();
    PropertyChangeHandler changeHandler;
    for (int i = 0; i < rawChildCount; ++i) {
      UIElement child = getRawChild(i);
      if (child.overridesProperty(property)) {
        return; // Stop propagation to children since there is a new value
      }
      changeHandler = property.getCallback(child.getDefinition());
      if (changeHandler != null) {
        changeHandler(child, property, oldValue, newValue);
      }

      if (child.hasListener(property)) {
        PropertyChangedEvent propEvent = PropertyChangedEvent.create(
            child, property, oldValue, newValue);
        child.notifyListeners(property, propEvent);
        PropertyChangedEvent.release(propEvent);
      }
      child.onChildPropertyChanged(property, oldValue, newValue);
    }
    UIElement maskElement = _mask;
    if ((maskElement != null) && (!maskElement.overridesProperty(property))) {
      changeHandler = property.getCallback(maskElement.getDefinition());
      if (changeHandler != null) {
        changeHandler(maskElement, property, oldValue, newValue);
      }
      if (maskElement.hasListener(property)) {
        PropertyChangedEvent maskEvent = PropertyChangedEvent.create(
            maskElement, property, oldValue, newValue);
        maskElement.notifyListeners(property, maskEvent);
        PropertyChangedEvent.release(maskEvent);
      }
      maskElement.onChildPropertyChanged(property, oldValue, newValue);
    }
  }

  Object findResource(Object key, [String interfaceName = null]) {
    if (_resources != null) {
      if (interfaceName != null) {
        Object resInterface = _resources.getResource(interfaceName);
        if (resInterface != null) {
          Resources intfResources = resInterface;
          Object resObject = intfResources.getResource(key);
          if (resObject != null) {
            return resObject;
          }
        }
      }
      Object res = _resources.getResource(key);
      if (res != null) {
        return res;
      }
    }
    UIElement parentElement = parent;
    if (parentElement == null) {
      return Application.findResource(key, interfaceName);
    }
    return parentElement.findResource(key, interfaceName);
  }

  /** Converts stage coordinate to local */
  Coord screenToLocal(Coord p) {
    screenToLocalInternal(p.x, p.y, sharedP);
    return sharedP;
  }

  /** Converts stage coordinate to local */
  void screenToLocalInternal(num px, num py, Coord localPoint) {
    localPoint.x = px;
    localPoint.y = py;
    if (overridesProperty(transformProperty)) {
      num centerX = transform.originX * layoutWidth;
      num centerY = transform.originY * layoutHeight;
      if (visualParent != null) {
        visualParent.screenToLocalInternal(px, py, localPoint);
        px = localPoint.x;
        py = localPoint.y;
      }
      px -= layoutX + centerX;
      py -= layoutY + centerY;
      Matrix m = transform.matrix;
      localPoint.x = m.transformPointXInverse(px, py) + centerX;
      localPoint.y = m.transformPointYInverse(px, py) + centerY;
    } else {
      if (visualParent != null) {
        visualParent.screenToLocalInternal(localPoint.x, localPoint.y,
            localPoint);
      }
      localPoint.x -= layoutX;
      localPoint.y -= layoutY;
    }
  }
   /** Converts local coordinate to stage */
  Coord localToScreen(Coord p) {
    Coord scrPoint = new Coord(p.x, p.y);
    UIElement element = this;
    while (element != null) {
      if (element.overridesProperty(transformProperty)) {
       num centerX = element.transform.originX * element.layoutWidth;
         num centerY = element.transform.originY * element.layoutHeight;
        num xP = element.transform.matrix.transformPointX(
            scrPoint.x - centerX, scrPoint.y - centerY);
        num yP = element.transform.matrix.transformPointY(
            scrPoint.x - centerX, scrPoint.y - centerY);
        scrPoint.x = xP + element.layoutX + centerX;
        scrPoint.y = yP + element.layoutY + centerY;
      } else {
        scrPoint.x += element.layoutX;
        scrPoint.y += element.layoutY;
      }
      element = element.visualParent;
    }
    return scrPoint;
  }

  /**
   * Update view when a transform property is changed.
   */
  void onTransformChanged(UITransform transform) {
    if (_hostSurface != null) {
      onApplyTransform(transform);
    }
    if (hasListener(transformChangedEvent)) {
      notifyListeners(transformChangedEvent, new EventArgs(this));
    }
  }

  /**
   * Elements can override this to change surface surfaceTransform
   * before it is applied.
   */
  void onApplyTransform(UITransform transform) {
    _hostSurface.surfaceTransform = transform;
  }

  /**
   * Sets mouse capture to element.
   */
  void captureMouse() {
    Application.current.setMouseCapture(this);
  }

  /**
   * Releases mouse capture from element.
   */
  void releaseMouse() {
    Application.current.releaseMouseCapture();
  }

  /** Gets or sets the render transform of an element */
  UITransform get transform {
    UITransform t = getProperty(UIElement.transformProperty);
    if (t == null) {
      t = new UITransform();
      setProperty(UIElement.transformProperty, t);
    }
    return t;
  }

  set transform(UITransform value) {
    setProperty(transformProperty, value);
  }

  bool get hasSurface {
    return _hostSurface != null;
  }

  UISurface get hostSurface {
    return _hostSurface;
  }

  /**
   * Returns true if element is visual child.
   */
  bool isVisualChild(UIElement element) {
    while (element != null) {
      if (element.visualParent == this) {
        return true;
      }
      element = element.visualParent;
    }
    return false;
  }

  /**
   * Returns true if element is a visual child of overlays.
   */
  bool _isOverlayChild(UIElement element) {
    return overlayContainer.isVisualChild(element);
  }

  /**
   * Returns true if mouse is over the element's bounding box.
   */
  bool hitTestBoundingBox(num screenX, num screenY) {
    // Convert from screen to local coordinates.
    // We're not calling screenToLocal since mousemove will call this
    // a lot and we don't want to generate a ton of Point objects as
    // the mouse is moving.
    // If we have no transforms traversing to root just adjust screenX/Y
    // otherwise we need to do expensive screenToLocal.
    UIElement element = this;
    bool hasTransforms= false;
    num sx = screenX;
    num sy = screenY;
    while (element != null) {
      sx -= element.layoutX;
      sy -= element.layoutY;
      if (element.overridesProperty(transformProperty)) {
        hasTransforms = true;
        break;
      }
      element = element.visualParent;
    }
    if (!hasTransforms) {
      // We're done.
      return ((sx >= 0) && (sx < layoutWidth) && (sy >= 0) &&
        (sy < layoutHeight));
    }
    screenToLocalInternal(screenX, screenY, sharedP);
    return ((sharedP.x >= 0) && (sharedP.x < layoutWidth) &&
        (sharedP.y >= 0) && (sharedP.y < layoutHeight));
  }

  bool _hasPrevLayoutData() => (_prevLayoutWidth != -1) ||
      (_prevLayoutHeight != -1);

// Used to mark measure as dirty when content is not loaded yet or is
  // being loaded and the area depends on content aspect ratio.
  void _markMeasureDirty() {
    _layoutFlags |= _UPDATEFLAG_SIZE_DIRTY;
  }

  /**
   * Invalidates filters of element.
   */
  void _invalidateFilters() {
    if (_getElementFlag(_ELEM_FLAG_HAS_FILTERS)) {
      _layoutFlags |= _UPDATEFLAG_FILTERS;
      UpdateQueue.updateFilters(this);
    }
  }

  void _applyFilters() {
    if ((_hostSurface != null) && _getElementFlag(_ELEM_FLAG_HAS_FILTERS)) {
      _hostSurface.applyFilters(filters);
    }
  }

  UIElement get mask => getProperty(maskProperty);

  set mask(UIElement element) {
    setProperty(maskProperty, element);
  }

  /**
   * Sets or returns tooltip for element.
   */
  UIElement get tooltip => getProperty(tooltipProperty);

  set tooltip(UIElement value) {
    setProperty(tooltipProperty, value);
  }


  void _invalidateMask() {
    UIElement maskElement = mask;
    if (maskElement != null && maskElement.parent != this) {
      maskElement.parent = this;
      maskElement.onParentChanged();
    }
    if (hostSurface != null) {
      if (mask != null) {
        if (mask.hostSurface == null) {
          // create UI surface
          mask.initSurface(hostSurface);
        } else {
          // reparent
          hostSurface.addChild(mask.hostSurface);
        }
        mask.layout(0, 0, this.layoutWidth, this.layoutHeight);
      }
    }
  }

  /**
   * Returns parent overlay container.
   */
  OverlayContainer get overlayContainer {
    UIElement parentElem = parent;
    return parent == null ? null : parentElem.overlayContainer;
  }


  /**
   * Adds an overlay to this element.
   *
   * @param resize Specifies if overlay element is resized when owner size
   *   changes.
   */
  void addOverlay(UIElement overlay, [bool resize = false, int location = 0]) {
    overlayContainer.add(this, overlay, resize, location);
    overlay.invalidateSize();
  }

  void _addTopLevelOverlay(UIElement targetElement,
                           bool resize,
                           int location) {
    UIElement topLevel = Application.current.content;
    topLevel.overlayContainer.add(this, targetElement, resize, location);
  }

  /**
   * Removes overlay from element.
   */
  void removeOverlay(UIElement overlay) {
    overlayContainer.remove(this, overlay);
  }

  /**
   * Finds overlay by element id.
   */
  UIElement getOverlay(String elementId) {
    return overlayContainer.findOverlay(this, elementId);
  }

  static void _visibleChangedHandler(Object target,
                                     Object property,
                                     Object oldValue,
                                     Object newValue) {
    bool visible = newValue;
    UIElement targetElement = target;
    targetElement.setElementFlag(_ELEM_FLAG_VISIBLE, visible);
    UISurface surface = targetElement._hostSurface;
    if (surface != null) {
      surface.visible = visible;
      if (visible) {
        targetElement.invalidateSize();
        if (targetElement.visualParent != null) {
          targetElement.visualParent.invalidateSizeForChild(targetElement);
          targetElement.visualParent.invalidateLayoutForChild(targetElement);
        }
        targetElement.invalidateDrawing();
      }
    }
  }

  /**
   * Scrolls parent containers of element to get it into view.
   * If item is already visible, no scrolling will be performed. Otherwise
   * scrollbar will be adjusted to lineup top or bottom of item with
   * viewport.
   */
  void scrollIntoView() {
    UpdateQueue.doLater((Object param) {
        EventArgs e = new EventArgs(this);
        e.event = scrollIntoViewEvent;
        routeEvent(e);
      }, "scrollIntoView${this.hashCode.toString()}", null);
  }

  static void _opacityChangeHandler(Object target,
                                    Object property,
                                    Object oldValue,
                                    Object newValue) {
    UIElement targetElement = target;
    UISurface surface = targetElement._hostSurface;
    if (surface != null) {
      surface.opacity = newValue;
    }
  }

  static void _stateChangeHandler(Object target,
                                  Object property,
                                  Object oldValue,
                                  Object newValue) {
    UIElement element = target;
    if (element.hasListener(stateChangedEvent)) {
      EventArgs stateEvent = new EventArgs(element);
      stateEvent.event = stateChangedEvent;
      element.routeEvent(stateEvent);
    }
  }

  static void _marginsChangeHandler(Object target,
                                    Object property,
                                    Object oldValue,
                                    Object newValue) {
      UIElement targetElement = target;
      targetElement._margins = newValue;
  }

  static void _maskChangeHandler(Object target,
                                 Object property,
                                 Object oldValue,
                                 Object newValue) {
      UIElement targetElement = target;
      targetElement._mask = newValue;
      targetElement._invalidateMask();
  }
  static void _minWidthConstraintChangeHandler(Object target,
                                               Object property,
                                               Object oldValue,
                                               Object newValue) {
    UIElement targetElement = target;
    if (targetElement.overridesProperty(minWidthProperty)) {
      targetElement._layoutFlags |= _LAYOUTFLAG_MINWIDTH_CONSTRAINT;
    } else {
      targetElement._layoutFlags &= 0xFFFFFFFF ^
          _LAYOUTFLAG_MINWIDTH_CONSTRAINT;
    }
  }

  static void _maxWidthConstraintChangeHandler(Object target,
                                               Object property,
                                               Object oldValue,
                                               Object newValue) {
    UIElement targetElement = target;
    if (targetElement.overridesProperty(maxWidthProperty)) {
      targetElement._layoutFlags |= _LAYOUTFLAG_MAXWIDTH_CONSTRAINT;
    } else {
      targetElement._layoutFlags &= 0xFFFFFFFF ^
          _LAYOUTFLAG_MAXWIDTH_CONSTRAINT;
    }
  }

  static void _minHeightConstraintChangeHandler(Object target,
                                                Object property,
                                                Object oldValue,
                                                Object newValue) {
    UIElement targetElement = target;
    if (targetElement.overridesProperty(minHeightProperty)) {
      targetElement._layoutFlags |= _LAYOUTFLAG_MINHEIGHT_CONSTRAINT;
    } else {
      targetElement._layoutFlags &= 0xFFFFFFFF ^
          _LAYOUTFLAG_MINHEIGHT_CONSTRAINT;
    }
  }

  static void _maxHeightConstraintChangeHandler(Object target,
                                                Object property,
                                                Object oldValue,
                                                Object newValue) {
    UIElement targetElement = target;
    if (targetElement.overridesProperty(maxHeightProperty)) {
      targetElement._layoutFlags |= _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT;
    } else {
      targetElement._layoutFlags &= 0xFFFFFFFF ^
          _LAYOUTFLAG_MAXHEIGHT_CONSTRAINT;
    }
  }

  static void _transformChangeHandler(UIElement target,
                                      Object property,
                                      Object oldValue,
                                      Object newValue) {
    if ((newValue != null) && (newValue is UITransform)) {
      UITransform t = newValue;
      t.target = target;
      if (target != null) {
        target.onTransformChanged(t);
      }
    }
  }

  static void _tooltipChangedHandler(Object target,
                                     Object property,
                                     Object oldValue,
                                     Object newValue) {
    if (newValue == null) {
      Application.current._toolTipManager.remove(target);
    } else {
      Application.current._toolTipManager.add(target);
    }
  }

  static void _clipChildrenChangeHandler(Object target,
                                         Object property,
                                         Object oldValue,
                                         Object newValue) {
    UIElement element = target;
    element.setElementFlag(_ELEM_FLAG_CLIP_CHILDREN, newValue);
    if (element._hostSurface != null) {
      element._hostSurface.clipChildren = true;
    }
  }

  static void _layoutVisibleChangedHandler(Object target,
                                           Object property,
                                           Object oldValue,
                                           Object newValue) {
    UIElement element = target;
    element.setElementFlag(_ELEM_FLAG_LAYOUT_VISIBLE, newValue);
  }

  /**
   * Returns resources collection.
   */
  Resources get resources {
    if (_resources == null) {
      _resources = new Resources();
    }
    return _resources;
  }

  /**
   * Finds first child element of a type.
   */
  UIElement getElementByType(ElementDef type) {
    UIElement res;
    if (this.getDefinition() == type) {
      return this;
    }
    int rawChildCount = getRawChildCount();
    for (int i = 0; i < rawChildCount; i++) {
      res = getRawChild(i);
      res = res.getElementByType(type);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  void _onEnabledChanged(bool elementEnabled) {
    setElementFlag(_ELEM_FLAG_ENABLED, elementEnabled);
    if (_hostSurface != null) {
      _hostSurface.enableHitTesting = elementEnabled && mouseEnabled;
      _hostSurface.enableChildHitTesting = elementEnabled;
    }
  }

  /**
   * Provides override for subclasses to track focus change.
   */
  void focusChanged() {
  }


  void onKeyDown(KeyboardEventArgs args) {
  }

  void onKeyUp(KeyboardEventArgs args) {
  }

  static void _keyEventHandler(UIElement element, KeyboardEventArgs args) {
    int t = args.eventType;
    switch (t) {
      case KeyboardEventArgs.KEY_DOWN:
        element.onKeyDown(args);
        break;
      case KeyboardEventArgs.KEY_UP:
        element.onKeyUp(args);
        break;
    }
  }

  static void _elementFocusChangedHandler(Object target,
                                          Object property,
                                          Object oldValue,
                                          Object newValue) {
     Application.focusManager._focusChangedHandler(target, property, oldValue,
         newValue);
     UIElement element = target;
     element.focusChanged();
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => elementDef;

  static void registerUIElement() {
    visibleProperty = ElementRegistry.registerProperty("visible",
         PropertyType.BOOL, PropertyFlags.RESIZE, _visibleChangedHandler, true);
    clipChildrenProperty = ElementRegistry.registerProperty("clipChildren",
         PropertyType.BOOL, PropertyFlags.NONE, _clipChildrenChangeHandler,
         false);
    opacityProperty = ElementRegistry.registerProperty("Opacity",
         PropertyType.NUMBER, PropertyFlags.NONE, _opacityChangeHandler, 1.0);
     widthProperty = ElementRegistry.registerProperty("width",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _widthChangedHandler, PropertyDefaults.NO_DEFAULT);
     heightProperty = ElementRegistry.registerProperty("height",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _heightChangedHandler, PropertyDefaults.NO_DEFAULT);
     hAlignProperty = ElementRegistry.registerProperty("hAlign",
         PropertyType.INT, PropertyFlags.RELAYOUT |
         PropertyFlags.PARENT_RELAYOUT, null, HALIGN_FILL);
     vAlignProperty = ElementRegistry.registerProperty("vAlign",
         PropertyType.INT, PropertyFlags.RELAYOUT |
         PropertyFlags.PARENT_RELAYOUT, null, VALIGN_FILL);
     minWidthProperty = ElementRegistry.registerProperty("minWidth",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _minWidthConstraintChangeHandler, 0.0);
     maxWidthProperty = ElementRegistry.registerProperty("maxWidth",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _maxWidthConstraintChangeHandler, PropertyDefaults.NO_DEFAULT);
     minHeightProperty = ElementRegistry.registerProperty("minHeight",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _minHeightConstraintChangeHandler, 0.0);
     maxHeightProperty = ElementRegistry.registerProperty("maxHeight",
         PropertyType.NUMBER, PropertyFlags.RESIZE,
         _maxHeightConstraintChangeHandler, PropertyDefaults.NO_DEFAULT);
     marginsProperty = ElementRegistry.registerProperty("margins",
         PropertyType.MARGIN, PropertyFlags.RESIZE, _marginsChangeHandler,
         Margin.EMPTY);
     maskProperty = ElementRegistry.registerProperty("mask",
         PropertyType.UIELEMENT, PropertyFlags.REDRAW, _maskChangeHandler,
         null);
     stateProperty = ElementRegistry.registerProperty("state",
         PropertyType.STRING, PropertyFlags.INHERIT, _stateChangeHandler, "");
     tooltipProperty = ElementRegistry.registerProperty("tooltip",
         PropertyType.OBJECT, PropertyFlags.NONE, _tooltipChangedHandler,
         null);
     filtersProperty = ElementRegistry.registerProperty("Filters",
         PropertyType.OBJECT, PropertyFlags.CREATE_ON_DEMAND,
         _filtersChangeHandler, null);
     isFocusGroupProperty = ElementRegistry.registerProperty("isFocusGroup",
         PropertyType.BOOL, PropertyFlags.NONE, null, false);
     isFocusedProperty = ElementRegistry.registerProperty("isFocused",
         PropertyType.BOOL, PropertyFlags.NONE, _elementFocusChangedHandler,
         false);
     transformProperty = ElementRegistry.registerProperty("transform",
         PropertyType.OBJECT, PropertyFlags.CREATE_ON_DEMAND,
         _transformChangeHandler, null);
     layoutVisibleProperty = ElementRegistry.registerProperty("layoutVisible",
         PropertyType.BOOL, PropertyFlags.PARENT_RELAYOUT,
         _layoutVisibleChangedHandler, true);
     mouseEnabledProperty = ElementRegistry.registerProperty("mouseEnabled",
         PropertyType.BOOL, PropertyFlags.NONE,
         (Object target, Object property, Object oldVal,
             Object newVal) {
           UIElement element = target;
           element.setElementFlag(_ELEM_FLAG_MOUSE_ENABLED, newVal);
         }, true);
     enabledProperty = ElementRegistry.registerProperty("enabled",
         PropertyType.BOOL, PropertyFlags.NONE,
         (Object target, Object property, Object oldVal,
             Object newVal) {
           UIElement element = target;
           element._onEnabledChanged(newVal);
         }, true);

     isMouseOverProperty = ElementRegistry.registerProperty("isMouseOver",
         PropertyType.BOOL, PropertyFlags.NONE, null, false);
     focusChromeProperty = ElementRegistry.registerProperty("focusChrome",
         PropertyType.CHROME,PropertyFlags.NONE, null, null);

     closedEvent = new EventDef("Closed", Route.DIRECT);
     mouseDownEvent = new EventDef("MouseDown", Route.BUBBLE);
     mouseUpEvent = new EventDef("MouseUp", Route.BUBBLE);
     mouseMoveEvent = new EventDef("MouseMove", Route.BUBBLE);
     mouseEnterEvent = new EventDef("MouseEnter", Route.BUBBLE);
     mouseExitEvent = new EventDef("MouseExit", Route.BUBBLE);
     mouseWheelEvent = new EventDef("MouseWheel", Route.BUBBLE);
     dragStartEvent = new EventDef("DragStart", Route.BUBBLE);
     dragEvent = new EventDef("Drag", Route.BUBBLE);
     dragEndEvent = new EventDef("DragEnd", Route.BUBBLE);
     dragEnterEvent = new EventDef("DragEnter", Route.BUBBLE);
     dragOverEvent = new EventDef("DragOver", Route.BUBBLE);
     dragLeaveEvent = new EventDef("DragLeave", Route.BUBBLE);
     dropEvent = new EventDef("Drop", Route.BUBBLE);
     layoutChangedEvent = new EventDef("LayoutChanged", Route.DIRECT);
     transformChangedEvent = new EventDef("TransformChanged", Route.DIRECT);
     keyDownEvent = new EventDef("KeyDown", Route.BUBBLE);
     keyUpEvent = new EventDef("KeyUp", Route.BUBBLE);
     scrollIntoViewEvent = new EventDef("ScrollIntoView", Route.BUBBLE);
     stateChangedEvent = new EventDef("StateChanged", Route.DIRECT);


     elementDef = ElementRegistry.register("UIElement",
         UxmlElement.baseElementDef,
         [visibleProperty, clipChildrenProperty, widthProperty, heightProperty,
         hAlignProperty, vAlignProperty, minWidthProperty, minHeightProperty,
         maxWidthProperty, maxHeightProperty, filtersProperty,
         isFocusGroupProperty, isFocusedProperty, transformProperty,
         layoutVisibleProperty, mouseEnabledProperty, isMouseOverProperty,
         enabledProperty, opacityProperty, marginsProperty, stateProperty],
         [closedEvent, mouseDownEvent, mouseUpEvent, mouseMoveEvent,
         mouseEnterEvent, mouseExitEvent, mouseWheelEvent, keyDownEvent,
         keyUpEvent, dragStartEvent, dragEvent, dragEndEvent, dragEnterEvent,
         dragOverEvent, dragLeaveEvent, transformChangedEvent,
         layoutChangedEvent, scrollIntoViewEvent, stateChangedEvent]);

     mouseDownEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     mouseUpEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     mouseMoveEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     mouseEnterEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     mouseExitEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     mouseWheelEvent.addHandler(UIElement.elementDef, _mouseEventHandler);
     dragEnterEvent.addHandler(UIElement.elementDef, _dragEventHandler);
     dragOverEvent.addHandler(UIElement.elementDef, _dragEventHandler);
     dragLeaveEvent.addHandler(UIElement.elementDef, _dragEventHandler);
     dropEvent.addHandler(UIElement.elementDef, _dragEventHandler);
     keyDownEvent.addHandler(UIElement.elementDef, _keyEventHandler);
     keyUpEvent.addHandler(UIElement.elementDef, _keyEventHandler);
  }

  static void _mouseEventHandler(UIElement element, MouseEventArgs args) {
    UIElement target = element;
    if (!target.enabled) {
      return;
    }
    if (!target.mouseEnabled) {
      return;
    }
    int t = args.eventType;
    switch (t) {
      case MouseEventArgs.MOUSE_DOWN:
        target.onMouseDown(args);
        break;
      case MouseEventArgs.MOUSE_UP:
        target.onMouseUp(args);
        break;
      case MouseEventArgs.MOUSE_MOVE:
        target.onMouseMove(args);
        break;
      case MouseEventArgs.MOUSE_ENTER:
        target.onMouseEnter(args);
        args.handled = true; // prevent event from bubbling up.
        break;
      case MouseEventArgs.MOUSE_EXIT:
        target.onMouseExit(args);
        args.handled = true; // prevent event from bubbling up.
        break;
      case MouseEventArgs.MOUSE_WHEEL:
        target.onMouseWheel(args);
        break;
    }
  }

  static void _dragEventHandler(UIElement target, DragEventArgs args) {
    if (!target.enabled) {
      return;
    }
    int t = args.eventType;
    switch (t) {
      case MouseEventArgs.MOUSE_MOVE:
        target.onDragOver(args);
        break;
      case MouseEventArgs.MOUSE_ENTER:
        target.onDragEnter(args);
        args.handled = true; // prevent event from bubbling up.
        break;
      case MouseEventArgs.MOUSE_EXIT:
        target.onDragLeave(args);
        args.handled = true; // prevent event from bubbling up.
        break;
    }
    if (args.event == dropEvent) {
      target.onDrop(args);
    }
  }

  /**
   * Starts drag & drop operation on element.
   */
  void startDragDrop(ClipboardData data,
                     bool moveElementImage) {
    Application.current.dragDropManager.startDragDrop(this,
        data, moveElementImage);
  }

  /** Provides override for subclasses to handle mouse down event. */
  void onMouseDown(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle mouse up event. */
  void onMouseUp(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle mouse move event. */
  void onMouseMove(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle mouse enter event. */
  void onMouseEnter(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle mouse exit event. */
  void onMouseExit(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle mouse wheel event. */
  void onMouseWheel(MouseEventArgs mouseArgs) {
  }

  /** Provides override for subclasses to handle drag&drop. */
  void onDragEnter(DragEventArgs dragDropArgs) {
  }

  /** Provides override for subclasses to handle drag&drop. */
  void onDragLeave(DragEventArgs dragDropArgs) {
  }

  /** Provides override for subclasses to handle drag&drop. */
  void onDragOver(DragEventArgs dragDropArgs) {
  }

  /** Provides override for subclasses to handle drag&drop. */
  void onDrop(DragEventArgs dragDropArgs) {
  }

  Object createOnDemand(PropertyDefinition property) {
    if (property == transformProperty) {
      return new UITransform();
    }
    return null;
  }

  String toString() {
    if (id != null && id is String) {
      return "${getDefinition().name} : $id";
    } else {
      return getDefinition().name;
    }
  }
}

abstract class Orientation {
  static const int HORIZONTAL = 0;
  static const int VERTICAL = 1;
}
