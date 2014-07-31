part of uxml;

/**
 * Manages a list of filters for UIElement.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Filters {

  List<Filter> _list;
  DropShadowFilter _innerShadow = null;
  DropShadowFilter _dropShadow = null;

  /**
   * Owner of filters collection used to notify of changes.
   */
  UIElement _owner;

  /**
   * Constructor.
   */
  Filters() : super() {
    _list = <Filter>[];
  }

  /**
   * Sets owner of filters collection.
   */
  set owner(UIElement value) {
    _owner = value;
    int filterCount = _list.length;
    for (int f = 0; f < filterCount; f++) {
      _list[f]._owner = value;
    }
  }

  /**
   * Return number of filters.
   */
  int get length {
    return _list.length;
  }

  /**
   * Appends the filter to the end of the list.
   */
  void add(Filter filter) {
    _list.add(filter);
    filter.target = _owner;
    if (filter is DropShadowFilter) {
      DropShadowFilter ds = filter;
      if (ds.inner) {
        _innerShadow = ds;
      } else {
        _dropShadow = filter;
      }
    }
  }

  /**
   * Removes filter from the list.
   */
  void remove(Filter filter) {
    filter._owner = null;
    int index = _list.indexOf(filter, 0);
    _list.removeAt(index);
  }

  /**
   * Returns filter at index.
   */
  Filter getFilter(int index) {
    return _list[index];
  }
}
