part of uxml;

/**
 * Provides base class for controller for MVC framework.
 *
 * @author:ferhat@ (Ferhat Buyukkokten)
 */
class Controller extends UxmlElement {
  static ElementDef controllerElementDef = null;
  /** Controller Property Definition */
  static PropertyDefinition controllerProperty;
  EventHandler _viewInitHandler = null;
  EventHandler _viewClosedHandler = null;

  /**
   * Holds reference to view.
   */
  UIElement _attachedView;

  /**
   * Holds bindings for this elements properties.
   */
  List<Object> bindings;

  Controller(UIElement view) : super() {
    bindings = [];
    _attachedView = view;
    view.setProperty(Controller.controllerProperty, this);
    _viewClosedHandler = onViewClosed;
    view.addListener(UIElement.closedEvent, _viewClosedHandler);
    _viewInitHandler = onViewInitialized;
    view.addListener(Controller.controllerProperty, _viewInitHandler);
  }

  /**
   * Returns attached view.
   */
  UIElement get view => _attachedView;

  /**
   * Returns controller of element.
   */
  static getTargetController(UIElement element) {
    return element.getProperty(Controller.controllerProperty);
  }

  /**
   * Sets controller of element.
   */
  static setTargetController(UIElement element, Controller controller) {
    element.setProperty(Controller.controllerProperty, controller);
  }

  /**
   * Called on chrome controllers before the element tree is assigned.
   */
  void preInit() {
  }

  /**
   * Called by view when initialization is complete.
   */
  void initCompleted() {
  }

  /**
   * Called when view's surface is initialized.
   */
  void viewInitialized() {
  }

  /**
   * Called when view is closed. Override this to perform cleanup.
   */
  void close() {
    if (_attachedView != null) {
      _attachedView.clearProperty(Controller.controllerProperty);
    }
    if (_viewInitHandler != null) {
      view.removeListener(Controller.controllerProperty, _viewInitHandler);
      _viewInitHandler = null;
    }
  }

  /**
   * Responds to view close event.
   */
  void onViewClosed(EventArgs event) {
    _attachedView.removeListener(UIElement.closedEvent, _viewClosedHandler);
    close();
  }

  /**
   * Responds to view surface initialized event.
   */
  void onViewInitialized(EventArgs event) {
    if (_viewInitHandler != null) {
      view.removeListener(Controller.controllerProperty, _viewInitHandler);
      _viewInitHandler = null;
    }
    viewInitialized();
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => controllerElementDef;

  /** Registers component. */
  static void registerController() {
    Controller.controllerProperty = ElementRegistry.registerProperty(
        "controller", PropertyType.OBJECT,
        PropertyFlags.ATTACHED | PropertyFlags.INHERIT, null, null);
    controllerElementDef = ElementRegistry.register(
        "Controller",
        UxmlElement.baseElementDef,
        [Controller.controllerProperty], null);
  }
}
