package com.hello.uxml.tools.framework;

/**
 * Defines an interface that allows ItemsContainer to attach to a host.
 *
 * @author ferhat
 */
public interface IItemsHost {
  void attachContainer(ItemsContainer container);
  void detachContainer(ItemsContainer container);
  boolean isContainerAttached();
  void itemSelectionChanging(UIElement element, boolean isSelected);
}
