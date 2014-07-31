part of uxml;

/**
 * Manages a command and associated event routing. Implements command
 * pattern (http://en.wikipedia.org/wiki/Command_pattern) for framework.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Command extends UxmlElement {

  static ElementDef commandElementDef;
  /** Command event definition */
  static EventDef commandEvent = null;

  /** Enabled property */
  static PropertyDefinition enabledProperty = null;

  Command(String commandId) {
    id = commandId;
  }

  /**
   * Walks up view tree and sends command event to each view node and
   * finally executes listeners on command instance.
   *
   * sourceEvent contains the initial event such input events that triggered
   * the command.
   */
  void execute(EventArgs sourceEvent, [Object params = null]) {
    CommandEventArgs cmdArgs = new CommandEventArgs(this,
        sourceEvent.source, params);
    cmdArgs.event = commandEvent;
    if (sourceEvent.source is UIElement) {
      UIElement viewNode = sourceEvent.source;
      viewNode.routeEvent(cmdArgs);
    }
    notifyListeners(commandEvent, cmdArgs);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => commandElementDef;

  /** Registers component. */
  static void registerCommand() {
    commandEvent = new EventDef("Command", Route.BUBBLE);
    enabledProperty = ElementRegistry.registerProperty("enabled",
        PropertyType.BOOL, PropertyFlags.NONE, null, true);
    commandElementDef = ElementRegistry.register("Command",
      null, [enabledProperty], [commandEvent]);
  }
}

/**
 * Defines command event arguments.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class CommandEventArgs extends EventArgs {

  Command _cmd;
  /** Sets or returns command parameters. */
  Object parameters = null;

  CommandEventArgs(Command command, Object source, Object params) :
      super(source) {
    _cmd = command;
    parameters = params;
  }

  /** Returns command. */
  Command get command => _cmd;
}
