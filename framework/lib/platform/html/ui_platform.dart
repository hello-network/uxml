part of uxml;

/**
 * Utility class to factor out dom/html/flash/objc implementations from base
 * framework.
 */
class UIPlatform {
  // List of supported mobile envs.
  static List<String> _androidAgentList = ["android"];
  static List<String> _iosAgentList = ["iphone", "ipad", "ipod"];
  static bool _isUsingRequestFrame = false;
  static bool _isTouchEnabled = false;
  static StreamSubscription<Event> _resizeSub = null;
  static StreamSubscription<Event> _orientationSub = null;
  static StreamSubscription<Event> _keyDownSub = null;
  static StreamSubscription<Event> _keyPressSub = null;
  static StreamSubscription<Event> _keyUpSub = null;
  static StreamSubscription<Event> _mouseDownSub = null;
  static StreamSubscription<Event> _mouseUpSub = null;
  static StreamSubscription<Event> _mouseMoveSub = null;
  static StreamSubscription<Event> _mouseOutSub = null;
  static StreamSubscription<Event> _mouseWheelSub = null;
  static StreamSubscription<Event> _touchStartSub = null;
  static StreamSubscription<Event> _touchMoveSub = null;
  static StreamSubscription<Event> _touchEndSub = null;

  static Map<String, String> _cookies = null;
  static Map<_TransitionCallback, StreamSubscription<TransitionEvent>>
      _listenerToSub =
      new Map<_TransitionCallback, StreamSubscription<TransitionEvent>>();

  static void initialize() {
    detectBrowser();
  }

  static UISurface createSurface() {
    return new UISurfaceImpl();
  }

  static UIEditSurface createEditSurface() {
    return new UIEditSurfaceImpl();
  }

  static UITextSurface createTextSurface() {
    return new UITextSurfaceImpl();
  }

