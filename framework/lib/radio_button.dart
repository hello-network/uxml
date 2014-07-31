part of uxml;

/**
 * Implements a button control that maintains a mutually exclusive checked
 * state among a group.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class RadioButton extends Button {

  static ElementDef radiobuttonElementDef;
  /** IsChecked property definition */
  static PropertyDefinition isCheckedProperty;
  /**
   * Group property definition. The group name is used as a key to
   * application level dictionary that keeps track of which radio button is
   * currently active among group members.
   */
  static PropertyDefinition groupProperty;
  static Map<String, RadioButton> _activeGroups;

  RadioButton() : super() {
  }

  /**
   * Sets/returns checked state.
   */
  bool get isChecked {
    return getProperty(isCheckedProperty);
  }

  set isChecked(bool value) {
    return setProperty(isCheckedProperty, value);
  }

  /**
   * Sets/returns radio button group name.
   */
  String get group {
    return getProperty(groupProperty);
  }

  set group(String name) {
    setProperty(groupProperty, name);
  }

  /** Overrides Button.onClick. */
  void onClick(EventArgs e) {
    bool prevChecked = isChecked;
    isChecked = true;
    EventArgs clickArgs = new EventArgs(this);
    clickArgs.event = Button.clickEvent;
    clickArgs.source = this;
    super.notifyListeners(Button.clickEvent, clickArgs);
    e.handled = true;
  }

  static void _isCheckedChangeHandler(UIElement target,
                                      PropertyDefinition property,
                                      Object oldValue,
                                      Object newValue) {
    RadioButton button = target;
    button._updateSharedGroupState(newValue);
  }

  static void _groupChangeHandler(UIElement target, PropertyDefinition property,
      Object oldValue, Object newValue) {
    RadioButton button = target;
    button._updateSharedGroupState(button.isChecked);
  }

  void _updateSharedGroupState(bool checked) {
    if (checked) {
      if (_activeGroups.containsKey(group)) {
        RadioButton activeButton = _activeGroups[group];
        if (activeButton != null && (activeButton != this)) {
          activeButton.setProperty(isCheckedProperty, false);
        }
      }
      _activeGroups[group] = this;
    }
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => radiobuttonElementDef;

  /** Registers component. */
  static void registerRadioButton() {
    _activeGroups = new Map<String, RadioButton>();
    isCheckedProperty = ElementRegistry.registerProperty("isChecked",
        PropertyType.BOOL, PropertyFlags.NONE, _isCheckedChangeHandler, false);
    groupProperty = ElementRegistry.registerProperty("group",
        PropertyType.STRING, PropertyFlags.NONE, _groupChangeHandler,
        "default");
    radiobuttonElementDef = ElementRegistry.register("RadioButton",
        Button.buttonElementDef,
        [isCheckedProperty, groupProperty],
        null);
  }
}
