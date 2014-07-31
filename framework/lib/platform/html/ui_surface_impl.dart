part of uxml;

class UISurfaceImpl implements UISurface {
  /**
   * Hit testing modes.
   */
  static const int HITTEST_CONTENT = 0;
  static const int HITTEST_BOUNDS  = 1;
  static const int HITTEST_DISABLED = 2;
  static const int HITTEST_CHILDREN_DISABLED = 4;

  static const num SIN45M = 0.292893218813453; // 1-sin(45deg).
  static const num SIN225M = 0.585786437626905; // 1-sin(22.5deg).

  static const bool OPTIMIZE_DIVS = false;

  static int _counter;
  List<UISurface> rawChildren = null;
  UISurfaceTarget _surfaceTarget;
  int _hitTestMode = 0;
  bool _painted = false;
  bool _visible;
  num _opacity = 1.0;
  static bool _globalDebugEnabled = false;
  Margin _filterDist = null;
  String _tag = null;

  // Transform used for path rendering ops. This does not effect scaling the
  // actually div. Used for efficiently drawing paths.
  UITransform renderTransform = null;

  UISurfaceImpl() {
    _visible = true;
  }

  UISurface parentSurface = null;

  Application root;
  Element hostElement = null;
  CanvasElement _canvas = null;
  Filters _filters = null;
  BorderRadius _borderRadius = null;
  Brush _backgroundBrush = null;

  bool mouseEnabled = true;
  UITransform _transform = null;

  /** Surface relative offset/size to parent */
  int layoutX = 0;
  int layoutY = 0;
  int layoutW = 0;
  int layoutH = 0;
  bool locationInitialized = false;

  set target(UISurfaceTarget target) {
    _surfaceTarget = target;
  }

  UISurfaceTarget get target {
    return _surfaceTarget;
  }

  int get childCount {
    return rawChildren != null ? rawChildren.length : 0;
  }

  UISurface childAt(int index) {
    return rawChildren[index];
  }

  DocumentFragment _frag = null;

  set tag(String value) {
    if (hostElement == null) {
      _tag = value;
    } else if (_tag != null) {
      hostElement.className = _tag;
    }
  }

  void lockUpdates(bool lock) {
    if (lock) {
      _frag = new DocumentFragment();
    } else {
      if (hostElement != null) {
        hostElement.nodes.add(_frag);
      }
      _frag = null;
    }
  }

  void reparentChild(UISurface child, [int index = -1]) {
    if (OPTIMIZE_DIVS) {
      UISurfaceImpl s = child;
      if (s.hostElement != null) {
        _insertElementAt(index, s.hostElement);
      }
      child.root = root;
      return;
    }
    _addChild(child, index);
    UISurfaceImpl c = child;
    if (_frag != null) {
      if (index != -1 && _frag.nodes.length != 0) {
        _frag.insertBefore(c.hostElement, _frag.nodes[index]);
      } else {
        _frag.nodes.add(c.hostElement);
      }
    } else {
      if (index != -1) {
        hostElement.insertBefore(c.hostElement,
            hostElement.nodes[index]);
      } else {
        hostElement.nodes.add(c.hostElement);
      }
    }
    child.root = root;
  }

  void _requestCanvas() {
    if (OPTIMIZE_DIVS && hostElement == null) {
      _createElementOnDemand();
    }
    assert(_canvas == null);
    RootSurface r = root.rootSurface;
    _canvas = new Element.tag('canvas');
    hostElement.nodes.add(_canvas);
    _canvas.style.position = 'absolute';
    bool hasFilters = _filterDist != null;
    if (Application.screenPixelRatio == 1.0) {
      if (hasFilters) {
        _canvas.width = layoutW + (_filterDist.left +
            _filterDist.right).toInt();
        _canvas.height = layoutH + (_filterDist.top +
            _filterDist.bottom).toInt();
      } else {
        _canvas.width = layoutW;
        _canvas.height = layoutH;
      }
    } else {
      if (hasFilters) {
        int cw = (layoutW + _filterDist.left + _filterDist.right).toInt();
        _canvas.style.width = "${cw}px";
        int ch = layoutH + _filterDist.top + _filterDist.bottom;
        _canvas.style.height = "${ch}px";
        _canvas.width = (cw * Application.screenPixelRatio).toInt();
        _canvas.height = (ch * Application.screenPixelRatio).toInt();
      } else {
        _canvas.style.width = "${layoutW}px";
        _canvas.style.height = "${layoutH}px";
        _canvas.width = (layoutW * Application.screenPixelRatio).toInt();
        _canvas.height = (layoutH * Application.screenPixelRatio).toInt();
      }
    }
    if (hasFilters) {
      if (_filterDist.left != 0) {
        _canvas.style.left = "${-_filterDist.left}px";
      }
      if (_filterDist.top != 0) {
        _canvas.style.top = "${-_filterDist.top}px";
      }
    }
    if (_borderRadius != null) {
      _setBorderRadius(_canvas.style, _borderRadius);
    }
    hostElement.style.removeProperty("box-shadow");
  }

  void _addChild(UISurface surface, int index) {
    surface.parentSurface = this;
    if (rawChildren == null) {
      rawChildren = <UISurface>[];
    }
    if (index != -1) {
      rawChildren.insert(index, surface);
    } else {
      rawChildren.add(surface);
    }
  }

  bool removeChild(UISurface surface) {
    int index = rawChildren == null ? -1 : rawChildren.indexOf(surface);
    if (index != -1) {
      rawChildren.removeAt(index);
      return true;
    }
    return false;
  }

  /** Removes surface from DOM. */
  void close() {
    if (hostElement != null) {
      hostElement.remove();
      hostElement = null;
      _canvas = null;
    }
  }

  /** Sets surface location */
  void setLocation(int targetX,
                   int targetY,
                   int targetWidth,
                   int targetHeight) {
    bool needsRepaint = false;
    if (OPTIMIZE_DIVS && hostElement == null) {
      layoutX = targetX;
      layoutY = targetY;
      if (layoutW != targetWidth) {
        layoutW = targetWidth;
        needsRepaint = true;
      }
      if (layoutH != targetHeight) {
        layoutH = targetHeight;
        needsRepaint = true;
      }
      // Since hostElement == null, if we have any children that have
      // an actual DOM element attached, we need to update their absolute
      // position.
      // TODO(ferhat): keep a flag that indcates if we have 1 or more
      // children with dom elements attached to optimize creation time.
      UpdateQueue._updateChildLocations(this);
    } else {
      int offsetToDivX = 0;
      int offsetToDivY = 0;
      if (parentSurface != null) {
        UISurfaceImpl p = parentSurface;
        while (p != null && p.hostElement == null) {
          offsetToDivX += p.layoutX;
          offsetToDivY += p.layoutY;
          p = p.parentSurface;
        }
      }
      locationInitialized = true;
      CssStyleDeclaration style = hostElement.style;
      if (layoutX != targetX) { // .width=.width will clear canvas.
        layoutX = targetX;
        style.left = "${targetX + offsetToDivX}px";
      }
      if (layoutY != targetY) {
        layoutY = targetY;
        style.top = "${targetY + offsetToDivY}px";
      }
      if (layoutW != targetWidth) {
        layoutW = targetWidth;
        style.width = "${targetWidth}px";
        if (_canvas != null) {
          if (Application.screenPixelRatio == 1.0) {
            _canvas.width = layoutW + (_filterDist == null ?
                0 : (_filterDist.left + _filterDist.right).toInt());
          } else {
            _canvas.width = (Application.screenPixelRatio * (layoutW +
                (_filterDist == null ? 0 : (_filterDist.left +
                _filterDist.right)))).toInt();
          }
          needsRepaint = true;
        }
      }
      if (layoutH != targetHeight) {
        layoutH = targetHeight;
        style.height = "${targetHeight}px";
        if (_canvas != null) {
          if (Application.screenPixelRatio == 1.0) {
            _canvas.height = layoutH + (_filterDist == null ?
                0 : (_filterDist.top + _filterDist.bottom).toInt());
          } else {
            _canvas.height = (Application.screenPixelRatio * (layoutH +
                (_filterDist == null ? 0 : (_filterDist.top +
                _filterDist.bottom)))).toInt();
          }
          needsRepaint = true;
        }
      }
    }
    if (needsRepaint) {
      if (_surfaceTarget != null) {
        _surfaceTarget.invalidateDrawing();
      }
    }
  }

