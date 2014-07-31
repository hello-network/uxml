package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.MouseEventArgs;
import com.hello.uxml.tools.framework.graphics.HitTestResult;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Provides access to application level resources.
 *
 * @author ferhat
 */
public class Application extends UxmlElement {

  /** Holds currently running application instance */
  private static Application currentApp;

  /** Platform specific container object. */
  private Object container;

  /** Root element of application */
  protected OverlayContainer rootElement;

  /** Root surface of application */
  protected UISurface rootSurface;

  /** Shared resources of application */
  private Resources resources;

  /** Maps a radio button group name to active button to implement
   * mutual exclusivity of IsChecked state.
   */
  private Map<String, UIElement> radioGroups = new HashMap<String, UIElement>();

  private static UIElement mouseCaptureTarget;
  // Reusable event argument.
  private static MouseEventArgs mouseArgs = new MouseEventArgs();
  // Reusable hit-test object.
  private static HitTestResult hitTestResult = new HitTestResult();
  // List of elements that have mouseOver set.
  private static List<UIElement> mouseOverList = new ArrayList<UIElement>();

  private static final Logger logger = Logger.getLogger(Application.class.getName());

  /**
   * Instance map is used to force propdef registration prior to calling getPropertyDefinitions.
   */
  protected static Set<Class<?>> classLoaded = new HashSet<Class<?>>();

  /**
   * Constructor.
   */
  public Application() {
    currentApp = this;
  }

  /** Returns current running application. */
  public static Application getCurrent() {
    return currentApp;
  }
  /**
   * Sets/returns platform specific container.
   */
  protected void setContainer(Object container) {
    this.container = container;
  }

  protected Object getContainer() {
    return container;
  }

  /**
   * Returns platform UISurface
   */
  public UISurface createSurface() {
    return null;
  }

  /**
   * Sets root element of application.
   */
  @ContentNode
  public void setContent(UIElement element) {
    if (rootElement != null) {
      rootElement.close();
    }
    rootElement = new OverlayContainer();
    rootElement.setContent(element);
    if ((rootElement != null) && (container != null)) {
      hostContent();
    }
  }

  /**
   * Returns root element of application.
   */
  public UIElement getContent() {
    return rootElement == null ? null : (UIElement) rootElement.getContent();
  }

  /**
   * Prepare content surface (override in subclass to attach surface implementation)
   */
  protected void hostContent() {
  }

  /**
   * Returns resources collection.
   */
  public Resources getResources() {
    if (resources == null) {
      resources = new Resources();
    }
    return resources;
  }

  /**
   * Returns application level resource.
   */
  public static Object findResource(String key) {
    return findResource(key, null);
  }

  /**
   * Returns application level resource.
   */
  public static Object findResource(String key, String interfaceName) {
    Resources resources = getCurrent().resources;
    if (resources == null) {
      return null;
    }
    if (interfaceName == null) {
      return resources.getResource(key);
    }
    Resources intf = (Resources) resources.getResource(interfaceName);
    return (intf == null) ? null : intf.findResource(key);
  }

  /**
   * Returns application level resource.
   */
  public static Object findResource(Class<?> classKey) {
    return (getCurrent().resources != null) ? getCurrent().resources.getResource(
        classKey) : null;
  }

  /**
   * Platform specific override to re-layout root application element
   */
  protected void relayoutRoot() {
  }

  /**
   * Platform override for mouse capture.
   */
  protected void setMouseCapture(UIElement target) {
    mouseCaptureTarget = target;
  }

  /**
   * Platform override for mouse capture.
   */
  protected void releaseMouseCapture() {
    mouseCaptureTarget = null;
  }

  /**
   * Platform surface hit test override.
   */
  protected boolean hitTestSurface(double mouseX, double mouseY, HitTestResult hitResult) {
    return (rootSurface != null) ? rootSurface.hitTest(mouseX, mouseY, hitResult) : false;
  }

