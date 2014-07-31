part of uxml;

/**
 * Implements base functionality for effects and animations.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Action {
  /**
   * Sets/returns if action is reversible.
   */
  bool reversible = true;

  /**
   * To be able to reverse values derived from multiple actions, we
   * need to keep track of a stack of active actions and the reversal values.
   * activeActionMap maps a control to a property dictionary.
   * Each propertyDictionary maps a property to an ActiveActionList.
   */
  static Map<UxmlElement, Map<PropertyDefinition,
      ActiveActionList>> activeActionMap = null;
  Map<UxmlElement, ActionData> dataMap = null;

  Action() {
  }

  /**
   * Starts an action.
   */
  void start(UxmlElement chromeRoot, UxmlElement control) {
  }

  /**
   * Reverses an action.
   */
  void reverse(UxmlElement control) {
  }

  /**
   * Resets an action (if reversible = false).
   */
  void reset(UxmlElement control) {
  }

  /**
   * Returns per instance action data.
   */
  ActionData getActionData(UxmlElement control) {
    if (dataMap == null) {
      dataMap = new Map<UxmlElement,ActionData>();
    }

    ActionData data = dataMap[control];
    if (data == null) {
      data = new ActionData();
      dataMap[control] = data;
    }
    return data;
  }

  /**
   * Returns true if action has been started for the given control.
   */
  bool getIsActive(UxmlElement control) {
    return getActionData(control).actionState == ActionData.ACTION_ACTIVE;
  }

  /**
   * Returns true if action is active and reversing for the given control.
   */
  bool getIsReversing(UxmlElement control) {
    return getActionData(control).actionState == ActionData.ACTION_REVERSE;
  }

  /**
   * Returns an ActiveActionList for element, property tuple.
   */
  static ActiveActionList getActiveActionList(UxmlElement element,
      PropertyDefinition property) {
    if (activeActionMap == null) {
      return null;
    }
    Map<PropertyDefinition, ActiveActionList> listMap =
        activeActionMap[element];
    if (listMap == null) {
      return null;
    }
    return listMap[property];
  }

  /**
   * Creates a new ActiveActionList for an element, property tuple.
   */
  static ActiveActionList createActiveActionList(UxmlElement element,
      PropertyDefinition property) {
    if (activeActionMap == null) {
      activeActionMap = new Map<UxmlElement, Map<PropertyDefinition,
          ActiveActionList>>();
    }
    Map<PropertyDefinition, ActiveActionList> listMap =
        activeActionMap[element];
    if (listMap == null) {
      listMap = new Map<PropertyDefinition, ActiveActionList>();
      activeActionMap[element] = listMap;
    }
    ActiveActionList activeActionList = listMap[property];
    if (activeActionList == null) {
      activeActionList = new ActiveActionList();
      listMap[property] = activeActionList;
    }
    return activeActionList;
  }

  /**
   * Applies a action property value due.
   */
  static void applyPropertyValue(Action action, UxmlElement element,
      PropertyDefinition property, Object value) {
    ActiveActionList activeActionList = getActiveActionList(element, property);
    if (activeActionList == null) {
      activeActionList = createActiveActionList(element, property);
    }
    activeActionList.add(action, element.getProperty(property), value);
    if (value is Brush) {
      // Brush tweener optimizes by reusing same instance, we need to set
      // target to null first to force redraw
      element.setProperty(property, null);
    }
    element.setProperty(property, value);
  }

  /**
   * Reverses property value action.
   */
  void reversePropertyValue(Action action, UxmlElement element,
      PropertyDefinition property) {
    ActiveActionList activeActionList= getActiveActionList(element, property);
    if (activeActionList == null) {
      return;
    }
    activeActionList.remove(action, element, property);
  }
}

/**
 * Keeps track of a list of active actions for a property on an element.
 * When an action is reversed to restore proper value we need to go through
 * list of all active actions.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ActiveActionList {

  List<Action> _actionList;
  List<ActionValues> _valueList;

  ActiveActionList() {
    _actionList = <Action>[];
    _valueList = <ActionValues>[];
  }

  /**
   * Adds an action to active list.
   */
  void add(Action action, oldValue, newValue) {
    int index = _actionList.indexOf(action, 0);
    if (index == -1) {
      _actionList.add(action);
      _valueList.add(new ActionValues(oldValue, newValue));
    } else {
      _valueList[index].newValue = newValue;
    }
  }

  /**
   * Removes a deactivated action.
   */
  void remove(Action action, UxmlElement element, PropertyDefinition property) {
    int index = _actionList.indexOf(action, 0);
    if (index == -1) return;
    ActionValues actionValues = _valueList[index];
    if (index == (_actionList.length - 1)) {
      // removing tail
      Object value = actionValues.oldValue;
      if (value is Brush) {
        // Brush tweener optimizes by reusing same instance, we need to set
        // target to null first to force redraw
        element.setProperty(property, null);
      }
      element.setProperty(property, value);
    } else {
      // we need to propagate oldValue up
      _valueList[index + 1].oldValue = actionValues.oldValue;
    }
    if (_actionList.indexOf(action) >= 0) {
      _actionList.removeAt(_actionList.indexOf(action));
    }
    if (_valueList.indexOf(actionValues) >= 0) {
      _valueList.removeAt(_valueList.indexOf(actionValues));
    }
  }
}

class ActionValues {
  Object oldValue;
  Object newValue;
  ActionValues(Object oldVal, Object newVal) {
    oldValue = oldVal;
    newValue = newVal;
  }
}

/**
 * Holds instance specific data for actions.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ActionData {

  /**
   * Initial inactive state of action.
   */
  static const int ACTION_IDLE = 0;

  /**
   * Action is active.
   */
  static const int ACTION_ACTIVE = 1;

  /**
   * Action is active in reverse.
   */
  static const int ACTION_REVERSE = 2;

  /**
   * Starting value of animation or action.
   */
  Object startValue;

  /**
   * Target element object.
   */
  UxmlElement targetElement = null;

  /**
   * Sets/returns if action is active.
   */
  int actionState = ACTION_IDLE;

  /**
   * Scheduled task.
   */
  ScheduledTask task;

  /**
   * Indicates special case for width/height Nan.
   */
  bool isUndefinedValue;

  /**
   * Tweener instance for optimizing animations.
   */
  Object tweener;

  ActionData();
}