  void _updateLocation() {
    int offsetToDivX = 0;
    int offsetToDivY = 0;
    UISurfaceImpl p = parentSurface;
    while (p != null && p.hostElement == null) {
      offsetToDivX += p.layoutX;
      offsetToDivY += p.layoutY;
      p = p.parentSurface;
    }
    offsetToDivX += layoutX;
    offsetToDivY += layoutY;
    CssStyleDeclaration style = hostElement.style;
    String newLeft = "${offsetToDivX}px";
    style.left = newLeft;
    String newTop = "${offsetToDivY}px";
    style.top = newTop;
  }

  bool _clipChildren = false;

  set clipChildren(bool value) {
    _clipChildren = value;
    if (value) {
      if (UISurfaceImpl.OPTIMIZE_DIVS && hostElement == null) {
        _createElementOnDemand();
      }
      hostElement.style.overflow = "hidden";
    } else {
      if (hostElement != null) {
        hostElement.style.removeProperty("overflow"); // defaults to visible.
      }
    }
  }

  set opacity(num value) {
    if (value != _opacity) {
      if (OPTIMIZE_DIVS && hostElement == null) {
        _createElementOnDemand();
      }
      _opacity = value;
      hostElement.style.opacity = value.toStringAsFixed(2);
    }
  }

  void setBackground(Brush brush) {
    if (OPTIMIZE_DIVS && hostElement == null) {
      if (brush != null) {
        _createElementOnDemand();
      } else {
        _backgroundBrush = null;
        return;
      }
    }
    if (brush == null) {
      if (_backgroundBrush != null) {
        hostElement.style.removeProperty("background-color");
        _backgroundBrush = null;
      }
    } else {
      if (hostElement != null) {
        UIPlatform.applyBrush(hostElement, brush);
      }
      _backgroundBrush = brush;
      if (!_painted) {
        _painted = true;
        if (_filters != null) {
          applyFilters(_filters);
        }
      }
    }
  }

  void setBorderRadius(BorderRadius borderRadius) {
    if (borderRadius == null) {
      if (hostElement == null) {
        return;
      }
      if (_borderRadius != null) {
        hostElement.style.removeProperty("border-radius");
      }
      _borderRadius = null;
      return;
    }

    _borderRadius = borderRadius;
    if (hostElement == null) {
      return;
    }
    if (_canvas != null) {
      _setBorderRadius(_canvas.style, borderRadius);
    } else {
      _setBorderRadius(hostElement.style, borderRadius);
    }
  }

  void _setBorderRadius(CssStyleDeclaration style, BorderRadius borderRadius) {
    if (borderRadius != null) {
      if (borderRadius.isUniform()) {
        String cssVal = "${borderRadius.topLeft.toString()}px";
        style.borderRadius = cssVal;
      } else {
        String cssVal = "${borderRadius.topLeft.toString()}px";
        style.borderTopLeftRadius = cssVal;
        cssVal = "${borderRadius.topRight.toString()}px";
        style.borderTopRightRadius = cssVal;
        cssVal = "${borderRadius.bottomLeft.toString()}px";
        style.borderBottomLeftRadius = cssVal;
        cssVal = "${borderRadius.bottomRight.toString()}px";
        style.borderBottomRightRadius = cssVal;
      }
    }
  }

  /**
   * Clears graphics surface.
   */
  void clear() {
    if (_canvas != null) {
      CanvasRenderingContext2D context = _canvas.getContext('2d');
      context.clearRect(0, 0, _canvas.width, _canvas.height);
    }
  }

  /**
   * Drawing API.
   */
  void drawPath(VecPath path, Brush brush, Pen pen, Margin nineSlice) {
    Rect bounds = path.getBounds();
    num renderWidth = bounds.width;
    num renderHeight = bounds.height;
    UITransform pathTrans = renderTransform;
    bool transformAdjusted = false;

    if (_canvas == null) {
      _requestCanvas();
    }
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    if (_filterDist != null && (_filterDist.left != 0 ||
        _filterDist.top != 0)) {
      _canvas.style.left = "${-_filterDist.left}px";
      _canvas.style.top = "${-_filterDist.top}px";
      context.translate(_filterDist.left, _filterDist.top);
      transformAdjusted = true;
    }

    if (pathTrans != null) {
      renderWidth = pathTrans.matrix.transformSizeX(renderWidth,
          renderHeight);
      renderHeight = pathTrans.matrix.transformSizeY(bounds.width,
          renderHeight);
    }
    var fillStyle = UISurfaceImpl.brushToFillStyle(context, brush, renderWidth,
        renderHeight);
    context.fillStyle = fillStyle != null ? fillStyle : "";
    if (pen != null) {
      _applyStrokeStyle(context, pen, renderWidth, renderHeight);
    }

    if (_filters != null) {
      _applyFiltersToCanvas(context);
    }

    if (_filters == null || (_filters._innerShadow == null)) {
      context.beginPath();
      UIPlatform.drawPath(context, pathTrans, path, nineSlice);
      if (brush != null) {
        context.fill();
      }
      if (pen != null) {
        context.stroke();
      }
    } else {
      // Draw inner shadow.
      DropShadowFilter ds = _filters.getFilter(0);
      num angleRad = ds.angle * PI / 180.0;
      num xDist = cos(angleRad) * ds.distance;
      num yDist = sin(angleRad) * ds.distance;
      Color filterColor = Color.fromColor(ds.color, ds.strength);
      // Draw path itself.
      if (ds.knockout == false) {
        context.beginPath();
        UIPlatform.drawPath(context, pathTrans, path, nineSlice);
        if (brush != null) {
          context.fill();
        }
        if (pen != null) {
          context.stroke();
        }
      }

      context.save(); // save point without shadow settings.
      fillStyle="#000"; // alpha will be multiplied with shadowColor.
      // Draw inner shadow.
      context.shadowBlur = ds.blurX;
      context.shadowOffsetX = xDist;
      context.shadowOffsetY = yDist;
      context.shadowColor = filterColor.toString();

      // Draw counter clockwise base.
      if (path.direction == VecPath.DIRECTION_CLOCKWISE) {
        context.beginPath();
        context.moveTo(1000.0, -1000.0);
        context.lineTo(-1000.0, -1000.0);
        context.lineTo(-1000.0, 1000.0);
        context.lineTo(1000.0, 1000.0);
        context.lineTo(1000.0, -1000.0);
        context.closePath();
      } else {
        context.beginPath();
        context.moveTo(-1000.0, -1000.0);
        context.lineTo(1000.0, -1000.0);
        context.lineTo(1000.0, 1000.0);
        context.lineTo(-1000.0, 1000.0);
        context.lineTo(-1000.0, -1000.0);
        context.closePath();
      }
      // Now cut out shape.
      UIPlatform.drawPath(context, pathTrans, path, nineSlice);
      context.fill();
      // Remove anything that's not blue shadow.
      context.restore(); // non shadow version.
      context.globalCompositeOperation = "destination-out";
      context.fill();
      context.globalCompositeOperation = "source-over";
    }
    if (transformAdjusted) {
      context.translate(-_filterDist.left, -_filterDist.top);
    }
  }

