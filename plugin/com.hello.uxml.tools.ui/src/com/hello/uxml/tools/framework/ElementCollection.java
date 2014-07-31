package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.ChangeType;
import com.hello.uxml.tools.framework.events.CollectionChangedEvent;

import java.util.ArrayList;
import java.util.List;

/**
 * Implements an observable collection.
 *
 * @author ferhat
 */
public class ElementCollection extends UxmlElement {

  /** internal list of items */
  private List<Object> items;
  /** instance of event arguments that is reused across multiple collection changes */
  private CollectionChangedEvent cachedChangeEvent;

  public ElementCollection() {
    super();
  }

  /**
   * Returns size of collection.
   */
  public int size() {
    return (items != null) ? items.size() : 0;
  }

  /**
   * Adds item to collection.
   */
  @ContentNode
  public void add(Object item) {
    if (items == null) {
      items = new ArrayList<Object>();
    }
    items.add(item);
    raiseChangedEvent(ChangeType.Add, items.size() - 1, 1);
  }

  /**
   * Inserts item into collection.
   * @param index Insertion index.
   * @param item object to insert into collection.
   */
  public void insert(int index, Object item) {
    if (items == null) {
      items = new ArrayList<Object>();
    }
    items.add(index, item);
    raiseChangedEvent(ChangeType.Add, index, 1);
  }

  /**
   * Removes item from collection.
   */
  public void remove(Object item) {
    if (items != null) {
      int index = items.indexOf(item);
      if (index != -1) {
        items.remove(index);
        raiseChangedEvent(ChangeType.Remove, index, 1);
      }
    }
  }

  /**
   * Removes item at index from collection.
   */
  public void removeAt(int index) {
    if ((index >= 0) && (items != null) && (index < size())) {
      items.remove(index);
      raiseChangedEvent(ChangeType.Remove, index, 1);
    }
  }

  /**
   * Removes all items from collection.
   */
  public void clear() {
    if ((items != null) && (items.size() != 0)) {
      int count = items.size();
      items.clear();
      raiseChangedEvent(ChangeType.Remove, 0, count);
    }
  }

  /**
   * Returns item at index.
   */
  public Object get(int index) {
    return items.get(index);
  }

  private void raiseChangedEvent(ChangeType type, int index, int count) {
    if (cachedChangeEvent == null) {
      cachedChangeEvent = new CollectionChangedEvent(this, type, index, count);
    } else {
      cachedChangeEvent.setType(type);
      cachedChangeEvent.setIndex(index);
      cachedChangeEvent.setCount(count);
    }
    this.notifyListeners(CollectionChangedEvent.changeEvent, cachedChangeEvent);
  }
}
