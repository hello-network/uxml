part of uxml;

/**
 * Creates element tree for a control's visual look and behaviour.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Chrome {
  String _id;
  Object _type;
  CreateElementsDelegate _createElements;
  List<Effect> _effects;

  /**
  * Constructor.
  */
  Chrome(String id, Object type, CreateElementsDelegate foo) {
    _id = id;
    _type = type;
    _createElements = foo;
    _effects = null;
  }

  /**
   * Returns id.
   */
  String get id => _id;

  /**
   * Returns effects collection. Lazily creates one if empty.
   */
  List<Effect> get effects {
    if (_effects == null) {
      _effects = <Effect>[];
    }
    return _effects;
  }

  /**
   * Returns target type of chrome.
   */
  Object get type => _type;

  /**
   * Overridable function that creates the element tree and applies effects.
   */
  UIElement applyToTarget(UIElement targetElement) {
    UIElement newChromeTree = null;
    if (_createElements != null) {
      newChromeTree = _createElements(targetElement);
    }
    if (effects != null && effects.length != 0) {
      for (int i = 0; i < effects.length; i++) {
        Effect effect = effects[i];
        Effect newEffect = effect.clone();
        if (newEffect.targetElement == null) {
          newEffect.targetElement = targetElement;
        }
        targetElement.effects.add(newEffect);
      }
    }
    return newChromeTree;
  }

  /**
   * Sets the default value of a property defined on it's chrome if it
   * has not been changed yet.
   */
  static void applyProperty(UxmlElement targetObject,
                            PropertyDefinition key, Object value) {
    if (!targetObject.overridesProperty(key)) {
      targetObject.setProperty(key, value);
    }
  }
}

typedef UIElement CreateElementsDelegate(UIElement target);
