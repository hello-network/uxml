package com.hello.uxml.tools.framework.events;

import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.utils.ClipboardData;

/**
 * Defines drag and drop event arguments.
 *
 * @author ferhat
 */
public class DragEventArgs extends MouseEventArgs {
  private UIElement dragSource;
  private ClipboardData data;

  /**
   * Sets/returns drag & drop source element.
   */
  public UIElement getDragSource() {
    return dragSource;
  }

  public void setDragSource(UIElement element) {
    dragSource = element;
  }

  /**
   * Sets/returns data source for drag & drop.
   */
  public ClipboardData getData() {
    return data;
  }

  public void setData(ClipboardData data) {
    this.data = data;
  }
}
