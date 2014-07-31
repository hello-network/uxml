part of uxml;

/**
 * Implements base class for controls that contain a list if Items.
 *
 * ListBase.Items maintains the items collection that is used by _itemsContainer
 * to populate the attached UIElementContainer. It handles updates to items
 * collection from source/data properties.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ListBase extends Control implements IItemsHost {
  static ElementDef listbaseElementDef;
  /** Items property definition */
  static PropertyDefinition itemsProperty;
  /** SelectedItems property definition */
  static PropertyDefinition selectedItemsProperty;
  /** Source property definition */
  static PropertyDefinition sourceProperty;
  /** Item chrome property definition */
  static PropertyDefinition itemChromeProperty;
  /** Container chrome property definition */
  static PropertyDefinition containerChromeProperty;
  /** SelectedItem property definition. */
  static PropertyDefinition selectedItemProperty;
  /** SelectedIndex property definition. */
  static PropertyDefinition selectedIndexProperty;
  /** Selected property definition */
  static PropertyDefinition selectedProperty;
  /** Multi-select property definition */
  static PropertyDefinition multiSelectProperty;

  /** SelectionChanged event definition */
  static EventDef selectionChangedEvent;

  Items _cachedItems;
  Items _selectedList;
  ItemsContainer _itemsContainer;
  PropertyBinding _itemsBinding;
  PropertyBinding _itemChromeBinding;
  PropertyBinding _itemChromeBindingRev;
  PropertyBinding _containerChromeBinding;
  EventHandler _changeHandler;

  /*
   * If selectionIndex changes before surface is initialized, this flag
   * is set and event is fired as soon as surface is initialized.
   */
  bool _delayedSelectionChanged = false;
  // Flag set when switching from one selected item to another to make
  // sure interim selectedIndex = -1/selectedItem=null is not set.
  bool _isAboutToSelectItem = false;
  bool _aggregateSelectionChanged = false;

  /** Item transform function. */
  ItemTransform itemTransform = null;


  /**
   * Constructor.
   */
  ListBase() : super() {
    _cachedItems = new Items();
    items = _cachedItems;
  }

  /**
   * Adds an item to listbox.
   */
  void addItem(Object item) {
    if (_cachedItems == null) {
      setProperty(itemsProperty, new Items());
    }
    _cachedItems.add(item);
  }

  /**
   * Removes an item from listbox.
   */
  void removeItem(Object item) {
    _cachedItems.remove(item);
  }

  /**
   * Inserts an item to listbox.
   */
  void insertItem(int index, Object item) {
    if (_cachedItems == null) {
      setProperty(itemsProperty, new Items());
    }
    _cachedItems.insert(index, item);
  }

  /**
   * Returns items collection.
   */
  Items get items => _cachedItems;

  /**
   * Sets items collection of listbox.
   */
  set items(Items value) {
    setProperty(itemsProperty, value);
  }

  /**
   * Returns selected items collection if multiSelect is set.
   */
  Items get selectedItems {
    if (_selectedList == null) {
      _selectedList = new Items();
      setProperty(selectedItemsProperty, _selectedList);
    }
    return _selectedList;
  }

  /**
   * Sets or returns item chrome.
   */
  Chrome get itemChrome => getProperty(itemChromeProperty);

  set itemChrome(Chrome value) {
    setProperty(itemChromeProperty, value);
  }

  /**
   * Sets or returns containerChrome.
   */
  Chrome get containerChrome => getProperty(containerChromeProperty);

  set containerChrome(Chrome chrome) {
    setProperty(containerChromeProperty, chrome);
  }

  /**
   * Gets or sets selected item.
   */
  Object get selectedItem => getProperty(selectedItemProperty);

  set selectedItem(Object value) {
    setProperty(selectedItemProperty, value);
  }

  /**
   * Gets or sets selected index.
   */
  int get selectedIndex => getProperty(selectedIndexProperty);

  set selectedIndex(int value) {
    if ((value >= items.length) || (value < -1)) {
      // When value is out of range set listbox to not selected.
      // The makes it convenient to set listbox.selectedIndex = 0 even
      // when items collection is empty.
      value = -1;
    }
    setProperty(selectedIndexProperty, value);
    Object itemObj;
    Item item;
    if (value != -1) {
      itemObj = items.getItemAt(value);
      if (itemObj is Item) {
        item = itemObj;
        item.selected = true;
      }
    } else {
      for (int i = 0; i < items.length; i++) {
        itemObj = items.getItemAt(i);
        if (itemObj is Item) {
          item = itemObj;
          item.selected = false;
        }
      }
    }
  }

  /**
   * Gets the index of the item that's using the specified data model.
   */
  int indexByData(Model data) {
    for (int i = 0; i < items.length; i++) {
      Object item = items.getItemAt(i);
      if (item is UxmlElement) {
        UxmlElement el = item;
        if (el.data == data) {
          return i;
        }
      }
    }
    return -1;
  }

  /**
   * Gets or Sets source property.
   */
  Object get source => getProperty(sourceProperty);

  set source(Object value) {
    setProperty(sourceProperty, value);
  }

  /**
   * Gets or sets if list supports multi item selection.
   */
  bool get multiSelect => getProperty(multiSelectProperty);

  set multiSelect(bool value) {
    setProperty(multiSelectProperty, value);
  }

  void _sendSelectionChangedEvent() {
    if (_aggregateSelectionChanged) {
      return;
    }
    EventArgs eventArgs= new EventArgs(this);
    eventArgs.event = selectionChangedEvent;
    routeEvent(eventArgs);
  }

  /**
   * Called when Items collection is changed.
   */
  static void _itemsChangedHandler(Object target,
                                   Object property,
                                   Object oldValue,
                                   Object newValue) {
    ListBase listBase = target;
    listBase._itemsChanged(newValue);
  }

  /**
   * Called when items collection changes.
   */
  void _itemsChanged(Items items) {
    if (_cachedItems != null) {
      _cachedItems.removeListener(CollectionChangedEvent.eventDef,
          _changeHandler);
    }
    onItemsChanging(items, _cachedItems);
    _cachedItems = items;
    for (int i = 0; i < _cachedItems.length; i++) {
      Item item = _cachedItems.getItemAt(i);
      if (item != null) {
        if (item.selected) {
          if (_selectedList == null) {
            _selectedList = new Items();
            setProperty(selectedItemsProperty, _selectedList);
          }
          _selectedList.add(item);
          if (selectedIndex == -1) {
            selectedIndex = i;
            selectedItem = item;
          }
        }
      }
    }
    if (_cachedItems != null) {
      _changeHandler = _collectionChangedHandler;
      _cachedItems.addListener(CollectionChangedEvent.eventDef,
          _changeHandler);
    }
    onItemsChanged(items);
  }

  void _collectionChangedHandler(EventArgs e) {
    CollectionChangedEvent changeEvent = e;
    if (changeEvent.type == CollectionChangedEvent.CHANGETYPE_ADD) {
      Object newItem = _cachedItems.getItemAt(changeEvent.index);
      if (newItem is UIElement && ListBase.getChildSelected(newItem)) {
        if (_selectedList == null) {
          _selectedList = new Items();
          setProperty(selectedItemsProperty, _selectedList);
        }
        _selectedList.add(newItem);
        selectedItem = newItem;
        selectedIndex = changeEvent.index;
      }
    } else if (changeEvent.type == CollectionChangedEvent.CHANGETYPE_REMOVING) {
      int startIndex = changeEvent.index;
      int itemCount = changeEvent.count;
      for (int i = itemCount - 1; i >= 0; --i) {
        Item item = _cachedItems.getItemAt(startIndex + i);
        if (item != null && ListBase.getChildSelected(item) &&
            (_selectedList != null)) {
          _selectedList.remove(item);
          int index = _cachedItems.indexOf(item);
          if (index != -1) {
            _selectedList.remove(item);
          }
          if (selectedIndex == index) {
            selectedIndex = -1;
            selectedItem = null;
          }
        }
      }
    }
  }

  /**
   * Allows subclasses to override to observe items collection changes.
   */
  void onItemsChanging(Items items, Items oldItems) {
  }

  /**
   * Allows subclasses to override to observe items collection changes.
   */
  void onItemsChanged(Items items) {
  }

  /**
   * Called when selectedIndex is changed. Syncs selectedItem.
   */
  static void _selectedIndexChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    ListBase listBase = target;
    listBase._onSelectedIndexChanged(oldValue, newValue);
  }

  void _onSelectedIndexChanged(int oldIndex, int newIndex) {
    if (newIndex == -1) {
      if (selectedItem != null) {
        setChildSelected(selectedItem, false);
        selectedItem = null;
      }
      _sendSelectionChangedAsync();
    } else {
      _isAboutToSelectItem = true;
      if (oldIndex != -1) {
        Object oldItem = _cachedItems.getItemAt(oldIndex);
        if (oldItem is UIElement) {
          setChildSelected(oldItem, false);
        }
      }
      _isAboutToSelectItem = false;
      Object newItem = _cachedItems.getItemAt(newIndex);
      if (newItem is UIElement) {
        setChildSelected(newItem, true);
      }
      if (newItem != selectedItem) {
        selectedItem = newItem;
      } else {
        _sendSelectionChangedAsync();
      }
    }
  }

  void _sendSelectionChangedAsync() {
    if (hostSurface != null) {
      _sendSelectionChangedEvent();
    } else {
      _delayedSelectionChanged = true;
    }
  }

  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    for (int i = 0; i < items.length; i++) {
      Object obj = items.getItemAt(i);
      if (obj is Item) {
        Item item = obj;
        if (item.selected && (selectedItems.indexOf(item) == -1)) {
          selectedItems.add(item);
        }
      }
    }
  }

  void surfaceInitialized(UISurface surface) {
    super.surfaceInitialized(surface);
    if (_delayedSelectionChanged) {
      _sendSelectionChangedAsync();
    }
  }

  /**
   * Called when selectedItem is changed. Syncs selectedIndex.
   */
  static void _selectedItemChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    ListBase listBase = target;
    if (newValue == null) {
      listBase.selectedIndex = -1;
    } else {
      listBase.selectedIndex = listBase.items.indexOf(newValue);
    }
  }

  /**
   * Called when .source property changes on a ListBase.
   */
  static void _sourceChangedHandler(Object target, Object property,
                                    Object oldValue, Object newValue) {
    ListBase listBase = target;
    if (!(oldValue is Model) && oldValue != null) {
      Model old = new Model();
      List l = oldValue;
      for (int i = 0; i < l.length; i++) {
        old.addChild(l[i]);
      }
      oldValue = old;
    }
    if (listBase.source is Model) {
      listBase._refreshItemsFromModel(oldValue,  listBase.source);
    } else if (listBase.source is List) {
      // TODO(ferhat): deprecate support for setting array as source.
      print("! Warning: setting list.source to List<T> deprecated");
      print(listBase);
      Model m = new Model();
      List l = listBase.source;
      for (int i = 0; i < l.length; i++) {
        m.addChild(l[i]);
      }
      listBase._refreshItemsFromModel(oldValue,  m);
    }
  }


  /**
   * Called when .data property changes on a ListBase.
   */
  static void _listDataChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    ListBase listBase = target;
    if (listBase.overridesProperty(UxmlElement.dataProperty)) {
      listBase._refreshItemsFromModel(oldValue, listBase.data);
    }
  }

  void _refreshItemsFromModel(Model oldValue, Model newData) {
    // remove previous event listener for collection changed
    if (oldValue != null && oldValue is Model) {
      Model oldModel = oldValue;
      oldModel.removeListener(CollectionChangedEvent.eventDef,
          _onModelCollectionChanged);
    }
    _cachedItems.clear();
    if (newData != null) {
      // listen to collection changed event
      newData.addListener(CollectionChangedEvent.eventDef,
          _onModelCollectionChanged);
      for (int i = 0; i < newData.length; i++) {
        Item newItem = _createItemFromContent(newData.getChildAt(i));
        _cachedItems.add(newItem);
      }
    }
  }

  void _onModelCollectionChanged(CollectionChangedEvent event) {
    // get the type of collection change
    Model collection = event.source;
    int i;
    Item newItem;
    switch (event.type) {
      case CollectionChangedEvent.CHANGETYPE_ADD:
        for (i = 0; i < event.count; ++i) {
          newItem = _createItemFromContent(collection.getChildAt(
              event.index + i));
          _cachedItems.insert(event.index + i, newItem);
        }
        break;
      case CollectionChangedEvent.CHANGETYPE_REMOVE:
        for (i = 0; i < event.count; i++) {
          _cachedItems.removeAt(event.index);
        }
        break;
      case CollectionChangedEvent.CHANGETYPE_MODIFY:
        // remove existing elements
        for (i = 0; i < event.count; i++) {
          _cachedItems.removeAt(event.index);
        }
        // add new items from new data
        for (i = 0; i < event.count; ++i) {
          newItem = _createItemFromContent(collection.getChildAt(
              event.index + i));
          _cachedItems.insert(event.index + i, newItem);
        }
        break;
    }
  }

  // helper function to create Item from content
  Item _createItemFromContent(Object content) {
    Item newItem;
    if (content is Item) {
      newItem = content;
    } else if (content is UxmlElement) {
      newItem = new Item(content);
      UxmlElement uiElem = content;
      newItem.data = uiElem.data;
    } else if (content is Model) {
      newItem = new Item(null);
      newItem.data = content;
    } else if (content is String) {
      String s = content;
      newItem = new Item(s);
      newItem.content = s;
    } else if (content is num) {
      String s = content.toString();
      newItem = new Item(s);
      newItem.content = s;
    } else {
      newItem = new Item(null);
      newItem.data = Model.fromObject(content);
    }
    newItem.chrome = itemChrome;
    // Apply item transform if specified.
    if (itemTransform != null) {
      itemTransform(newItem);
    }
    return newItem;
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    super.close();
    _itemsContainer = null;
  }

  /**
   * @see IItemsHost.
   */
  void attachContainer(ItemsContainer container) {
    if (_itemsContainer != container) {
      _itemsContainer = container;
      _containerChromeBinding = new PropertyBinding(container,
          ItemsContainer.containerChromeProperty, this,
          [containerChromeProperty]);
      _itemChromeBinding = new PropertyBinding(container,
          ItemsContainer.itemChromeProperty, this, [itemChromeProperty]);
      _itemChromeBindingRev = new PropertyBinding(this, itemChromeProperty,
        container, [ItemsContainer.itemChromeProperty]);
      _itemsBinding = new PropertyBinding(container,
          ItemsContainer.itemsProperty, this, [itemsProperty]);
    }
  }
  /**
   * @see IItemsHost.
   */
  void detachContainer(ItemsContainer container) {
    if (_itemsBinding != null) {
      _itemsBinding.clear();
      _itemsBinding = null;
      _itemChromeBinding.clear();
      _itemChromeBinding = null;
      _itemChromeBindingRev.clear();
      _itemChromeBindingRev = null;
      _containerChromeBinding.clear();
      _containerChromeBinding = null;
    }
    _itemsContainer = null;
  }

  /**
   * @see IItemsHost.
   */
  bool get isContainerAttached {
    return _itemsContainer != null;
  }

  /**
   * @see IItemsHost.
   */
  void itemSelectionChanging(UIElement element, bool isSelected) {
  }

  /**
   * @see IItemsHost.
   */
  void itemSelectionChanged(UIElement element, bool isSelected) {
  }

  static bool getChildSelected(UIElement element) {
    return element.getProperty(selectedProperty);
  }

  static void setChildSelected(UIElement element, bool select) {
    element.setProperty(selectedProperty, select);
  }

  static void _multiSelectChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    ListBase listBase = target;
    listBase._multiSelectChanged();
  }

  void _multiSelectChanged() {
    // If multiselect was turned off, make sure we have only 1
    // item selected. Otherwise keep first item selected.
    if ((multiSelect == false) && _selectedList.length > 1) {
      bool skippedFirst = false;
      for (int i = 0; i < _cachedItems.length; i++) {
        if (getChildSelected(_cachedItems.getItemAt(i))) {
          if (skippedFirst) {
            setChildSelected(items.getItemAt(i), false);
          } else {
            skippedFirst = true;
          }
        }
      }
    }
  }

  static void _selectedPropChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    // Find ItemsContainer parent of target and called selectedChanged
    UIElement element = target;
    ListBase listBase = ListBase.containerFromChild(element);
    if (listBase != null) {
      listBase._selectedPropertyChanged(element, newValue);
    }
  }

  /**
   * Handles Selected property changes on children.
   */
  void _selectedPropertyChanged(UIElement element, bool isSelected) {
    itemSelectionChanging(element, isSelected);
    int index = (_selectedList == null) ? -1 : _selectedList.indexOf(element);
    if (isSelected) {
      // element switched from not selected to selected state
      if (_selectedList == null) {
        _selectedList = selectedItems;
      } else if (multiSelect == false && (_selectedList.length != 0)) {
        // deselect prior item
        UIElement itemToDeselect = _selectedList.getItemAt(
            _selectedList.length - 1);
        if (itemToDeselect == element) {
          return; // item already selected return.
        }
        _isAboutToSelectItem = true;
        ListBase.setChildSelected(itemToDeselect, false);
        _isAboutToSelectItem = false;
      }
      _selectedList.add(element);
      if (multiSelect == false) {
        selectedItem = element;
        selectedIndex = _cachedItems.indexOf(selectedItem);
      } else {
        _sendSelectionChangedEvent();
      }
    } else {
      // element was deselected
      if (index != -1) {
        _selectedList.remove(element);
        if (_isAboutToSelectItem == false) {
          if (multiSelect == false) {
            if (_selectedList.length == 0) {
              selectedItem = null;
            }
            selectedIndex = -1;
          } else  {
            _sendSelectionChangedEvent();
          }
        }
      }
    }
    itemSelectionChanged(element, isSelected);
  }

  /**
   * Returns ListBase parent of an element.
   */
  static ListBase containerFromChild(UIElement element) {
    while (element != null) {
      if (element is ListBase) {
        return element;
      }
      element = element.parent;
    }
    return null;
  }

  /**
   * Selects all items.
   */
  bool selectAll() {
    return _selectAllItems(true);
  }

  /**
   * Unselect all items.
   */
  bool unselectAll() {
    return _selectAllItems(false);
  }

  bool _selectAllItems(bool select) {
    bool itemStateChanged = false;
    int length = _cachedItems.length;
    _aggregateSelectionChanged = true;
    for (int i = 0; i < length; i++) {
      Item item = _cachedItems.getItemAt(i);
      if (item.selected != select) {
        itemStateChanged = true;
        item.selected = select;
      }
    }
    _aggregateSelectionChanged = false;
    if (itemStateChanged) {
      _sendSelectionChangedEvent();
    }
    return itemStateChanged;
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availW, num availH) {
    bool res = super.onMeasure(availW, availH);
    if (id == "debugList") {
      Application.current.log("debugList measuredHeight= $measuredHeight");
    }
    return res;
  }

  /** Overrides UIElement.onLayout. */

  /**
   * Returns parent List for element.
   */
  static ListBase getParentList(Object element) {
    if (!(element is UIElement)) {
      return null;
    }
    UIElement elm = element;
    while (elm != null) {
      if (elm is ListBase) {
        return elm as ListBase;
      }
      elm = elm.parent;
    }
    return null;
  }

  /** Gets the capacity of the visual container. */
  int estimateCapacity() {
    return (_itemsContainer == null ? 0 : _itemsContainer.estimateCapacity());
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => listbaseElementDef;

  /** Registers component. */
  static void registerListBase() {
    itemsProperty = ElementRegistry.registerProperty("items",
        PropertyType.OBJECT, PropertyFlags.NONE, _itemsChangedHandler, null);
    selectedItemsProperty = ElementRegistry.registerProperty("selectedItems",
        PropertyType.OBJECT, PropertyFlags.NONE, null, null);
    sourceProperty = ElementRegistry.registerProperty("source",
        PropertyType.OBJECT, PropertyFlags.NONE, _sourceChangedHandler, null);
    multiSelectProperty = ElementRegistry.registerProperty("multiSelect",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    itemChromeProperty = ElementRegistry.registerProperty("itemChrome",
        PropertyType.CHROME, PropertyFlags.NONE, null, null);
    containerChromeProperty = ElementRegistry.registerProperty(
        "containerChrome", PropertyType.CHROME, PropertyFlags.NONE, null, null);
    selectedProperty = ElementRegistry.registerProperty("selected",
        PropertyType.BOOL, PropertyFlags.ATTACHED, _selectedPropChangedHandler,
        false);
    selectedItemProperty = ElementRegistry.registerProperty("selectedItem",
        PropertyType.OBJECT, PropertyFlags.NONE, _selectedItemChangedHandler,
        null);
    selectedIndexProperty = ElementRegistry.registerProperty("selectedIndex",
        PropertyType.INT, PropertyFlags.NONE, _selectedIndexChangedHandler, -1);
    selectionChangedEvent = new EventDef("selectionChanged", Route.BUBBLE);
    listbaseElementDef = ElementRegistry.register("ListBase",
        Control.controlElementDef,
        [itemsProperty, sourceProperty, multiSelectProperty, itemChromeProperty,
        containerChromeProperty, selectedProperty, selectedItemProperty,
        selectedItemsProperty, selectedIndexProperty], [selectionChangedEvent]);
    UxmlElement.dataProperty.overrideCallback(listbaseElementDef,
        _listDataChangedHandler);
  }
}

typedef void ItemTransform(Item item);
