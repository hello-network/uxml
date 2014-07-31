part of uxml;

typedef void TextChangedCallback(String text);

abstract class IosSurface {
  set tag(String value);
  set visible(bool value);
  set opacity(num value);
  set clipChildren(bool value);
  void clear();
  void insertChildAt(int index, IosSurface child);
  void setBounds(int x, int y, int width, int height);
  void setBackground(String jsonBrush);
  void setBorderRadius(num topLeft, num topRight, num bottomRight,
                       num bottomLeft);
  bool hitTest(num mouseX, num mouseY);
  void setTransform(num a, num b, num c, num d, num tx, num ty);
  void drawPath(String rpc);
  void drawEllipse(String rpc);
  void drawBitmap(Object image, num x, num y, num width, num height, bool tile);
  void drawMonochromeBitmap(Object image, num x, num y, num width, num height,
                            bool tile, int rgb);
  void applyFilters(String filters);
  String measureText(String text, num availWidth, num availHeight);
  void close();
}

abstract class IosTextSurface extends IosSurface{
  set text(String value);
  set htmlText(String value);
  set wordWrap(bool value);
  set textAlign(int value);
  set fontName(String value);
  set fontSize(num value);
  set fontBold(bool value);
  set textColor(int value);
  void onTextLinked(EventHandler handler);
  set selectable(bool value);
}

abstract class IosEditSurface extends IosSurface{
  set text(String value);
  set htmlText(String value);
  set multiline(bool value);
  set wordWrap(bool value);
  set textAlign(int value);
  set fontName(String value);
  set fontSize(num value);
  set fontBold(bool value);
  set textColor(int value);
  set promptMessage(String prompt);
  set maxChars(int length);
  void onTextLink(EventHandler handler);
  void setFocus(bool selectAll);
  void lostFocus();
}

class UISurfaceImpl implements UISurface {
  /**
   * Hit testing modes.
   */
  static const int HITTEST_CONTENT = 0;
  static const int HITTEST_BOUNDS  = 1;
  static const int HITTEST_DISABLED = 2;
  static const int HITTEST_CHILDREN_DISABLED = 4;

  static bool _globalDebugEnabled = false;

  IosSurface hostSurface;
  UISurfaceTarget _surfaceTarget;
  List<UISurface> rawChildren = null;
  bool _visible = true;
  String _tag = null;
  num _opacity = 1.0;
  int _hitTestMode = 0;
  bool _clipChildren = false;
  UITransform _transform = null;
  bool _painted = false;

  /**
   * Sets the target to be called for input events on the surface.
   */
  set target(UISurfaceTarget target) {
    _surfaceTarget = target;
  }
  UIElement get target => _surfaceTarget;

  void _addChild(UISurface surface, int index) {
    surface.parentSurface = this;
    if (rawChildren == null) {
      rawChildren = <UISurface>[];
    }
    if (index != -1) {
      rawChildren.insertRange(index, 1, surface);
    } else {
      rawChildren.add(surface);
    }
  }

  /** Adds a child surface. Returns child. */
  UISurface addChild(UISurface child) {
    UISurfaceImpl c = child;
    _addChild(c, -1);
    c.root = root;
    c._createElementOnDemand();
    return child;
  }

  UISurface insertChild(int index, UISurface child) {
    UISurfaceImpl c = child;
    _addChild(c, index);
    c.root = root;
    c._createElementOnDemand();
    return child;
  }

  bool removeChild(UISurface child) {
    int index = rawChildren == null ? -1 : rawChildren.indexOf(child);
    if (index != -1) {
      rawChildren.removeRange(index, 1);
      return true;
    }
    return false;
  }

  void reparentChild(UISurface child, [int index = -1]) {
    print('surface reparentChild');
    _addChild(child, index);
    UISurfaceImpl c = child;
    hostSurface.insertChildAt(-1, c.hostSurface);
    child.root = root;
  }

  // Called by child when a host element is created for surface.
  void _hostElementCreated(UISurfaceImpl child) {
    int index = rawChildren.indexOf(child);
    hostSurface.insertChildAt(index, child.hostSurface);
  }

  void _onInitSurface() {
  }

  void _createElementOnDemand() {
    if (hostSurface == null) {
      hostSurface = window.createSurface();
    }
    if (_tag != null) {
      hostSurface.tag = _tag;
    }
    if (parentSurface != null) {
      parentSurface._hostElementCreated(this);
    }
    _onInitSurface();
  }

