package com.hello.uxml.tools.framework.effects;

import com.hello.uxml.tools.framework.UxmlElement;

import java.util.HashMap;
import java.util.Map;

/**
 * Implements base class for chrome effect actions.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Action {
  protected boolean reversible = false;
  protected Map<UxmlElement, ActionData> dataMap;
  /**
   * Starts the action.
   */
  public void start(UxmlElement chromeRoot, UxmlElement control) {
  }

  /**
   * Reverses the action.
   */
  public void reverse(UxmlElement control) {
  }

  /**
   * Sets or returns weather action is reversible.
   */
  public void setReversible(boolean value) {
    reversible = value;
  }

  public boolean getReversible() {
    return reversible;
  }

  /**
   * Returns true if action has been started for the given control.
   */
   public boolean getIsActive(UxmlElement control) {
     int state = getActionData(control).actionState;
     return state == ActionData.ACTION_ACTIVE;
   }

  /**
   * Returns per instance action data.
   */
  protected ActionData getActionData(UxmlElement control) {
     if (dataMap == null) {
       dataMap = new HashMap<UxmlElement, Action.ActionData>();
     }

     ActionData data = dataMap.get(control);
     if (data == null) {
       data = new ActionData();
       dataMap.put(control, data);
     }
     return data;
  }

  /**
   * Keeps track of action state.
   */
  protected static class ActionData {
    public static final int ACTION_IDLE = 0;
    public static final int ACTION_ACTIVE = 1;
    public static final int ACTION_REVERSE = 0;

    /** Value of property before action is started */
    private Object startValue;
    /** Target element object. */
    private UxmlElement targetElement;
    /** Current state of action */
    private int actionState;
    /** Indicates special case for double propdefs with Nan value */
    private boolean isUndefinedValue;

    /**
     * Constructor.
     */
    public ActionData() {
    }

    /**
     * Sets or returns start value of property.
     */
    public Object getStartValue() {
      return startValue;
    }

    public void setStartValue(Object value) {
      startValue = value;
    }

    /**
     * Sets or returns targetElement.
     */
    public UxmlElement getTargetElement() {
      return targetElement;
    }

    public void setTargetElement(UxmlElement element) {
      targetElement = element;
    }

    /**
     * Sets or returns action state.
     */
    public int getActionState() {
      return actionState;
    }

    public void setActionState(int state) {
      actionState = state;
    }

    /**
     * Sets or returns undefinedValue state.
     */
    public void setIsUndefinedValue(boolean isUndefined) {
      isUndefinedValue = isUndefined;
    }

    public boolean getIsUndefinedValue() {
      return isUndefinedValue;
    }
  }
}
