part of uxml;

/**
* Implements container that decorates an inner element.
*
* @author ferhat@ (Ferhat Buyukkokten)
*/
class ContentContainer extends Control {

  UIElement _cachedContent = null;

  ContentContainer() : super() {
  }

  static ElementDef contentcontainerElementDef;
  static PropertyDefinition contentProperty;

  static int checkId;

  /** Sets or returns content element. */
  set content(Object value) {
    checkId++;
    setProperty(contentProperty, value);
  }

  Object get content => getProperty(contentProperty);

  /**
   * Sets the content element if it is not set already.
   */
  void addChild(UIElement child) {
    if (content != null) {
      throw "Cannot replace existing content using addChild. Set it directly.";
    }
    content = child;
  }

  void updateContent(Object newContent) {
    if (chrome == null) {
      if (_cachedContent != null) {
        removeRawChild(_cachedContent);
      }
      if (newContent != null) {
        _cachedContent = createControlFromContent(newContent);
        if (_cachedContent != null) {
          insertRawChild(_cachedContent, -1);
        }
      } else {
        _cachedContent = null;
      }
    }
  }

  UIElement createControlFromContent(Object content) {
    if ((content is String)) {
      Label label = new Label();
      label.text = content;
      return label;
    } else if ((content is num) || (content is int)) {
      Label label = new Label();
      label.text = content.toString();
      return label;
    } else if (content is UIElement) {
      return content;
    }
    return null;
  }

  int getRawChildCount() {
    if (chromeTree != null) {
      return 1;
    }
    return _cachedContent == null ? 0 : 1;
  }

  UIElement getRawChild(int index) {
    if (chromeTree != null) {
      return chromeTree;
    }
    return _cachedContent;
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    if (chromeTree != null) {
      return super.onMeasure(availableWidth, availableHeight);
    }
    num maxWidth = 0.0;
    num maxHeight = 0.0;
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    if (_cachedContent != null) {
      _cachedContent.measure(availableWidth - pw, availableHeight - ph);
      maxWidth = _cachedContent.measuredWidth;
      maxHeight = _cachedContent.measuredHeight;
    }
    setMeasuredDimension(maxWidth + pw, maxHeight + ph);
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    if (chromeTree != null) {
      chromeTree.layout(padding.left, padding.top, targetWidth - pw,
          targetHeight - ph);
    } else if (_cachedContent != null) {
      _cachedContent.layout(padding.left, padding.top, targetWidth - pw,
          targetHeight - ph);
    }
  }

  static void _contentChangedHandler(Object target,
      Object property, Object oldValue, Object newValue) {
    ContentContainer container = target;
    container.updateContent(newValue);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => contentcontainerElementDef;

  /** Registers component. */
  static void registerContentContainer() {
    checkId = 100;
    contentProperty = ElementRegistry.registerProperty("content",
        PropertyType.OBJECT, PropertyFlags.NONE, _contentChangedHandler, null);
    contentcontainerElementDef = ElementRegistry.register("ContentContainer",
        Control.controlElementDef, [contentProperty], null);
  }
}