  int get childCount => rawChildren != null ? rawChildren.length : 0;
  UISurface childAt(int index) {
    print('surface childAt');
    return rawChildren[index];
  }

  // Sets the location and size of surface relative to parent.
  void setLocation(int targetX, int targetY, int targetWidth, int targetHeight)
  {
    bool needsRepaint = false;
    int offsetToDivX = 0;
    int offsetToDivY = 0;
    if (parentSurface != null) {
      UISurfaceImpl p = parentSurface;
      while (p != null && p.hostSurface == null) {
        offsetToDivX += p.layoutX;
        offsetToDivY += p.layoutY;
        p = p.parentSurface;
      }
    }
    if (layoutX != targetX) {
      layoutX = targetX + offsetToDivX;
    }
    if (layoutY != targetY) {
      layoutY = targetY + offsetToDivY;
    }
    if (layoutW != targetWidth) {
      layoutW = targetWidth;
      if (hostSurface != null) {
        needsRepaint = true;
      }
    }
    if (layoutH != targetHeight) {
      layoutH = targetHeight;
      if (hostSurface != null) {
        needsRepaint = true;
      }
    }
    if (needsRepaint) {
      if (_surfaceTarget != null) {
        _surfaceTarget.invalidateDrawing();
      }
    }
    hostSurface.setBounds(targetX, targetY, targetWidth, targetHeight);
  }

  void setBackground(Brush brush) {
    if (brush == null) return;
    _painted = true;
    hostSurface.setBackground(stringify(_brushToJson(brush)));
  }
  void setBorderRadius(BorderRadius border) {
    if (border == null) return;
    hostSurface.setBorderRadius(border.topLeft, border.topRight,
        border.bottomRight, border.bottomLeft);
  }
  set clipChildren(bool clip) {
    if (_clipChildren == clip)
      return;
    hostSurface.clipChildren = clip;
  }

  /** Delays updates to add multiple children efficiently. */
  void lockUpdates(bool lock) {
    // TODO(sanjayc): Implement lock updates.
  }

  int layoutX = 0;
  int layoutY = 0;
  int layoutW = 0;
  int layoutH = 0;
  // Tag is a value attached to the surface to enable platform
  // specific debugging.
  set tag(String value) {
    print('surface set tag');
  }
  UITransform renderTransform = null;
  UITransform get surfaceTransform => _transform;
  set surfaceTransform(UITransform transform) {
    // TODO(sanjayc:) Just comparing object is not enough, also compare their
    // properties.
    //if (_transform != transform)
    if (transform != null) {
      _transform = transform;
      hostSurface.setTransform(transform.matrix.a, transform.matrix.b,
          transform.matrix.c, transform.matrix.d, transform.matrix.tx,
          transform.matrix.ty);
    } else if (_transform != null) {
      print('clearing surface transform');
      _transform = null;
      hostSurface.setTransform(1, 0, 0, 1, 0, 0);
    }
  }

  /**
   * Clears graphics surface.
   */
  void clear() {
    hostSurface.clear();
  }
  /**
   * Drawing API.
   */
  void drawPath(Path path, Brush brush, Pen pen, Margin nineSlice) {
    if (brush == null && pen == null || path == null) return;
    var jsonDrawCmd = {
      "path": _normalizePath(path, nineSlice),
      "brush": _brushToJson(brush),
      "pen": _penToJson(pen)
    };
    _painted = true;
    hostSurface.drawPath(stringify(jsonDrawCmd));
  }

