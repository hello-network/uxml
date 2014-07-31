part of uxml;

/**
 * Provides container for tooltip overlays.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ToolTip extends ContentContainer {
  int _locationValue;

  static ElementDef tooltipElementDef;
  static PropertyDefinition locationProperty;
  static PropertyDefinition finalLocationProperty;

  ToolTip() : super() {
    _locationValue = OverlayLocation.DEFAULT;
  }

  /**
   * Sets/Returns the location of popup relative to the container.
   */
  set location(int value) {
    setProperty(locationProperty, value);
  }

  int get location => getProperty(locationProperty);

  /** Returns final location of tooltip */
  int get finalLocation => getProperty(finalLocationProperty);

  /**
   * Forces a tooltip to show.
   */
  void show() {
    Application.current._toolTipManager.showToolTip(parent, true);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => tooltipElementDef;

  /** Registers component. */
  static void registerToolTip() {
    locationProperty = ElementRegistry.registerProperty(
      "Location", PropertyType.LOCATION, PropertyFlags.NONE, null, 0);
    finalLocationProperty = OverlayContainer.finalLocationProperty;
    tooltipElementDef = ElementRegistry.register("ToolTip",
        ContentContainer.contentcontainerElementDef, [locationProperty,
        finalLocationProperty], null);
  }
}
