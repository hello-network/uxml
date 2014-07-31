part of uxml;

/**
 * Implements image control.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Image extends Control {

  static ElementDef imageElementDef;
  Object _image = null;
  int _loadedWidth;
  int _loadedHeight;
  num _zoomCenterXValue = 0.5;
  num _zoomCenterYValue = 0.5;

  /** Source property definition */
  static PropertyDefinition sourceProperty;
  /** Scale mode property definition */
  static PropertyDefinition scaleModeProperty;
  /** loaded property definition (readonly) */
  static PropertyDefinition loadedProperty;
  /** Tile mode property definition */
  static PropertyDefinition tileProperty;
  /** Monochrome mode property definition */
  static PropertyDefinition monoChromeProperty;

  /** LoadComplete event definition */
  static EventDef loadCompletedEvent;
  /** Load error event definition */
  static EventDef loadErrorEvent;

  /**
   * Constructor.
   */
  Image() : super() {
    _loadedWidth = 0;
    _loadedHeight = 0;
  }

  /**
   * Sets or returns image source.
   */
  Object get source => getProperty(sourceProperty);

  set source(Object value) {
    setProperty(sourceProperty, value);
  }

  /**
   * Sets the zoom scaling
   */
  set zoomCenterX(num scale) {
    _zoomCenterXValue = scale;
  }

  set zoomCenterY(num scale) {
    _zoomCenterYValue = scale;
  }

  /**
   * Returns true if image load was completed.
   */
  bool get loaded => getProperty(loadedProperty);

  /** Gets or sets scaling mode */
  int get scaleMode => getProperty(scaleModeProperty);

  set scaleMode(int value) {
    setProperty(scaleModeProperty, value);
  }

  /** Gets or sets tile mode */
  bool get tile => getProperty(tileProperty);

  set tile(bool value) {
    setProperty(tileProperty, value);
  }

  /** Gets or sets mono chrome color */
  Color get monoChrome => getProperty(monoChromeProperty);

  set monoChrome(Color value) {
    if (value == null || value.A == 0) {
      clearProperty(monoChromeProperty);
    } else {
      setProperty(monoChromeProperty, value);
    }
  }

  /** Gets the loaded bitmap's width. */
  int get imageWidth => _loadedWidth;

  /** Gets the loaded bitmap's height. */
  int get imageHeight => _loadedHeight;

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    if (source != null) {
      _loadImageFromSource(source, true);
    }
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    // If tiling is enabled return 0,0 since we can tile to any dimension
    // including smaller areas than the original image itself.
    if ((_image != null) && (!tile)) {
      num measuredW = _loadedWidth;
      num measuredH = _loadedHeight;
      if (scaleMode == ScaleMode.UNIFORM ||
          scaleMode == ScaleMode.ZOOM ||
          scaleMode == ScaleMode.ZOOM_OUT) {
        if (_loadedWidth != 0 && _loadedHeight != 0) {
          num boundsW;
          if (overridesProperty(UIElement.maxWidthProperty)) {
            boundsW = (maxWidth < measuredW) ? maxWidth : measuredW;
          } else {
            boundsW = availableWidth;
          }
          num boundsH;
          if (overridesProperty(UIElement.maxHeightProperty)) {
            boundsH = (maxHeight < measuredH) ? maxHeight : measuredH;
          } else {
            boundsH = availableHeight;
          }
          if (overridesProperty(UIElement.minHeightProperty)) {
            boundsH = max(minHeight, boundsH);
            if ((!overridesProperty(UIElement.minWidthProperty)) &&
                (minHeight > availableHeight)) {
              // if minHeight is defined but no minWidth, we should ignore
              // available height and return optimum height.
              setMeasuredDimension((minHeight / _loadedHeight) *
                  _loadedWidth, minHeight);
              return false;
            }
          }
          if (overridesProperty(UIElement.minWidthProperty)) {
            boundsW = max(minWidth, boundsW);
            if ((!overridesProperty(UIElement.minHeightProperty)) &&
                minWidth > availableWidth) {
              // if minWidth is defined but no minHeight, we should ignore
              // available width and return optimum height.
              setMeasuredDimension(minWidth, (minWidth / _loadedWidth) *
                  _loadedHeight);
              return false;
            }
          }
          num sx = boundsW / _loadedWidth;
          num sy = boundsH / _loadedHeight;
          if (sx < sy) {
            sy = sx;
          } else {
            sx = sy;
          }
          measuredW = (_loadedWidth * sx);
          measuredH = (_loadedHeight * sy);
        }
      }
      setMeasuredDimension(measuredW, measuredH);
    } else {
      setMeasuredDimension(0.0, 0.0);
    }
    if (scaleMode == ScaleMode.UNIFORM) {
      _markMeasureDirty();
    }
    return false;
  }

  /**
   * Loads content from url or bytearray.
   */
  void _loadImageFromSource(Object value, bool isInitializing) {
    if (_image != null) {
      stopLoading();
    }
    if (value == null) {
      _image = null;
      invalidateSize();
      invalidateDrawing();
      return;
    }
    if (value is String) {
      _image = UIPlatform.loadImage(UIPlatform.rewriteUrl(value),
          _imageContentsLoaded, _imageLoadFailure);
    } else {
      _image = UIPlatform.loadImageFromBytes(value,
          _imageContentsLoaded);
    }
  }

  void _imageContentsLoaded(Object image, num naturalWidth, num naturalHeight) {
    _image = image;
    _loadedWidth = naturalWidth.toInt();
    _loadedHeight = naturalHeight.toInt();
    _updateAfterLoadComplete();
  }

  void stopLoading() {
    if (_image != null) {
      UIPlatform.cancelLoadImage(_image);
      _image = null;
    }
  }

  void _updateAfterLoadComplete() {
    setProperty(loadedProperty, true);
    invalidateSize();
    invalidateDrawing();
    _sendLoadCompleteEvent();
  }

  void _sendLoadCompleteEvent() {
    EventArgs eventArgs = new EventArgs(this);
    eventArgs.event = loadCompletedEvent;
    eventArgs.source = this;
    routeEvent(eventArgs);
  }

  void _imageLoadFailure() {
    EventArgs eventArgs = new EventArgs(this);
    eventArgs.event = loadErrorEvent;
    eventArgs.source = this;
    routeEvent(eventArgs);
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    surface.clear();
    if (_image != null && loaded) {
      Margin m = _margins;
      int mode = scaleMode;
      int offsetX = 0;
      int offsetY = 0;
      num sx = 1.0;
      num sy = 1.0;
      if (mode != ScaleMode.NONE) {
        sx = layoutWidth / _loadedWidth;
        sy = layoutHeight / _loadedHeight;
        if (mode == ScaleMode.UNIFORM) {
          // Scale uniformly to fit within layoutRectangle.
          if (sx < sy) {
            sy = sx;
            offsetY += ((layoutHeight -
                (_loadedHeight * sy)) ~/ 2.0);
          } else {
            sx = sy;
            offsetX += ((layoutWidth -
                (_loadedWidth * sx)) ~/ 2.0);
          }
        } else if (scaleMode == ScaleMode.ZOOM_OUT) {
          // Scale uniformly to fill layoutRectangle but don't upscale.
          if (layoutWidth < _loadedWidth ||
              layoutHeight < _loadedHeight) {
              if (sx < sy) {
                sy = sx;
                offsetY += ((layoutHeight - (_loadedHeight * sy)) ~/ 2);
              } else {
                sx = sy;
                offsetX += ((layoutWidth - (_loadedWidth * sx)) ~/ 2);
              }
          } else {
            sx = 1.0;
            sy = 1.0;
          }
        } else if (scaleMode == ScaleMode.ZOOM) {
          // Scale uniformly to fill layoutRectangle.
          if (sy < sx) {
            sy = sx;
            offsetY += ((layoutHeight - (_loadedHeight * sy)) *
                _zoomCenterYValue).toInt();
          } else {
            sx = sy;
            offsetX += ((layoutWidth - (_loadedWidth * sx)) *
                _zoomCenterXValue).toInt();
          }
        }
      }
      num targetWidth = (_loadedWidth * sx);
      num targetHeight = (_loadedHeight * sy);
      if (tile) {
        targetWidth = layoutWidth;
        targetHeight = layoutHeight;
      }
      if (overridesProperty(monoChromeProperty)) {
        ColorTransform colorTransform = new ColorTransform();
        colorTransform.colorize(getProperty(monoChromeProperty));
        surface.drawBitmapTransformColor(_image, offsetX, offsetY,
            targetWidth, targetHeight, tile, colorTransform);
      } else if (mode == ScaleMode.FILL && _image == null) {
        surface.drawImage(source);
      } else if (_image != null) {
        if (mask != null && mask is PathShape) {
          PathShape pathShape = mask;
            surface.maskBitmap(_image, offsetX, offsetY,
                targetWidth, targetHeight, pathShape.content);
        } else {
          surface.drawBitmap(_image, offsetX, offsetY,
              targetWidth, targetHeight, tile);
        }
      }
    }
  }

  static void _imageSourceChangeHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    // load image from source ONLY if surface is initialized
    Image image = target;
    if (image._hostSurface != null) {
      image._loadImageFromSource(newValue, false);
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => imageElementDef;

  /** Registers component. */
  static void registerImage() {
    sourceProperty = ElementRegistry.registerProperty("source",
        PropertyType.OBJECT, PropertyFlags.NONE, _imageSourceChangeHandler,
        null);
    scaleModeProperty = ElementRegistry.registerProperty("scaleMode",
        PropertyType.SCALEMODE, PropertyFlags.REDRAW, null, ScaleMode.NONE);
    loadedProperty = ElementRegistry.registerProperty("loaded",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    tileProperty = ElementRegistry.registerProperty("tile",
        PropertyType.BOOL, PropertyFlags.REDRAW, null, false);
    monoChromeProperty = ElementRegistry.registerProperty("monoChrome",
        PropertyType.COLOR, PropertyFlags.REDRAW, null, null);
    loadCompletedEvent = new EventDef("loadCompleted", Route.BUBBLE);
    loadErrorEvent = new EventDef("loadError", Route.BUBBLE);
    imageElementDef = ElementRegistry.register("Image",
        Control.controlElementDef, [sourceProperty, scaleModeProperty,
        loadedProperty, tileProperty, monoChromeProperty],
        [loadCompletedEvent]);
  }
}