  /**
   * Draw the path to the UISurface.
   * @param surface The UISurface to draw to.
   */
  static void drawPath(CanvasRenderingContext2D context,
                       UITransform renderTransform,
                       VecPath path,
                       Margin nineSlice) {

    List<PathCommand> commands = path.commands;
    Rect bounds = path._cachedBounds;
    int commandCount = commands == null ? 0 : commands.length;
    if (commandCount == 0) {
      return;
    }

    PathCommand cmd;
    int cmdType = 3;
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
            case 1:
              context.moveTo(cmd.x, cmd.y);
              break;
            case 2:
              context.lineTo(cmd.x, cmd.y);
              break;
            case 3:
              context.closePath();
              break;
            case 4:
              CubicBezierCommand cubic = cmd;
              context.bezierCurveTo(cubic.controlPoint1X, cubic.controlPoint1Y,
                  cubic.controlPoint2X, cubic.controlPoint2Y, cubic.x, cubic.y);
              break;
            case 5:
              QuadraticBezierCommand quad = cmd;
              context.quadraticCurveTo(quad.controlPointX, quad.controlPointY,
                  quad.x, quad.y);
              break;
          }
        } else {
          // We are scaling the path.
          Matrix renderMatrix = renderTransform.matrix;
          switch(cmdType) {
            case 1:
              x = renderMatrix.transformPointX(cmd.x, cmd.y);
              y = renderMatrix.transformPointY(cmd.x, cmd.y);
              context.moveTo(x, y);
              break;
            case 2:
              x = renderMatrix.transformPointX(cmd.x, cmd.y);
              y = renderMatrix.transformPointY(cmd.x, cmd.y);
              context.lineTo(x, y);
              break;
            case 3:
              context.closePath();
              break;
            case 4:
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
              context.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
              break;
            case 5:
              QuadraticBezierCommand quad = cmd;
              num cpx = renderMatrix.transformPointX(quad.controlPointX,
                  quad.controlPointY);
              num cpy = renderMatrix.transformPointY(quad.controlPointX,
                  quad.controlPointY);
              x = renderMatrix.transformPointX(quad.x, quad.y);
              y = renderMatrix.transformPointY(quad.x, quad.y);
              context.quadraticCurveTo(cpx, cpy, x, y);
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
          case 1:
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
            context.moveTo(x, y);
            break;
          case 2:
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
            context.lineTo(x, y);
            break;
          case 3:
            context.closePath();
            break;
          case 4:
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
            context.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
            break;
          case 5:
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
            context.quadraticCurveTo(cpx, cpy, x, y);
            break;
        }
      }
    }
    if (cmdType != 3) {
      context.closePath();
    }
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

  /**
   * Selects the pen into the drawing context of the UISurface. This is
   * overridden by derived classes.
   *
   * @param pen to draw stroke with.
   * @param surface The surface to draw into.
   * @param bounds The bounds of the rectangle used to calculate gradient.
   */
  static void beginStroke(Pen pen, UISurface surface, Rect bounds) {
    // TODO(ferhat): impl pen begin stroke.
    // surface.graphics.lineStyle(thickness, colorValue.rgb,
    // colorValue.alpha, true);
  }

  static void applyBrush(Element element, Brush brush) {
    int type = brush._type;
    if (type == 0) {
      SolidBrush br = brush;
      element.style.backgroundColor = br._color.toString();
    } else if (type == 1) {
      _applyLinearGradient(element, brush);
    } else {
      // radial.
    }
  }

  static void _applyLinearGradient(DivElement element, LinearBrush br) {
    List<GradientStop> stops = br.stops;
    Coord start = br.start;
    Coord end = br.end;
    StringBuffer backStyle = new StringBuffer();
    if (stops.length >= 2) {
      if (Application.isWebKit) {
        backStyle.write("-webkit-gradient(linear, ");
        backStyle.write((br.start.x * 100).ceil());
        backStyle.write("%");
        backStyle.write((br.start.y * 100).ceil());
        backStyle.write("%,");
        backStyle.write((br.end.x * 100).ceil());
        backStyle.write("%");
        backStyle.write((br.end.y * 100).ceil());
        backStyle.write("%,");
        for (int i = 0; i < stops.length; i++) {
          if (i != 0) {
            backStyle.write(",");
          }
          GradientStop stop = stops[i];
          backStyle.write(" color-stop(");
          backStyle.write((((100.0 * stop.offset)) ~/ 100).toString());
          backStyle.write(",");
          backStyle.write(stop.color.toString());
          backStyle.write(")");
        }
        backStyle.write(")");
        element.style.background = backStyle.toString();
      } else if (Application.isFF) {
        // TODO(ferhat): add support for arbitrary angle.
        backStyle.write("-moz-linear-gradient(");
        backStyle.write(start.x == end.x ? "top" : "left");
        for (int i = 0; i < stops.length; i++) {
          backStyle.write(",");
          backStyle.write(stops[i].color.toString());
          backStyle.write(" ");
          backStyle.write((((100.0 * stops[i].offset))).toInt().toString());
          backStyle.write("%");
        }
        element.style.background = backStyle.toString();
      } else if (Application.isIE) {
        // filter:  progid:DXImageTransform.Microsoft.gradient(GradientType=0,
        //    startColorstr='#e6e6e6', endColorstr='#CCCCCC'); /* IE6 & IE7 */
        // -ms-filter: "progid:DXImageTransform.Microsoft.gradient(
        //     GradientType=0,startColorstr='#e6e6e6',
        //     endColorstr='#CCCCCC')"; /* IE8+ */
        int version = Application.uaVersion;
        if (version >= 100) { // IE10 supports ms-linear.
          backStyle.write("-ms-linear-gradient(");
          backStyle.write(start.x == end.x ? "top" : "left");
          for (int i = 0; i < stops.length; i++) {
            backStyle.write(",");
            backStyle.write(stops[i].color.toString());
            backStyle.write(" ");
            backStyle.write((((100.0 * stops[i].offset))).toInt().toString());
            backStyle.write("%");
          }
          element.style.background = backStyle.toString();
        } else if (version >= 60) { // IE 6.0 - 9.0
          // Degrading to 2 stops and vert/horizontal for IE.
          backStyle.write(
              "progid:DXImageTransform.Microsoft.gradient(GradientType=");
          backStyle.write((end.x == start.x) ? "0," : "1,");
          backStyle.write("startColorstr='");
          backStyle.write(stops[0].color.toString());
          backStyle.write("', endColorstr='");
          backStyle.write(stops[stops.length - 1].color.toString());
          backStyle.write("'");
          backStyle.write(")");
          element.style.setProperty((version >= 80) ? "-ms-filter" : "filter",
              backStyle.toString());
        }
      }
    }
  }

  static UISurface createRootSurface(Application owner, Object host) {
    return new RootSurface(owner, host);
  }

  static void writeToConsole(String message) {
    print(message);
  }

  static void detectBrowser() {
    String ua = window.navigator.userAgent.toLowerCase();
    Application.isMobile = false;
    for (int i = _androidAgentList.length - 1; i >= 0; i--) {
      if (ua.indexOf(_androidAgentList[i]) != -1) {
        Application.isAndroid = true;
        break;
      }
    }
    for (int i = _iosAgentList.length - 1; i >= 0; i--) {
      if (ua.indexOf(_iosAgentList[i]) != -1) {
        Application.isIos = true;
        break;
      }
    }
    if (Application.isAndroid || Application.isIos) {
      Application.isMobile = true;
    }
    Application.uaVersion = parseUA("Chrome/");
    if (Application.uaVersion != -1) {
      Application.isChrome = true;
      Application.isWebKit = true;
      return;
    }
    Application.uaVersion = parseUA("Firefox/");
    if (Application.uaVersion != -1) {
      Application.isFF = true;
      return;
    }
    Application.uaVersion = parseUA("MSIE", semiColonEnd:true);
    if (Application.uaVersion != -1) {
      Application.isIE = true;
      return;
    }
    Application.uaVersion = parseUA("Safari", parseVersion:true);
    if (Application.uaVersion != -1) {
      Application.isSafari = true;
      Application.isWebKit = true;
    }
    // iPhone Simulator.
    Application.uaVersion = parseUA("AppleWebKit", parseVersion:true);
    if (Application.uaVersion != -1) {
      Application.isSafari = true;
      Application.isWebKit = true;
    }
    Application.screenPixelRatio = window.devicePixelRatio;
  }

  static int parseUA(String name, {bool parseVersion: false,
      bool semiColonEnd: false}) {
    int pos, endPos;
    String userAgent = window.navigator.userAgent;
    pos = userAgent.indexOf(name);
    if (pos == -1) {
      return -1;
    }
    if (parseVersion) {
      name = "Version/";
      pos = userAgent.indexOf(name);
      if (pos == -1) {
        return 0;
      }
    }
    if (semiColonEnd) {
      endPos = userAgent.indexOf(";", (pos + name.length));
    } else {
      endPos = userAgent.indexOf(" ", (pos + name.length));
    }
    if (endPos == -1) {
      if (endPos == -1) {
        endPos = userAgent.length;
      }
    }
    try {
      String vStr = userAgent.substring(pos + name.length, endPos - 1);
      int dotPos = vStr.indexOf('.');
      if (dotPos != -1) {
        int nextPos = vStr.substring(dotPos + 1).indexOf('.');
        if (nextPos != -1) {
          vStr = vStr.substring(0, nextPos + dotPos + 1);
        }
      }
      return (double.parse(vStr) * 10.0).toInt();
    } on FormatException catch (e) {
      return 0;
    }
  }

  static bool inAnimFrameCallback = false;
  static bool pendingEnterFrame = false;
  // TODO(erjo): Replace this total hack with a proper fix addressing cause.
  static double previousAnimationTime = 0.0;
  static void scheduleEnterFrame(Application app) {
    if (inAnimFrameCallback) {
      pendingEnterFrame = true;
      return;
    }
    Function animCallbackHandler = (time) {
        if (time == previousAnimationTime) {
          return; // We have already handled a callback for this time.
        }
        previousAnimationTime = time;
        inAnimFrameCallback = true;
        app._enterFrame(time);
        inAnimFrameCallback = false;
        if (pendingEnterFrame) {
          scheduleEnterFrame(app);
          pendingEnterFrame = false;
        }
      };

    try {
      window.requestAnimationFrame(animCallbackHandler);
      _isUsingRequestFrame = true;
    } on NoSuchMethodError catch (e) {
      setTimeout(() {
        animCallbackHandler(new DateTime.now().millisecondsSinceEpoch);
      }, 20);
    }
  }

  static void initializeAppEvents(Application app) {
    var resizeHandler = (Event event) {
        RootSurface rootSurface = app.rootSurface;
        int width = window.innerWidth;
        int height = window.innerHeight;
        app.setHostSize(width, height);
      };
    _resizeSub = window.onResize.listen(resizeHandler);
    _orientationSub = window.onDeviceOrientation.listen(resizeHandler);

    _keyDownSub = window.onKeyDown.listen((Event e) {
        if (app._keyDownEventHandler(e)) {
          e.preventDefault();
        }
      });

    _keyPressSub = window.onKeyPress.listen((Event e) {
        if (app._keyPressEventHandler(e)) {
          e.preventDefault();
        }
      });

    _keyUpSub = window.onKeyUp.listen((Event e) {
        if (app._keyUpEventHandler(e)) {
          e.preventDefault();
        }
      });

    _mouseOutSub = document.onMouseOut.listen((MouseEvent event) {
        //UISurfaceImpl._globalDebugEnabled = true;
        if (_isTouchEnabled) {
          return false;
        }
        int button = _buttonFromEvent(event);
        EventArgs resEvent = app._routeMouseEvent(event.page.x, event.page.y,
            button, MouseEventArgs.MOUSE_MOVE);
        bool handled = (resEvent == null) ? false :
          (resEvent._forceDefault ? false : resEvent.handled);
        if (handled) {
          event.preventDefault();
        }
        UpdateQueue.flush();
        return handled;
      });

    _mouseDownSub = document.onMouseDown.listen((MouseEvent event) {
        //UISurfaceImpl._globalDebugEnabled = true;
        if (_isTouchEnabled) {
          return false;
        }
        int button = _buttonFromEvent(event);
        EventArgs resEvent = app._routeMouseEvent(event.page.x, event.page.y,
            button, MouseEventArgs.MOUSE_DOWN);
        bool handled = (resEvent == null) ? false :
          (resEvent._forceDefault ? false : resEvent.handled);
        if (handled) {
          event.preventDefault();
        }
        UpdateQueue.flush();
        return handled;
      });

    _mouseUpSub = document.onMouseUp.listen((MouseEvent event) {
        if (_isTouchEnabled) {
          return false;
        }
        int button = _buttonFromEvent(event);
        EventArgs resEvent = app._routeMouseEvent(event.page.x, event.page.y,
            button, MouseEventArgs.MOUSE_UP);
        bool handled = (resEvent == null) ? false :
          (resEvent._forceDefault ? false : resEvent.handled);
        if (handled) {
          event.preventDefault();
        }
        UpdateQueue.flush();
        //Uncomment to debug. UISurfaceImpl._globalDebugEnabled = false;
        return handled;
      });

    _mouseMoveSub = document.onMouseMove.listen((MouseEvent event) {
          if (_isTouchEnabled) {
            return false;
          }
          int button = _buttonFromEvent(event);
          if (event.page.x == 0 && event.page.y == 0) {
            return false;
          }
          EventArgs resEvent = app._routeMouseEvent(event.page.x, event.page.y,
              button, MouseEventArgs.MOUSE_MOVE);
          bool handled = (resEvent == null) ? false :
            (resEvent._forceDefault ? false : resEvent.handled);
          if (handled) {
            event.preventDefault();
          }
          return handled;
        });

    // Disable panning the browser view to not show contents below it.
    document.onTouchStart.listen((TouchEvent event) {
        event.preventDefault();
      });

    // Handle touch events.
    initializeTouchEvents(app);

    _mouseWheelSub = document.onMouseWheel.listen(_mouseWheelHandler);
    RootSurface r = app.rootSurface;
    int width = window.innerWidth;
    int height = window.innerHeight;
    app.setHostSize(width, height);
    scheduleEnterFrame(app);
  }

  static void shutdownAppEvents(Application app) {
    _resizeSub.cancel();
    _resizeSub = null;
    _orientationSub.cancel();
    _orientationSub = null;
    _keyDownSub.cancel();
    _keyDownSub = null;
    _keyPressSub.cancel();
    _keyPressSub = null;
    _keyUpSub.cancel();
    _keyUpSub = null;
    _mouseDownSub.cancel();
    _mouseDownSub = null;
    _mouseUpSub.cancel();
    _mouseUpSub = null;
    _mouseMoveSub.cancel();
    _mouseMoveSub = null;
    _mouseOutSub.cancel();
    _mouseOutSub = null;
    if (_mouseWheelSub != null) {
      _mouseWheelSub.cancel();
      _mouseWheelSub = null;
    }
    _touchStartSub.cancel();
    _touchMoveSub.cancel();
    _touchEndSub.cancel();
  }

  // TODO(ferhat): talk to dart team about DOMMouseScroll/FireFox problem.
  static bool _mouseWheelHandlerFF(int delta) {
    return Application.current._routeMouseWheelEvent(-delta);
  }

  // Override for platform to decide if mouse event should be routed
  // element or not. In Html we don't want to pass through.
  // In platforms such as flash we need mouseArgs._passthrough();
  static void handleEditMouseEvent(MouseEventArgs mouseArgs) {
  }

  static void _mouseWheelHandler(WheelEvent event) {
    num delta = 0;
    try {
      delta = event.deltaY;
      if (!(delta < 30 && delta > - 30)) {
        delta = event.deltaY / 30;
      }
    } on NoSuchMethodError catch (e) {
      // ignore. api still in flux.
    }
    if (delta != 0) {
      bool handled = Application.current._routeMouseWheelEvent(delta.toInt());
      if (handled) {
        event.preventDefault();
      }
      UpdateQueue.flush();
    }
  }

  static void initializeTouchEvents(Application app) {
    // Cache pageX and pageY in touchStart and touchMove because touchEnd does
    // not set these.
    int pageX, pageY;
    _touchStartSub = document.onTouchStart.listen((TouchEvent event) {
      _isTouchEnabled = true;
      Touch touch = event.touches[0];
      pageX = touch.page.x;
      pageY = touch.page.y;
      //UISurfaceImpl._globalDebugEnabled = true;
      int button = MouseEventArgs.LEFT_BUTTON;
      EventArgs resEvent = app._routeMouseEvent(pageX, pageY,
          button, MouseEventArgs.MOUSE_DOWN);
      bool handled = (resEvent == null) ? false :
        (resEvent._forceDefault ? false : resEvent.handled);
      if (handled) {
        event.preventDefault();
      }
      UpdateQueue.flush();
      return handled;
    });
    _touchMoveSub = document.onTouchMove.listen((TouchEvent event) {
      Touch touch = event.touches[0];
      pageX = touch.page.x;
      pageY = touch.page.y;
      int button = MouseEventArgs.LEFT_BUTTON;
      EventArgs resEvent = app._routeMouseEvent(pageX, pageY,
          button, MouseEventArgs.MOUSE_MOVE);
      bool handled = (resEvent == null) ? false :
        (resEvent._forceDefault ? false : resEvent.handled);
      if (handled) {
        event.preventDefault();
      }
      return handled;
    });
    _touchEndSub = document.onTouchEnd.listen((TouchEvent event) {
      int button = MouseEventArgs.LEFT_BUTTON;
      EventArgs resEvent = app._routeMouseEvent(pageX, pageY,
          button, MouseEventArgs.MOUSE_UP);
      bool handled = (resEvent == null) ? false :
        (resEvent._forceDefault ? false : resEvent.handled);
      if (handled) {
        event.preventDefault();
      }
      UpdateQueue.flush();
      //Uncomment to debug. UISurfaceImpl._globalDebugEnabled = false;
      return handled;
    });
  }

  static int _buttonFromEvent(event) {
    int button = MouseEventArgs.NO_BUTTON;
    if (event.which == null) {
      // IE case.
      button = (event.button < 2) ? MouseEventArgs.LEFT_BUTTON :
          ((event.button == 4) ? MouseEventArgs.MIDDLE_BUTTON :
          MouseEventArgs.RIGHT_BUTTON);
    } else if (event.which > 0) {
      // All other browsers.
      button= (event.which < 2) ? MouseEventArgs.LEFT_BUTTON :
          ((event.which == 2) ? MouseEventArgs.MIDDLE_BUTTON :
          MouseEventArgs.RIGHT_BUTTON);
    }
    return button;
  }

  static Object createHttpRequest() {
    return new HttpRequest();
  }

  static Model protoXmlToModel(dynamic protoXml) {
    if (protoXml is! Node) {
      return protoXml.toModel();
    }
    Node element = protoXml;
    Model proto = new Model();
    // iterate through all child elements
    List<Node> nodes = element.nodes;
    for (int nodeIndex = 0; nodeIndex < nodes.length; ++nodeIndex) {
      Node child = nodes[nodeIndex];
      if (child is! Element) {
        continue;
      }
      Element elm = child;
      // get the name of the field
      String name = elm.tagName;

      // if the field name is message set, ex: social_hello_proto.Location
      // use the name after the "."
      int index = name.indexOf(".", 0);
      if (index >= 0) {
        name = name.substring(index + 1, name.length - (index + 1));
      }
      Object value;
      // protocol buffer fields have data (type) attribute
      if (elm.attributes != null && elm.attributes.length != 0) {
        Map<String, String> attribs = elm.attributes;
        String attribValue;
        attribValue = attribs["data"];
        if (attribValue != null) {
          value = attribValue;
        } else {
          attribValue = attribs["int"];
          if (attribValue != null) {
            value = int.parse(attribValue);
          } else {
            attribValue = attribs["num"];
            if (attribValue != null) {
              value = double.parse(attribValue);
            } else {
              attribValue = attribs["bool"];
              if (attribValue != null) {
                value = (attribValue == "true") || (attribValue == "1");
              } else {
                attribValue = attribs["float"];
                if (attribValue != null) {
                  value = double.parse(attribValue);
                } else {
                  attribValue = attribs["long"];
                  if (attribValue != null) {
                    value = int.parse(attribValue);
                  } else {
                    attribValue = attribs["double"];
                    if (attribValue != null) {
                      value = double.parse(attribValue);
                    } else {
                      StringBuffer sb = new StringBuffer();
                      sb.write("unknown proto type field");
                      sb.write(child.toString());
                      Application.current.error(sb.toString());
                      continue;
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        // It's a child object or message set.
        value = protoXmlToModel(child);
      }
      // Check for repeatable field
      Object prevValue = proto.getMember(name);
      Model prevModel = prevValue is Model ? prevValue : null;
      if (prevValue != null) {
        // if previous value is not Model, make it so
        if ((prevModel == null) || (prevModel.getMember("_repeatable_") ==
            null)) {
          // Remove existing as a property.
          proto._properties.remove(name);

          // Re-insert as repeatable field.
          Model repeatable = new Model();
          repeatable.setChildByName("_repeatable_", true);
          repeatable.addChild(prevModel);
          repeatable.addChild(value);

          proto.setChildByName(name, repeatable);
        } else {
          prevModel.addChild(value);
        }
      } else {
        proto.setChildByName(name, value);
      }
    }
    return proto;
  }

  static ServiceRequestInterceptor interceptor = null;
  static String rewriteUrl(String url) {
    if (interceptor == null) {
      return url;
    }
    return interceptor(url);
  }

  /**
   * Loads image and calls callback when image and dimensions are ready.
   * clients typically call drawBitmap api's on UISurface to consume.
   */
  static Object loadImage(String url, LoadImageCallback callback,
                          [loadFailureCallback = null]) {
    RootSurface rs = Application.current.rootSurface;
    ImageElement image = new Element.tag('img');
    new _ImageLoader(image, callback, loadFailureCallback);
    image.src = url;
    return image;
  }

  /**
   * Loads an image from alternative source (non-url based).
   */
  static Object loadImageFromBytes(Object value, LoadImageCallback callback) {
    if (value is ImageData) {
      ImageData imageData = value;
      callback(value, imageData.width, imageData.height);
      return imageData;
    } else if (value is FFImage) {
      FFImage imageSource = value;
      callback(imageSource.data, imageSource.width, imageSource.height);
      return value;
    } else {
      throw new Exception("Unsupported image data type");
    }
  }

  /**
   * Gets masked image bytes.
   */
  static Object getMaskedImageData(Object image_or_imageElement,
                                     num x,
                                     num y,
                                     num width,
                                     num height,
                                     VecPath mask) {
    CanvasElement canvas = new Element.tag('canvas');
    Object imageElement = image_or_imageElement;
    if (imageElement is Image) {
      imageElement = (imageElement as Image)._image;
    }
    canvas.width = width.toInt();
    canvas.height = height.toInt();
    CanvasRenderingContext2D context = canvas.getContext('2d');

    drawPath(context, null, mask, null);
    context.clip();

    if (imageElement is ImageData) {
      context.putImageData(imageElement, -x, -y);
    } else if (imageElement is FFImage) {
      FFImage ffImage = imageElement;
      Object d = ffImage.data;
      context.putImageData(d, -x, -y, 0, 0,
          ffImage.width, ffImage.height);
    } else {
      context.drawImage(imageElement, -x, -y);
    }
    Object imageData = context.getImageData(0, 0, width, height);
    if (Application.isFF) {
      return new FFImage(imageData, width, height);
    }
    return imageData;
  }

  /**
   * Gets cropped image bytes.
   */
  static Object getCroppedImageData(Object image_or_imageElement,
                                     num x,
                                     num y,
                                     num width,
                                     num height) {
    CanvasElement canvas = new Element.tag('canvas');
    Object imageElement = image_or_imageElement;
    if (imageElement is Image) {
      imageElement = (imageElement as Image)._image;
    }
    canvas.width = width.toInt();
    canvas.height = height.toInt();
    CanvasRenderingContext2D context = canvas.getContext('2d');
    if (imageElement is ImageData) {
      context.putImageData(imageElement, -x, -y);
    } else if (imageElement is FFImage) {
      FFImage ffImage = imageElement;
      Object d = ffImage.data;
      context.putImageData(d, -x, -y, 0, 0,
          ffImage.width, ffImage.height);
    } else {
      context.drawImage(imageElement, -x, -y);
    }
    Object imageData = context.getImageData(0, 0, width, height);
    if (Application.isFF) {
      return new FFImage(imageData, width, height);
    }
    return imageData;
  }

  /**
   * Gets cropped image bytes encoded as png.
   */
  static List<int> getCroppedImagePng(Image image,
                                     num x,
                                     num y,
                                     num width,
                                     num height) {
    CanvasElement canvas = new Element.tag('canvas');
    canvas.width = (width).toInt();
    canvas.height = (height).toInt();
    CanvasRenderingContext2D context = canvas.getContext('2d');
    Object imageElement = image._image;
    if (imageElement is ImageData) {
      context.putImageData(imageElement, -x, -y);
    } else if (imageElement is FFImage) {
      FFImage ffImage = imageElement;
      context.drawImage(ffImage.data, -x, -y);
    } else {
      context.drawImage(imageElement, -x, -y);
    }
    return _getImageBytes(canvas);
  }

  /**
   * Gets image bytes encoded as png.
   */
  static List<int> _getImageBytes(CanvasElement canvas) {
    String dataUrl = canvas.toDataUrl("image/png");
    String image64 = dataUrl.substring(dataUrl.indexOf('base64,') + 7);
    String rawStream = window.atob(image64);
    List<int> rawBytes = new List<int>(rawStream.length);
    // TODO(ferhat): talk to dart team about rawStream to List<int> conversion.
    // The code below should not be required.
    for (int i = 0; i < rawStream.length; i++) {
      rawBytes[i] = rawStream.codeUnitAt(i);
    }
    return rawBytes;
  }

  /**
   * Gets resized image bytes encoded as png.
   */
  static List<int> getResizedImgPng(Image image) {
    UITransform transform = image.transform;
    num width = transform.scaleX * image.width;
    num height = transform.scaleY * image.height;

    CanvasElement canvas = new Element.tag('canvas');
    canvas.width = (width).toInt();
    canvas.height = (height).toInt();
    CanvasRenderingContext2D context = canvas.getContext('2d');
    Object imageElement = image._image;

    if (imageElement is ImageData) {
      // Copy the original image to a new canvas' drawing context.
      CanvasElement originalImage = new Element.tag('canvas');
      originalImage.width = (image.imageWidth).toInt();
      originalImage.height = (image.imageHeight).toInt();
      CanvasRenderingContext2D originalContext = originalImage.getContext('2d');
      originalContext.putImageData(imageElement, 0, 0);

      // Resize the image.
      context.drawImageScaled(originalImage, 0, 0, width, height);
    } else if (imageElement is FFImage) {
      FFImage ffImage = imageElement;
      context.drawImageScaledFromSource(ffImage.data,
          0, 0, width, height,
          0, 0, image.imageWidth, image.imageHeight);
    } else {
      context.drawImageScaledFromSource(imageElement,
          0, 0, width, height,
          0, 0, image.imageWidth, image.imageHeight);
    }
    return _getImageBytes(canvas);
  }

  /**
   * Cancels image loading for object returned from UIPlatform.loadImage.
   */
  static void cancelLoadImage(Object image) {
    if (image is ImageData || image is FFImage) {
      return;
    }
    ImageElement img = image;
    img.attributes.remove("src");
  }

  static void setTimeout(handler, int timeout) {
    new Timer(new Duration(milliseconds: timeout), handler);
  }

  /**
   * Performs relayout on root when top level host(browser window) resizes.
   */
  static void relayoutRoot(UISurface rootSurface, bool disableScrollBars) {
    RootSurface s = rootSurface;
    s.onRelayoutRoot(disableScrollBars);
  }

  /**
   * Transforms the element with given css transform and transition.
   * TODO(ferhat): deprecate.
   */
  static void setTransition(UISurface surface, String transition,
                            [TransitionEndCallback endCB]) {
    UISurfaceImpl s = surface;
    Element element = s.hostElement;
    element.style.transition = transition;
    if (endCB != null) {
      Function endListener;
      endListener= (event) {
        _listenerToSub[endListener].cancel();
        _listenerToSub.remove(endListener);
        endCB();
      };
      _listenerToSub[endListener] = element.onTransitionEnd.listen(endListener);
    }
  }

  /**
   * Allow platform specific animations.
   */
  static AnimateAction animate(UxmlElement target,
                               PropertyDefinition propertyKey,
                               Object targetValue, {int duration:250,
                               TaskCompleteCallback callback:null, int delay:0,
                               String easing:'linear'}) {

    // For transform properties, use CSS3 transitions.
    if (target is UITransform || propertyKey == UIElement.transformProperty ||
        propertyKey == UIElement.opacityProperty) {
      UIElement uiElement = (target is UITransform ?
          target.target : target);
      UISurfaceImpl surface = uiElement.hostSurface;

      // Use the AnimateAction class to hold the target and the property.
      AnimateAction action = new AnimateAction();
      action.fromValue = target.getProperty(propertyKey);
      action.toValue = targetValue;
      action.targetValue = target;
      action.property = propertyKey;
      action.duration = duration;
      action.delay = delay;
      action.easing = easing;

      UpdateQueueHandler handler = (param) {
        Element element = surface.hostElement;
        element.style.transitionProperty =
            (propertyKey == UIElement.opacityProperty ? "opacity" :
              "-webkit-transform");
        element.style.transitionDelay = '${delay/1000}s';
        element.style.transitionTimingFunction = easing;
        element.style.transitionDuration = '${duration/1000}s';

        // Listen to transition end to clear the transition.
        Function endListener;
        endListener = (event) {
          element.style.transition = 'none';
          _listenerToSub[endListener].cancel();
          _listenerToSub.remove(endListener);

          if (callback != null) {
            callback(action, null);
          }
        };
        _listenerToSub[endListener] = element.onTransitionEnd.listen(
            endListener);

        // Now set the property to trigger the transition.
        target.setProperty(propertyKey, targetValue);
      };
      UpdateQueue.doLater(handler, null, null);

      // Return the animate action so that we can cancel the animation below.
      return action;
    } else {
      return target.animate(propertyKey, targetValue, duration:duration,
          callback:callback, delay:delay);
    }
  }

  /**
   * Reverses the animation started with .animate.
   */
  static void reverseAnimation(AnimateAction animation) {
    UxmlElement target = animation.targetValue;
    if (target is UITransform ||
        animation.property == UIElement.transformProperty ||
        animation.property == UIElement.opacityProperty) {
      animate(animation.targetValue, animation.property, animation.fromValue,
          duration:animation.duration, easing:animation.easing);
    } else {
      animation.reverse(target);
    }
  }

  /**
   * Cancel platform specific animation.
   */
  static void cancelAnimation(AnimateAction animation) {
    UxmlElement target = animation.targetValue;
    if (target is UITransform ||
        animation.property == UIElement.transformProperty ||
        animation.property == UIElement.opacityProperty) {
      UIElement uiElement = (target is UITransform ? target.target : target);
      UISurfaceImpl surface = uiElement.hostSurface;
      Element element = surface.hostElement;
      element.style.transition = 'none';
    } else {
      animation.stop(target);
    }
  }

  /** Updates all child div locations. */
  static void _updateChildLocations(UISurface surface) {
    UISurfaceImpl s = surface;
    int childCount = s.childCount;
    for (int c = childCount - 1; c >= 0; c--) {
      UISurface child = s.childAt(c);
      _updateLocations(child);
    }
  }

  static void _updateLocations(UISurfaceImpl s) {
    if (s.hostElement != null) {
      s._updateLocation();
      return; // We're done since this is a physical surface, all children will
              // be relative to this surface. No need to update children.
    } else {
      int childCount = s.childCount;
      for (int c = childCount - 1; c >= 0; c--) {
        UISurface child = s.childAt(c);
        _updateLocations(child);
      }
    }
  }

  static String getCookie(String name) {
    if (_cookies != null) {
      return _cookies[name];
    }
    _cookies = new Map<String, String>();
    List cookieList = document.cookie.split(";");
    for (int i = cookieList.length - 1; i >=0 ; i--) {
      String nameVal = cookieList[i];
      int pos = nameVal.indexOf("=");
      if (pos != -1) {
        _cookies[nameVal.substring(0, pos -1)] = nameVal.substring(pos + 1);
      }
    }
  }
}

/** Creates a wrapper around document body that represents root surface */
class RootSurface extends UISurfaceImpl {
  Application app;
  Element body;

  RootSurface(Application owner, Window win) : super() {
    app = owner;
    body =  document.body;
    document.body.style.margin = '0';
    document.body.style.height = '100%';
  }

  UISurface addChild(UISurface child) {
    super.addChild(child);
    (child as UISurfaceImpl).root = app;
    return child;
  }

  UISurface insertChild(int index, UISurface child) {
    super.insertChild(index, child);
    (child as UISurfaceImpl).root = app;
    return child;
  }

  void _createElementOnDemand() {
  }

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
    body.append(newChild);
  }

  void _hostElementCreated(UISurfaceImpl child) {
    child.hostElement.style.position = "absolute";
    body.nodes.add(child.hostElement);
    app.onRootSurfaceCreated();
  }

  void onRelayoutRoot(bool disableScrollBars) {
    Element docBody = document.body;
    if (disableScrollBars) {
      docBody.style.overflowY = "hidden";
      docBody.style.overflowX = "hidden";
    } else {
      docBody.style.removeProperty("overflow-y");
      docBody.style.removeProperty("overflow-x");
    }
  }
}

class FFImage {
  var data;
  num width;
  num height;
  FFImage(this.data, this.width, this.height);
}

class _ImageLoader {
  LoadImageCallback loadCallback;
  var errorCallback;
  StreamSubscription<Event> _loadSub = null;
  StreamSubscription<Event> _errorSub = null;

  ImageElement image;

  _ImageLoader(this.image, this.loadCallback, this.errorCallback) {
    _loadSub = image.onLoad.listen(onSuccess);
    if (errorCallback != null) {
      _errorSub = image.onError.listen(onError);
    }
  }

  void onSuccess(event) {
    loadCallback(image, image.naturalWidth, image.naturalHeight);
    cleanup();
  }

  void onError(event) {
    if (errorCallback != null) {
      errorCallback();
    }
    cleanup();
  }

  void cleanup() {
    if (_loadSub != null) {
      _loadSub.cancel();
      _loadSub = null;
    }
    if (_errorSub != null) {
      _errorSub.cancel();
      _errorSub = null;
    }
    loadCallback = null;
    errorCallback = null;
    image = null;
  }
}

typedef String ServiceRequestInterceptor(String url);
typedef void LoadImageCallback(Object image,num width, num height);
typedef void _TransitionCallback(Event event);
typedef void TransitionEndCallback();
