package com.hello.uxml.tools.framework.utils;

import com.hello.uxml.tools.framework.Button;
import com.hello.uxml.tools.framework.Canvas;
import com.hello.uxml.tools.framework.Chrome;
import com.hello.uxml.tools.framework.Margin;
import com.hello.uxml.tools.framework.Panel;
import com.hello.uxml.tools.framework.PropertyChangedEvent;
import com.hello.uxml.tools.framework.PropertyData;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.PropertyFlags;
import com.hello.uxml.tools.framework.PropertySystem;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UIElementContainer;
import com.hello.uxml.tools.framework.UpdateQueue;
import com.hello.uxml.tools.framework.effects.Action;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Manages view state transitions for a group of Panels.
 * When a panel is maximized, other panels will be faded out by default
 * and restored when panel switches to normal or minimized states.
 *
 * The desktop is typically a canvas to allow free drag/drop of panels.
 * To provide custom layout of panels, subclass and override buildLayout
 * to change panel locations.
 *
 * @author ferhat
 */
public class PanelManager extends EventNotifier {

  // Holds list of panels managed
  protected ArrayList<Panel> panels = new ArrayList<Panel>();
  protected UIElementContainer desktop;

  // This flag is set if .add/remove or viewStateChange causes a
  // a single panel to enter maximized state.
  protected boolean hasMaximizedPanel = false;

  // Animation action to reverse for restoring normal state
  private ArrayList<Action> restoreActions = new ArrayList<Action>();

  // Holds layout information on a panel before it was maximized.
  protected HashMap<UIElement, PanelLayoutData> preMaxLayout = new HashMap<UIElement,
      PanelLayoutData>();

  // Maps panel to target layout data. calling applylayout will
  // start animating panels from current state to target.
  protected HashMap<UIElement, PanelLayoutData> targetLayout = new HashMap<UIElement,
      PanelLayoutData>();
  protected HashMap<UIElement, Integer> animationSetting = new HashMap<UIElement, Integer>();

  /**
  * Sets/returns margins of panels inside desktop.
  */
  public Margin margins = Margin.EMPTY;

  // Number of panel layout updates used for triggering animation.
  private HashMap<UIElement, Integer> updateCount = new HashMap<UIElement, Integer>();

  /** PanelAnimation Property Definition */
  public static PropertyDefinition panelAnimationPropDef =
    PropertySystem.register("PanelAnimation", Integer.class, Panel.class,
      new PropertyData(PropertyFlags.Attached));

  private EventHandler hostedPodViewStateHandler;
  private EventHandler desktopLayoutChangedHandler;

  /**
  * Effect constant for fade transition.
  */
  public static final int FADE = 1;

  /**
   * Effect constant for zoom transition.
   */
  public static final int ZOOM = 2;
  // TODO(ferhat): implement animations
  // private static final int FADE_DURATION = 100;
  // private static final int LAYOUT_ANIM_DURATION = 400;
  // private static final double ZOOM_START_FACTOR = 0.7;

  /**
   * Constructor.
   */
  public PanelManager() {
    hostedPodViewStateHandler = new EventHandler() {
      @Override
      public void handleEvent(EventNotifier targetObject, EventArgs e) {
        hostedPodViewStateChanged((PropertyChangedEvent) e);
      }};

    desktopLayoutChangedHandler = new EventHandler() {
      @Override
      public void handleEvent(EventNotifier targetObject, EventArgs e) {
        updateLayoutsLater();
      }};
  }

  /**
   * Adds a panel with optional effect to use when transitioning to new
   * layout.
   */
  public void add(Panel panel) {
    add(panel, ZOOM | FADE);
  }

  /**
   * Adds a panel with optional effect to use when transitioning to new
   * layout.
   */
  public void add(Panel panel, int animEffect) {
    panel.setOpacity(0.0);
    desktop.addChild(panel);
    animationSetting.put(panel, animEffect);
    panels.add(panel);
    panel.setProperty(panelAnimationPropDef, animEffect);
    panel.addListener(Panel.viewStatePropDef, new EventHandler() {
      @Override
      public void handleEvent(EventNotifier targetObject, EventArgs e) {
        hostedPodViewStateChanged((PropertyChangedEvent) e);
      }});
    updateLayoutsLater();
    updateHasMaximizedPanel();
  }

  /**
   * Removes panel.
   */
  public void remove(Panel panel) {
    int index = panels.indexOf(panel);
    if (index != -1) {
      panel.removeListener(Panel.viewStatePropDef, hostedPodViewStateHandler);
      panels.remove(index);
      desktop.removeChild(panel);
    }
    updateLayoutsLater();
    updateHasMaximizedPanel();
  }