  /**
   * Draw the path to the UISurface.
   * @param surface The UISurface to draw to.
   */
  String _normalizePath(Path path, Margin nineSlice) {
    List<PathCommand> commands = path.commands;
    Rectangle bounds = path._cachedBounds;
    int commandCount = commands == null ? 0 : commands.length;
    if (commandCount == 0) {
      return "";
    }

    StringBuffer buffer = new StringBuffer();
    PathCommand cmd;
    int cmdType = PathCommand.CLOSE_COMMAND;
    num x, y;
    if (renderTransform == null || nineSlice == null) {
      for (int i = 0; i < commandCount; i++) {
        cmd = commands[i];
        cmdType = cmd.type;
        // Instead of checking for renderMatrix every time.
        // We duplicate switch to perf.
        if (renderTransform == null) {
          // No scaling, no nineslice calc.
          switch(cmdType) {
            case PathCommand.MOVE_COMMAND:
              buffer.add('M ${cmd.x} ${cmd.y} ');
              break;
            case PathCommand.LINETO_COMMAND:
              buffer.add('L ${cmd.x} ${cmd.y} ');
              break;
            case PathCommand.CLOSE_COMMAND:
              buffer.add('Z ');
              break;
            case PathCommand.CUBIC_CURVE_COMMAND:
              CubicBezierCommand cubic = cmd;
              buffer.add('C ');
              buffer.add(
                  '${cubic.controlPoint1X} ${cubic.controlPoint1Y} ');
              buffer.add(
                  '${cubic.controlPoint2X} ${cubic.controlPoint2Y} ');
              buffer.add('${cubic.x} ${cubic.y} ');
              break;
            case PathCommand.QUAD_CURVE_COMMAND:
              QuadraticBezierCommand quad = cmd;
              buffer.add('Q ');
              buffer.add('${quad.controlPointX} ${quad.controlPointY} ');
              buffer.add('${quad.x} ${quad.y} ');
              break;
          }
        } else {
          // We are scaling the path.
          Matrix renderMatrix = renderTransform.matrix;
          switch(cmdType) {
            case PathCommand.MOVE_COMMAND:
              x = renderMatrix.transformPointX(cmd.x, cmd.y);
              y = renderMatrix.transformPointY(cmd.x, cmd.y);
              buffer.add('M ${x} ${y} ');
              break;
            case PathCommand.LINETO_COMMAND:
              x = renderMatrix.transformPointX(cmd.x, cmd.y);
              y = renderMatrix.transformPointY(cmd.x, cmd.y);
              buffer.add('L ${x} ${y} ');
              break;
            case PathCommand.CLOSE_COMMAND:
              buffer.add('Z ');
              break;
            case PathCommand.CUBIC_CURVE_COMMAND:
              CubicBezierCommand cubic = cmd;
              num cp1x = renderMatrix.transformPointX(cubic.controlPoint1X,
                  cubic.controlPoint1Y);
              num cp1y = renderMatrix.transformPointY(cubic.controlPoint1X,
                  cubic.controlPoint1Y);
              num cp2x = renderMatrix.transformPointX(cubic.controlPoint2X,
                  cubic.controlPoint2Y);
              num cp2y = renderMatrix.transformPointY(cubic.controlPoint2X,
                  cubic.controlPoint2Y);
              x = renderMatrix.transformPointX(cubic.x, cubic.y);
              y = renderMatrix.transformPointY(cubic.x, cubic.y);
              buffer.add('C ${cp1x} ${cp1y} ${cp2x} ${cp2y} ${x} ${y} ');
              break;
            case PathCommand.QUAD_CURVE_COMMAND:
              QuadraticBezierCommand quad = cmd;
              num cpx = renderMatrix.transformPointX(quad.controlPointX,
                  quad.controlPointY);
              num cpy = renderMatrix.transformPointY(quad.controlPointX,
                  quad.controlPointY);
              x = renderMatrix.transformPointX(quad.x, quad.y);
              y = renderMatrix.transformPointY(quad.x, quad.y);
              buffer.add('Q ${cpx} ${cpy} ${x} ${y} ');
              break;
          }
        }
      }
    } else {
      Matrix renderMatrix = renderTransform.matrix.clone();

      // Scale path and apply nine slice.
      num leftLimit, topLimit, rightLimit, bottomLimit;
      bool centerLeft, centerTop, centerRight, centerBottom, alignToCenter;
      if (nineSlice.left < 0) {
        leftLimit = -nineSlice.left;
        centerLeft = true;
      } else {
        leftLimit = nineSlice.left;
        centerLeft = false;
      }
      if (nineSlice.top < 0) {
        topLimit = -nineSlice.top;
        centerTop = true;
      } else {
        topLimit = nineSlice.top;
        centerTop = false;
      }
      if (nineSlice.right < 0) {
        rightLimit = bounds.width + nineSlice.right;
        centerRight = true;
      } else {
        rightLimit = bounds.width - nineSlice.right;
        centerRight = false;
      }
      if (nineSlice.bottom < 0) {
        bottomLimit = bounds.height + nineSlice.bottom;
        centerBottom = true;
      } else {
        bottomLimit = bounds.height - nineSlice.bottom;
        centerBottom = false;
      }

      num scaleX = renderTransform.scaleX;
      num scaleY = renderTransform.scaleY;
      num scaledWidth = bounds.width * scaleX;
      num scaledHeight = bounds.height * scaleY;
      num newX;
      num newY;
      // we want to manually scale and then apply rotate and translate.
      // so first we compute [1/sx, 0, 0, 1/sy, 0, 0] x matrix.
      renderMatrix.a /= renderTransform.scaleX;
      renderMatrix.d /= renderTransform.scaleY;
      for (int i = 0; i < commandCount; i++) {
        cmd = commands[i];
        cmdType = cmd.type;
        switch(cmdType) {
          case PathCommand.MOVE_COMMAND:
            alignToCenter = (centerTop && (cmd.y < topLimit)) ||
                (centerBottom && (cmd.y > bottomLimit));
            newX = nineSliceVal(cmd.x, leftLimit, rightLimit, bounds.width,
                scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (cmd.x < leftLimit)) ||
                (centerRight && (cmd.x > rightLimit));
            newY = nineSliceVal(cmd.y, topLimit, bottomLimit, bounds.height,
                scaledHeight, scaleY, alignToCenter);
            x = renderMatrix.transformPointX(newX, newY);
            y = renderMatrix.transformPointY(newX, newY);
            buffer.add('M ${x} ${y} ');
            break;
          case PathCommand.LINETO_COMMAND:
            alignToCenter = (centerTop && (cmd.y < topLimit)) ||
                (centerBottom && (cmd.y > bottomLimit));
            newX = nineSliceVal(cmd.x, leftLimit, rightLimit, bounds.width,
                scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (cmd.x < leftLimit)) ||
                (centerRight && (cmd.x > rightLimit));
            newY = nineSliceVal(cmd.y, topLimit, bottomLimit, bounds.height,
                scaledHeight, scaleY, alignToCenter);
            x = renderMatrix.transformPointX(newX, newY);
            y = renderMatrix.transformPointY(newX, newY);
            buffer.add('L ${x} ${y} ');
            break;
          case PathCommand.CLOSE_COMMAND:
            buffer.add('Z ');
            break;
          case PathCommand.CUBIC_CURVE_COMMAND:
            CubicBezierCommand cubic = cmd;
            alignToCenter = (centerTop && (cubic.controlPoint1Y <
                topLimit)) || (centerBottom && (cubic.controlPoint1Y >
                bottomLimit));
            newX = nineSliceVal(cubic.controlPoint1X, leftLimit, rightLimit,
                bounds.width, scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (cubic.controlPoint1X <
                leftLimit)) || (centerRight && (cubic.controlPoint1X >
                rightLimit));
            newY = nineSliceVal(cubic.controlPoint1Y, topLimit, bottomLimit,
                bounds.height, scaledHeight, scaleY, alignToCenter);
            num cp1x = renderMatrix.transformPointX(newX, newY);
            num cp1y = renderMatrix.transformPointY(newX, newY);
            alignToCenter = (centerTop && (cubic.controlPoint2Y <
                topLimit)) || (centerBottom && (cubic.controlPoint2Y >
                bottomLimit));
            newX = nineSliceVal(cubic.controlPoint2X, leftLimit, rightLimit,
                bounds.width, scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (cubic.controlPoint2X <
                leftLimit)) || (centerRight && (cubic.controlPoint2X >
                rightLimit));
            newY = nineSliceVal(cubic.controlPoint2Y, topLimit, bottomLimit,
                bounds.height, scaledHeight, scaleY, alignToCenter);
            num cp2x = renderMatrix.transformPointX(newX, newY);
            num cp2y = renderMatrix.transformPointY(newX, newY);
            alignToCenter = (centerTop && (cubic.y < topLimit)) ||
                (centerBottom && (cubic.y > bottomLimit));
            newX = nineSliceVal(cubic.x, leftLimit, rightLimit,
                bounds.width, scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (cubic.x < leftLimit)) ||
                (centerRight && (cubic.x > rightLimit));
            newY = nineSliceVal(cubic.y, topLimit, bottomLimit,
                bounds.height, scaledHeight, scaleY, alignToCenter);
            x = renderMatrix.transformPointX(newX, newY);
            y = renderMatrix.transformPointY(newX, newY);
            buffer.add('C ${cp1x} ${cp1y} ${cp2x} ${cp2y} ${x} ${y} ');
            break;
          case PathCommand.QUAD_CURVE_COMMAND:
            QuadraticBezierCommand quad = cmd;
            alignToCenter = (centerTop && (quad.controlPointY <
                topLimit)) || (centerBottom && (quad.controlPointY >
                bottomLimit));
            newX = nineSliceVal(quad.controlPointX, leftLimit, rightLimit,
                bounds.width, scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (quad.controlPointX <
                leftLimit)) || (centerRight && (quad.controlPointX >
                rightLimit));
            newY = nineSliceVal(quad.controlPointY, topLimit, bottomLimit,
                bounds.height, scaledHeight, scaleY, alignToCenter);
            num cpx = renderMatrix.transformPointX(newX, newY);
            num cpy = renderMatrix.transformPointY(newX, newY);
            alignToCenter = (centerTop && (quad.y < topLimit)) ||
                (centerBottom && (quad.y > bottomLimit));
            newX = nineSliceVal(quad.x, leftLimit, rightLimit,
                bounds.width, scaledWidth, scaleX, alignToCenter);
            alignToCenter = (centerLeft && (quad.x < leftLimit)) ||
                (centerRight && (quad.x > rightLimit));
            newY = nineSliceVal(quad.y, topLimit, bottomLimit,
                bounds.height, scaledHeight, scaleY, alignToCenter);
            x = renderMatrix.transformPointX(newX, newY);
            y = renderMatrix.transformPointY(newX, newY);
            buffer.add('Q ${cpx} ${cpy} ${x} ${y} ');
            break;
        }
      }
    }
    if (cmdType != PathCommand.CLOSE_COMMAND) {
      buffer.add('Z ');
    }
    return buffer.toString();
  }

