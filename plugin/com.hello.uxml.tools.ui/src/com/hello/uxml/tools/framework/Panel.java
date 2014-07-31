package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.events.MouseEventArgs;

import java.util.EnumSet;

/**
 * Implements a container that provides windowing services.
 *
 * @author ferhat
 */
public class Panel extends ContentContainer {

  /** ViewState constant for normal view */
  public static final int VIEW_STATE_NORMAL = 0;

  /** ViewState constant for maximized view */
  public static final int VIEW_STATE_MAXIMIZED = 1;

  /** ViewState constant for maximized view */
  public static final int VIEW_STATE_MINIMIZED = 2;

  /**
   * Standard framework id for maximize button.
   */
   public static final String MAXIMIZE_BUTTON_ID = "maximizePanelButton";

   /**
    * Standard framework id for minimize button.
    */
   public static final String MINIMIZE_BUTTON_ID = "minimizePanelButton";

   /**
   * Standard framework id for maximize button chrome.
   */
   public static final String MAXIMIZE_CHROME_ID = "maximizePanelChrome";

   /**
   * Standard framework id for maximize button chrome.
   */
   public static final String MINIMIZE_CHROME_ID = "minimizePanelChrome";

  /** Title Property Definition */
  public static PropertyDefinition titlePropDef = PropertySystem.register("Title",
      String.class,
      Panel.class,
      new PropertyData("", EnumSet.of(PropertyFlags.None, PropertyFlags.Localizable)));

  /** ViewState Property Definition */
  public static PropertyDefinition viewStatePropDef = PropertySystem.register("ViewState",
      Integer.class,
      Panel.class,
      new PropertyData(VIEW_STATE_NORMAL, EnumSet.of(PropertyFlags.None)));

  /** MaximizeEnabled Property Definition */
  public static PropertyDefinition maximizeEnabledPropDef = PropertySystem.register(
      "MaximizeEnabled", Boolean.class, Panel.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /** MinimizeEnabled Property Definition */
  public static PropertyDefinition minimizeEnabledPropDef = PropertySystem.register(
      "MinimizeEnabled", Boolean.class, Panel.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /** MoveEnabled Property Definition */
  public static PropertyDefinition moveEnabledPropDef = PropertySystem.register(
      "MoveEnabled", Boolean.class, Panel.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /** Panel moved event definition */
  public static EventDefinition movedEvent = EventManager.register(
      "Moved", Panel.class, EventArgs.class, Panel.class, null);

  private EventArgs movedEventArgs = null;
  private boolean isMousePressed = false;
  private Point mouseDelta;

  /** Sets or returns title of panel */
  public String getTitle() {
    return (String) getProperty(titlePropDef);
  }

  public void setTitle(String title) {
    setProperty(titlePropDef, title);
  }

  /** Sets or returns view state */
  public int getViewState() {
    return ((Integer) getProperty(viewStatePropDef)).intValue();
  }

  public void setViewState(int viewState) {
    setProperty(viewStatePropDef, viewState);
  }

  /**
   * Sets or returns whether panel can be maximized.
   */
  public void setMaximizeEnabled(boolean value) {
    setProperty(maximizeEnabledPropDef, value);
  }

  public boolean getMaximizeEnabled() {
     return ((Boolean) getProperty(maximizeEnabledPropDef)).booleanValue();
  }

  /**
   * Sets or return if panel can be moved with mouse.
   */
  public void setMoveEnabled(boolean value) {
    setProperty(moveEnabledPropDef, value);
  }

  public boolean getMoveEnabled() {
    return ((Boolean) getProperty(moveEnabledPropDef)).booleanValue();
  }

  /**
   * Sets or returns whether panel can be minimized.
   */
  public void setMinimizeEnabled(boolean value) {
    setProperty(maximizeEnabledPropDef, value);
  }

  public boolean getMinimizeEnabled() {
     return ((Boolean) getProperty(minimizeEnabledPropDef)).booleanValue();
  }

  /**
   * Restore panel view.
   */
  public void restore() {
    setViewState(VIEW_STATE_NORMAL);
  }

  /**
   * Maximizes panel view.
   */
  public void maximize() {
    setViewState(VIEW_STATE_MAXIMIZED);
  }

  /**
   * Minimizes panel view.
   */
  public void minimize() {
    setViewState(VIEW_STATE_MINIMIZED);
  }

  @Override
  protected void onMouseDown(MouseEventArgs e) {
    if (getMoveEnabled()) {
      captureMouse();
      mouseDelta = e.getMousePosition(this);
      isMousePressed = true;
      e.setHandled(true);
    }
  }

  @Override
  protected void onMouseMove(MouseEventArgs e) {
    if (isMousePressed) {
      Point mousePosition = e.getMousePosition((UIElement) this.parent);
      Canvas.setChildLeft(this, mousePosition.x - mouseDelta.x);
      Canvas.setChildTop(this, mousePosition.y - mouseDelta.y);
      if (movedEventArgs == null) {
        movedEventArgs = new EventArgs(this, movedEvent);
        notifyListeners(movedEvent, movedEventArgs);
      }
    }
  }
}
