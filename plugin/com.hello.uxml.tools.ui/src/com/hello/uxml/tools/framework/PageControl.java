package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Manages it's children as a collection of pages.
 *
 * When currentPage changes, pageActive property of children that expose
 * a pageKey property that matches currentPage will be set to true.
 *
 * Typically children bind their visibility property to pageActive property to
 * switch their view state.
 *
 * A pageControl controller can listen to previewPageChanged and pageChanged
 * to provide enhanced functionality such as inserting pages on demand.
 *
 * Example:
 * <PageControl currentPage="Topics">
 *   <Canvas PageControl.pageKey="Topics" visible="{PageControl.pageActive}"/>
 *   <DockBox PageControl.pageKey="Groups"...
 * </PageControl>
 *
 * Another option is to define an effect, such as an animation on a control
 * triggered by pageActive=true.
 *
 * @author ferhat
 */
public class PageControl extends Group {

  /** CurrentPage Property Definition */
  public static PropertyDefinition currentPagePropDef = PropertySystem.register("CurrentPage",
      String.class, PageControl.class, new PropertyData("", EnumSet.of(PropertyFlags.None),
      new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ((PageControl) e.getSource()).onPageChanged(((String) e.getNewValue()));
      }}));

  /** Transition property definition */
  public static PropertyDefinition transitionPropDef = PropertySystem.register("Transition",
      String.class, PageControl.class,
      new PropertyData("default", EnumSet.of(PropertyFlags.None)));

  /** PageKey Property Definition */
  public static PropertyDefinition pageKeyPropDef = PropertySystem.register("PageKey",
      String.class, PageControl.class, new PropertyData("", EnumSet.of(PropertyFlags.Attached),
      new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          // find parent page control.
          while (element != null) {
            element = element.getParent();
            if (element instanceof PageControl) {
              break;
            }
          }
          if (element == null) {
            // not parent page control found. noop.
            return;
          }
          boolean isActivePage = ((PageControl) element).getCurrentPage().equals(e.getNewValue());
          setChildPageActive((UIElement) e.getSource(), isActivePage);
        }}));

  /** PageActive Property Definition */
  public static PropertyDefinition pageActivePropDef = PropertySystem.register("PageActive",
      Boolean.class, PageControl.class, new PropertyData("", EnumSet.of(PropertyFlags.Attached),
          null));

  /** PageChanging event definition */
  public static EventDefinition pageChangingEvent = EventManager.register("PageChanging",
      UIElement.class, EventArgs.class);

  /** PageChanged event definition */
  public static EventDefinition pageChangedEvent = EventManager.register("PageChanged",
      UIElement.class, EventArgs.class);

  /**
   * Called when current page changes.
   */
  protected void onPageChanged(String newPage) {
    if (this.hasListener(pageChangingEvent)) {
      notifyListeners(pageChangingEvent, new EventArgs(this, pageChangingEvent));
    }

    for (int i = 0; i < getChildCount(); i++) {
      UIElement child = getChild(i);
      child.setProperty(pageActivePropDef,
        newPage.equals(child.getProperty(pageKeyPropDef)));
    }

    if (this.hasListener(pageChangedEvent)) {
      notifyListeners(pageChangedEvent, new EventArgs(this, pageChangedEvent));
    }
  }

  /**
   * Sets/returns page transition style.
   */
  public String getTransition() {
    return (String) getProperty(transitionPropDef);
  }

  public void setTransition(String name) {
    setProperty(transitionPropDef, name);
  }

  /**
   * Sets child element page active property.
   */
  public static void setChildPageActive(UIElement element, boolean value) {
    element.setProperty(pageActivePropDef, value);
  }

  /**
   * Sets child element page key property.
   */
  public static void setChildPageKey(UIElement element, String key) {
    element.setProperty(pageKeyPropDef, key);
  }

  /**
   * Sets or returns current page.
   */
  public void setCurrentPage(String value) {
    setProperty(currentPagePropDef, value);
  }

  public String getCurrentPage() {
    return (String) getProperty(currentPagePropDef);
  }
}