  static num nineSliceVal(num val, num minLimit, num maxLimit, num origSize,
                       num scaledSize, num scaleFactor, bool alignToCenter) {
    if (val <= minLimit) {
      return val;
    } else if (val >= maxLimit) {
      return scaledSize - (origSize - val);
    }
    if (alignToCenter) {
      // keep distance to center constant.
      return val - (origSize / 2) + (scaledSize / 2);
    } else {
      return scaleFactor * val;
    }
  }

  void drawRect(num x, num y, num width, num height,
      Brush brush, Pen pen, BorderRadius borderRadius) {
    print('surface drawRect');
    _painted = true;
  }

  void drawEllipse(num x, num y, num width, num height, Brush brush, Pen pen) {
    if (brush == null && pen == null) return;
    var jsonDrawCmd = {
      "brush": _brushToJson(brush),
      "pen": _penToJson(pen),
      "x": x,
      "y": y,
      "width": width,
      "height": height
    };
    _painted = true;
    hostSurface.drawEllipse(stringify(jsonDrawCmd));
  }
  void drawLine(Brush brush, Pen pen, num xFrom,num yFrom, num xTo, num yTo) {
    print('surface drawLine');
    _painted = true;
  }
  void drawBitmap(Object image,
                  num x,
                  num y,
                  num width,
                  num height,
                  bool tile) {
    hostSurface.drawBitmap(image, x, y, width, height, tile);
    _painted = true;
  }
  void drawBitmapTransformColor(Object image, num x, num y, num width,
      num height, bool tile, ColorTransform transform) {
    Color monochromeColor = Color.from(transform.alphaMultiplier * 255,
        transform.redMultiplier * 255, transform.greenMultiplier * 255,
        transform.blueMultiplier * 255);
    hostSurface.drawMonochromeBitmap(image, x, y, width, height, tile,
        monochromeColor.rgb);
    _painted = true;
  }
  void drawImage(String source) {
    print('surface drawImage with source');
    _painted = true;
  }

