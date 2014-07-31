package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.EnumSet;

/**
 * Provides base class for MVC controllers.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Controller extends UxmlElement {

  protected UIElement view;

  /** Controller Property Definition */
  public static PropertyDefinition controllerPropDef = PropertySystem.register("Controller",
      Controller.class, Controller.class, new PropertyData(null, EnumSet.of(PropertyFlags.Attached,
          PropertyFlags.Inherit)));

  /**
   * Constructor.
   */
  public Controller(UIElement view) {
    this.view = view;
    view.setProperty(controllerPropDef, this);
    view.addListener(UIElement.closedEvent, new EventHandler() {
        @Override
        public void handleEvent(EventNotifier targetObject, EventArgs e) {
          Controller controller = Controller.getTargetController((UxmlElement) targetObject);
          controller.close();
        }
    });
  }

  /**
   * Returns view being controlled.
   */
  public UIElement getView() {
    return view;
  }

  /**
   * Called on chrome controllers before the element tree is assigned.
   */
  public void preInit() {
  }

  /**
   * Provides override that is called after view initialization is complete.
   */
  public void initCompleted() {
  }

  /**
   * Called when view is closed. Override this to perform cleanup.
   */
  protected void close() {
  }

  /**
   * Returns controller of element.
   */
   public static Controller getTargetController(UxmlElement element) {
     return (Controller) element.getProperty(controllerPropDef);
   }

   /**
    * Returns controller of EventNotifier.
    */
    public static Controller getTargetController(EventNotifier element) {
      return (Controller) ((UxmlElement) element).getProperty(controllerPropDef);
    }

   /**
    * Sets controller of element.
    */
   public static void setTargetController(UxmlElement element, Controller controller) {
     element.setProperty(controllerPropDef, controller);
   }
}
