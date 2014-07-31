part of uxml;

/**
 * Manages it's children as a collection of pages.
 *
 * When currentPage changes, pageActive property of children that expose
 * a pageKey property that matches currentPage will be set to true.
 *
 * Typically children bind their visibility property to pageActive property to
 * switch their view state if ViewTransition is NONE. This is automatically
 * done by PageControl for ViewTransition.DEFAULT.
 *
 * A pageControl controller can listen to pageChanging and pageChanged events
 * to provide enhanced functionality such as inserting pages on demand.
 *
 * Example:
 * <PageControl currentPage="Topics">
 *   <Canvas PageControl.pageKey="Topics" visible="{PageControl.pageActive}"/>
 *   <DockBox PageControl.pageKey="Groups"...
 * </PageControl>
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class PageControl extends Group {

  static ElementDef pagecontrolElementDef;
  static PropertyDefinition currentPageProperty;
  static PropertyDefinition transitionProperty;
  static PropertyDefinition pageKeyProperty;
  static PropertyDefinition pageActiveProperty;
  static EventDef pageChangingEvent;
  static EventDef pageChangedEvent;

  /**
   * Called when current page changes.
   */
  void onPageChanged(String newPage) {
    if (hasListener(pageChangingEvent)) { // check so we dont' alloc EventArgs
      notifyListeners(pageChangingEvent, new EventArgs(this));
    }

    String t = transition;
    for (int i = 0; i < childCount; i++) {
      UIElement child = childAt(i);
      bool isPageActive = child.getProperty(pageKeyProperty) == newPage;
      child.setProperty(pageActiveProperty, isPageActive);
      switch (t) {
        case ViewTransition.DEFAULT:
          child.visible = isPageActive;
          break;
        case ViewTransition.CROSS_FADE:
          child.animate(UIElement.opacityProperty, isPageActive ? 1.0 : 0.0);
          break;
        default:
          break;
      }
    }

    if (hasListener(pageChangedEvent)) { // check so we dont' alloc EventArgs
      notifyListeners(pageChangedEvent, new EventArgs(this));
    }
  }

  static void _currentPageChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    PageControl pc = target;
    pc.onPageChanged(newValue);
  }

  static void _pageKeyChangedHandler(Object target, Object property,
      Object oldValue, Object newValue) {
    UIElement element = target;
    // find parent page control.
    while (element != null) {
      element = element.parent;
      if (element is PageControl) {
        break;
      }
    }
    if (element == null) {
      // not parent page control found. noop.
      return;
    }
    if (element is PageControl) {
      PageControl pc = element;
      bool isPageActive = (pc.currentPage == newValue);
      setChildPageActive(target, isPageActive);
    }
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    String t = transition;
    String curPage = currentPage;
    if (t != ViewTransition.NONE) {
      for (int i = 0; i < childCount; i++) {
        UIElement child = childAt(i);
        bool isPageActive = child.getProperty(pageKeyProperty) == curPage;
        child.setProperty(pageActiveProperty, isPageActive);
        switch (t) {
          case ViewTransition.DEFAULT:
            child.visible = isPageActive;
            break;
          case ViewTransition.CROSS_FADE:
            child.opacity = isPageActive ? 1.0 : 0.0;
            break;
          default:
            break;
        }
      }
    }
  }

  /**
   * Sets child element page active property.
   */
  static void setChildPageActive(UIElement element, bool value) {
    element.setProperty(pageActiveProperty, value);
  }

  /**
   * Sets child element page key property.
   */
  static void setChildPageKey(UIElement element, String key) {
    element.setProperty(pageKeyProperty, key);
  }

  /**
   * Sets or returns current page.
   */
  set currentPage(String value) {
    setProperty(currentPageProperty, value);
  }

  String get currentPage => getProperty(currentPageProperty);

  /**
   * Sets or returns view transition.
   */
  set transition(String value) {
    setProperty(transitionProperty, value);
  }

  String get transition => getProperty(transitionProperty);

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => pagecontrolElementDef;

  /** Registers component. */
  static void registerPageControl() {
    currentPageProperty = ElementRegistry.registerProperty("currentPage",
        PropertyType.STRING, PropertyFlags.NONE, _currentPageChangedHandler,
        "");
    transitionProperty = ElementRegistry.registerProperty("transition",
        PropertyType.INT, PropertyFlags.NONE, null, ViewTransition.DEFAULT);
    pageKeyProperty = ElementRegistry.registerProperty("pageKey",
        PropertyType.STRING, PropertyFlags.NONE, _pageKeyChangedHandler, "");
    pageActiveProperty = ElementRegistry.registerProperty("pageActive",
        PropertyType.BOOL, PropertyFlags.ATTACHED, null, false);
    pageChangingEvent = new EventDef("PageChanging", Route.DIRECT);
    pageChangedEvent = new EventDef("PageChanged", Route.DIRECT);
    pagecontrolElementDef = ElementRegistry.register("PageControl",
        Group.groupElementDef, [currentPageProperty, transitionProperty,
        pageKeyProperty, pageActiveProperty], [pageChangingEvent,
        pageChangedEvent]);
  }
}

/** Defines transition  constants. */
abstract class ViewTransition {
  // No action is taken for transition other than setting activation related
  // property on view.
  static const String NONE = "none";
  // Default transition sets visible property of children.
  static const String DEFAULT = "default";
  // Cross fade transition.
  static const String CROSS_FADE = "crossfade";
}
