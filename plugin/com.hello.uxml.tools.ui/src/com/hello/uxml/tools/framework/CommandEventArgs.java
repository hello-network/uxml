package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;

/**
 * Defines command event arguments.
 *
 * @author ferhat
 */
public class CommandEventArgs extends EventArgs {

  private Command cmd;
  private Object params;

  /**
   * Constructor.
   */
  public CommandEventArgs(Command command, Object source, Object parameters) {
    this.source = source;
    params = parameters;
    cmd = command;
  }

  /**
   * Gets or sets the data of the event.
   */
  public Command getCommand() {
    return cmd;
  }

  /** Sets or returns parameters of command. */
  public void setParameters(Object parameters) {
    this.params = parameters;
  }

  public Object getParameters() {
    return params;
  }
}
