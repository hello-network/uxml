part of uxml;

/**
 * Provides control level properties such as FontName, FontSize,
 * tabbing support, etc.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class Control extends UIElement {

  static const String DEFAULT_FONT_NAME = "Helvetica";
  static const num DEFAULT_FONT_SIZE = 10.0;
  static const bool DEFAULT_FONT_BOLD = false;
  static Color DEFAULT_TEXT_COLOR;

  /** Border radius property definition */
  static PropertyDefinition borderRadiusProperty;
  /** FontName property definition */
  static PropertyDefinition fontNameProperty;
  static PropertyDefinition backgroundProperty;
  /** FontSize property definition */
  static PropertyDefinition fontSizeProperty;
  /** FontBold property definition */
  static PropertyDefinition fontBoldProperty;
  /** Textcolor property definition */
  static PropertyDefinition textColorProperty;
  /**
   * LinkColor property definition, specifies color used for inline
   * hyperlinks
   */
  static PropertyDefinition linkColorProperty;
  /** Chrome property definition */
  static PropertyDefinition chromeProperty;
  /** Padding Property Definition */
  static PropertyDefinition paddingProperty;
  /** Prompt message property definition */
  static PropertyDefinition promptMessageProperty;
  /** Validation error message property definition */
  static PropertyDefinition errorMessageProperty;
  static ElementDef controlElementDef;

  /** Cached padding value */
  Margin _cachedPadding;

  /**
   * Holds ui tree provided by chrome.
   */
  UIElement chromeTree = null;

  // chromeDirty flag is used to delay generating the chromeTree until
  // a visible surface is initialized.
  // If user's accesses DOM tree before surface initialization we force
  // chromeTree creation since code will need to find elements by ids.
  bool _chromeDirty = false;

  /**
   * Constructor
   */
  Control() : super() {
    _cachedPadding = Margin.EMPTY;
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    // Initialize chrome before surface initialization
    if (chrome == null) {
      Chrome res = findResource(getDefinition());
      if (res != null) {
        chrome = res;
      }
    }
    if (_chromeDirty) {
      _generateChromeTree();
      applyEffects();
    }
    super.initSurface(parentSurface, index);
    if (borderRadius != null && _hostSurface != null) {
      _hostSurface.setBorderRadius(borderRadius);
    }
  }

  void _generateChromeTree() {
    _chromeDirty = false;
    Object prevController = null;
    if (overridesProperty(Controller.controllerProperty)) {
      prevController = Controller.getTargetController(this);
    }
    if (chrome != null) {
      chromeTree = chrome.applyToTarget(this);
      if (chromeTree != null) {
        insertRawChild(chromeTree, -1);
      }
      if (overridesProperty(Controller.controllerProperty)) {
        Controller newController = Controller.getTargetController(this);
        if (prevController != newController) {
          newController.initCompleted();
        }
      }
    }
    onChromeTreeReady();
  }

  /**
   * Provides override to access chromeTree after lazy initialization.
   */
  void onChromeTreeReady() {
  }

  int getRawChildCount() => (chromeTree == null) ? 0 : 1;

  UIElement getRawChild(int index) => chromeTree;

  /**
  * Sets or returns background brush.
  */
  Brush get background => getProperty(backgroundProperty);

  set background(Brush brush) {
    setProperty(backgroundProperty, brush);
  }

  /**
   * Sets or returns border radius.
   */
  BorderRadius get borderRadius => getProperty(borderRadiusProperty);

  set borderRadius(BorderRadius value) {
    setProperty(borderRadiusProperty, value);
  }

  /** Gets or sets the padding of a border */
  Margin get padding => _cachedPadding;

  set padding(Margin value) {
    setProperty(paddingProperty, value);
  }

  /**
  * Sets or returns font name.
  */
  String get fontName => getProperty(fontNameProperty);

  set fontName(String familyName) {
    setProperty(fontNameProperty, familyName);
  }

  /**
   * Sets or returns font size.
   */
  num get fontSize => getProperty(fontSizeProperty);

  set fontSize(num size) {
    setProperty(fontSizeProperty, size);
  }

  /**
   * Sets or returns font bold.
   */
  bool get fontBold => getProperty(fontBoldProperty);

  set fontBold(bool bold) {
    setProperty(fontBoldProperty, bold);
  }

  /**
   * Sets or returns text color.
   */
  Color get textColor => getProperty(textColorProperty);

  set textColor(Color color) {
    setProperty(textColorProperty, color);
  }

  /**
  * Sets or returns chrome of control.
  */
  Chrome get chrome => getProperty(chromeProperty);

  set chrome(Chrome value) {
    setProperty(chromeProperty, value);
  }

  /**
   * Sets or returns prompt message.
   */
  String get promptMessage => getProperty(promptMessageProperty);

  set promptMessage(String message) {
    setProperty(promptMessageProperty, message);
  }

  /**
   * Sets or returns validation error message.
   */
  String get errorMessage => getProperty(errorMessageProperty);

  set errorMessage(String message) {
    setProperty(errorMessageProperty, message);
  }

  /** Overrides UIElement.onRedraw. */
  void onRedraw(UISurface surface) {
    if (_hostSurface != null) {
      _hostSurface.setBackground(background);
      _hostSurface.setBorderRadius(borderRadius);
    }
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    if (_chromeDirty) {
      _generateChromeTree();
    }
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    if (chromeTree != null) {
      chromeTree.measure(availableWidth - pw, availableHeight - ph);
      maxWidth = chromeTree.measuredWidth;
      maxHeight = chromeTree.measuredHeight;
    }
    setMeasuredDimension(maxWidth + pw, maxHeight + ph);
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    if (chromeTree != null) {
      chromeTree.layout(_cachedPadding.left, _cachedPadding.top,
          targetWidth - _cachedPadding.left - _cachedPadding.right,
          targetHeight - _cachedPadding.top - _cachedPadding.bottom);
    }
  }

  UIElement getElement(String elementId) {
    if (_chromeDirty) {
      _generateChromeTree();
    }
    UIElement element = super.getElement(elementId);
    if (element == null && chromeTree != null) {
      return chromeTree.getElement(elementId);
    }
    return element;
  }

  void onChromeChanged(Chrome oldChrome, Chrome newChrome) {
    // Remove old chrome tree
    if (chromeTree != null) {
      removeRawChild(chromeTree);

      // Also remove effects added by the old chrome.
      for (int i = 0; i < oldChrome.effects.length; i++) {
        Effect oldEffect = oldChrome.effects[i];
        for (int e = 0; e < effects.length; e++) {
          if (oldEffect.id == effects[e].id) {
            effects.removeAt(effects.indexOf(effects[e]));
            break;
          }
        }
      }
      chromeTree = null;
    }
    if (_hostSurface == null) {
      _chromeDirty = true;
    } else {
      _generateChromeTree();
      applyEffects();
    }
  }
  /**
   * Override stub for classes.
   */
  void onFontChanged() {
  }

  static void _borderRadiusChangedHandler(Object target,
                                          Object property,
                                          Object oldValue,
                                          Object newValue) {
    UIElement element = target;
    UISurface surface = element._hostSurface;
    if (surface != null) {
      BorderRadius border = newValue;
      surface.setBorderRadius(border);
    }
  }

  static void _paddingChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    Control control = target;
    control._cachedPadding = (newValue == PropertyDefaults.NO_DEFAULT) ? null :
        newValue;
  }

  static void _fontChangedHandler(Object target,
                                  Object property,
                                  Object oldValue,
                                  Object newValue) {
    if (target is Control) {
      Control control = target;
      control.onFontChanged();
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => controlElementDef;

  /** Registers component. */
  static void registerControl() {
    DEFAULT_TEXT_COLOR = Color.fromRGB(0);
    borderRadiusProperty = ElementRegistry.registerProperty("borderRadius",
        PropertyType.BORDERRADIUS, PropertyFlags.REDRAW,
        _borderRadiusChangedHandler, null);
    fontNameProperty = ElementRegistry.registerProperty("fontName",
        PropertyType.STRING, PropertyFlags.RESIZE | PropertyFlags.INHERIT,
        _fontChangedHandler, DEFAULT_FONT_NAME);
    backgroundProperty = ElementRegistry.registerProperty("background",
        PropertyType.BRUSH, PropertyFlags.REDRAW, null, null);
    fontSizeProperty = ElementRegistry.registerProperty("fontSize",
        PropertyType.NUMBER, PropertyFlags.RESIZE | PropertyFlags.INHERIT,
        _fontChangedHandler, DEFAULT_FONT_SIZE);
    fontBoldProperty = ElementRegistry.registerProperty("fontBold",
        PropertyType.BOOL, PropertyFlags.RESIZE | PropertyFlags.INHERIT,
        _fontChangedHandler, DEFAULT_FONT_BOLD);
    textColorProperty = ElementRegistry.registerProperty("textColor",
        PropertyType.COLOR, PropertyFlags.INHERIT,
        _fontChangedHandler, Color.fromRGB(0));
    linkColorProperty = ElementRegistry.registerProperty("linkColor",
        PropertyType.COLOR, PropertyFlags.INHERIT,
      _fontChangedHandler, Color.fromRGB(0x0000CC));
    chromeProperty = ElementRegistry.registerProperty("chrome",
        PropertyType.CHROME, PropertyFlags.NONE,
        (UIElement target, PropertyDefinition property,
            Object oldVal, Object newVal) {
          if (target is Control) {
            Control control = target;
            control.onChromeChanged(oldVal, newVal);
          }
        }, null);

    paddingProperty = ElementRegistry.registerProperty("padding",
        PropertyType.MARGIN, PropertyFlags.RESIZE, _paddingChangedHandler,
        Margin.EMPTY);
    promptMessageProperty = ElementRegistry.registerProperty("promptMessage",
        PropertyType.STRING, PropertyFlags.NONE, null, null);
    errorMessageProperty = ElementRegistry.registerProperty("errorMessage",
        PropertyType.STRING, PropertyFlags.NONE, null, null);
    controlElementDef = ElementRegistry.register("Control",
        UIElement.elementDef,
        [backgroundProperty, borderRadiusProperty, fontNameProperty,
        fontSizeProperty, fontBoldProperty, textColorProperty, chromeProperty,
        paddingProperty, promptMessageProperty, errorMessageProperty], null);
  }
}
