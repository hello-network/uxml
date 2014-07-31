part of uxml;

/**
 * Holds DropShadow filter properties.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class DropShadowFilter extends Filter {
  static ElementDef dropshadowfilterElementDef;
  /** The alpha transparency of the value of the shadow color. */
  static PropertyDefinition alphaProperty;
  /** The angle of the shadow. */
  static PropertyDefinition angleProperty;
  /** The amount of horizontal blur. */
  static PropertyDefinition blurXProperty;
  /** The amount of vertical blur. */
  static PropertyDefinition blurYProperty;
  /** The offset distance for the shadow, in pixels. */
  static PropertyDefinition distanceProperty;
  /** The color of the shadow. */
  static PropertyDefinition colorProperty;
  /** Indicates whether or not the object is hidden. */
  static PropertyDefinition hideObjectProperty;
  /** Indicates whether or not the shadow is an inner shadow. */
  static PropertyDefinition innerProperty;
  /**
   * Applies a knockout effect (true), which effectively makes the object's
   * fill transparent and reveals the background color of the document.
   */
  static PropertyDefinition knockoutProperty;
  /** The number of times to apply the filter. */
  static PropertyDefinition qualityProperty;
  /** The strength of the imprint or spread. */
  static PropertyDefinition strengthProperty;

  DropShadowFilter() : super() {
  }

  /**
   * Sets or returns alpha.
   */
  set alpha(num value) {
    setProperty(alphaProperty, value);
  }

  num get alpha => getProperty(alphaProperty);

  /**
   * Sets or returns shadow angle.
   */
  set angle(num value) {
    setProperty(angleProperty, value);
  }

  num get angle => getProperty(angleProperty);

  /**
   * Sets or returns x axis blur.
   */
  set blurX(num value) {
    setProperty(blurXProperty, value);
  }

  num get blurX => getProperty(blurXProperty);

  /**
   * Sets or returns y axis blur.
   */
  set blurY(num value) {
    setProperty(blurYProperty, value);
  }

  num get blurY => getProperty(blurYProperty);

  /**
   * Sets or returns distance of shadow.
   */
  set distance(num value) {
    setProperty(distanceProperty, value);
  }

  num get distance => getProperty(distanceProperty);

  /**
   * Sets or returns strength of the glow
   */
  set strength(num value) {
    setProperty(strengthProperty, value);
  }

  num get strength => getProperty(strengthProperty);

  /**
   * Sets or returns y axis blur.
   */
  set quality(int value) {
    setProperty(qualityProperty, value);
  }

  int get quality => getProperty(qualityProperty);

  /**
   * Sets or returns if knockout.
   */
  set knockout(bool value) {
    setProperty(knockoutProperty, value);
  }

  bool get knockout => getProperty(knockoutProperty);

  /**
   * Sets or returns if filter is inner glow.
   */
  set inner(bool value) {
    setProperty(innerProperty, value);
  }

  bool get inner => getProperty(innerProperty);

  /**
   * Sets or returns glow filter color.
   */
  set color(Color value) {
    setProperty(colorProperty, value);
  }

  Color get color => getProperty(colorProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => dropshadowfilterElementDef;

  /** Registers component. */
  static void registerDropShadowFilter() {
    alphaProperty = ElementRegistry.registerProperty("alpha",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 1.0);
    angleProperty = ElementRegistry.registerProperty("angle",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 45.0);
    blurXProperty = ElementRegistry.registerProperty("blurX",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 4.0);
    blurYProperty = ElementRegistry.registerProperty("blurY",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 4.0);
    distanceProperty = ElementRegistry.registerProperty("distance",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 4.0);
    colorProperty = ElementRegistry.registerProperty("color",
        PropertyType.COLOR, PropertyFlags.NONE, null,
        Color.fromRGB(0));
    hideObjectProperty = ElementRegistry.registerProperty("hideObject",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    innerProperty = ElementRegistry.registerProperty("inner",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    knockoutProperty = ElementRegistry.registerProperty("knockout",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    qualityProperty = ElementRegistry.registerProperty("quality",
        PropertyType.INT, PropertyFlags.NONE, null, 1);
    strengthProperty = ElementRegistry.registerProperty("strength",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 1.0);

    dropshadowfilterElementDef = ElementRegistry.register("DropShadowFilter",
        Filter.filterElementDef,
        [alphaProperty, angleProperty, blurXProperty, blurYProperty,
        distanceProperty, colorProperty, innerProperty, hideObjectProperty,
        knockoutProperty, qualityProperty, strengthProperty], null);
  }
}
