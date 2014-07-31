part of uxml;

/**
 * Implements a grid column.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class GridColumn extends GridDef {
  static ElementDef gridcolumnElementDef;
  /**
   * MinWidth Property Definition.
   */
  static PropertyDefinition minWidthProperty;
  /**
   * MaxWidth Property Definition.
   */
  static PropertyDefinition maxWidthProperty;

  /**
   * Width Property Definition.
   */
  static PropertyDefinition widthProperty;

  GridColumn() : super() {
  }

  /**
   * Gets or sets width of a grid column.
   */
  num get width => _length;

  set width(num value) {
    setProperty(widthProperty, value);
  }

  /**
   * Gets or sets the minimum width of a grid column.
   */
  num get minWidth => minLength;

  set minWidth(num value) {
    setProperty(minWidthProperty, value);
  }

  /**
   * Gets or sets the maximum width of a grid column.
   */
  num get maxWidth => maxLength;

  set maxWidth(num value) {
    setProperty(maxWidthProperty, value);
  }

  static void _widthChangedHandler(UxmlElement target,
                                   PropertyDefinition property,
                                   Object oldValue,
                                   Object newValue) {
    GridColumn column = target;
    if (newValue == PropertyDefaults.NO_DEFAULT) {
      column.lengthDefined = false;
    } else {
      column._length = newValue;
      column.lengthDefined = true;
    }
    if (column.owner != null) {
      column.owner._gridDefChanged();
    }
  }

  static void _maxWidthChangedHandler(UxmlElement target,
                                      PropertyDefinition property,
                                      Object oldValue,
                                      Object newValue) {
    GridColumn column = target;
    if (newValue == PropertyDefaults.NO_DEFAULT) {
      column.maxLengthDefined = false;
    } else {
      column.maxLength = newValue;
    }
    if (column.owner != null) {
      column.owner._gridDefChanged();
    }
  }

  static void _minWidthChangedHandler(UxmlElement target,
                                      PropertyDefinition property,
                                      Object oldValue,
                                      Object newValue) {
    GridColumn column = target;
    column.minLength = (newValue == PropertyDefaults.NO_DEFAULT) ? 0 : newValue;
    if (column.owner != null) {
      column.owner._gridDefChanged();
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => gridcolumnElementDef;

  /** Registers component. */
  static void registerGridColumn() {
    minWidthProperty = ElementRegistry.registerProperty("minWidth",
        PropertyType.NUMBER, PropertyFlags.NONE, _minWidthChangedHandler, 0.0);
    maxWidthProperty = ElementRegistry.registerProperty("maxWidth",
        PropertyType.NUMBER, PropertyFlags.NONE, _maxWidthChangedHandler, 0.0);
    widthProperty = ElementRegistry.registerProperty("width",
        PropertyType.NUMBER, PropertyFlags.NONE, _widthChangedHandler, 0.0);

    gridcolumnElementDef = ElementRegistry.register("GridColumn",
        UxmlElement.baseElementDef,
        [minWidthProperty, maxWidthProperty, widthProperty], null);
  }
}
