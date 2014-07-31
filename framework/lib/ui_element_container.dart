part of uxml;

/**
 * Implements a container of UIElement(s).
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class UIElementContainer extends Control {
  static ElementDef uielementcontainerElementDef;

  /** Holds children */
  List<UIElement> childElements = null;

  UIElementContainer() : super() {
  }

  /**
   * Returns number of child element
   */
  int get childCount {
    return (childElements == null) ? 0 : childElements.length;
  }

  /**
   * Override for containers to provide the number of children that can fit
   * in this container for pagination / fill to capacity features.
   */
  int estimateCapacity() {
    return childCount;
  }

  /**
   * Returns child at index
   */
  UIElement childAt(int index) {
    return childElements[index];
  }

  /**
   * Returns index of child element.
   */
  int getIndexOfChild(UIElement element) {
    return childElements == null ? -1 : childElements.indexOf(element);
  }

  /**
   * Adds a child to container
   */
  void addChild(UIElement child) {
    if (childElements == null) {
      childElements = <UIElement>[];
    }
    childElements.add(child);
    insertRawChild(child, -1);
  }

  /**
   * Inserts a child to container.
   */
  void insertChild(int index, UIElement child) {
    if (childElements == null) {
      childElements = <UIElement>[];
      childElements.add(child);
    } else {
      childElements.insert(index, child);
    }
    insertRawChild(child, index);
  }

  /** Adds a child to container with explicit parent. Used for overlays */
  void _internalOverlayChild(UIElement child, UIElement parentElement) {
    if (childElements == null) {
      childElements = <UIElement>[];
    }
    childElements.add(child);
    _internalAddRawChild(child, parentElement);
  }

  /**
   * Removes child from container
   */
  void removeChild(UIElement child) {
    if (childElements != null && childElements.indexOf(child) != -1) {
      childElements.removeAt(childElements.indexOf(child));
    }
    removeRawChild(child);
  }

  /**
   * Removes child at index from container
   */
  void removeChildAt(int index) {
    UIElement child = childElements[index];
    childElements.removeAt(index);
    removeRawChild(child);
  }

  /**
   * Removes all children from container
   */
  void removeAllChildren() {
    if (childElements == null) {
      return;
    }
    for (int i = childElements.length - 1; i >= 0; --i) {
      removeChildAt(i);
    }
  }

  /**
   * Returns raw child count
   */
  int getRawChildCount() {
    return childCount;
  }

  /** Returns raw child collection */
  UIElement getRawChild(int index) {
    return childElements[index];
  }

  /**
   * Updates Z order to bring the child element to the front.
   */
  void bringToFront(UIElement child) {
    int index = childElements.indexOf(child, 0);
    if ((index != -1) && index != (childElements.length - 1)) {
      setChildDepth(child, index, childElements.length - 1);
    }
  }

  /**
   * Updates Z order to send the child element to the back.
   */
  void sendToBack(UIElement child) {
    int index = childElements.indexOf(child, 0);
    if (index != -1) {
      setChildDepth(child, index, 0);
    }
  }

  void setChildDepth(UIElement child, int prevIndex,
      int newIndex) {
    // TODO(ferhat): implement setchilddepth for TabControl.
    /*
    childElements.remove(prevIndex);
    if (newIndex >= childElements.size()) {
      childElements.add(child);
    } else {
      childElements.add(newIndex, child);
    }
    super.setChildDepth(child, prevIndex, newIndex);
    */
   }

  void _lockUpdates(bool lock) {
    if (_hostSurface != null) {
      _hostSurface.lockUpdates(lock);
    }
  }

   /** @see UxmlElement.getDefinition. */
   ElementDef getDefinition() => uielementcontainerElementDef;

   /** Registers component. */
   static void registerUIElementContainer() {
     uielementcontainerElementDef = ElementRegistry.register(
         "UIElementContainer", Control.controlElementDef, null, null);
   }
}
