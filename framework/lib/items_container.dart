part of uxml;

/**
 * Manages the visual container of an Items collection and selection.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ItemsContainer extends Control {
  /**
   * Cached value of collection property.
   */
  Items _cachedItems;
  UIElementContainer _visualContainer;
  IItemsHost _itemsHost;
  Item _firstItem;
  Item _lastItem;

  // maps visual element to item in items collection.
  Map<UIElement, Item> _elementToItemMap;

  static ElementDef itemsContainerElementDef;
  /** Content property definition */
  static PropertyDefinition itemsProperty;

  /** IsFirst Property Definition */
  static PropertyDefinition isFirstProperty;
  /** IsLast Property Definition */
  static PropertyDefinition isLastProperty;
  /** Chrome property definition */
  static PropertyDefinition containerChromeProperty;
  /** Chrome property definition */
  static PropertyDefinition itemChromeProperty;
  /**
   * isAlternateRow property definition (attached property used for
   * odd/even row styling)
   */
  static PropertyDefinition isAlternateRowProperty;
  EventHandler _changeHandler;

  ItemsContainer() : super() {
  }

  void _setSource(Items items) {
    if (_cachedItems != null) {
      _cachedItems.removeListener(CollectionChangedEvent.eventDef,
          _changeHandler);
      _changeHandler = null;
    }
    if (_visualContainer != null) {
      _visualContainer.removeAllChildren();
    }
    _cachedItems = items;
    if (_cachedItems != null) {
      if (_visualContainer == null) {
        _visualContainer = _createVisualContainer();
      }
      if (_cachedItems.length != 0) {
        _generateElements(0, _cachedItems.length);
      }
      _changeHandler = _collectionChangedHandler;
      _cachedItems.addListener(CollectionChangedEvent.eventDef,
          _changeHandler);
    }
  }

  UIElementContainer _createVisualContainer() {
    UIElementContainer container;
    if (containerChrome != null) {
      container = containerChrome.applyToTarget(this);
    } else {
      container = new VBox();
    }
    insertRawChild(container, -1);
    return container;
  }

  /**
   * Sets or returns containerChrome.
   */
  Chrome get containerChrome {
    return getProperty(containerChromeProperty);
  }

  set containerChrome(Chrome chrome) {
    setProperty(containerChromeProperty, chrome);
  }

  void _generateElements(int startIndex, int count) {
    Chrome chrome = itemChrome;
    if (count != 0 && _elementToItemMap == null) {
      _elementToItemMap = new Map<UIElement, Item>();
    }
    _visualContainer._lockUpdates(true);
    for (int i = 0; i < count; ++i) {
      Object item = _cachedItems.getItemAt(startIndex + i);
      UIElement visualItem;
      if (item is UIElement) {
        visualItem = item;
        if ((startIndex + i) >= _visualContainer.childCount) {
          _resetIsLastItem();
        }
        _elementToItemMap[visualItem] = item;
        if ((chrome != null) && (item is Control)) {
          Control control = item;
          if (((startIndex + i) % 2) == 1) {
            setChildIsAlternateRow(control, true);
          }

          if (control.chrome != chrome
              && overridesProperty(itemChromeProperty)) {
            control.chrome = chrome;
          }
          // TODO (ferhat): when items are re-parented, inherited properties
          // should push a notification down to children.
          Object temp = control.data;
          if (temp != null ||
              control.overridesProperty(UxmlElement.dataProperty)) {
            control.clearProperty(UxmlElement.dataProperty);
            control.data = temp;
          }
        }
        if ((startIndex + i) >= _visualContainer.childCount) {
          _visualContainer.addChild(visualItem);
        } else {
          _visualContainer.insertChild(startIndex + i, visualItem);
        }
      } else {
        if (chrome != null) {
          visualItem = chrome.applyToTarget(this);
          if (visualItem is ContentContainer) {
            ContentContainer contentContainer = visualItem;
            contentContainer.content = item;
          }
        } else {
          visualItem = new Item(item);
        }
        _elementToItemMap[visualItem] = item;
        if ((startIndex + i) >= _visualContainer.childCount) {
          _visualContainer.addChild(visualItem);
        } else {
          _visualContainer.insertChild((startIndex + i), visualItem);
        }
      }
    }
    _visualContainer._lockUpdates(false);
    _updateFirstLastItem();
  }

  void _collectionChangedHandler(EventArgs e) {
    CollectionChangedEvent changeEvent = e;
    if (changeEvent.type == CollectionChangedEvent.CHANGETYPE_ADD) {
        _resetIsLastItem();
        _generateElements(changeEvent.index, changeEvent.count);
        _updateFirstLastItem();
      } else if (changeEvent.type == CollectionChangedEvent.CHANGETYPE_REMOVE) {
        int startIndex = changeEvent.index;
        int itemCount = changeEvent.count;
        for (int i = itemCount - 1; i >= 0; --i) {
          UIElement visualElement = _visualContainer.childAt(startIndex + i);
          _elementToItemMap[visualElement] = null;
          _resetIsLastItem();
          _visualContainer.removeChild(visualElement);
          _updateFirstLastItem();
        }
      } else {
        // TODO(ferhat) : implement collection modified
      }
  }

  int getRawChildCount() {
    return (_visualContainer == null) ? 0 : 1;
  }

  UIElement getRawChild(int index) => _visualContainer;

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    if (_visualContainer == null) {
      setMeasuredDimension(0.0, 0.0);
      return false;
    }
    num pw = padding.left + padding.right;
    num ph = padding.top + padding.bottom;
    _visualContainer.measure(availableWidth - pw, availableHeight - ph);
    setMeasuredDimension(_visualContainer.measuredWidth + pw,
        _visualContainer.measuredHeight + ph);
    return false;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    if (_visualContainer != null) {
      _visualContainer.layout(padding.left, padding.top,
          targetWidth - padding.left - padding.right,
          targetHeight - padding.top - padding.bottom);
    }
  }

  static void _itemsChangedHandler(Object target,
      Object property, Object oldValue, Object newValue) {
    ItemsContainer itemsContainer = target;
    itemsContainer._setSource(newValue);
  }

  /**
   * Sets or returns items.
   */
  Items get items => getProperty(itemsProperty);

  set items(Items value) {
    setProperty(itemsProperty, value);
  }

  /**
   * Sets or returns item chrome.
   */
  Chrome get itemChrome => getProperty(itemChromeProperty);

  set itemChrome(Chrome value) {
    setProperty(itemChromeProperty, value);
  }

  /**
   * Sets or returns isAlternateRow property.
   */
  static bool getChildIsAlternateRow(UIElement child) {
    return child.getProperty(isAlternateRowProperty);
  }

  static void setChildIsAlternateRow(UIElement child, bool value) {
    child.setProperty(isAlternateRowProperty, value);
  }

  /**
   * Returns ItemsContainer parent of an element.
   */
  static ItemsContainer containerFromChild(UIElement element) {
    while (element != null) {
      if (element is ItemsContainer) {
        return element;
      }
      element = element.parent;
    }
    return null;
  }

  static void _itemChromeChangedHandler(Object target,
      Object property, Object oldValue, Object newValue) {
    ItemsContainer container = target;
    container._onItemChromeChanged(newValue);
  }

  void _onItemChromeChanged(Chrome chrome) {
    if (_visualContainer != null) {
      _visualContainer.removeAllChildren();
    }
    Items existingItems = _cachedItems;
    if (existingItems != null) {
      _generateElements(0, existingItems.length);
    }
  }

  void _onContainerChromeChanged(Chrome chrome) {
    if (_visualContainer == null) {
      // If itemscontainer is not initialized yet, visualContainer will
      // be created later.
      return;
    }
    UIElementContainer newCont = _createVisualContainer();
    while (_visualContainer.childCount > 0) {
      newCont.addChild(_visualContainer.childAt(0));
    }
    removeRawChild(_visualContainer);
    _visualContainer = newCont;
  }

  void surfaceInitialized(UISurface surface) {
    super.surfaceInitialized(surface);
    if (_itemsHost == null) {
      _findItemsHost();
    }
  }

  void onParentChanged() {
    super.onParentChanged();
    _findItemsHost();
  }

  void _findItemsHost() {
    // Find parent that contains this ItemsContainer in it's chromeTree and
    // attach to it.
    UIElement p = parent;
    while (p != null) {
      if (p is IItemsHost && p is Control) {
        Control control = p;
        if (control.chromeTree != null) {
          IItemsHost itemsHost = p as IItemsHost;
          if (itemsHost.isContainerAttached == false) {
            _itemsHost = itemsHost;
            _itemsHost.attachContainer(this);
          }
        }
        break; // if outer parent was itemshost, stop searching.
      }
      p = p.parent;
    }
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    super.close();
    if (_itemsHost != null) {
      _itemsHost.detachContainer(this);
      _itemsHost = null;
    }
  }

  // First/Last item handling
  void _updateFirstLastItem() {
    if (items.length == 0) {
      _resetIsFirstItem();
      _resetIsLastItem();
      return;
    }
    if (_cachedItems.getItemAt(0) != _firstItem) {
      _resetIsFirstItem();
      _firstItem = items.getItemAt(0);
      if (_firstItem != null) {
        _firstItem.setProperty(isFirstProperty, true);
      }
    }
    Item item = _cachedItems.getItemAt(items.length - 1);
    _resetIsLastItem();
    if (item != null) {
      _lastItem = item;
      _lastItem.setProperty(isLastProperty, true);
    }
  }

  void _resetIsFirstItem() {
    if (_firstItem != null) {
      _firstItem.setProperty(isFirstProperty, false);
      _firstItem = null;
    }
  }

  void _resetIsLastItem() {
    if (_lastItem != null) {
      _lastItem.setProperty(isLastProperty, false);
      _lastItem = null;
    }
  }

  /**
  * Returns if child is first item.
  */
  static bool getChildIsFirst(UIElement element) {
    return element.getProperty(isFirstProperty);
  }

  /**
   * Returns if child is last item.
   */
  static bool getChildIsLast(UIElement element) {
    return element.getProperty(isLastProperty);
  }

  /** Gets the capacity of the visual container. */
  int estimateCapacity() {
    return (_visualContainer == null ? 0 : _visualContainer.estimateCapacity());
  }

  static void _containerChromeChangeHandler(Object target,
                                            Object property,
                                            Object oldValue,
                                            Object newValue) {
    ItemsContainer container = target;
    container._onContainerChromeChanged(newValue);
  }

  /** Registers component. */
  static void registerItemsContainer() {
    itemsProperty = ElementRegistry.registerProperty("items",
        PropertyType.OBJECT, PropertyFlags.NONE, _itemsChangedHandler, null);
    isFirstProperty = ElementRegistry.registerProperty("isFirst",
        PropertyType.BOOL, PropertyFlags.ATTACHED, null, false);
    isLastProperty = ElementRegistry.registerProperty("isLast",
        PropertyType.BOOL, PropertyFlags.ATTACHED, null, false);
    containerChromeProperty = ElementRegistry.registerProperty(
        "containerChrome", PropertyType.CHROME, PropertyFlags.NONE,
        _containerChromeChangeHandler, null);
    itemChromeProperty = ElementRegistry.registerProperty("itemChrome",
        PropertyType.CHROME, PropertyFlags.NONE, _itemChromeChangedHandler,
        null);
    isAlternateRowProperty = ElementRegistry.registerProperty("isAlternateRow",
        PropertyType.BOOL, PropertyFlags.ATTACHED, null, false);
    itemsContainerElementDef = ElementRegistry.register("ItemsContainer",
        Control.controlElementDef, [itemsProperty, isFirstProperty,
        isLastProperty, containerChromeProperty, itemChromeProperty,
        isAlternateRowProperty], []);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => itemsContainerElementDef;
}

/**
 * Defines an interface that allows ItemsContainer to attach to a host.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
abstract class IItemsHost {
  /**
   * Attaches an items container to it's hosting container.
   *
   * @param container The items container.
   */
  void attachContainer(ItemsContainer container);
  void detachContainer(ItemsContainer container);
  bool get isContainerAttached;
}
