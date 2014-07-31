part of uxml;

/**
 * Implements a grid row.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class GridRow extends GridDef {
  /**
   * MinHeight Property Definition.
   */
  static PropertyDefinition minHeightProperty;

  /**
   * MaxHeight Property Definition.
   */
  static PropertyDefinition maxHeightProperty;

  /**
   * Height Property Definition.
   */
  static PropertyDefinition heightProperty;

  static ElementDef gridrowElementDef;

  GridRow() : super() {
  }

  /**
   * Gets or sets height of a grid row.
   */
  num get height => length;

  set height(num value) {
    setProperty(heightProperty, value);
  }

  /**
   * Gets or sets the minimum height of a grid row.
   */
  num get minHeight => minLength;

  set minHeight(num value) {
    setProperty(minHeightProperty, value);
  }

  /**
   * Gets or sets the maximum height of a grid row.
   */
  num get maxHeight => maxLength;

  set maxHeight(num value) {
    setProperty(maxHeightProperty, value);
  }

  static void _heightChangeHandler(UxmlElement target,
                                   PropertyDefinition property,
                                   Object oldValue,
                                   Object newValue) {
    GridRow row = target;
    if (newValue == PropertyDefaults.NO_DEFAULT) {
      row.lengthDefined = false;
    } else {
      row.length = newValue;
    }
    if (row.owner != null) {
      row.owner._gridDefChanged();
    }
  }

  static void _maxHeightChangeHandler(UxmlElement target,
                                      PropertyDefinition property,
                                      Object oldValue,
                                      Object newValue) {
    GridRow row = target;
    if (newValue == PropertyDefaults.NO_DEFAULT) {
      row.maxLengthDefined = false;
    } else {
      row.maxLength = newValue;
    }
    if (row.owner != null) {
      row.owner._gridDefChanged();
    }
  }

  static void _minHeightChangeHandler(UxmlElement target,
                                      PropertyDefinition property,
                                      Object oldValue,
                                      Object newValue) {
    GridRow row = target;
    row.minLength = (newValue == PropertyDefaults.NO_DEFAULT) ? 0 : newValue;
    if (row.owner != null) {
      row.owner._gridDefChanged();
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => gridrowElementDef;

  /** Registers component. */
  static void registerGridRow() {
    minHeightProperty = ElementRegistry.registerProperty("minHeight",
        PropertyType.NUMBER, PropertyFlags.NONE, _minHeightChangeHandler, 0.0);
    maxHeightProperty = ElementRegistry.registerProperty("maxHeight",
        PropertyType.NUMBER, PropertyFlags.NONE, _maxHeightChangeHandler, 0.0);
    heightProperty = ElementRegistry.registerProperty("height",
        PropertyType.NUMBER, PropertyFlags.NONE, _heightChangeHandler, 0.0);
    gridrowElementDef = ElementRegistry.register("GridRow",
        UxmlElement.baseElementDef,
        [minHeightProperty, maxHeightProperty, heightProperty], null);
  }
}
