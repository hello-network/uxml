part of uxml;

/**
 * Defines event class for changes to property of an object.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class PropertyChangedEvent extends EventArgs {

  /** The property change event definition. */
  static EventDef changeEvent;
  static void initPropertyChangedEvent() {
    changeEvent = new EventDef("change", Route.DIRECT);
  }

  /**
   * Queue used for object pooling. User calls
   * static create and release to access shared instances.
   */
  static List<PropertyChangedEvent> _objectPool;

  /** The property that changed. */
  Object property;

  /** The old value of the property. */
  Object oldValue;

  /** The new value of the property. */
  Object newValue;

  /** Constructs PropertyChangedEvent. */
  PropertyChangedEvent(Object source,
                       Object propertyKey,
                       Object oldValue,
                       Object newValue) : super(source) {
    this.property = propertyKey;
    this.oldValue = oldValue;
    this.newValue = newValue;
  }

  /**
   * Returns a PropertyChangedEvent by reusing an instance from an objectPool
   * or by creating a new instance.
   * @param source Source element of the property change event.
   * @param property Contains property definition or key for the change event.
   * @param oldValue Contains old property value.
   * @param newValue Container new property value.
   */
  static PropertyChangedEvent create(Object source, Object propertyKey,
      Object oldValue, Object newValue) {
    if (_objectPool == null) {
      _objectPool = <PropertyChangedEvent>[];
    }
    if (_objectPool.length == 0) {
      return new PropertyChangedEvent(source, propertyKey,
          oldValue, newValue);
    }
    PropertyChangedEvent propEvent = _objectPool.removeLast();
    propEvent.source = source;
    propEvent.currentSource = source;
    propEvent.property = propertyKey;
    propEvent.oldValue = oldValue;
    propEvent.newValue = newValue;
    return propEvent;
  }

  /**
   * Returns a PropertyChangedEvent instance to the shared pool to reduce
   * allocations.
   * @param e Instance to return to object pool.
   */
  static void release(PropertyChangedEvent e) {
    _objectPool.add(e);
  }
}
