package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.ArrayList;
import java.util.List;

/**
 * Implements a container of UIElement(s).
 *
 * @author ferhat
 */
public class UIElementContainer extends Control {

  /** Holds children */
  protected List<UIElement> childElements;

  /**
   * Constructor
   */
  public UIElementContainer() {
  }

  /**
   * Returns number of child element
   */
  public int getChildCount() {
    return (childElements == null) ? 0 : childElements.size();
  }

  /**
   * Returns child at index
   */
  public UIElement getChild(int index) {
    return childElements.get(index);
  }

  /**
   * Adds a child to container
   */
  @ContentNode
  public void addChild(UIElement child) {
    if (childElements == null) {
      childElements = new ArrayList<UIElement>();
    }
    childElements.add(child);
    addRawChild(child);
  }

  /**
   * Removes child from container
   */
  public void removeChild(UIElement child) {
    childElements.remove(child);
    removeRawChild(child);
  }

  /**
   * Removes child at index from container
   */
  public void removeChildAt(int index) {
    UIElement child = childElements.get(index);
    childElements.remove(index);
    removeRawChild(child);
  }

  /**
   * Removes all children from container
   */
  public void removeAllChildren() {
    for (int i = childElements.size() - 1; i >= 0; --i) {
      removeChildAt(i);
    }
  }

  /**
   * Returns raw child count
   */
  @Override
  protected int getRawChildCount() {
    return getChildCount();
  }

  /** Returns raw child collection */
  @Override
  protected UIElement getRawChild(int index) {
    return childElements.get(index);
  }

  @Override
  protected void onRedraw(UISurface surface) {
    Brush backgroundBrush = getBackground();
    if (backgroundBrush != null) {
      surface.drawRect(backgroundBrush, null, new Rectangle(0, 0, getLayoutRect().width,
          getLayoutRect().height));
    }
  }

  /**
   * Updates Z order to bring the child element to the front.
   */
   public void bringToFront(UIElement child) {
     int index = childElements.indexOf(child);
     if ((index != -1) && index != (childElements.size() - 1)) {
       setChildDepth(child, index, childElements.size() - 1);
     }
   }

   /**
   * Updates Z order to send the child element to the back.
   */
   public void sendToBack(UIElement child) {
     int index = childElements.indexOf(child);
     if (index != -1) {
       setChildDepth(child, index, 0);
     }
   }

   @Override
   protected void setChildDepth(UIElement child, int prevIndex,
       int newIndex) {
     childElements.remove(prevIndex);
     if (newIndex >= childElements.size()) {
       childElements.add(child);
     } else {
       childElements.add(newIndex, child);
     }
     super.setChildDepth(child, prevIndex, newIndex);
   }
}