  set hitTestMode(int mode) {
    _hitTestMode = mode;
  }

  UISurface hitTest(num mouseX, num mouseY) {
    bool debugEnabled = UISurfaceImpl._globalDebugEnabled/* &&
        KeyboardEventArgs.altKey*/;
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
      } else if (_painted == true && hostSurface.hitTest(mouseX, mouseY)) {
        return this;
      }
    }

    return null;
  }

  UISurface parentSurface;
  Application root;
  bool mouseEnabled;

  bool get enableHitTesting => (_hitTestMode & HITTEST_DISABLED) == 0;

  set enableHitTesting(bool value) {
    if (value) {
      _hitTestMode &= ~HITTEST_DISABLED;
    } else {
      _hitTestMode |= HITTEST_DISABLED;
    }
  }

  /**
   * Sets or returns if mouse event are handled by children.
   */
  bool get enableChildHitTesting => (_hitTestMode & HITTEST_CHILDREN_DISABLED)
      == 0;

  set enableChildHitTesting(bool value) {
    if (value) {
      _hitTestMode &= ~HITTEST_CHILDREN_DISABLED;
    } else {
      _hitTestMode |= HITTEST_CHILDREN_DISABLED;
    }
  }
  set opacity(num value) {
    if (value != _opacity) {
      hostSurface.opacity = _opacity = value;
    }
  }
  set visible(bool value) {
    if (value != _visible) {
      hostSurface.visible = _visible = value;
    }
  }
  bool get visible => _visible;
  bool get hasTransform => _transform != null;
  void applyFilters(Filters filters) {
    List arrFilters = [];
    for (int i = 0; i < filters.length; i++) {
      Filter filter = filters.getFilter(i);
      if (filter.runtimeType == DropShadowFilter) {
        DropShadowFilter drop = filter;
        arrFilters.add({
          "alpha": drop.alpha,
          "angle": drop.angle,
          "blurX": drop.blurX,
          "blurY": drop.blurY,
          "color": drop.color.argb,
          "distance": drop.distance,
          "strength": drop.strength,
          "quality": drop.quality,
          "inner": drop.inner,
          "knockout": drop.knockout
        });
      } else if (filter.runtimeType == GlowFilter) {
        GlowFilter glow = filter;
        arrFilters.add({
          "alpha": glow.alpha,
          "blurX": glow.blurX,
          "blurY": glow.blurY,
          "color": glow.color.argb,
          "strength": glow.strength,
          "quality": glow.quality,
          "inner": glow.inner,
          "knockout": glow.knockout
        });
      }
    }
    if (arrFilters.length > 0) {
      hostSurface.applyFilters(stringify(arrFilters));
    }
  }
  bool setupTopLevelCursor(Cursor cursor) {
    return false;
  }
  void cursorChanged(Cursor cursor) {
  }
  void close() {
    if (hostSurface != null) {
      hostSurface.close();
      hostSurface = null;
    }
  }

  Map _brushToJson(Brush brush) {
    if (brush == null) return null;
    if (brush.runtimeType == SolidBrush) {
      SolidBrush solid = brush;
      return {
        "type": "solid",
        "color": solid.color.argb
      };
    }
    if (brush.runtimeType == LinearBrush) {
      LinearBrush linear = brush;
      return {
        "type": "linear",
        "start": {
          "x": linear.start.x,
          "y": linear.start.y
        },
        "end": {
          "x": linear.end.x,
          "y": linear.end.y
        },
        "stops": linear.stops.mappedBy((GradientStop stop) => {
          "color": stop.color.argb,
          "offset": stop.offset
        })
      };
    }
    if (brush.runtimeType == RadialBrush) {
      RadialBrush radial = brush;
      return {
        "type": "radial",
        "origin": {
          "x": radial.origin.x,
          "y": radial.origin.y
        },
        "center": {
          "x": radial.center.x,
          "y": radial.center.y
        },
        "radius": {
          "x": radial.radius.x,
          "y": radial.radius.y
        },
        "stops": radial.stops.mappedBy((GradientStop stop) => {
          "color": stop.color.argb,
          "offset": stop.offset
        }),
        "transform": _matrixToJson(radial.transform)
      };
    }
  }
  Map _penToJson(Pen pen) {
    if (pen == null) return null;
    if (pen.runtimeType == SolidPen) {
      SolidPen solid = pen;
      return {
        "type": "solid",
        "thickness": solid.thickness,
        "color": solid.color.argb
      };
    }
  }
  Map _marginToJson(Margin margin) {
    if (margin == null) return null;
    return {
      "left": margin.left,
      "top": margin.top,
      "right": margin.right,
      "bottom": margin.bottom
    };
  }
  Map _transformToJson(UITransform transform) {
    if (transform == null) return null;
    return _matrixToJson(transform.matrix);
  }

  Map _matrixToJson(Matrix matrix) {
    if (matrix == null) return null;
    return {
      "a": matrix.a,
      "b": matrix.b,
      "c": matrix.c,
      "d": matrix.d,
      "tx": matrix.tx,
      "ty": matrix.ty
    };
  }

  String _colorTransformToJson(ColorTransform transform) {
    if (transform == null) return null;
    return stringify({
      "alphaOffset": transform.alphaOffset,
      "redOffset": transform.redOffset,
      "greenOffset": transform.greenOffset,
      "blueOffset": transform.blueOffset,
      "alphaMultiplier": transform.alphaMultiplier,
      "redMultiplier": transform.redMultiplier,
      "greenMultiplier": transform.greenMultiplier,
      "blueMultiplier": transform.blueMultiplier,
      "monoChrome": transform.monoChrome
    });
  }
}

