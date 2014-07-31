package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.ContentNode;
import com.hello.uxml.tools.framework.UIElement;

import java.util.ArrayList;
import java.util.List;

/**
 * Manages a list of filters for UIElement.
 * @author ferhat@
 *
 */
public class Filters {

  private List<Filter> list = new ArrayList<Filter>();
  private UIElement owner;
  /**
   * Constructor.
   */
  public Filters() {
  }

  /**
   * Sets owner of filters collection.
   */
  public void setOwner(UIElement owner) {
    this.owner = owner;
    for (Filter filter : list) {
      filter.setTarget(owner);
    }
  }

  /**
   * Appends the filter to the end of the list.
   */
  @ContentNode
  public void add(Filter filter) {
    list.add(filter);
    filter.setTarget(owner);
  }

  /**
   * Removes filter from the list.
   */
  public void remove(Filter filter) {
    filter.setTarget(null);
    list.remove(filter);
  }
}
