part of uxml;

/**
 * Implements an observable collection.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ElementCollection extends UxmlElement {
  List<Object> _items;
  static const int _NUM_ITEMS_CHANGED_ONE_ITEM = 1;
  static const int _START_CHANGE_INDEX = 0;

  /** Collection change event definition. */
  static EventDef changedEvent;
  static void initElementCollection() {
    changedEvent = CollectionChangedEvent.eventDef;
  }

  ElementCollection() : super() {
  }

  /**
   * Returns size of collection.
   */
  int get length => _items == null ? 0 : _items.length;

  /**
   * Adds items to collection.
   * @param item object to add to collection.
   */
  void add(Object item) {
    if (_items == null) {
      _items = [];
    }
    _items.add(item);
    int changeIndex = _items.length - 1;
    raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_ADD,
        changeIndex, _NUM_ITEMS_CHANGED_ONE_ITEM);
  }

  /**
   * Inserts item into collection.
   * @param index Insertion index.
   * @param item object to insert into collection.
   */
  void insert(int index, Object item) {
    if (_items == null) {
      _items = [];
    }
    _items.insert(index, item);
    raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_ADD,
        index, _NUM_ITEMS_CHANGED_ONE_ITEM);
  }

  /**
   * Inserts a list of items into collection.
   * @param index Insertion index.
   * @param list of item objects to insert into collection.
   */
  void insertAll(int index, List list) {
    if (_items == null) {
      _items = [];
    }
    int numItems = list.length;
    for (int i = 0; i < numItems; i++) {
      _items.insert(index + i, list[i]);
    }
    raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_ADD,
        index, numItems);
  }

  /**
   * Removes an item from collection.
   * @param item Object to remove from collection.
   */
  void remove(Object item) {
    if (_items == null) {
      return;
    }
    int index = _items.indexOf(item, 0);
    if (index != -1) {
      raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVING, index,
          _NUM_ITEMS_CHANGED_ONE_ITEM);
      _items.removeAt(index);
      raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVE, index,
          _NUM_ITEMS_CHANGED_ONE_ITEM);
    }
  }

  /**
   * Returns index of item in collection.
   * @param item Object to search for.
   * @param fromIndex Search start location.
   * @return return index of object in collection. Returns -1 if item is not
   *  in the collection.
   */
  int indexOf(Object item) {
    return _items != null ? _items.indexOf(item, 0) : -1;
  }

  /**
   * Removes an item at an index from collection.
   * @param index Index of object to be remove from collection.
   */
  void removeAt(int index) {
    if (_items == null) {
      return;
    }
    raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVING, index,
        _NUM_ITEMS_CHANGED_ONE_ITEM);
    _items.removeAt(index);
    raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVE, index,
        _NUM_ITEMS_CHANGED_ONE_ITEM);
  }

  /**
   * Removes all items from collection.
   */
  void clear() {
    if ((_items != null) && (_items.length != 0)) {
      int count = _items.length;
      raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVING,
          _START_CHANGE_INDEX, count);
      _items.clear();
      raiseChangedEvent(CollectionChangedEvent.CHANGETYPE_REMOVE,
          _START_CHANGE_INDEX, count);
    }
  }

  /**
   * Returns an item at specified index or undefined if index is out of
   * bounds.
   */
  Object getItemAt(int index) => _items[index];

  void raiseChangedEvent(int type, int index, int count) {
    CollectionChangedEvent event = CollectionChangedEvent.create(
        this, type, index, count);
    notifyListeners(changedEvent, event);
    CollectionChangedEvent.release(event);
  }

  /**
   * Copies collection contents to an array. If array already has items,
   * contents are appended to end of array.
   * @param targetArray Array to copy items to.
   */
  void copyTo(List<Object> targetArray) {
    for (int index = 0; index < _items.length; index++) {
      targetArray.add(_items[index]);
    }
  }
}
