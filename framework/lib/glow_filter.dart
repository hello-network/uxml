part of uxml;

/**
 * Holds Glow filter properties.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class GlowFilter extends Filter {
  static ElementDef glowFilterElementDef;

  /** The alpha transparency of the value of the shadow color. */
  static PropertyDefinition  alphaProperty;
  /** The amount of horizontal blur. */
  static PropertyDefinition  blurXProperty;
  /** The amount of vertical blur. */
  static PropertyDefinition  blurYProperty;
  /** The color of the shadow. */
  static PropertyDefinition colorProperty;

  /** Indicates whether or not the shadow is an inner shadow. */
  static PropertyDefinition  innerProperty;
  /**
   * Applies a knockout effect (true), which effectively makes the object's
   * fill transparent and reveals the background color of the document.
   */
  static PropertyDefinition knockoutProperty;
  /** The number of times to apply the filter. */
  static PropertyDefinition qualityProperty;
  /** The strength of the imprint or spread. */
  static PropertyDefinition strengthProperty;

  GlowFilter() : super() {
  }

  /**
   * Sets or returns alpha.
   */
  set alpha(num value) {
    setProperty(alphaProperty, value);
  }

  num get alpha => getProperty(alphaProperty);

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
   * Sets or returns strength of the glow
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
  ElementDef getDefinition() => glowFilterElementDef;

  /** Registers component. */
  static void registerGlowFilter() {
    alphaProperty = DropShadowFilter.alphaProperty;
    blurXProperty = DropShadowFilter.blurXProperty;
    blurYProperty = DropShadowFilter.blurYProperty;
    colorProperty = DropShadowFilter.colorProperty;
    innerProperty = DropShadowFilter.innerProperty;
    knockoutProperty = DropShadowFilter.knockoutProperty;
    qualityProperty = DropShadowFilter.qualityProperty;
    strengthProperty = DropShadowFilter.strengthProperty;

    glowFilterElementDef = ElementRegistry.register("GlowFilter",
        Filter.filterElementDef,
        [alphaProperty, blurXProperty, blurYProperty, colorProperty,
        innerProperty, knockoutProperty, qualityProperty, strengthProperty],
        null);
  }
}
