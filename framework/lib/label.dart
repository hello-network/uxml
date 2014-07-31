part of uxml;

/**
 * Implements label control to display static text.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Label extends Control {
  static ElementDef labelElementDef;
  /** Text property definition. */
  static PropertyDefinition textProperty;
  /** Wordwrap property definition. */
  static PropertyDefinition wordWrapProperty;
  /** Multiline property definition. */
  static PropertyDefinition multilineProperty;
  /** SizeToBold property definition. */
  static PropertyDefinition sizeToBoldProperty;
  /** Text alignment property definition. */
  static PropertyDefinition textAlignProperty;
  /** HtmlEnabled property definition. */
  static PropertyDefinition htmlEnabledProperty;
  /** Ellipsis property definition. */
  static PropertyDefinition ellipsisProperty;
  /** Selectable property definition. */
  static PropertyDefinition selectableProperty;
  /** LinkClick event definition. */
  static EventDef linkClickEvent;

  static const int ALIGN_LEFT = 0;
  static const int ALIGN_CENTER = 1;
  static const int ALIGN_RIGHT = 2;

  Label() : super() {
    mouseEnabled = false;
  }

  /**
   * Sets or returns text.
   */
  String get text {
    String value = getProperty(textProperty);
    return (value == null ? "" : value);
  }

  set text(String value) {
    setProperty(textProperty, value);
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    UITextSurface textSurface = parentSurface.insertChild(index,
        UIPlatform.createTextSurface());
    _hostSurface = textSurface;
    _hostSurface.target = this;
    updateTextSurface();
    //textSurface.alpha = opacity;
    if (!isLayoutInitialized) {
      textSurface.visible = false;
    }
    textSurface.mouseEnabled = mouseEnabled;
    textSurface.enableHitTesting = mouseEnabled;
    // TODO(ferhat): Implement ellipsis,multiline in text surface.
    // textSurface.ellipsisEnabled = ellipsis;
    if (wordWrap) {
      textSurface.wordWrap = wordWrap;
    }
    int align = textAlign;
    if (align != 0) {
      textSurface.textAlign = textAlign;
    }
    textSurface.textColor = textColor;
    textSurface.onTextLink = _onTextEvent;
    if (overridesProperty(UIElement.filtersProperty)) {
      UpdateQueue.updateFilters(this);
    }
    surfaceInitialized(_hostSurface);
  }

  void updateTextSurface() {
    UITextSurface textSurface = _hostSurface;
    if (textSurface == null) {
      return;
    }
    if (!htmlEnabled) {
      textSurface.text = text;
    }
    textSurface.fontName = fontName;
    textSurface.fontSize = fontSize;
    textSurface.fontBold = fontBold;
    textSurface.textColor = textColor;

    if (htmlEnabled) {
      textSurface.htmlText = text;
      if (overridesProperty(selectableProperty)) {
        textSurface.selectable = selectable;
      }
      mouseEnabled = true;
    } else {
      textSurface.selectable = selectable;
    }

    // TODO(ferhat): Implement ellipsis in text surface.
    // textSurface.ellipsisEnabled = ellipsis;
    textSurface.updateTextView();
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    UITextSurface textSurface = _hostSurface;
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    if (textSurface != null) {
      textSurface.measureText(text, availableWidth - pw, availableHeight - ph,
          sizeToBold);
      setMeasuredDimension(textSurface.measuredWidth + pw,
          textSurface.measuredHeight + ph);
    }
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    UITextSurface textSurface = _hostSurface;
    if (textSurface != null) {
      if (!isLayoutInitialized) {
        // Set visibility if this is the first time onLayout is called.
        textSurface.visible = visible;
      }
      num pw = padding.left + padding.right;
      num ph = padding.top + padding.bottom;
      textSurface.setLocation((textSurface.layoutX + padding.left).toInt(),
          (textSurface.layoutY + padding.top).toInt(),
          (targetWidth - pw).toInt(),
          (targetHeight - ph).toInt());
    }
  }

  void onFontChanged() {
    if (_hostSurface != null) {
      UITextSurface textSurface = _hostSurface;
      textSurface.fontName = fontName;
      textSurface.fontSize = fontSize;
      textSurface.fontBold = fontBold;
      textSurface.textColor = (textColor == null) ? Color.BLACK : textColor;
      textSurface.updateTextView();
    }
    invalidateSize();
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    if (_hostSurface != null) {
      UITextSurface textSurface = _hostSurface;
      textSurface.onTextLink = null;
    }
    super.close();
  }

  /**
   * Sets or returns if ellipsis is enabled.
   */
  bool get ellipsis => getProperty(ellipsisProperty);

  set ellipsis(bool value) {
    setProperty(ellipsisProperty, value);
  }

  /**
   * Sets or returns if wordWrap is enabled.
   */
  bool get wordWrap => getProperty(wordWrapProperty);

  set wordWrap(bool value) {
    setProperty(wordWrapProperty, value);
  }

  /**
   * Sets or returns if line breaks are enabled.
   */
  bool get multiline => getProperty(multilineProperty);

  set multiline(bool value) {
    setProperty(multilineProperty, value);
  }

  /**
   * Sets or returns if label is measured with bold style.
   */
  bool get sizeToBold => getProperty(sizeToBoldProperty);

  set sizeToBold(bool value) {
    setProperty(sizeToBoldProperty, value);
  }

  /**
   * Sets or returns text alignment.
   */
  int get textAlign => getProperty(textAlignProperty);

  set textAlign(int value) {
    setProperty(textAlignProperty, value);
  }

  /**
   * Sets or returns if text is selectable.
   */
  bool get selectable => getProperty(selectableProperty);

  set selectable(bool value) {
    setProperty(selectableProperty, value);
  }

  void _onTextEvent(DataEvent event) {
    if (hasListener(linkClickEvent)) {
      notifyListeners(linkClickEvent, event);
    }
  }

  /**
   * Sets or returns if label content is html.
   */
  bool get htmlEnabled => getProperty(htmlEnabledProperty);

  set htmlEnabled(bool value) {
    setProperty(htmlEnabledProperty, value);
  }

  static void _htmlEnabledChangeHandler(Object target,
                                        Object propDef,
                                        Object oldValue,
                                        Object newValue) {
    Label label = target;
    UITextSurface textSurface = label._hostSurface;
    if (textSurface != null) {
      if (label.htmlEnabled) {
        textSurface.htmlText = label.text;
      } else {
        textSurface.text = label.text;
      }
    }
  }

  static void _lineStyleChangeHandler(Object target,
                                      Object propDef,
                                      Object oldValue,
                                      Object newValue) {
    Label label = target;
    UITextSurface textSurface = label._hostSurface;
    if (textSurface != null) {
      textSurface.textAlign = label.textAlign;
    }
  }

  static void _wordWrapChangeHandler(Object target,
                                      Object propDef,
                                      Object oldValue,
                                      Object newValue) {
    Label label = target;
    UITextSurface textSurface = label._hostSurface;
    if (textSurface != null) {
      textSurface.wordWrap = label.wordWrap;
    }
  }

  static void _textChangeHandler(Object target,
                                 Object propDef,
                                 Object oldValue,
                                 Object newValue) {
    Label label = target;
    if (newValue is num) {
      throw new Exception("Invalid type");
    }
    label.updateTextSurface();
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => labelElementDef;

  /** Registers component. */
  static void registerLabel() {
    textProperty = ElementRegistry.registerProperty("text",
        PropertyType.STRING, PropertyFlags.RESIZE, _textChangeHandler, "");
    wordWrapProperty = ElementRegistry.registerProperty("wordWrap",
        PropertyType.BOOL, PropertyFlags.RESIZE, _wordWrapChangeHandler,
        false);
    multilineProperty = ElementRegistry.registerProperty("multiline",
        PropertyType.BOOL, PropertyFlags.RESIZE, _wordWrapChangeHandler,
        false);
    ellipsisProperty = ElementRegistry.registerProperty("ellipsis",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    sizeToBoldProperty = ElementRegistry.registerProperty("sizeToBold",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    textAlignProperty = ElementRegistry.registerProperty("textAlign",
        PropertyType.INT, PropertyFlags.REDRAW, _lineStyleChangeHandler, 0);
    selectableProperty = ElementRegistry.registerProperty("selectable",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    htmlEnabledProperty = ElementRegistry.registerProperty("htmlEnabled",
        PropertyType.BOOL, PropertyFlags.RESIZE, _htmlEnabledChangeHandler,
        false);
    ellipsisProperty = ElementRegistry.registerProperty("ellipsis",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    linkClickEvent = new EventDef("LinkClick", Route.DIRECT);
    labelElementDef = ElementRegistry.register("Label",
        Control.controlElementDef, [htmlEnabledProperty, selectableProperty,
        textAlignProperty, textProperty, wordWrapProperty], [linkClickEvent]);
  }
}
