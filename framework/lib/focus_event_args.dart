part of uxml;

/**
 * Defines focus event arguments.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class FocusEventArgs extends EventArgs {

  UIElement _oldElement;
  UIElement _newElement;

  /**
   * Constructor
   */
  FocusEventArgs(UIElement oldElement,
                 UIElement newElement) : super(Application.focusManager) {
    _oldElement = oldElement;
    _newElement = newElement;
  }

  /**
   * Returns element that is loosing focus.
   */
  UIElement get oldElement {
    return _oldElement;
  }

  set oldElement(UIElement value) {
    _oldElement = value;
  }

  /**
   * Returns element that received focus.
   */
    UIElement get newElement {
    return _newElement;
  }

  set newElement(UIElement value) {
    _newElement = value;
  }
}