  void drawRect(num x, num y, num width, num height,
      Brush brush, Pen pen, BorderRadius borderRadius) {
    if (_canvas == null) {
      _requestCanvas();
    }
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    var fillStyle = UISurfaceImpl.brushToFillStyle(context, brush, width,
        height);
    context.fillStyle = fillStyle != null ? fillStyle : "";
    if (pen != null) {
      _applyStrokeStyle(context, pen, width, height);
    }

    if (_filters != null) {
      _applyFiltersToCanvas(context);
    }

    if (_filters == null || _filters._innerShadow == null) {
      context.beginPath();
      _drawRoundRect(context, x, y, width, height, borderRadius);
      _painted = true;
    } else {
      // Draw inner shadow.
      DropShadowFilter ds = _filters.getFilter(0);
      num angleRad = ds.angle * PI / 180.0;
      num xDist = cos(angleRad) * ds.distance;
      num yDist = sin(angleRad) * ds.distance;
      Color filterColor = Color.fromColor(ds.color, ds.strength);
      // Draw path itself.
      if (ds.knockout == false) {
        context.beginPath();
        _drawRoundRect(context, x, y, width, height, borderRadius);
        _painted = true;
      }

      context.save(); // save point without shadow settings.
      fillStyle="#000"; // alpha will be multiplied with shadowColor.
      // Draw inner shadow.
      context.shadowBlur = ds.blurX;
      context.shadowOffsetX = xDist;
      context.shadowOffsetY = yDist;
      context.shadowColor = filterColor.toString();

      // Draw counter clockwise base.
      xDist *= 2;
      yDist *= 2;
      context.beginPath();
      context.moveTo(x + width + xDist, y - yDist);
      context.lineTo(x - xDist, y - yDist);
      context.lineTo(x - xDist, y + height + yDist);
      context.lineTo(x + width + xDist, y + height + yDist);
      context.lineTo(x + width + xDist, y - yDist);
      context.closePath();
      // Now cut out shape.
      _drawRoundRect(context, x, y, width, height, borderRadius);
      // Remove anything that's not blue shadow.
      context.restore(); // non shadow version.
      context.globalCompositeOperation = "destination-out";
      context.fill();
      context.globalCompositeOperation = "source-over";
    }
    if (pen != null) {
      context.beginPath();
      _drawRoundRect(context, x, y, width, height, borderRadius, true);
      _painted = true;
    }
  }

  void _drawRoundRect(CanvasRenderingContext2D context,
                     num x,
                     num y,
                     num width,
                     num height,
                     BorderRadius borderRadius, [bool stroke = false]) {
    if (borderRadius == null || borderRadius == BorderRadius.EMPTY) {
      if (stroke) {
        context.strokeRect(x, y, width, height);
      } else {
        context.fillRect(x, y, width, height);
      }
      return;
    }
    _createRoundedPath(context, x, y, width, height, borderRadius);
    if (stroke) {
      context.stroke();
    } else {
      context.fill();
    }
  }

  void _createRoundedPath(CanvasRenderingContext2D context,
                     num x,
                     num y,
                     num width,
                     num height,
                     BorderRadius borderRadius) {
    num ex = x + width;
    num ey = y + height;
    num minSize = width < height ? width * 2 : height * 2;
    num topLeftRadius = borderRadius.topLeft;
    num topRightRadius = borderRadius.topRight;
    num bottomLeftRadius = borderRadius.bottomLeft;
    num bottomRightRadius = borderRadius.bottomRight;
    topLeftRadius = topLeftRadius < minSize ? topLeftRadius : minSize;
    topRightRadius = topRightRadius < minSize ? topRightRadius : minSize;
    bottomLeftRadius = bottomLeftRadius < minSize ?
        bottomLeftRadius : minSize;
    bottomRightRadius = bottomRightRadius < minSize ?
        bottomRightRadius : minSize;

    // bottom-right corner
    num a = bottomRightRadius * SIN45M;
    num s = bottomRightRadius * SIN225M;
    context.moveTo(ex, ey - bottomRightRadius);
    context.quadraticCurveTo(ex, ey - s, ex - a, ey - a);
    context.quadraticCurveTo(ex - s, ey, ex - bottomRightRadius, ey);

    // bottom-left corner
    a = bottomLeftRadius * SIN45M;
    s = bottomLeftRadius * SIN225M;
    context.lineTo(x + bottomLeftRadius, ey);
    context.quadraticCurveTo(x + s, ey, x + a, ey - a);
    context.quadraticCurveTo(x, ey - s, x, ey - bottomLeftRadius);

    // top-left corner
    a = topLeftRadius * SIN45M;
    s = topLeftRadius * SIN225M;
    context.lineTo(x, y + topLeftRadius);
    context.quadraticCurveTo(x, y + s, x + a, y + a);
    context.quadraticCurveTo(x + s, y, x + topLeftRadius, y);

    // top-right corner
    a = topRightRadius * SIN45M;
    s = topRightRadius * SIN225M;
    context.lineTo(ex - topRightRadius, y);
    context.quadraticCurveTo(ex - s, y, ex - a, y + a);
    context.quadraticCurveTo(ex, y + s, ex, y + topRightRadius);
    context.lineTo(ex, ey - bottomRightRadius);
  }

  void _applyFiltersToCanvas(CanvasRenderingContext2D context) {
    if (_filters._dropShadow != null) {
      DropShadowFilter shadowFilter = _filters._dropShadow;
      num angleRad = shadowFilter.angle * PI / 180.0;
      num xDist = cos(angleRad) * shadowFilter.distance;
      num yDist = sin(angleRad) * shadowFilter.distance;
      context.shadowBlur = shadowFilter.blurX;
      context.shadowOffsetX = xDist;
      context.shadowOffsetY = yDist;
      context.shadowColor = Color.fromColor(shadowFilter.color,
          shadowFilter.strength).toString();
    }
  }

  void drawEllipse(num x, num y, num width, num height, Brush brush, Pen pen) {
    if (_canvas == null) {
      _requestCanvas();
    }
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    if (brush != null) {
      Object fillStyle = brushToFillStyle(context, brush, width, height);
      if (fillStyle != null) {
        context.fillStyle = fillStyle;
      } else if (pen == null) {
        return;
      }
    }
    if (pen != null) {
      _applyStrokeStyle(context, pen, width, height);
    }
    if (_filterDist != null && (_filterDist.left != 0 ||
        _filterDist.top != 0)) {
      _canvas.style.left = "${-_filterDist.left}px";
      _canvas.style.top = "${-_filterDist.top}px";
      context.translate(_filterDist.left, _filterDist.top);
    }
    _painted = true;

    if (_filters != null) {
      _applyFiltersToCanvas(context);
    }

    num cx = (width / 2) * .5522848;
    num cy = (height / 2) * .5522848;
    num xe = x + width;
    num ye = y + height;
    num xm = x + (width / 2);
    num ym = y + (height / 2);

    if (_filters != null && (_filters._innerShadow != null)) {
      DropShadowFilter ds = _filters.getFilter(0);
      num angleRad = ds.angle * PI / 180.0;
      num xDist = cos(angleRad) * ds.distance;
      num yDist = sin(angleRad) * ds.distance;
      Color filterColor = Color.fromColor(ds.color, ds.strength);

      // Draw shape
      if (ds.knockout == false) {
        context.moveTo(x, ym);
        context.bezierCurveTo(x, ym - cy, xm - cx, y, xm, y);
        context.bezierCurveTo(xm + cx, y, xe, ym - cy, xe, ym);
        context.bezierCurveTo(xe, ym + cy, xm + cx, ye, xm, ye);
        context.bezierCurveTo(xm - cx, ye, x, ym + cy, x, ym);
        context.closePath();
        context.fill();
      }

      context.save(); // save point without shadow settings.
      context.fillStyle="#000"; // alpha will be multiplied with shadowColor.
      // Draw inner shadow.
      context.shadowBlur = ds.blurX;
      context.shadowOffsetX = xDist;
      context.shadowOffsetY = yDist;
      context.shadowColor = filterColor.toString();

      context.beginPath();
      // Draw counter clockwise base.
      context.moveTo(xe + 1000, y - 1000);
      context.lineTo(x - 1000, y - 1000);
      context.lineTo(x - 1000, y + 1000);
      context.lineTo(x + 1000, y + 1000);
      context.lineTo(x + 1000, y - 1000);
      context.closePath();

    } else {
      context.beginPath();
    }

    context.moveTo(x, ym);
    context.bezierCurveTo(x, ym - cy, xm - cx, y, xm, y);
    context.bezierCurveTo(xm + cx, y, xe, ym - cy, xe, ym);
    context.bezierCurveTo(xe, ym + cy, xm + cx, ye, xm, ye);
    context.bezierCurveTo(xm - cx, ye, x, ym + cy, x, ym);
    context.closePath();
    if (brush != null) {
      context.fill();
    }
    if (pen != null) {
      context.stroke();
    }

    context.fillStyle = "";
    if (_filters != null && _filters._innerShadow != null) {
      context.restore(); // non shadow version.
      context.globalCompositeOperation = "destination-out";
      context.fill();
      context.globalCompositeOperation = "source-over";
    }
    if (_filterDist != null && (_filterDist.left != 0 ||
        _filterDist.top != 0)) {
      context.translate(-_filterDist.left, -_filterDist.top);
    }
  }

