package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements a ContentContainer for items in ListBox/Tree controls.
 *
 * @author ferhat
 */
public class Item extends ContentContainer{

  public static PropertyDefinition selectedPropDef =
      ListBase.selectedPropDef;

  public static PropertyDefinition isFirstPropDef =
      ItemsContainer.isFirstPropDef;

  public static PropertyDefinition isLastPropDef =
      ItemsContainer.isLastPropDef;

  /** IsPressed property definition */
  public static PropertyDefinition isPressedPropDef = PropertySystem.register("IsPressed",
      Boolean.class, Item.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Returns selection state of element.
   */
  public boolean getSelected() {
    return ListBase.getChildSelected(this);
  }

  /**
   * Returns true if item is first item in an ItemsContainer.
   */
  public boolean getIsFirst() {
    return ItemsContainer.getChildIsFirst(this);
  }

  /**
   * Returns true if item is last item in an ItemsContainer.
   */
  public boolean getIsLast() {
    return ItemsContainer.getChildIsLast(this);
  }

  /**
   * Returns whether mouse button over an item is in pressed state.
   */
  public boolean getIsPressed() {
    return (Boolean) getProperty(isPressedPropDef);
  }

  /**
   * Sets selection state of element.
   */
  public void setSelected(boolean selected) {
    ListBase.setChildSelected(this, selected);
  }

  /**
   * Returns parent Item of element.
   */
  public static Item getParentItem(UIElement element) {
    while (element != null) {
      if (element instanceof Item) {
        return (Item) element;
      }
      element = element.getParent();
    }
    return null;
  }
}