  /**
   * Sends a left mouse button event to application.
   * @param element Target element
   * @param mouseX Mouse coordinate
   * @param mouseY Mouse coordinate
   * @param eventDef Mouse event definition
   */
  public void sendMouseEvent(UIElement element, float mouseX, float mouseY,
      EventDefinition eventDef) {
    int mouseEventType;
    if (eventDef == UIElement.mouseDownEvent) {
      mouseEventType = MouseEventArgs.MOUSE_DOWN;
    } else if (eventDef == UIElement.mouseUpEvent) {
      mouseEventType = MouseEventArgs.MOUSE_UP;
    } else if (eventDef == UIElement.mouseMoveEvent) {
      mouseEventType = MouseEventArgs.MOUSE_MOVE;
    } else {
      logger.log(Level.WARNING, "Invalid event definition in call to sendMouseEvent");
      return;
    }
    Point mouseP = element.localToScreen(new Point(mouseX, mouseY));
    routeMouseEvent(mouseP.x, mouseP.y, MouseEventArgs.LEFT_BUTTON,
        mouseEventType, eventDef);
  }

  /**
   * Routes mouse event to UIElements
   * @param mouseX Absolute x-axis coordinate of mouse location
   * @param mouseY Absolute x-axis coordinate of mouse location
   * @param mouseButton Mouse button pressed
   * @param mouseEventType Mouse event type enumeration
   * @param eventDef UIElement mouse event definition
   * @return true if event was handled
   */
  protected boolean routeMouseEvent(double mouseX, double mouseY, int mouseButton,
      int mouseEventType, EventDefinition eventDef) {
    UIElement targetElement = null;
    if (mouseCaptureTarget != null) {
      targetElement = mouseCaptureTarget;
    } else {
      if (rootSurface != null && rootSurface.hitTest(mouseX, mouseY, hitTestResult)) {
        targetElement = hitTestResult.getTarget();
      }
    }

    boolean eventWasHandled = false;

    // Manage mouse enter/exit list.
    // For each item in watch list, if mouse is not over the item anymore
    // call onMouseExit.
    int mouseOverListCount = mouseOverList.size();
    for (int m = mouseOverListCount - 1; m >= 0; --m) {
      UIElement element = mouseOverList.get(m);
      if (!element.hitTestBoundingBox(mouseX, mouseY)) {
        element.setProperty(UIElement.isMouseOverPropDef, false);
        mouseOverList.remove(m);
      }
    }

    // For targetElement and all parents call onMouseEnter if item is not already
    // in watch list
    UIElement element = targetElement;
    while (element != null) {
      if (!mouseOverList.contains(element)) {
        if (element.hitTestBoundingBox(mouseX, mouseY)) {
          mouseOverList.add(element);
          element.setProperty(UIElement.isMouseOverPropDef, true);
        }
      }
      element = element.getParent();
    }

    // Route event to target
    if (targetElement != null) {
      mouseArgs.reset();
      mouseArgs.setEvent(eventDef);
      mouseArgs.setButton(mouseButton);
      mouseArgs.setSource(targetElement);
      mouseArgs.setEventType(mouseEventType);
      mouseArgs.setMousePosition(mouseX, mouseY);
      targetElement.routeEvent(mouseArgs);
      eventWasHandled = mouseArgs.getHandled();
    }
    UpdateQueue.flush();
    return eventWasHandled;
  }

  /**
   * Returns active radio button in a group.
   */
  UIElement getRadioButton(String groupName) {
    return radioGroups.get(groupName);
  }

  /**
   * Sets active radio button for a group.
   */
  void setRadioButton(String groupName, UIElement button) {
    radioGroups.put(groupName, button);
  }

  /**
   * Returns root surface.
   */
  public UISurface getRootSurface() {
    return rootSurface;
  }

  /**
   * Closes application and releases resources.
   */
  public void shutdown() {
    setContent(null);
  }

  /**
   * Reads a key value from object. Needs to be implemented for each
   * platform (GWT doesn't support reflection, but using JSNI works well...).
   */
  protected Object readDynamicValue(Object source, String keyName) {
    return null;
  }

  /**
   * Writes a value using key to object.
   */
  protected void writeDynamicValue(Object source, String keyName, Object value) {
  }

  /**
   * Verifies that a class has been loaded. Classes have to be loaded for
   * PropertyDefinitions to be registered.
   */
  public boolean verifyClassLoaded(Class<? extends UxmlElement> ownerClass) {
    try {
      ownerClass.newInstance();
      return true;
    } catch (IllegalAccessException e) {
      return false;
    } catch (InstantiationException e) {
      return false;
    }
  }

  /**
   * Calls an eventhandler dynamically.
   */
  public void callListener(Object targetObject, String keyPath) {
  }

  public void trace(String message) {
  }
}
