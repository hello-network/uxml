part of uxml;

/**
 * Implements container that decorates an inner element.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class LabeledControl extends Control {

  static ElementDef labeledcontrolElementDef;
  /** Content property definition */
  static PropertyDefinition contentProperty;
  /** Label property definition */
  static PropertyDefinition labelProperty;
  /** Content property definition */
  static PropertyDefinition pictureProperty;

  LabeledControl() : super() {
  }

  /** Sets or returns content element. */
  set content(Object content) {
    setProperty(contentProperty, content);
  }

  Object get content => getProperty(contentProperty);

  /** Sets or returns label. */
  set label(Object element) {
    setProperty(labelProperty, element);
  }

  Object get label => getProperty(labelProperty);

  /** Sets or returns picture element. */
  set picture(UIElement element) {
    setProperty(pictureProperty, element);
  }

  UIElement get picture => getProperty(pictureProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => labeledcontrolElementDef;

  /** Registers component. */
  static void registerLabeledControl() {
    labelProperty = ElementRegistry.registerProperty("label",
        PropertyType.OBJECT, PropertyFlags.NONE, null, null);
    contentProperty = ElementRegistry.registerProperty("content",
        PropertyType.OBJECT, PropertyFlags.NONE, null, null);
    pictureProperty = ElementRegistry.registerProperty("picture",
        PropertyType.UIELEMENT, PropertyFlags.NONE, null, null);
    labeledcontrolElementDef = ElementRegistry.register("LabeledControl",
        Control.controlElementDef, [contentProperty, labelProperty,
        pictureProperty], null);
  }
}
