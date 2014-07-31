part of uxml;

/**
 * Implements a ContentContainer for listbox/tree items.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Item extends ContentContainer {
  // This class could also be called SelectableRepeatableContent
  // since it manages the selection state of an item and has chrome to show
  // selection.
  static ElementDef itemElementDef;
  /** IsPressed property definition */
  static PropertyDefinition isPressedProperty;

  /**
   * Constructor.
   */
  Item([Object content = null]) : super() {
    if (content != null) {
      setProperty(ContentContainer.contentProperty, content);
    }
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    if (_hostSurface != null) {
      _hostSurface.hitTestMode = UISurfaceImpl.HITTEST_BOUNDS;
    }
  }

  /**
   * Sets or returns if item is selected.
   */
  bool get selected => ListBase.getChildSelected(this);

  set selected(bool value) {
    ListBase.setChildSelected(this, value);
  }

  /**
   * Returns if item is first in ItemsContainer.
   */
  bool get isFirst => ItemsContainer.getChildIsFirst(this);

  /**
   * Returns if item is last in ItemsContainer.
   */
  bool get isLast => ItemsContainer.getChildIsLast(this);

  /** Overrides UIElement.onMouseDown to update IsPressed property. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    captureMouse();
    setProperty(isPressedProperty, true);
    mouseArgs.handled = true;
  }

  /**
   * Returns true if button is currently in pressed state.
   */
  bool get isPressed {
    return getProperty(isPressedProperty);
  }

  /** Overrides UIElement.onMouseUp to set item selected property. */
  void onMouseUp(MouseEventArgs mouseArgs) {
    /** Overrides UIElement.onMouseDown. */
    if (isPressed) {
      releaseMouse();
      setProperty(isPressedProperty, false);
      if (isMouseOver) {
        selected = true;
      }
    }
  }

  /**
   * Returns parent Item of element.
   */
  static Item getParentItem(UIElement element) {
    while (element != null) {
      if (element is Item) {
        return element;
      }
      element = element.parent;
    }
    return null;
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => itemElementDef;

  /** Registers component. */
  static void registerItem() {
    isPressedProperty = ElementRegistry.registerProperty("isPressed",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    itemElementDef = ElementRegistry.register("Item",
        ContentContainer.contentcontainerElementDef, [isPressedProperty], null);
  }
}
