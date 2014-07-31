package com.hello.uxml.tools.framework.events;

/**
 * Provides base class for event arguments.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class EventArgs {

  /** Set if event was handled during routing */
  protected boolean handled;

  /** Used to expose source event definition to handlers */
  protected EventDefinition eventDef;

  /** The object that fired this event. */
  protected Object source;

  /**
   * Constructor.
   */
  public EventArgs() {
  }

  /**
   * Constructor.
   */
  public EventArgs(Object source, EventDefinition eventDef) {
    this.source = source;
    this.eventDef = eventDef;
  }

  /**
   * Sets or returns if an event was handled.
   */
  public boolean getHandled() {
    return handled;
  }

  public void setHandled(boolean value) {
    handled = value;
  }

  /**
   * Sets or returns event definition
   */
  public EventDefinition getEvent() {
    return eventDef;
  }

  public void setEvent(EventDefinition event) {
    eventDef = event;
  }

  /**
   * Gets or sets the source of the event.
   */
  public Object getSource() {
    return source;
  }

  public void setSource(Object value) {
    source = value;
  }
}
