part of uxml;

/**
 * Implements control to provide support for creating tabbed ui.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class TabControl extends ListBase {
  static ElementDef tabcontrolElementDef;

  TabControl() : super() {
  }

  /** Overrides ListBase.itemSelectionChanged. */
  void itemSelectionChanged(UIElement element, bool isSelected) {
    // element selection is changing. Bring to front
    if (element.parent is UIElementContainer) {
      // Change surface child depth without changing item order.
      UIElementContainer container = element.parent;
      UISurface parentSurface = container._hostSurface;
      if (parentSurface != null) {
        // TODO(ferhat): implement setChildDepth for TabControl.
        //parentSurface.setChildDepth(element.hostSurface,
        //    container.childCount - 1);
      }
    }
  }

  /** Overrides UIElement.surfaceInitialized. */
  void surfaceInitialized(UISurface surface) {
    super.surfaceInitialized(surface);
    if (selectedIndex != -1) {
      if (items.getItemAt(selectedIndex) is UIElement) {
        itemSelectionChanged(items.getItemAt(selectedIndex), true);
      }
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => tabcontrolElementDef;

  /** Registers component. */
  static void registerTabControl() {
    tabcontrolElementDef = ElementRegistry.register("TabControl",
        ListBase.listbaseElementDef, null, null);
    Cursor.cursorProperty.overrideDefaultValue(tabcontrolElementDef,
        Cursor.BUTTON);
  }
}