class UITextSurfaceImpl extends UISurfaceImpl implements UITextSurface {
  IosTextSurface _textSurface;

  void _createElementOnDemand() {
    hostSurface = window.createTextSurface();
    _textSurface = hostSurface;
    super._createElementOnDemand();
  }
  set text(String value) => _textSurface.text = value;

  set htmlText(String value) => _textSurface.htmlText = value;

  set wordWrap(bool value) => _textSurface.wordWrap = value;

  set textAlign(int value) => _textSurface.textAlign = value;

  set fontName(String value) => _textSurface.fontName = value;

  set fontSize(num value) => _textSurface.fontSize = value;

  set fontBold(bool value) => _textSurface.fontBold = value;

  set textColor(Color value) => _textSurface.textColor = value.rgb;

  set onTextLink(EventHandler handler) => _textSurface.onTextLinked(handler);

  set selectable(bool value) => _textSurface.selectable = value;

  void measureText(String text, num availWidth, num availHeight,
      bool sizeToBold) {
    String jsonSize = hostSurface.measureText(text, availWidth, availHeight);
    Map sizeMap = parse(jsonSize);
    measuredWidth = sizeMap['measuredWidth'];
    measuredHeight = sizeMap['measuredHeight'];
  }

  void updateTextView() {
  }
  int measuredWidth = 0;
  int measuredHeight = 0;
}

