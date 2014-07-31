package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Manages a command and associated event routing. Implements command
 * pattern (http://en.wikipedia.org/wiki/Command_pattern) for framework.
 *
 * @author ferhat
 */
public class Command extends UxmlElement {

  private String id;

  /** Click event definition */
  public static EventDefinition commandEvent = EventManager.register(
      "Command", UIElement.class, CommandEventArgs.class, UIElement.class, null);

  /** Enabled property definition */
  public static PropertyDefinition enabledPropDef = PropertySystem.register("Enabled",
      Boolean.class, UIElement.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  public Command() {
    id = "";
  }

  public Command(String commandId) {
    id = commandId;
  }

  /** Returns id of command. */
  @Override
  public String getId() {
    return id;
  }

  /** Sets or returns whether command is enabled. */
  public void setEnabled(boolean val) {
    setProperty(enabledPropDef, val);
  }

  public boolean getEnabled() {
    return ((Boolean) getProperty(enabledPropDef)).booleanValue();
  }

  public void execute(EventArgs e, Object param) {
    CommandEventArgs data = new CommandEventArgs(this, e.getSource(), param);
    data.setEvent(commandEvent);
    if (e.getSource() instanceof UxmlElement) {
      ((UxmlElement) e.getSource()).notifyListeners(commandEvent, data);
    }
    notifyListeners(commandEvent, data);
  }
}
