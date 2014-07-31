part of uxml;

/**
 * Implements a button control that toggles a checked state when pressed.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class CheckBox extends Button {
  /** IsChecked property definition */
  static PropertyDefinition isCheckedProperty;
  static ElementDef checkboxElementDef;
  bool _isCheckedValueForMouseDown = false;

  CheckBox() : super() {
  }

  /**
   * Sets/returns checked state.
   */
  bool get isChecked => getProperty(isCheckedProperty);

  set isChecked(bool value) {
    return setProperty(isCheckedProperty, value);
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    _isCheckedValueForMouseDown = isChecked;
    super.onMouseDown(mouseArgs);
  }

  /** Overrides Button.onClick to toggle isChecked state. */
  void onClick(EventArgs e) {
    bool oldValue = isChecked;
    if (oldValue != _isCheckedValueForMouseDown) {
      // If a binding updated isChecked during mouseDown, don't perform
      // toggle. The user's intention is to switch from value prior to
      // mouse down to the inverse. This makes sure we don't toggle
      // again and revert isChecked.
      return;
    }
    isChecked = !isChecked;
    if (isChecked != oldValue) { // Check if isChecked was cancelled when set.
      super.notifyListeners(Button.clickEvent, new EventArgs(this));
    }
    e.handled = true;
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => checkboxElementDef;

  /** Registers component. */
  static void registerCheckBox() {
    CheckBox.isCheckedProperty = ElementRegistry.registerProperty("IsChecked",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    CheckBox.checkboxElementDef = ElementRegistry.register("CheckBox",
        Button.buttonElementDef, [isCheckedProperty], null);
  }
}