class UIEditSurfaceImpl extends UISurfaceImpl implements UIEditSurface {
  IosEditSurface _editSurface;

  void _createElementOnDemand() {
    TextChangedCallback callback = (String text) {
      if (_surfaceTarget != null) {
        _surfaceTarget.surfaceTextChanged(text);
      }
    };
    hostSurface = window.createEditSurface(callback);
    _editSurface = hostSurface;
    super._createElementOnDemand();
  }
  set text(String value) => _editSurface.text = value;

  set htmlText(String value) => _editSurface.htmlText = value;

  set multiline(bool value) => _editSurface.multiline = value;

  set wordWrap(bool value) => _editSurface.wordWrap = value;

  set textAlign(int value) => _editSurface.textAlign = value;

  set fontName(String value) => _editSurface.fontName = value;

  set fontSize(num value) => _editSurface.fontSize = value;

  set fontBold(bool value) => _editSurface.fontBold = value;

  set textColor(Color value) => _editSurface.textColor = value.rgb;

  set onTextLink(EventHandler handler) => _editSurface.onTextLink(handler);

  set promptMessage(String prompt) => _editSurface.promptMessage = prompt;
  set maxChars(int length) => _editSurface.maxChars = length;

  void enableMouseEvents(bool val) {

  }

  void measureText(String text, num availWidth, num availHeight) {
    String jsonSize = hostSurface.measureText(text, availWidth, availHeight);
    Map sizeMap = parse(jsonSize);
    measuredWidth = sizeMap['measuredWidth'];
    measuredHeight = sizeMap['measuredHeight'];
  }
  void initFocus(bool selectAll) {
    _editSurface.setFocus(selectAll);
  }
  void focusChanged(bool isFocused) {
    if (!isFocused) {
      _editSurface.lostFocus();
    }
  }
  int measuredWidth = 0;
  int measuredHeight = 0;
}
