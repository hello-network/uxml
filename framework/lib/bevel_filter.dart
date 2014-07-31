part of uxml;

/**
 * Holds Bevel filter properties.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class BevelFilter extends Filter {
  static ElementDef bevelfilterElementDef;
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
  /** The color properties of the bevel. */
  static PropertyDefinition colorProperty;
  static PropertyDefinition highlightColorProperty;
  static PropertyDefinition shadowColorProperty;
  /** Indicates whether or not the object is hidden. */
  static PropertyDefinition hideObjectProperty;
  /** Indicates the type of bevel. */
  static PropertyDefinition typeProperty;
  /**
   * Applies a knockout effect (true), which effectively makes the object's
   * fill transparent and reveals the background color of the document.
   */
  static PropertyDefinition knockoutProperty;
  /** The number of times to apply the filter. */
  static PropertyDefinition qualityProperty;
  /** The strength of the imprint or spread. */
  static PropertyDefinition strengthProperty;

  BevelFilter() : super() {
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
   * Sets or returns strength of the filter.
   */
  set strength(num value) {
    setProperty(strengthProperty, value);
  }

  num get strength => getProperty(strengthProperty);

  /**
   * Sets or returns rendering quality of blur.
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
   * Sets or returns type of filter.
   */
  set type(String value) {
    setProperty(typeProperty, value);
  }

  String get type => getProperty(typeProperty);

  /**
   * Sets or returns glow filter color.
   */
  set color(Color value) {
    setProperty(colorProperty, value);
  }

  Color get color => getProperty(colorProperty);

  /**
   * Sets or returns bevel highlight color.
   */
  set highlightColor(Color value) {
    setProperty(highlightColorProperty, value);
  }

  Color get highlightColor => getProperty(highlightColorProperty);

  /**
   * Sets or returns bevel shadow color.
   */
  set shadowColor(Color value) {
    setProperty(shadowColorProperty, value);
  }

  Color get shadowColor => getProperty(shadowColorProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => bevelfilterElementDef;

  /** Registers component. */
  static void registerBevelFilter() {
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
    highlightColorProperty = ElementRegistry.registerProperty("highlightColor",
        PropertyType.COLOR, PropertyFlags.NONE, null,
        Color.fromRGB(0xFFFFFF));
    shadowColorProperty = ElementRegistry.registerProperty("shadowColor",
        PropertyType.COLOR, PropertyFlags.NONE, null,
        Color.fromRGB(0));
    hideObjectProperty = ElementRegistry.registerProperty("hideObject",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    typeProperty = ElementRegistry.registerProperty("type", PropertyType.STRING,
        PropertyFlags.NONE, null, "inner");
    knockoutProperty = ElementRegistry.registerProperty("knockout",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    qualityProperty = ElementRegistry.registerProperty("quality",
        PropertyType.INT, PropertyFlags.NONE, null, 1);
    strengthProperty = ElementRegistry.registerProperty("strength",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 1.0);

    bevelfilterElementDef = ElementRegistry.register("BevelFilter",
        Filter.filterElementDef,
        [alphaProperty, angleProperty, blurXProperty, blurYProperty,
        distanceProperty, highlightColorProperty, shadowColorProperty,
        typeProperty, hideObjectProperty, knockoutProperty,
        qualityProperty, strengthProperty], null);
  }
}