  void drawLine(Brush brush, Pen pen, num xFrom,num yFrom, num xTo, num yTo) {
    if (pen == null) {
      return;
    }
    if (_canvas == null) {
      _requestCanvas();
    }
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    UISurfaceImpl._applyStrokeStyle(context, pen, xTo - xFrom, yTo-yFrom);

    context.moveTo(xFrom, yFrom);
    context.lineTo(xTo, yTo);
    context.stroke();
  }

  // WebKit will scale an image on putImageData(data,x,y) to fit inside
  // bounding canvas width/height. FireFox doesn't.
  void drawBitmap(Object image,
                  num x,
                  num y,
                  num width,
                  num height,
                  bool tile) {
    if (_canvas == null) {
      _requestCanvas();
    }
    _painted = true;
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    if (_borderRadius != null) {
      _createRoundedPath(context, 0, 0, layoutW, layoutH, _borderRadius);
      context.clip();
    }

    _drawBitmap(context, image, x, y, width, height);

    if (_borderRadius != null) {
      context.restore();
    }
  }

  /**
   * Applies a path as a bitmap image mask.
   */
  void maskBitmap(Object image,
                  num x,
                  num y,
                  num width,
                  num height,
                  VecPath mask) {
    if (_canvas == null) {
      _requestCanvas();
    }
    _painted = true;
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    if (mask != null) {
      UIPlatform.drawPath(context, null, mask, null);
      context.clip();
    }
    _drawBitmap(context, image, x, y, width, height);
    context.restore();
  }

  /**
   * Draws a bitmap image onto the given context. The bitmap image is drawn at
   * the specified positions and dimensions.
   */
  void _drawBitmap(CanvasRenderingContext2D context, Object image, num x, num y,
                   num width, num height) {
    if (image is ImageData || image is FFImage) {
      CanvasElement newCanvas = new Element.tag('canvas');
      CanvasRenderingContext2D newContext = newCanvas.getContext("2d");
      if (image is ImageData) {
        ImageData imageData = image;
        newCanvas.width = imageData.width.toInt();
        newCanvas.height = imageData.height.toInt();
        newContext.putImageData(imageData, 0, 0);
      } else if (image is FFImage) {
        FFImage ffImage = image;
        Object imageData = ffImage.data;
        newCanvas.width = ffImage.width.toInt();
        newCanvas.height = ffImage.height.toInt();
        newContext.putImageData(imageData, 0, 0);
      }
      context.drawImageScaled(newCanvas, x, y, width, height);
    } else {
      context.drawImageScaled(image, x, y, width, height);
    }
  }

  void drawBitmapTransformColor(Object image,
                                num x,
                                num y,
                                num width,
                                num height,
                                bool tile,
                                ColorTransform transform) {
    if (_canvas == null) {
      _requestCanvas();
    }
    _painted = true;
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    if (Application.screenPixelRatio > 1.0) {
      context.scale(Application.screenPixelRatio, Application.screenPixelRatio);
    }
    if (image is ImageData) {
      context.putImageData(image, x, y);
    } else if (image is FFImage) {
      FFImage ffImage = image;
      context.drawImage(ffImage.data, -x, -y);
    } else {
      context.drawImageScaled(image, x, y, width, height);
    }
    if (transform != null) {
      ImageData imageData = context.getImageData(x, y, width, height);
      if (imageData.data is Uint8ClampedList) {
        Uint8ClampedList bytes = imageData.data;
        int numBytes = bytes.length;
        num aMult = transform.alphaMultiplier;
        num rMult = transform.redMultiplier;
        num gMult = transform.greenMultiplier;
        num bMult = transform.blueMultiplier;
        num aOffset = transform.alphaOffset * 255.0;
        num rOffset = transform.redOffset * 255.0;
        num gOffset = transform.greenOffset * 255.0;
        num bOffset = transform.blueOffset * 255.0;
        if (transform.monoChrome) {
          for (int i = numBytes - 4; i >= 0; i-=4) {
            num rgb = (bytes[i] + bytes[i + 1] + bytes[i + 2]) / 3.0;
            int c = ((rgb * rMult) + rOffset).toInt();
            bytes[i] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((rgb * gMult) + gOffset).toInt();
            bytes[i + 1] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((rgb * bMult) + bOffset).toInt();
            bytes[i + 2] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((bytes[i + 3] * aMult) + aOffset).toInt();
            bytes[i + 3] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
          }
        } else {
          for (int i = numBytes - 4; i >= 0; i-=4) {
            int c = ((bytes[i] * rMult) + rOffset).toInt();
            bytes[i] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((bytes[i + 1] * gMult) + gOffset).toInt();
            bytes[i + 1] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((bytes[i + 2] * bMult) + bOffset).toInt();
            bytes[i + 2] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
            c = ((bytes[i + 3] * aMult) + aOffset).toInt();
            bytes[i + 3] = c < 0 ? 0 : ( (c > 255) ? 255 : c);
          }
        }
        context.putImageData(imageData, x, y);
      }
    }
  }

  void drawImage(String source) {
    ImageElement _image = null;
    if (hostElement.nodes.length != 0) {
      Element elm = hostElement.nodes[0];
      if (elm is ImageElement) {
        _image = elm;
      } else {
        hostElement.nodes.clear();
      }
    }
    if (_image == null) {
      RootSurface r = root.rootSurface;
      ImageElement childImage = new Element.tag('img');
      hostElement.nodes.add(childImage);
    }
    if (_image.src != source) {
      _image.src = source;
    }
    _painted = true;
    _image.style.position = 'absolute';
    _image.style.width = '100%';
    _image.style.height = '100%';
    _image.width = layoutW;
    _image.height = layoutH;
  }

  static void _applyStrokeStyle(CanvasRenderingContext2D context, Pen pen,
                                 num w, num h) {
    if (pen is SolidPen) {
      SolidPen sPen = pen;
      context.lineWidth = sPen.thickness;
      context.strokeStyle = sPen.color.toString();
    }
  }

  static Object brushToFillStyle(CanvasRenderingContext2D context, Brush brush,
      num w, num h) {
    if (brush is SolidBrush) {
      SolidBrush sBrush = brush;
      return sBrush.color.toString();
    } else if (brush is LinearBrush) {
      LinearBrush br = brush;
      // create a gradient object from the canvas context
      CanvasGradient gradient = context.createLinearGradient(br.start.x * w,
          br.start.y * h, br.end.x * w, br.end.y * h);
      int numStops = br.stops.length;
      List<GradientStop> stops = br.stops;
      for (int i = 0; i < numStops; i++) {
        gradient.addColorStop(stops[i].offset, stops[i].color.toString());
      }
      return gradient;
    }
    return null;
  }