  /**
   * Removes all panels from PanelManager.
   */
  public void removeAll() {
    while (panels.size() != 0) {
      Panel panel = panels.get(0);
      panel.removeListener(Panel.viewStatePropDef, hostedPodViewStateHandler);
    }
    desktop.removeAllChildren();
    updateHasMaximizedPanel();
  }

  /**
   * Handles maximize/minimize viewState changes on panels.
   */
  private void hostedPodViewStateChanged(PropertyChangedEvent e) {
    Panel panel = (Panel) e.getSource();
    if (panel.getViewState() == Panel.VIEW_STATE_MAXIMIZED) {
      PanelLayoutData layoutData = new PanelLayoutData();
      layoutData.visible = panel.getVisible();
      layoutData.left = Canvas.getChildLeft(panel);
      layoutData.top = Canvas.getChildTop(panel);
      layoutData.width = panel.getWidth();
      layoutData.height = panel.getHeight();
      layoutData.maxWidth = panel.getMaxWidth();
      layoutData.maxHeight = panel.getMaxHeight();
      panel.clearProperty(UIElement.maxWidthPropDef);
      panel.clearProperty(UIElement.maxHeightPropDef);
      preMaxLayout.put(panel, layoutData);
      ((UIElementContainer) panel.getParent()).bringToFront(panel);
      switchButtonChrome(panel, Panel.MINIMIZE_CHROME_ID);
    } else {
      switchButtonChrome(panel, Panel.MAXIMIZE_CHROME_ID);
    }
    updateHasMaximizedPanel();
  }

  protected void updateHasMaximizedPanel() {
    boolean hasMaximized = false;
    for (int p = 0; p < panels.size(); p++) {
      if (panels.get(p).getViewState() == Panel.VIEW_STATE_MAXIMIZED) {
        hasMaximized = true;
        break;
      }
    }
    if (hasMaximized != hasMaximizedPanel) {
      hasMaximizedPanel = hasMaximized;
      updateLayoutsLater();
    }
  }

  @SuppressWarnings("unused")
  private void addRestoreAction(Action action) {
    action.setReversible(true);
    restoreActions.add(action);
  }

  private void switchButtonChrome(Panel panel, String resourceName) {
    Button maxButton = (Button) panel.getElement(Panel.MAXIMIZE_BUTTON_ID);
    if (maxButton != null) {
      Chrome minChrome = (Chrome) panel.findResource(resourceName);
      if (minChrome != null) {
        maxButton.setChrome(minChrome);
      }
    }
  }

  /**
   * Returns current target layout data for panel.
   */
  protected PanelLayoutData getTargetLayout(Panel panel) {
    PanelLayoutData layout = targetLayout.get(panel);
    if (layout == null) {
      layout = new PanelLayoutData();
      layout.width = panel.getWidth();
      layout.height = panel.getHeight();
      layout.maxWidth = panel.getMaxWidth();
      layout.maxHeight = panel.getMaxHeight();
      layout.visible = panel.getVisible();
      targetLayout.put(panel, layout);
    }
    return layout;
  }

  /**
   * Overridable function to update layout of elements managed by
   * PanelManager.
   */
  protected void buildLayout() {
    PanelLayoutData layoutData = new PanelLayoutData();
    Panel panel;
    Panel maximizedPanel = null;

    updateHasMaximizedPanel();

    for (int p = 0; p < panels.size(); p++) {
      panel = panels.get(p);
      if (panel.getViewState() == Panel.VIEW_STATE_MAXIMIZED) {
        maximizedPanel = panel;
        break;
      }
    }

    for (int panelIndex = 0; panelIndex < panels.size(); panelIndex++) {
      panel = panels.get(panelIndex);
      PanelLayoutData targetLayout = getTargetLayout(panel);
      if (panel.getViewState() == Panel.VIEW_STATE_MAXIMIZED) {
        layoutData.visible = true;
        layoutData.left = margins.getLeft();
        layoutData.top = margins.getTop();
        layoutData.width = desktop.getLayoutRect().width -
            (margins.getLeft() + margins.getRight());
        layoutData.height = desktop.getLayoutRect().height -
            (margins.getTop() + margins.getBottom());
      } else {
        // Check if panel changed from maximize to normal state, if so
        // used premax layout data for new layout.
        layoutData = preMaxLayout.get(panel);
        if (layoutData != null) {
          targetLayout.left = layoutData.left;
          targetLayout.top = layoutData.top;
          targetLayout.width = layoutData.width;
          targetLayout.height = layoutData.height;
          preMaxLayout.remove(panel);
        } else {
          if (maximizedPanel != null) {
            targetLayout.left = Canvas.getChildLeft(panel);
            targetLayout.top = Canvas.getChildTop(panel);
            targetLayout.width = panel.getWidth();
            targetLayout.height = panel.getHeight();
            targetLayout.visible = false;
          }
        }
      }
    }
  }

