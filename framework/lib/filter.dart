part of uxml;

/**
 * Base class for graphics effects filters.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class Filter extends UxmlElement {
  static ElementDef filterElementDef;

  /** Filter changed event definition. */
  static EventDef changedEvent;

  UIElement _owner = null;

  Filter() : super() {
  }

  set target(UIElement element) {
    if ((element != null) && (_owner != null) && (_owner != element)) {
      throw new ArgumentError(
          "Target element already assigned to filter");
    }
    _owner = element;
    if (_owner != null) {
      UpdateQueue.updateFilters(_owner);
    }
  }

  /**
   * Updates the filter object and schedules UI update.
   */
  void onPropertyChanged(Object propertyKey, Object oldVal, Object newVal) {
    if (_owner != null) {
      UpdateQueue.updateFilters(_owner);
    }
    // fire change event to all listeners
    if (hasListener(changedEvent)) {
      EventArgs event = new EventArgs(this);
      notifyListeners(changedEvent, event);
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => filterElementDef;

  /** Registers component. */
  static void registerFilter() {
    changedEvent = new EventDef("Changed", Route.DIRECT);
    filterElementDef = ElementRegistry.register("Filter",
        UxmlElement.baseElementDef, null, [changedEvent]);
  }
}