  void _createElementOnDemand() {
    assert(null == hostElement);
    hostElement = new Element.tag('div');
    if (_tag != null) {
      hostElement.className = _tag;
    }
    if (parentSurface != null) {
      parentSurface._hostElementCreated(this);
    }
    if (OPTIMIZE_DIVS) {
      if (!locationInitialized) {
        locationInitialized = true;
        CssStyleDeclaration style = hostElement.style;
        int offsetToDivX = 0;
        int offsetToDivY = 0;
        if (parentSurface != null) {
          UISurfaceImpl p = parentSurface;
          while (p != null && p.hostElement == null) {
            offsetToDivX += p.layoutX;
            offsetToDivY += p.layoutY;
            p = p.parentSurface;
          }
        }
        if ((layoutX + offsetToDivX) != 0) { // .width=.width will clear canvas.
          style.left = "${layoutX + offsetToDivX}px";
        }
        if ((layoutY +offsetToDivY) != 0) {
          style.top = "${layoutY + offsetToDivY}px";
        }
        style.width = "${layoutW}px";
        if (_canvas != null) {
          if (Application.screenPixelRatio == 1.0) {
            _canvas.width = layoutW + (_filterDist == null ?
                0 : _filterDist.right);
          } else {
            _canvas.width = (Application.screenPixelRatio * (layoutW +
                (_filterDist == null ? 0 : _filterDist.right))).toInt();
          }
        }
        style.height = "${layoutH}px";
        if (_canvas != null) {
          if (Application.screenPixelRatio == 1.0) {
            _canvas.height = layoutH + (_filterDist == null ?
                0 : _filterDist.bottom);
          } else {
            _canvas.height = (Application.screenPixelRatio * (layoutH +
                (_filterDist == null ? 0 : _filterDist.bottom))).toInt();
          }
        }
      }
      CssStyleDeclaration style = hostElement.style;
      if (!_visible) {
        style.display = "none";
      }
      if (_opacity != 1.0) {
        style.opacity = _opacity.toStringAsFixed(2);
      }
      if (_clipChildren) {
        style.overflow = "hidden";
      }
      if (_borderRadius != null) {
        if (_canvas != null) {
          _setBorderRadius(_canvas.style, _borderRadius);
        } else {
          _setBorderRadius(style, _borderRadius);
        }
      }
      if (_backgroundBrush != null) {
        UIPlatform.applyBrush(hostElement, _backgroundBrush);
      }
      if (_transform != null) {
        surfaceTransform = _transform;
      }
      if (_filters != null) {
        applyFilters(_filters);
      }
    }
    _onInitSurface();
  }

  void _onInitSurface() {
  }

  UISurface addChild(UISurface child) {
    UISurfaceImpl c = child;
    _addChild(c, -1);
    c.root = root;
    if (OPTIMIZE_DIVS == false) {
      c._createElementOnDemand();
    }
    return child;
  }

  UISurface insertChild(int index, UISurface child) {
    UISurfaceImpl c = child;
    _addChild(c, index);
    c.root = root;
    if (OPTIMIZE_DIVS == false) {
      c._createElementOnDemand();
    }
    return child;
  }

  // We need to find the next element starting at child index.
  void _insertElementAt(int index, Element newChild) {
    int numChildren = rawChildren.length;
    while (index < (numChildren - 1)) {
      ++index;
      UISurfaceImpl next = rawChildren[index];
      Element elm = next._findFirstElement();
      if (elm != null) {
        elm.parent.insertBefore(newChild, elm);
        return;
      }
    }
    // None of the siblings after index have elements attached.
    // Append.
    if (hostElement != null) {
      hostElement.append(newChild);
      return;
    }
    UISurfaceImpl p = parentSurface;
    p._insertElementAt(p.rawChildren.indexOf(this), newChild);
  }

  /**
   * Finds first element in subtree that has a valid element attached.
   *
   * TODO(ferhat): this is very inefficient at startup time since
   * siblings have deep trees with no elements when we create surfaces
   * back-to-front. Optimize this by keeping track of empty routes.
   */
  Element _findFirstElement() {
    if (hostElement != null) {
      return hostElement;
    }
    if (rawChildren == null) {
      return null;
    }
    int numChildren = rawChildren.length;
    int index = 0;
    Element elm = null;
    while (index < numChildren) {
      UISurfaceImpl child = rawChildren[index];
      elm = child._findFirstElement();
      if (elm != null) {
        return elm;
      }
      ++index;
    }
    return null;
  }

  void _hostElementCreated(UISurfaceImpl child) {
    int index;
    int numChildren = rawChildren.length;
    if (numChildren == 0 || child == rawChildren[numChildren - 1]) {
      index = -1;
    }
    index = rawChildren.indexOf(child);
    if (OPTIMIZE_DIVS) {
      _insertElementAt(index, child.hostElement);
      // Now place all children under this element.
      List childElements = [];
      child._findChildElements(childElements);
      for (int i = 0; i < childElements.length; i++) {
        child.hostElement.append(childElements[i].hostElement);
      }
      if (childElements.length > 0) {
        UpdateQueue._updateChildLocations(child);
      }
    } else {
      if (_frag != null) {
        if (index != -1 && index < _frag.nodes.length) {
          _frag.insertBefore(child.hostElement, _frag.nodes[index]);
        } else {
          _frag.nodes.add(child.hostElement);
        }
      } else {
        if (index != -1 && index < hostElement.nodes.length) {

          hostElement.insertBefore(child.hostElement,
              hostElement.nodes[index]);
        } else {
          hostElement.nodes.add(child.hostElement);
        }
      }
    }
    child.hostElement.style.position = 'absolute';
    // On Ios, embedded UIWebViews will flicker during transitions if 3d
    // transforms are used. This is mitigated by setting backfaceVisibility
    // css property to 'hidden'. In fact, it improves performance (FPS) at the
    // cost of parsing the css property at loadtime. See:
    // http://albertogasparin.it/articles/2011/06/ios-css-animations-performances/
    if (Application.isIos && Application.isMobile) {
      child.hostElement.style.backfaceVisibility = 'hidden';
    }
  }

  /** Returns children that have elements associated in display list order */
  void _findChildElements(List list) {
    if (rawChildren == null) {
      return;
    }
    int numChildren = rawChildren.length;
    for (int i = 0; i < numChildren; i++) {
      UISurfaceImpl child = rawChildren[i];
      if (child.hostElement != null) {
        list.add(child);
      } else {
        child._findChildElements(list);
      }
    }
  }

  /**
   * Sets or returns the surface transform.
   */
  set surfaceTransform(UITransform transform) {
    if (transform != null) {
      Matrix matrix = transform.matrix;
      _transform = transform;
      if (hostElement != null) {
        num centerMoveX = 0;
        num centerMoveY = 0;
        bool originShift = false;
        if (transform.overridesProperty(UITransform.originXProperty) ||
            transform.overridesProperty(UITransform.originYProperty)) {
          num originX = 0.5 - transform.originX;
          num originY = 0.5 - transform.originY;
          if (originX != 0 || originY != 0) {
            centerMoveX = (layoutW * matrix.a * originX) +
                (layoutH * matrix.b * originY) - (layoutW * originX);
            centerMoveY = (layoutW * matrix.c * originX) +
                (layoutH * matrix.d * originY) - (layoutH * originY);
            originShift = true;
          }
        }
        if (Application.isWebKit) {
          StringBuffer transformBuilder = new StringBuffer();
          num tx = _transform.translateX;
          num ty = _transform.translateY;
          if (originShift) {
            tx += centerMoveX;
            ty += centerMoveY;
          }
          if (tx != 0 || ty != 0) {
            transformBuilder.write('translate3d(${tx}px,');
            transformBuilder.write('${ty}px,0px) ');
          }
          if (_transform.scaleX != 1 || _transform.scaleY != 1) {
            transformBuilder.write('scale3d(${_transform.scaleX},');
            transformBuilder.write('${_transform.scaleY},1) ');
          }
          if (_transform.rotate != 0) {
            transformBuilder.write('rotate3d(0,0,1,${_transform.rotate}deg) ');
          }
          hostElement.style.setProperty("-webkit-transform",
              transformBuilder.toString());
        } else if (Application.isIE) {
          hostElement.style.setProperty("-ms-transform", _transform.toString());
        } else {
          hostElement.style.transform = _transform.toString();
        }
      }
    } else {
      if (_transform != null) {
        if (Application.isWebKit) {
          hostElement.style.removeProperty("-webkit-transform");
        } else if (Application.isIE) {
          hostElement.style.removeProperty("-ms-transform");
        } else {
          hostElement.style.removeProperty("transform");
        }
      }
      // scaleX = 1;
      // scaleY = 1;
      // Reset transform on html element
    }
  }