  /**
   * Applies the target layout settings in layout dictionary to
   * panels.
   */
  protected void applyLayout() {
    for (int panelIndex = 0; panelIndex < panels.size(); panelIndex++) {
      Panel panel = panels.get(panelIndex);
      PanelLayoutData layoutData = getTargetLayout(panel);
      if (layoutData == null) {
        continue;
      }

      int updates = updateCount.containsKey(panel) ? updateCount.get(panel) : 0;
      if (updates == 0 &&
          (animationSetting.get(panel) == PanelManager.ZOOM)) {
        Canvas.setChildLeft(panel, layoutData.left);
        Canvas.setChildTop(panel, layoutData.top);
        panel.setWidth((int) layoutData.width);
        panel.setHeight((int) layoutData.height);
        // TODO(ferhat): implement uielement transform.
        /** panel.transform.scaleX = ZOOM_START_FACTOR;
        panel.transform.scaleY = ZOOM_START_FACTOR;
        panel.transform.animate(Transform.scaleXPropDef, 1.0,
            LAYOUT_ANIM_DURATION);
        panel.transform.animate(Transform.scaleYPropDef, 1.0,
            LAYOUT_ANIM_DURATION);
        */
        updateCount.put(panel, 1);
      } else {
        if (layoutData.left != Canvas.getChildLeft(panel)) {
          Canvas.setChildLeft(panel, layoutData.left);
        }
        if (layoutData.top != Canvas.getChildTop(panel)) {
          Canvas.setChildTop(panel, layoutData.top);
        }
        if (layoutData.width != panel.getWidth()) {
          panel.setWidth((int) layoutData.width);
        }
        if (layoutData.height != panel.getHeight()) {
          panel.setHeight((int) layoutData.height);
        }
        updateCount.put(panel, 2);
      }

      panel.setVisible(layoutData.visible);
      // TODO(ferhat): animate fade
      if (layoutData.visible) {
        //panel.animate(UIElement.opacityPropDef, 1.0, FADE_DURATION);
      } else {
        //panel.animate(UIElement.opacityPropDef, 0.0, FADE_DURATION);
      }
    }
  }

  private static void updateLayouts(Object target) {
    ((PanelManager) target).updateLayout();
  }

  protected void updateLayout() {
    if ((desktop != null) &&
        desktop.getIsLayoutInitialized()) {
      buildLayout();
      applyLayout();
    }
  }

  /**
   * Sets/returns container that hosts panels.
   */
  public void setDesktop(UIElementContainer value) {
    if (desktop != null) {
      desktop.removeListener(UIElement.layoutChangedEvent,
          desktopLayoutChangedHandler);
    }
    desktop = value;
    if (desktop != null) {
      desktop.addListener(UIElement.layoutChangedEvent,
          desktopLayoutChangedHandler);
    }
  }

  /**
   * @return parent of panel manager.
   */
  public UIElementContainer getDesktop() {
    return desktop;
  }

  /**
   * Holds layout information for updateLayout pass of PanalManager.
   */
  protected static class PanelLayoutData {
    /**
     * Sets or returns if panel is visible.
     */
    public boolean visible;

    /**
    * Sets or returns target left position.
    */
    public double left;

    /**
     * Sets or returns target top position.
     */
    public double top;

    /**
     * Sets or returns target width of panel.
     */
    public double width;

    /**
     * Sets or returns target height of panel.
     */
    public double height;

    /**
     * Sets or returns maxHeight of panel.
     */
    public double maxWidth;

    /**
     * Sets or returns maxHeight of panel.
     */
    public double maxHeight;

    /**
     * Constructor.
     */
    public PanelLayoutData() {
    }
  }

  protected void updateLayoutsLater() {
    UpdateQueue.doLater(new EventHandler() {
      @Override
      public void handleEvent(EventNotifier targetObject, EventArgs e) {
        updateLayouts(((UpdateQueue.CallbackData) e).getSource());
      }}, this, this);
  }
}
