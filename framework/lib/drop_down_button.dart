part of uxml;

/**
 * Implements button that shows popup as drop down on mouse down.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class DropDownButton extends Button {
  /** IsOpen property definition */
  static PropertyDefinition isOpenProperty;
  /** Popup property definition */
  static PropertyDefinition popupProperty;
  static ElementDef dropdownbuttonElementDef;

  DropDownButton() : super() {
  }

  /**
   * Sets/returns open state.
   */
  bool get isOpen => getProperty(isOpenProperty);

  set isOpen(bool value) {
    return setProperty(isOpenProperty, value);
  }

  /**
   * Sets/returns popup element.
   */
  UIElement get popup => getProperty(popupProperty);

  set popup(UIElement value) {
    return setProperty(popupProperty, value);
  }

  /** Overrides Button.onMouseDown to toggle dropdown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    captureMouse();
    setProperty(Button.isPressedProperty, true);
    isOpen = !isOpen;
    mouseArgs.handled = true;
  }

  /** Overrides Button.onMouseUp. */
  void onMouseUp(MouseEventArgs mouseArgs) {
    releaseMouse();
    setProperty(Button.isPressedProperty, false);
    if (isMouseOver) {
      onClick(mouseArgs);
    }
  }

  static void _popupContentChanged(Object target, Object propDef,
      Object oldValue, Object newValue) {
    // TODO(ferhat): implement Popup hosting and wiring up isOpen properties.
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => dropdownbuttonElementDef;

  /** Registers component. */
  static void registerDropDownButton() {
    isOpenProperty = ElementRegistry.registerProperty("isOpen",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    popupProperty = ElementRegistry.registerProperty("popup",
        PropertyType.UIELEMENT, PropertyFlags.NONE, _popupContentChanged, null);
    dropdownbuttonElementDef = ElementRegistry.register("DropDownButton",
        Button.buttonElementDef, [isOpenProperty, popupProperty], null);
  }
}
