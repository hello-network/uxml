part of uxml;

/**
 * Implements textbox control to display editable text.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class TextBox extends Control {

  static ElementDef textboxElementDef;
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
  /** IsEmpty property definition */
  static PropertyDefinition isEmptyProperty;
  /** MaxChars property definition */
  static PropertyDefinition maxCharsProperty;
  /** CharsRemaining property definition */
  static PropertyDefinition charsRemainingProperty;
  /** TextChanged event definition */
  static EventDef textChangedEvent;

  static EventArgs _changeEventArgs;
  bool _deferredFocus;

  TextBox() : super() {
    focusEnabled = true;
    _deferredFocus = false;
  }

  /**
   * Sets or returns text.
   */
  String get text => getProperty(textProperty);

  set text(String value) {
    setProperty(textProperty, value);
  }

  /**
   * Sets or returns displayAsPassword.
   */
  bool get displayAsPassword => getProperty(displayAsPasswordProperty);

  set displayAsPassword(bool value) {
    setProperty(displayAsPasswordProperty, value);
  }

  /**
   * Sets or returns if multiline is enabled.
   */
  bool get multiline => getProperty(multilineProperty);

  set multiline(bool value) {
    setProperty(multilineProperty, value);
  }

  /**
   * Sets or returns if wordWrap is enabled.
   */
  bool get wordWrap => getProperty(wordWrapProperty);

  set wordWrap(bool value) {
    setProperty(wordWrapProperty, value);
  }

  /**
   * Sets or returns if text content is html.
   */
  bool get htmlEnabled => getProperty(htmlEnabledProperty);

  set htmlEnabled(bool value) {
    setProperty(htmlEnabledProperty, value);
  }

  /**
   * Sets or returns if text content is editable.
   */
  bool get readonly => getProperty(readOnlyProperty);

  set readonly(bool value) {
    setProperty(readOnlyProperty, value);
  }

  /**
   * Sets or returns max chars allowed in text field.
   */
  int get maxChars => getProperty(maxCharsProperty);

  set maxChars(int value) {
    setProperty(maxCharsProperty, value);
  }

  /** Overrides UIElement.onChromeChanged. */
  void onChromeChanged(Chrome oldChrome, Chrome newChrome) {
    super.onChromeChanged(oldChrome, newChrome);
    _redirectFocusChrome();
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    _redirectFocusChrome();
    if (_deferredFocus && (_internalTextEdit != null)) {
      _internalTextEdit.setFocus();
    }
  }

  TextEdit get _internalTextEdit {
    if (chromeTree != null) {
      return chromeTree.getElementByType(TextEdit.texteditElementDef);
    }
    return null;
  }

  void _redirectFocusChrome() {
    if (chromeTree != null) {
      TextEdit textEdit = _internalTextEdit;
      if (textEdit != null) {
        FocusManager.redirectFocusChrome(textEdit, this);
      }
    }
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    TextEdit textEdit = _internalTextEdit;
    if (textEdit != null) {
      if (textEdit.isFocused == false) {
        textEdit.setFocus();
      }
    }
    mouseArgs.handled = true;
    mouseArgs._passthrough();
  }

  /**
   * Selects all text in editor.
   */
 void selectAll() {
    if (_internalTextEdit != null) {
      _internalTextEdit.selectAll();
    }
  }

  /**
   * Returns the number of chars remaining out of maxChars.
   */
  int get charsRemaining => getProperty(charsRemainingProperty);

  /**
   * Returns true if textbox is empty.
   */
  bool get isEmpty => getProperty(isEmptyProperty);

  static void _maxCharsChangedHandler(Object target,
                                      Object propDef,
                                      Object oldValue,
                                      Object newValue) {
    TextBox textBox = target;
    textBox._updateCharsRemaining();
  }

  static void _textChangedHandler(Object target,
                                  Object propDef,
                                  Object oldValue,
                                  Object newValue) {
    TextBox textBox = target;
    if (newValue != null && textBox.maxChars > 0) {
      textBox._updateCharsRemaining();
    }

    _changeEventArgs.source = textBox;
    textBox.notifyListeners(textChangedEvent, _changeEventArgs);
  }

  void _updateCharsRemaining() {
    setProperty(isEmptyProperty, text.length == 0);
    if (maxChars > 0) {
      setProperty(charsRemainingProperty, maxChars - text.length);
    } else {
      setProperty(charsRemainingProperty, 0x7FFFFFFF);
    }
  }

  /** Sets input focus to textbox. */
  void setFocus() {
    if (_hostSurface == null) {
      _deferredFocus = true;
    }
    TextEdit textEdit = _internalTextEdit;
    if (textEdit != null) {
      textEdit.setFocus();
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => textboxElementDef;

  /** Registers component. */
  static void registerTextBox() {
    textProperty = ElementRegistry.registerProperty("text",
        PropertyType.STRING, PropertyFlags.RESIZE, _textChangedHandler, "");
    wordWrapProperty = ElementRegistry.registerProperty("wordWrap",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    htmlEnabledProperty = ElementRegistry.registerProperty("htmlEnabled",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    multilineProperty = ElementRegistry.registerProperty("multiline",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    displayAsPasswordProperty = ElementRegistry.registerProperty(
        "displayAsPassword", PropertyType.BOOL, PropertyFlags.NONE, null,
        false);
    readOnlyProperty = ElementRegistry.registerProperty("ReadOnly",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    isEmptyProperty = ElementRegistry.registerProperty("IsEmpty",
        PropertyType.BOOL, PropertyFlags.NONE, null, true);
    maxCharsProperty = ElementRegistry.registerProperty("MaxChars",
        PropertyType.INT, PropertyFlags.NONE, _maxCharsChangedHandler, 0);
    charsRemainingProperty = ElementRegistry.registerProperty("CharsRemaining",
        PropertyType.INT, PropertyFlags.NONE, null, 0x7FFFFFFF);
    textChangedEvent = new EventDef("TextChanged", Route.DIRECT);
    textboxElementDef = ElementRegistry.register("TextBox",
        Control.controlElementDef,
        [textProperty, wordWrapProperty, htmlEnabledProperty, isEmptyProperty,
        multilineProperty, displayAsPasswordProperty, readOnlyProperty,
        maxCharsProperty, charsRemainingProperty], null);
    Cursor.cursorProperty.overrideDefaultValue(textboxElementDef, Cursor.IBEAM);
    _changeEventArgs = new EventArgs(null);
  }
}