  UITransform get surfaceTransform =>  _transform;

  set hitTestMode(int mode) {
    _hitTestMode = mode;
  }

  set visible(bool value) {
    if (_visible != value) {
      _visible = value;
      if (hostElement != null) {
        if (value) {
          hostElement.style.display = "";
        } else {
          hostElement.style.display = "none";
        }
      }
    }
  }

  void cursorChanged(Cursor cursor) {
    if (Application.isIE && hostElement != null) {
      if (cursor == null) {
        hostElement.style.removeProperty("cursor");
      } else {
        hostElement.style.cursor = _cursorToCursorStyle(cursor);
      }
    }
  }

  bool get visible {
    return _visible;
  }

  void applyFilters(Filters filters) {
    _filters = filters;
    // Clear existing filters.
    if (filters == null || filters.length == 0) {
      if (hostElement != null) {
        hostElement.style.removeProperty("box-shadow");
      }
      _filterDist = null;
      return;
    }
    if (_filterDist == null) {
      _filterDist = new Margin(0, 0, 0, 0);
    } else {
      _filterDist.left = 0;
      _filterDist.top = 0;
      _filterDist.right = 0;
      _filterDist.bottom = 0;
    }
    bool requiresCanvasRefresh = false;
    for (int f = 0; f < filters.length; f++) {
      Filter filter = filters.getFilter(f);
      if (filter is DropShadowFilter) {
        DropShadowFilter shadowFilter = filter;
        num angleRad = shadowFilter.angle * PI / 180.0;
        num xDist = cos(angleRad) * shadowFilter.distance;
        num blurX = max(1, shadowFilter.blurX);
        num blurY = max(1, shadowFilter.blurY);
        // Keep track of max filtere distance so we can resize the canvas
        // to contain enough space for shadow.
        if (xDist >= 0) {
          if ((xDist + blurX) > _filterDist.right) {
            _filterDist.right = xDist + blurX;
          }
          // If xDist > blurX, nothing bleeding out of object on the left side.
          // xDist+blurX on right side. Otherwise we have filter rendering to
          // the left of object too.
          if ((xDist < blurX) && ((blurX - xDist) > _filterDist.left)) {
            _filterDist.left = (blurX - xDist);
          }
        } else {
          if ((blurX - xDist) > _filterDist.left) {
            _filterDist.left = blurX - xDist;
          }
          if ((-xDist < blurX) && ((blurX + xDist) > _filterDist.right)) {
            _filterDist.right = blurX + xDist;
          }
        }
        num yDist = sin(angleRad) * shadowFilter.distance;
        if (yDist >= 0) {
          if ((yDist + blurY) > _filterDist.bottom) {
            _filterDist.bottom = yDist + blurY;
          }
          if ((yDist < blurY) && ((blurY - yDist) > _filterDist.top)) {
            _filterDist.top = (blurY - yDist);
          }
        } else {
          if ((blurY - yDist) > _filterDist.top) {
            _filterDist.top = blurY - yDist;
          }
          if ((-yDist < blurY) && ((blurY + yDist) > _filterDist.bottom)) {
            _filterDist.bottom = blurY + yDist;
          }
        }
        if (hostElement != null) {
          // For canvas, force a repaint on filter update.
          if (_canvas != null) {
            hostElement.style.removeProperty("box-shadow");
            requiresCanvasRefresh = true;
          } else {
            if (_painted) {
              // For non-canvas divs, just set boxShadow.
              Color filterColor = Color.fromColor(shadowFilter.color,
                  shadowFilter.strength);
              StringBuffer sb = new StringBuffer();
              sb.write(shadowFilter.inner ? "inset " : "");
              sb.write(xDist.toInt().toString());
              sb.write("px ");
              sb.write(yDist.toInt().toString());
              sb.write("px ");
              sb.write(shadowFilter.blurX.toString());
              sb.write("px ");
              sb.write(filterColor.toString());
              hostElement.style.boxShadow = sb.toString();
            }
          }
        }
      }
    }
    if (requiresCanvasRefresh) {
      _canvas.width = layoutW + (_filterDist.left + _filterDist.right).toInt();
      _canvas.height = layoutH + (_filterDist.top + _filterDist.bottom).toInt();
      _canvas.style.left = "${-_filterDist.left}px";
      _canvas.style.top = "${-_filterDist.top}px";
      _surfaceTarget.invalidateDrawing();
    }
  }

  bool get enableHitTesting {
    return (_hitTestMode & HITTEST_DISABLED) == 0;
  }

  set enableHitTesting(bool value) {
    if (value) {
      _hitTestMode &= ~HITTEST_DISABLED;
    } else {
      _hitTestMode |= HITTEST_DISABLED;
      if (hostElement != null) {
        hostElement.style.pointerEvents = "none";
      }
    }
  }

  /**
   * Sets or returns if mouse event are handled by children.
   */
  bool get enableChildHitTesting {
    return (_hitTestMode & HITTEST_CHILDREN_DISABLED) == 0;
  }

  set enableChildHitTesting(bool value) {
    if (value) {
      _hitTestMode &= ~HITTEST_CHILDREN_DISABLED;
    } else {
      _hitTestMode |= HITTEST_CHILDREN_DISABLED;
    }
  }

