package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UpdateQueue;
import com.hello.uxml.tools.framework.UxmlElement;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

/**
 * Base class for graphics effects filters.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public abstract class Filter extends UxmlElement{

  /** Filter changed event definition. */
  public static EventDefinition changedEventDef = EventManager.register(
      "Changed", Filter.class, EventArgs.class);

  /**
   * Target of filter. This is set by the filters collection and used
   * to update UIElement's surface when filter properties are changed.
   */
  private UIElement target;
  /**
   * Platform specific filter object.
   */
  protected Object nativeFilter;
  /**
   * Sets owner of filter.
   */
  public void setTarget(UIElement target) {
    this.target = target;
    if (target != null) {
      UpdateQueue.updateFilters(target);
    }
  }

  /**
   * Updates owner
   */
  protected void updateOwner() {
    UISurface surface = target.getSurface();
    if (nativeFilter != null) {
      surface.removeFilter(this);
    }
    createNativeFilter();
    if (nativeFilter != null) {
      surface.addFilter(this);
    }
  }

  /**
   * Creates native filter object.
   */
  protected void createNativeFilter() {
  }

  /**
   * Updates native style and fires the change event.
   */
  @Override
  protected void onPropertyChanged(PropertyDefinition propDef,
      Object oldValue, Object newValue) {
    if (target != null) {
      UpdateQueue.updateFilters(target);
    }

    // fire change event to all listeners
    if (hasListener(changedEventDef)) {
      EventArgs e = new EventArgs();
      e.setSource(this);
      notifyListeners(changedEventDef, e);
    }
  }
}
