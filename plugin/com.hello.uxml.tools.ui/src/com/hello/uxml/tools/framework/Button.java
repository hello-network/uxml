package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.events.MouseEventArgs;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Implements button control.
 *
 * @author ferhat
 */
public class Button extends ContentContainer {
  private static final int HITTEST_MODE_BOUNDS = 1;

  /** IsPressed property definition */
  public static PropertyDefinition isPressedPropDef = PropertySystem.register("IsPressed",
      Boolean.class, Button.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** ClickWhenPressed property definition */
  public static PropertyDefinition clickWhenPressedPropDef = PropertySystem.register(
      "ClickWhenPressed", Boolean.class, Button.class,
          new PropertyData(false));

  /** UpdateFocusOnMouseDown property definition */
  public static PropertyDefinition updateFocusOnMouseDownPropDef = PropertySystem.register(
      "UpdateFocusOnMouseDown", Boolean.class, Button.class,
          new PropertyData(true));

  /** RepeatRate property definition */
  public static PropertyDefinition repeatRatePropDef = PropertySystem.register(
      "RepeatRate", Integer.class, Button.class,
          new PropertyData(0));

  /** RepeatDelay property definition */
  public static PropertyDefinition repeatDelayPropDef = PropertySystem.register(
      "RepeatDelay", Integer.class, Button.class,
          new PropertyData(250));

  /** Click event definition */
  public static EventDefinition clickEvent = EventManager.register(
      "Click", Button.class, EventArgs.class, Button.class, null);

  @Override
  public void initSurface(UISurface parentSurface) {
    super.initSurface(parentSurface);
    hostSurface.setHitTestMode(HITTEST_MODE_BOUNDS);
  }

  /**
   * Returns whether button is in pressed down state.
   */
  public boolean getIsPressed() {
    return (Boolean) getProperty(isPressedPropDef);
  }

  @Override
  protected void onMouseDown(MouseEventArgs e) {
    e.setHandled(true);
    captureMouse();
    setProperty(isPressedPropDef, true);
  }

  @Override
  protected void onMouseUp(MouseEventArgs e) {
    e.setHandled(true);
    setProperty(isPressedPropDef, false);
    releaseMouse();
    if (getIsMouseOver()) {
      onMouseClick(e);
    }
  }

  protected void onMouseClick(MouseEventArgs e) {
    EventArgs clickArgs = new EventArgs(this, clickEvent);
    routeEvent(clickArgs);
  }
}