  /**
   * Returns child surface under given local mouse coordinates.
   */
  UISurface hitTest(num mouseX, num mouseY) {
    bool debugEnabled = UISurfaceImpl._globalDebugEnabled &&
        KeyboardEventArgs.altKey;
    if (debugEnabled) {
      if (target!= null && target is UIElement) {
        UIElement ue = target;
        Application.current.log("mouse = $mouseX , $mouseY");
        Application.current.log("starting hit testing ${ue.toString}"
            "layoutXYWH=$layoutX, $layoutY, $layoutW, $layoutH id=${ue.id}");
      } else {
        Application.current.log("mouse = $mouseX , $mouseY"
          " target null ${this.toString()}"
          " layoutXYWH= $layoutX, $layoutY, $layoutW, $layoutH");
      }
    }

    if ((_hitTestMode & HITTEST_DISABLED) != 0 &&
        (_hitTestMode & HITTEST_CHILDREN_DISABLED) != 0) {
      return null;
    }
    num mx = mouseX;
    num my = mouseY;

    if (visible == false || _opacity == 0.0) {
      return null;
    }

    // Don't check children if hit point is outside our mask bounds
    if ((_clipChildren == true) && ((mx < 0) || (my < 0) ||
        (mx >= layoutW) || (my >= layoutH))) {
      return null;
    }
    // TODO(ferhat): hittest mask
    // end check mask/clip bounds.

    UISurface surface = null;

    // Hit test each child surface front to back
    if ((_hitTestMode & HITTEST_CHILDREN_DISABLED) == 0) {
      for (int i = childCount - 1; i >= 0; --i) {
        Object dispObj = rawChildren[i];
        if (dispObj is UISurface) {
          UISurface s = dispObj;
          if (!s.visible) {
            continue;
          }
          if (s.hasTransform) {
            UITransform t = s.surfaceTransform;
            Matrix m = t.matrix;
            Matrix mOrigin = m.clone();
            num cx = s.layoutW * t.originX;
            num cy = s.layoutH * t.originY;
            mOrigin.tx = (-m.a * cx) + (-m.b * cy) + m.tx + cx;
            mOrigin.ty = (-m.c * cx) + (-m.d * cy) + m.ty + cy;
            // distance to untransformed left,top
            num distanceToLeftTopX = mx - s.layoutX;
            num distanceToLeftTopY = my - s.layoutY;
            num newX = mOrigin.transformPointXInverse(distanceToLeftTopX,
                distanceToLeftTopY);
            num newY = mOrigin.transformPointYInverse(distanceToLeftTopX,
                distanceToLeftTopY);
            surface = s.hitTest(newX, newY);
          } else {
            mouseX -= s.layoutX;
            mouseY -= s.layoutY;
            surface = s.hitTest(mouseX, mouseY);
            mouseX += s.layoutX;
            mouseY += s.layoutY;
          }
          if (surface != null) {
            if (debugEnabled) {
              UIElement u = surface.target;
              Application.current.log("hit test success on child ${u.toString}"
                  " id= ${u.id}");
            }
            return surface;
          }
        }
      }
    }

    if ((_hitTestMode & HITTEST_DISABLED) != 0) {
      return null;
    }
    if ((mx >= 0) && (my >= 0) && (mx < layoutW) && (my < layoutH)) {
      if (debugEnabled) {
        UIElement u = target;
        Application.current.log("hit test success on self $u id=${u.id}");
      }
      if ((_hitTestMode & HITTEST_BOUNDS) != 0) {
        return this;
      } else {
        if (_painted == true) {
          return this;
        }
//        // TODO(ferhat): hit test using shapes and what's physically painted
//        // inline localtoglobal
//        UISurfaceImpl parentObj = this;
//        while (parentObj != null) {
//          if (parentObj.hasTransform) {
//            num newMX = parentObj.transform.matrix.tx +
//                (parentObj.transform.matrix.a * mouseX) +
//                (parentObj.transform.matrix.b * mouseY);
//            num newMY = parentObj.transform.matrix.ty +
//                (parentObj.transform.matrix.c * mouseX) +
//                (parentObj.transform.matrix.d * mouseY);
//            mouseX = newMX;
//            mouseY = newMY;
//          } else {
//            mouseX += parentObj.layoutX;
//            mouseY += parentObj.layoutY;
//          }
//          parentObj = parentObj.parent;
//        }
//        if (hitTestPoint(mouseX, mouseY, true)) {
//          return this;
//        }
      }
    }

    return null;
  }

  bool get hasTransform {
    return _transform != null;
  }

  String _cursorToCursorStyle(Cursor cursor) {
    return cursor.name;
  }

  bool setupTopLevelCursor(Cursor cursor) {
    Document doc = document;
    Element body = document.body;
    if (body != null) {
      body.style.cursor = _cursorToCursorStyle(cursor);
      if (Application.isIE) {
        Element htmlElement = doc.documentElement;
        htmlElement.style.cursor = _cursorToCursorStyle(cursor);
      }
      return true;
    }
    return false;
  }
}

class UITextSurfaceImpl extends UISurfaceImpl implements UITextSurface {
  UITextSurfaceImpl() : super() {
    _textColor = Color.BLACK;
  }

  String _text;
  String _fontName;
  num _fontSize = 10;
  Color _textColor;
  bool _fontBold;
  bool _divDirty = false;
  bool _wordWrap = false;

  static final num _INNER_PADDING = 2;

  num measuredWidth = 0;
  num measuredHeight = 0;
  int maxChars;
  static TextMeasureUtils _measureUtils = null;
  bool _isHtmlText = false;

  /**
   * Sets text.
   */
  set text(String value) {
    if (value != _text) {
      _isHtmlText = false;
      _text = value;
      int nlPos = -1;
      if (_text == null || !(_text is String)) {
        _text = "";
      } else {
        nlPos = _text.indexOf("\n");
      }
      int start = 0;
      if (UISurfaceImpl.OPTIMIZE_DIVS && hostElement == null) {
        _createElementOnDemand();
      }
      if (nlPos == -1) {
        hostElement.innerHtml = HtmlSanitizer.sanitize(_text,
            useWhiteList:false);
      } else {
        StringBuffer sb = new StringBuffer();
        do {
          sb.write("<p>");
          sb.write(HtmlSanitizer.sanitize(_text.substring(start, nlPos)));
          start = nlPos + 1;
          sb.write("</p>");
          nlPos = _text.indexOf("\n", start);
        } while (nlPos != -1);
        hostElement.innerHtml = sb.toString();
      }
      hostElement.style.left = "${layoutX + _INNER_PADDING}px";
      hostElement.style.top = "${layoutY + _INNER_PADDING}px";
    }
  }

  /**
   * Sets text.
   */
  set htmlText(String value) {
    if (value != _text) {
      _isHtmlText = true;
      if (UISurfaceImpl.OPTIMIZE_DIVS && hostElement == null) {
        _createElementOnDemand();
      }
      hostElement.style.left = "${layoutX + _INNER_PADDING}px";
      hostElement.style.top = "${layoutY + _INNER_PADDING}px";
      if (value.length != 0) {
        try {
          var textElement = new Element.html(value);
          if (hostElement.nodes.length == 0) {
            hostElement.nodes.add(textElement);
          } else {
            hostElement.nodes[0].replaceWith(textElement);
          }
          _text = value;
          return;
        } on Exception catch (e) {
          print(e);
        }
      }
      // Clear.
      if (hostElement.nodes.length != 0) {
        hostElement.nodes.removeLast();
      }
    }
  }

  /**
   * Sets font name.
   */
  set fontName(String fontName) {
    _fontName = fontName;
    _divDirty = true;
  }

  /**
   * Sets font size.
   */
  set fontSize(num fontSize) {
    _fontSize = fontSize;
    _divDirty = true;
  }

  /**
   * Sets font bold.
   */
  set fontBold(bool fontBold) {
    _fontBold = fontBold;
    _divDirty = true;
  }

  /**
   * Sets text color.
   */
  set textColor(Color textColor) {
    if (!(textColor is Color)) {
      textColor = Color.BLACK;
    }
    _textColor = textColor;
    _divDirty = true;
  }

  /**
   * Measures size of image given width constraint.
   */
  void measureText(String textValue, num availWidth, num availHeight,
                   bool sizeToBold) {
    updateTextView();
    if (_measureUtils == null) {
      _measureUtils = new TextMeasureUtils();
    }
    _measureUtils.setFont(_fontName, _fontSize, sizeToBold ? true : _fontBold);
    String text = (_text != null && _text is String) ? _text : "";
    _measureUtils.measure(HtmlSanitizer.sanitize(text,
        useWhiteList:_isHtmlText), availWidth, availHeight,
        _wordWrap);
    measuredWidth = _measureUtils.width;
    measuredHeight = _measureUtils.height;
  }

  void updateTextView() {
    if (_divDirty) {
      CssStyleDeclaration style = hostElement.style;
      if (_fontName != "") {
        style.fontFamily = _fontName;
      }
      style.color = _textColor.toString();
      if (_fontBold) {
        style.fontWeight = "700";
      } else {
        style.removeProperty("font-weight");
      }
      style.fontSize = "${_fontSize.toInt().toString()}px";
      hostElement.style.left = "${layoutX + _INNER_PADDING}px";
      hostElement.style.top = "${layoutY + _INNER_PADDING}px";
      _divDirty = false;
    }
  }

