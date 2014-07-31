part of uxml;

/**
 * Transforms the layout or rendering of a UIElement
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class UITransform extends UxmlElement {
  static ElementDef transformElementDef;
  /** ScaleX property definition */
  static PropertyDefinition scaleXProperty;
  /** ScaleY property definition */
  static PropertyDefinition scaleYProperty;
  /** TranslateX property definition */
  static PropertyDefinition translateXProperty;
  /** TranslateY property definition */
  static PropertyDefinition translateYProperty;
  /** Rotate property definition */
  static PropertyDefinition rotateProperty;
  /** Rotation OriginX property definition */
  static PropertyDefinition originXProperty;
  /** Rotation OriginY property definition */
  static PropertyDefinition originYProperty;

  /** Notification target of transform */
  UIElement _targetElement;
  Matrix _transMatrix;

  /**
   * Constructor.
   */
  UITransform() : super() {
    _transMatrix = new Matrix.identity();
  }

  /**
   * Sets or returns target of transform.
   */
  UIElement get target {
    return _targetElement;
  }

  set target(UIElement element) {
    _targetElement = element;
  }

  /**
   * Sets or returns scaleX of transform.
   */
  num get scaleX {
    return getProperty(scaleXProperty);
  }

  set scaleX(num value) {;
    setProperty(scaleXProperty, value);
  }

  /**
   * Sets or returns scaleY of transform.
   */
  num get scaleY {
    return getProperty(scaleYProperty);
  }

  set scaleY(num value) {
    setProperty(scaleYProperty, value);
  }

  /**
   * Sets or returns translateX of transform.
   */
  num get translateX {
    return getProperty(translateXProperty);
  }

  set translateX(num value) {
    setProperty(translateXProperty, value);
  }

  /**
  * Sets or returns translateY of transform.
  */
  num get translateY {
    return getProperty(translateYProperty);
  }

  set translateY(num value) {
    setProperty(translateYProperty, value);
  }

  /**
   * Sets or returns x origin of transform.
   */
  num get originX {
    return getProperty(originXProperty);
  }

  set originX(num value) {
    setProperty(originXProperty, value);
  }

  /**
   * Sets or returns y origin of transform.
   */
  num get originY {
    return getProperty(originYProperty);
  }

  set originY(num value) {
    setProperty(originYProperty, value);
  }

  /**
   * Sets or returns rotation of transform.
   */
  num get rotate {
    return getProperty(rotateProperty);
  }

  set rotate(num value) {
    setProperty(rotateProperty, value);
  }

  /**
   * Transforms size on x axis.
   */
  num transformSizeX(num value) {
    return _transMatrix.a * value;
  }

  /**
   * Transforms size on y axis.
   */
  num transformSizeY(num value) {
    return _transMatrix.d * value;
  }

  /**
   * Overrides UxmlElement.onPropertyChanged to capture all property changes
   * and update target element transform.
   */
  void onPropertyChanged(Object propKey, Object oldValue, Object newValue) {
    num cosVal = cos(PI * rotate / 180.0);
    num sinVal = sin(PI * rotate / 180.0);
    _transMatrix.a = scaleX * cosVal;
    _transMatrix.b = scaleY * -sinVal;
    _transMatrix.c = scaleX * sinVal;
    _transMatrix.d = scaleY * cosVal;
    _transMatrix.tx = translateX;
    _transMatrix.ty = translateY;
    if (_targetElement != null) {
      _targetElement.onTransformChanged(this);
    }
  }

  /**
   * Returns matrix for transform.
   */
  Matrix get matrix {
    return _transMatrix;
  }

  /**
   * Returns css representation of matrix.
   */
  String toString() {
    Matrix m = matrix;
    StringBuffer sb = new StringBuffer();
    sb.write("matrix(");
    sb.write(m.a.toStringAsFixed(4));
    sb.write(",");
    sb.write(m.c.toStringAsFixed(4));
    sb.write(",");
    sb.write(m.b.toStringAsFixed(4));
    sb.write(",");
    sb.write(m.d.toStringAsFixed(4));
    sb.write(",");
    sb.write(m.tx.toStringAsFixed(4));
    sb.write(",");
    sb.write(m.ty.toStringAsFixed(4));
    sb.write(")");
    return sb.toString();
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => transformElementDef;

  /** Registers component. */
  static void registerTransform() {
    scaleXProperty = ElementRegistry.registerProperty("scaleX",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 1.0);
    scaleYProperty = ElementRegistry.registerProperty("scaleY",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 1.0);
    translateXProperty = ElementRegistry.registerProperty("translateX",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.0);
    translateYProperty = ElementRegistry.registerProperty("translateY",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.0);
    rotateProperty = ElementRegistry.registerProperty("rotate",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.0);
    originXProperty = ElementRegistry.registerProperty("originX",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.5);
    originYProperty = ElementRegistry.registerProperty("originY",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 0.5);

    transformElementDef = ElementRegistry.register("UITransform", null,
        [scaleXProperty, scaleYProperty, translateXProperty, translateYProperty,
        rotateProperty, originXProperty, originYProperty], null);
  }
}
