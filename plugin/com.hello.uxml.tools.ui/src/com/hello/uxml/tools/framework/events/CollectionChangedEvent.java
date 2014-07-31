package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.UxmlElement;

/**
* Defines collection change event arguments.
*
* @author ferhat@
*/
public class CollectionChangedEvent extends EventArgs{

  public static EventDefinition changeEvent = EventManager.register(
      "Change", UxmlElement.class, CollectionChangedEvent.class,
      UxmlElement.class, null);

  /** The type of collection change. */
  private ChangeType type;

  /** The index in the collection that changed. */
  private int index;

  /** The number of items that changed starting at index. */
  private int count;

  /**
   * Constructor.
   */
  public CollectionChangedEvent(Object source, ChangeType type, int index, int count) {
    this.source = source;
    this.type = type;
    this.index = index;
    this.count = count;
  }

  /**
   * Sets or returns collection change type.
   */
  public void setType(ChangeType type) {
    this.type = type;
  }

  public ChangeType getType() {
    return type;
  }

  /**
   * Sets or returns index of item that changed.
   */
  public void setIndex(int index) {
    this.index = index;
  }

  public int getIndex() {
    return index;
  }

  /**
   * Returns number of items that changed.
   */
  public void setCount(int count) {
    this.count = count;
  }

  public int getCount() {
    return count;
  }
}