  /** Sets surface location */
  void setLocation(int targetX,
                   int targetY,
                   int targetWidth,
                   int targetHeight) {
    bool needsRepaint = false;
    CssStyleDeclaration style = hostElement.style;
    if (layoutX != targetX) { // .width=.width will clear canvas.
      layoutX = targetX;
      style.left = "${targetX + _INNER_PADDING}px";
    }
    if (layoutY != targetY) {
      layoutY = targetY;
      style.top = "${targetY + _INNER_PADDING}px";
    }
    if (layoutW != targetWidth) {
      if (_canvas != null) {
        if (_wordWrap) {
          _canvas.width = layoutW;
        }
        needsRepaint = true;
      }
      layoutW = targetWidth;
      if (_wordWrap) {
        style.width = "${targetWidth}px";
      }
    }
    if (layoutH != targetHeight) {
      layoutH = targetHeight;
      style.height = "${targetHeight}px";
      if (_canvas != null) {
        _canvas.height = layoutH;
        needsRepaint = true;
      }
    }
    if (needsRepaint) {
      if (_surfaceTarget != null) {
        _surfaceTarget.invalidateDrawing();
      }
    }
  }

  set wordWrap(bool value) {
    _wordWrap = value;
    if (hostElement != null) {
      if (value) {
        if (_wordWrap) {
          hostElement.style.width = "${layoutW}px";
        }
      } else {
        hostElement.style.removeProperty("width");
      }
    }
  }

  set textAlign(int value) {
    if (hostElement != null) {
      if (value == 0) {
        hostElement.style.textAlign = "";
      } else {
        hostElement.style.textAlign = (value == 1) ? "center" : "right";
      }
    }
  }

  /** TODO(ferhat): impl Override to handle hyperlink event. */
  set onTextLink(EventHandler handler) {
  }

  void applyFilters(Filters filters) {
    if (filters == null) {
      // Clear existing filters.
      hostElement.style.removeProperty("text-shadow");
      return;
    }

    for (int f = 0; f < filters.length; f++) {
      Filter filter = filters.getFilter(f);
      if (filter is DropShadowFilter) {
        if (hostElement != null) {
          DropShadowFilter shadowFilter = filter;
          num angleRad = shadowFilter.angle * PI / 180.0;
          num xDist = cos(angleRad) * shadowFilter.distance;
          num yDist = sin(angleRad) * shadowFilter.distance;
          Color filterColor = Color.fromColor(shadowFilter.color,
              shadowFilter.strength);
          String boxShadowValue = "${xDist.toInt().toString()} px "
              "${yDist.toInt().toString()} px "
              "${shadowFilter.blurX.toString()} px "
              "${filterColor.toString()}";
          if (shadowFilter.inner) {
            boxShadowValue = "inset $boxShadowValue";
          }
          hostElement.style.textShadow = boxShadowValue;
        }
      }
    }
  }

  set selectable(bool value) {
    if (hostElement != null) {
      if (value) {
        hostElement.style.removeProperty("user-select");
        hostElement.style.removeProperty("-webkit-user-select");
        hostElement.style.removeProperty("cursor");
      } else {
        hostElement.style.userSelect = "none";
        if (!Application.isFF) {
          hostElement.style.setProperty("-webkit-user-select", "none");
        }
        hostElement.style.cursor = "default";
      }
    }
  }

  void cursorChanged(Cursor cursor) {
    if (hostElement != null) {
      hostElement.style.cursor = _cursorToCursorStyle(cursor);
    }
  }
}

/**
 * Utility to measure text using a shared documentFragment and span.
 * Assumes that fontname,textcolor don't change much from one measurement
 * to next to optimize style setters.
 */
class TextMeasureUtils {
  Element hiddenTextElem = null;
  Element hiddenTextDivParent = null;
  Element hiddenTextDiv = null;
  String _fontName = "";
  num _fontSize = 0;
  bool _fontBold = false;
  int _argb = 0xFF00000000;
  num width;
  num height;
  CanvasElement canvas;
  String _fontKey;
  String _fontSizeStr;
  Map<String, num> _heightCache;
  Map<String, num> _heightCacheBold;
  static final num _INNER_PADDING2 = 4;

  TextMeasureUtils() {
    _heightCache = new Map<String, num>();
    _heightCacheBold = new Map<String, num>();
    hiddenTextElem = new Element.tag('documentFragment');
    hiddenTextElem.style.visibility = "hidden";
    hiddenTextElem.style.width = "100%";
    document.body.nodes.add(hiddenTextElem);
    CssStyleDeclaration style = hiddenTextElem.style;
    style.position = 'absolute';
    style.margin = "0";
    style.border = "0";
    style.padding = "0";
    hiddenTextDiv = new Element.tag('div');
    hiddenTextDivParent = new Element.tag('div');
    style = hiddenTextDivParent.style;
    style.position = 'absolute';
    style.margin = "0";
    style.border = "0";
    style.padding = "0";
    hiddenTextElem.nodes.add(hiddenTextDivParent);
    hiddenTextDivParent.nodes.add(hiddenTextDiv);
    canvas = new Element.tag('canvas');
    hiddenTextElem.nodes.add(canvas);
  }

  void setFont(String fontName, num fontSize, bool fontBold) {
    CssStyleDeclaration style = hiddenTextDiv.style;
    if (_fontSize != fontSize) {
      _fontSize = fontSize;
      _fontSizeStr = "${_fontSize.toInt().toString()}px";
      style.fontSize = _fontSizeStr;
    }
    if (_fontName != fontName) {
      _fontName = fontName;
      style.fontFamily = fontName;
    }
    if (_fontBold != fontBold) {
      _fontBold = fontBold;
      if (fontBold) {
        style.fontWeight = "700";
      } else {
        style.removeProperty("font-weight");
      }
    }
    if (_fontBold) {
      _fontKey = "bold $_fontSizeStr $fontName";
    } else {
      _fontKey = "$_fontSizeStr $fontName";
    }
  }

  void measure(String text, num availWidth, num availHeight, bool wordWrap) {
    num screenCssPixelRatio = (window.outerWidth) / window.innerWidth;
    bool screenZoomed = (screenCssPixelRatio < .98 ||
        screenCssPixelRatio > 1.02);
    if (wordWrap == false && _heightCache.containsKey(_fontKey) &&
        screenCssPixelRatio > 0.66 && text != "") {
      CanvasRenderingContext2D context = canvas.getContext("2d");
      context.font = _fontKey;
      TextMetrics metrics = context.measureText(text);
      width = metrics.width + _INNER_PADDING2;
      height = _heightCache[_fontKey];
    } else if (text == ""){
      width = 0;
      height = 0;
    } else {
      CssStyleDeclaration style = hiddenTextDivParent.style;
      hiddenTextDiv.innerHtml = text;
      width = hiddenTextDivParent.offset.width + _INNER_PADDING2;
      height = hiddenTextDivParent.offset.height + _INNER_PADDING2;
      if (width > availWidth) {
        if (wordWrap) {
          String wConstraint = (availWidth < 0 ? 0 :
              availWidth).toInt().toString();
          hiddenTextDiv.style.wordWrap = "normal";
          style.width = "${wConstraint}px";
        } else {
          style.removeProperty("width");
        }
        width = hiddenTextDivParent.offset.width + _INNER_PADDING2;
        height = hiddenTextDivParent.offset.height + _INNER_PADDING2;
      }
      // Cache single line height for font&size to speed up measurement.
      // Check for height 0 case when there is no text.
      if (screenZoomed == false && text != "" && wordWrap == false &&
          (height != 0)) {
        _heightCache[_fontKey] = height;
      }
      style.removeProperty("width");
    }

    // Correct for zoom ratio.
    if (screenZoomed) {
      // fractional pixel correction when zoomed in.
      width = (((width * screenCssPixelRatio).ceil()) /
          screenCssPixelRatio).ceil();
      // correct for very small ratios.
      if (screenCssPixelRatio < 0.67) {
        // font getting quite small , lot of errors due to browser
        // mapping to larger font if we dont' correct.
        width = width - _INNER_PADDING2 + 1 +
            (_INNER_PADDING2 / screenCssPixelRatio);
        height += 2;
      } else if (screenCssPixelRatio < 0.98) {
        width++;
        height++;
      }
    }
  }
}
