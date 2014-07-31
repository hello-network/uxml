part of uxml;

/**
 * Implements a property setter declaration for effects
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class PropertyAction extends Action {

  /** Name of target element to animate */
  String target;

  /**
   * Property to set.
   */
  Object property;

  /**
   * Target value of property.
   */
  Object value;

  /**
   * Delay in ms before action is executed.
   */
  int delay = 0;

  PropertyAction() : super() {
  }

  /**
   * Starts the action by scheduling an animation task.
   */
  void start(UxmlElement chromeRoot, UxmlElement control) {
    ActionData data = getActionData(control);
    if (data.actionState != ActionData.ACTION_ACTIVE) {
      data.actionState = ActionData.ACTION_ACTIVE;
      if (delay != 0) {
        Application.current.scheduler.schedule(delay,
            0, _delayedExecute, this, [chromeRoot, control]);
      } else {
        _applyActionValue(chromeRoot, control);
      }
    }
  }

  void _delayedExecute(num tweenValue, Object tag){
    List<Object> tagParts = tag;
    UxmlElement chromeRoot = tagParts[0];
    UxmlElement control = tagParts[1];
    ActionData data = getActionData(control);
    _applyActionValue(chromeRoot, control);
    data.actionState = ActionData.ACTION_IDLE;
  }

  void _applyActionValue(UxmlElement chromeRoot, UxmlElement control) {
    ActionData data = getActionData(control);
    if (target == null) {
      // If target was not specified, the owner itself is the target
      data.targetElement = chromeRoot;
      if (!(data.targetElement is UIElement)) {
        throw new Exception("Invalid targetElement");
      }
    } else {
      // resolve target name. Either id or id.subObject
      if (chromeRoot is UIElement) {
        UIElement uiChromeRoot = chromeRoot;
        if (target.indexOf(".", 0) == -1) {
            data.targetElement = uiChromeRoot.getElement(target);
            if (!(data.targetElement is UxmlElement)) {
              data.targetElement = null;
            }
        } else {
          List<String> targetChain = target.split(".");
          UxmlElement element = uiChromeRoot.getElement(targetChain[0]);
          for (int i = 1; i < targetChain.length; i++) {
            PropertyDefinition propDef = PropertyCache.getPropertyDefinition(
                element.getDefinition(), targetChain[i]);
            element = element.getProperty(propDef);
          }
          data.targetElement = element;
          if (!(data.targetElement is IKeyValue)) {
            throw new Exception("Invalid targetElement");
          }
        }
      }
    }
    if (data.targetElement != null) {
      data.startValue = data.targetElement.getProperty(property);
      Action.applyPropertyValue(this, data.targetElement, property, value);
    }
  }

  /**
   * Resets action to original idle state before starting action or
   * once reversal is complete.
   */
  void reset(UxmlElement control) {
    ActionData data = getActionData(control);
    data.actionState = ActionData.ACTION_IDLE;
  }

  /**
   * Reverses the action.
   */
  void reverse(UxmlElement control) {
    ActionData data = getActionData(control);
    if (data.actionState == ActionData.ACTION_ACTIVE &&
        data.targetElement != null) {
      reversePropertyValue(this, data.targetElement, property);
      data.actionState = ActionData.ACTION_IDLE;
    }
  }
}
