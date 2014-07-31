part of uxml;

/**
 * Implements text edit control to display editable text.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class TextEdit extends Control {
  static ElementDef texteditElementDef;
  /** Text property definition */
  static PropertyDefinition textProperty;
  /** Wordwrap property definition */
  static PropertyDefinition wordWrapProperty;
  /** HtmlEnabled property definition */
  static PropertyDefinition htmlEnabledProperty;
  /** Multiline property definition */
  static PropertyDefinition multilineProperty;
  /** Display as password property definition */
  static PropertyDefinition displayAsPasswordProperty;
  /** Readonly property definition */
  static PropertyDefinition readOnlyProperty;
  /** MaxChars property definition */
  static PropertyDefinition maxCharsProperty;

  /** LinkClick event definition */
  static EventDef linkClickEvent;

  TextEdit() : super() {
    focusEnabled = true;
    cursor = Cursor.IBEAM.name;
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

  /** Overrides UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    UIEditSurface editSurface = parentSurface.insertChild(
        index, UIPlatform.createEditSurface());
    _hostSurface = editSurface;
    _hostSurface.target = this;
    _updateTextSurface();
    //editSurface.alpha = opacity;
    editSurface.visible = false;
    editSurface.mouseEnabled = mouseEnabled;
    editSurface.enableHitTesting = mouseEnabled;
    editSurface.wordWrap = wordWrap;
    editSurface.multiline = multiline;
    editSurface.textColor = textColor;
    editSurface.onTextLink = _onTextEvent;
    editSurface.maxChars = maxChars;
    if (overridesProperty(UIElement.filtersProperty)) {
      UpdateQueue.updateFilters(this);
    }
    _updatePrompt();
    surfaceInitialized(_hostSurface);
    _hostSurface.hitTestMode = UISurfaceImpl.HITTEST_BOUNDS;
  }

  void _updateTextSurface() {
    UIEditSurface editSurface = _hostSurface;
    if (editSurface == null) {
      return;
    }
    if (!htmlEnabled) {
      editSurface.text = text;
    }
    editSurface.fontName = fontName;
    editSurface.fontSize = fontSize;
    editSurface.fontBold = fontBold;
    editSurface.textColor = textColor;
    if (htmlEnabled) {
      editSurface.htmlText = text;
    }
  }

  void _updatePrompt() {
    if (promptMessage == null || promptMessage.length == 0) {
      return;
    }
    if (hostSurface != null) {
      UIEditSurface editSurface = hostSurface;
      editSurface.promptMessage = promptMessage;
    }
  }

  /** Overrides UIElement.onMouseDown to set focus to text edit. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    if (enabled && (!readOnly)) {
      if (!isFocused) {
          setFocus();
      }
    }
    UIPlatform.handleEditMouseEvent(mouseArgs);
    mouseArgs.handled = true;
  }

  void onMouseEnter(MouseEventArgs e) {
    if (hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.enableMouseEvents(true && enabled);
    }
  }

  void onMouseExit(MouseEventArgs e) {
    if (hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.enableMouseEvents(false);
    }
  }

  void onKeyDown(KeyboardEventArgs e) {
    if (e.keyCode == KeyboardEventArgs.KEYCODE_ENTER && multiline == false) {
      e.handled = true;
    }
  }

  /**
   * Called by UISurface to focus input to an element.
   */
  bool surfaceFocusChanged(bool hasFocus) {
    isFocused = hasFocus;
    return isFocused == hasFocus;
  }

  /** Sets focus to element. */
  void setFocus() {
    isFocused = true;
    if (hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.initFocus(false);
    }
  }

  /**
   * Called on focus change.
   */
  void focusChanged() {
    if (hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.focusChanged(isFocused);
    }
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    UIEditSurface editSurface = _hostSurface;
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    if (editSurface != null) {
      editSurface.measureText(text, availableWidth - pw, availableHeight - ph);
      setMeasuredDimension(editSurface.measuredWidth + pw,
          editSurface.measuredHeight + ph);
    }
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    UIEditSurface editSurface = _hostSurface;
    if (editSurface != null) {
      if (!isLayoutInitialized) {
        // Set visibility if this is the first time onLayout is called.
        editSurface.visible = visible;
      }
      num pw = padding.left + padding.right;
      num ph = padding.top + padding.bottom;
      editSurface.setLocation((editSurface.layoutX + padding.left).toInt(),
          (editSurface.layoutY + padding.top).toInt(),
          (targetWidth - pw).toInt(), (targetHeight - ph).toInt());
    }
  }

  /** Implements ISurfaceTarget.surfaceTextChanged. */
  void surfaceTextChanged(String newText) {
    text = newText;
  }

  /** Overrides Control.onFontChanged to update surface. */
  void onFontChanged() {
    if (_hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.fontName = fontName;
      editSurface.fontSize = fontSize;
      editSurface.fontBold = fontBold;
      editSurface.textColor = (textColor == null) ? Color.BLACK : textColor;
    }
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    if (_hostSurface != null) {
      UIEditSurface editSurface = _hostSurface;
      editSurface.onTextLink = null;
    }
    super.close();
  }

  /**
   * Sets or returns if wordWrap is enabled.
   */
  bool get wordWrap => getProperty(wordWrapProperty);

  set wordWrap(bool value) {
    setProperty(wordWrapProperty, value);
  }

  /**
   * Sets or returns if textedit is readonly.
   */
  bool get readOnly => getProperty(readOnlyProperty);

  set readOnly(bool value) {
    setProperty(readOnlyProperty, value);
  }

  /**
   * Sets or returns if multiline is enabled.
   */
  bool get multiline => getProperty(multilineProperty);

  set multiline(bool value) {
    setProperty(multilineProperty, value);
  }

  /**
   * Sets or returns max chars allowed in text field.
   */
  int get maxChars => getProperty(maxCharsProperty);

  set maxChars(int value) {
    setProperty(maxCharsProperty, value);
  }

  void _onTextEvent(DataEvent event) {
    if (hasListener(linkClickEvent)) {
      notifyListeners(linkClickEvent, event);
    }
  }

  /**
   * Sets or returns if text edit content is html.
   */
  bool get htmlEnabled => getProperty(htmlEnabledProperty);

  set htmlEnabled(bool value) {
    setProperty(htmlEnabledProperty, value);
  }

  static void _htmlEnabledChangeHandler(Object target,
                                        Object propDef,
                                        Object oldValue,
                                        Object newValue) {
    TextEdit textEdit = target;
    UIEditSurface editSurface = textEdit._hostSurface;
    if (editSurface != null) {
      if (textEdit.htmlEnabled) {
        editSurface.htmlText = ""; // force change.
        editSurface.htmlText = textEdit.text;
      } else {
        editSurface.text = ""; // force change.
        editSurface.text = textEdit.text;
      }
    }
  }

  static void _maxCharsChangedHandler(Object target,
                                      Object propDef,
                                      Object oldValue,
                                      Object newValue) {
    TextEdit textEdit = target;
    UIEditSurface editSurface = textEdit._hostSurface;
    if (editSurface != null) {
      editSurface.maxChars = textEdit.maxChars;
    }
  }

  static void _lineStyleChangeHandler(Object target,
                                      Object propDef,
                                      Object oldValue,
                                      Object newValue) {
    TextEdit textEdit = target;
    UIEditSurface editSurface = textEdit._hostSurface;
    if (editSurface != null) {
      editSurface.multiline = textEdit.multiline;
      editSurface.wordWrap = textEdit.wordWrap;
    }
  }

  static void _textChangeHandler(Object target,
                                 Object propDef,
                                 Object oldValue,
                                 Object newValue) {
    TextEdit textEdit = target;
    textEdit._updateTextSurface();
  }

  /** Selects all text.*/
  void selectAll() {
    // TODO(ferhat):impl.
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => texteditElementDef;

  /** Registers component. */
  static void registerTextEdit() {
    textProperty = ElementRegistry.registerProperty("text",
        PropertyType.STRING, PropertyFlags.RESIZE, _textChangeHandler, "");
    wordWrapProperty = ElementRegistry.registerProperty("wordWrap",
        PropertyType.BOOL, PropertyFlags.RESIZE, _lineStyleChangeHandler,
        false);
    htmlEnabledProperty = ElementRegistry.registerProperty("htmlEnabled",
        PropertyType.BOOL, PropertyFlags.RESIZE, _htmlEnabledChangeHandler,
        false);
    multilineProperty = ElementRegistry.registerProperty("multiline",
        PropertyType.BOOL, PropertyFlags.RESIZE, _lineStyleChangeHandler,
        false);
    displayAsPasswordProperty = ElementRegistry.registerProperty(
        "displayAsPassword", PropertyType.BOOL, PropertyFlags.NONE, null,
        false);
    readOnlyProperty = ElementRegistry.registerProperty("readOnly",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    maxCharsProperty = ElementRegistry.registerProperty("maxChars",
        PropertyType.INT, PropertyFlags.NONE, _maxCharsChangedHandler, 0);
    linkClickEvent = new EventDef("LinkClick", Route.DIRECT);
    texteditElementDef = ElementRegistry.register("TextEdit",
        Control.controlElementDef,
        [textProperty, wordWrapProperty, htmlEnabledProperty, multilineProperty,
        displayAsPasswordProperty, readOnlyProperty, maxCharsProperty],
        [linkClickEvent]);

    Cursor.cursorProperty.overrideDefaultValue(texteditElementDef,
        Cursor.IBEAM);
  }
}
