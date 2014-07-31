part of uxml;

/**
 * Defines event class for changes to collections.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class CollectionChangedEvent extends EventArgs {

  // Event types are prefixed CHANGETYPE_ so it is compatible with
  // java enum for codegen
  /** The add event. */
  static const int CHANGETYPE_ADD = 1;

  /** The about to remove event. */
  static const int CHANGETYPE_REMOVING = 2;

  /** The remove event. */
  static const int CHANGETYPE_REMOVE = 3;

  /** The remove event. */
  static const int CHANGETYPE_MODIFY = 4;

  /**
   * Queue used for object pooling. User calls
   * static create and release to access shared instances.
   */
  static List<CollectionChangedEvent> _objectPool = null;

  static EventDef eventDef;
  static void initCollectionChangedEvent() {
    eventDef = new EventDef("Changed", Route.DIRECT);
  }
  /** The type of collection change. */
  int type;

  /** The index in the collection that changed. */
  int index;

  /** The count of items that changed starting at index. */
  int count;

  /**
   * Constructor.
   */
  CollectionChangedEvent(Object source,
      int changeType, int changeIndex, int changeCount) : super(source) {
    type = changeType;
    index = changeIndex;
    count = changeCount;
  }

  /**
   * Returns a CollectionChangedEvent by reusing an instance from an
   * objectPool or by creating a new instance.
   */
  static CollectionChangedEvent create(Object source,
                                       int type,
                                       int index,
                                       int count) {
    if (_objectPool == null || _objectPool.length == 0) {
      return new CollectionChangedEvent(source, type, index, count);
    }
    CollectionChangedEvent cEvent = _objectPool.removeLast();
    cEvent.source = source;
    cEvent.type = type;
    cEvent.index = index;
    cEvent.count = count;
    return cEvent;
  }

  /**
   * Returns a CollectionChangedEvent instance to the shared pool to reduce
   * allocations.
   * @param e Instance to return to object pool.
   */
  static void release(CollectionChangedEvent e) {
    if (_objectPool == null) {
      _objectPool = <CollectionChangedEvent>[];
    }
    _objectPool.add(e);
  }
}
