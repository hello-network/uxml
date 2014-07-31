package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventManager;

import java.util.EnumSet;

/**
 * Implements base functionality for controls (such as ListBox/ComboBox) that
 * represent lists of items that can have one or more selected.
 *
 * @author ferhat@
 */
public abstract class ListBase extends Control implements IItemsHost {

  protected Items cachedItems;
  protected ItemsContainer itemsContainer;
  private PropertyBinding itemsBinding;
  private PropertyBinding itemChromeBinding;
  private PropertyBinding itemChromeBindingRev;
  private PropertyBinding containerChromeBinding;

  /** Items Property Definition */
  public static PropertyDefinition itemsPropDef = PropertySystem.register("Items",
      Items.class, ListBase.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None, PropertyFlags.Relayout),
          new PropertyChangeListener() {
              @Override
              public void propertyChanged(PropertyChangedEvent e) {
                  ((ListBox) e.getSource()).cachedItems = ((Items) e.getNewValue());
              }
          }));

  /** SelectedItems Property Definition */
  public static PropertyDefinition selectedItemsPropDef = PropertySystem.register("Items",
      Items.class, ListBase.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None, PropertyFlags.Relayout)));

  /** Selected property definition */
  public static PropertyDefinition selectedPropDef = PropertySystem.register("Selected",
      Boolean.class, ListBase.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached)));

  /** SelectedIndex property definition */
  public static PropertyDefinition selectedIndexPropDef = PropertySystem.register("SelectedIndex",
      Integer.class, ListBase.class,
      new PropertyData(-1, EnumSet.of(PropertyFlags.None)));

  /** SelectedItem property definition */
  public static PropertyDefinition selectedItemPropDef = PropertySystem.register("SelectedItem",
      Object.class, ListBase.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None)));

  /** ItemChrome Property Definition */
  public static PropertyDefinition itemChromePropDef = PropertySystem.register("ItemChrome",
      Chrome.class, ListBase.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None, PropertyFlags.None)));

  /** ContainerChrome Property Definition */
  public static PropertyDefinition containerChromePropDef = PropertySystem.register(
      "ContainerChrome", Chrome.class, ListBase.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None), null));

  /** SelectionChanged event definition */
  public static EventDefinition selectionChangedEvent = EventManager.register(
      "SelectionChanged", ListBase.class, EventArgs.class, ListBase.class, null);

  /** HidePartialItems Property Definition */
  public static PropertyDefinition hidePartialItemsPropDef = PropertySystem.register(
      "HidePartialItems", Boolean.class, Panel.class,
      new PropertyData(true, EnumSet.of(PropertyFlags.None)));

  /** MultiSelect property definition */
  public static PropertyDefinition multiSelectPropDef = PropertySystem.register("MultiSelect",
      Boolean.class, ListBase.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  @ContentNode
  public void addItem(Object item) {
    if (cachedItems == null) {
      setItems(new Items());
    }
    cachedItems.add(item);
  }

  /**
   * Inserts an item to listbox.
   */
   public void insertItem(int index, Object item) {
     if (cachedItems == null) {
       setProperty(itemsPropDef, new Items());
     }
     cachedItems.insert(index, item);
   }

  /**
   * Sets or returns items collection.
   */
  public void setItems(Items items) {
    setProperty(itemsPropDef, items);
  }
  public Items getItems() {
    return cachedItems;
  }

  /**
   * Returns selected items in a multiSelect list.
   */
  public Items getSelectedItems() {
    return (Items) getProperty(selectedItemsPropDef);
  }

  /**
   * Sets or returns item chrome.
   */
  public void setItemChrome(Chrome chrome) {
    setProperty(itemChromePropDef, chrome);
  }

  public Chrome getItemChrome() {
    return (Chrome) getProperty(itemChromePropDef);
  }

  /**
   * Sets or returns container chrome.
   */
  public void setContainerChrome(Chrome chrome) {
    setProperty(containerChromePropDef, chrome);
  }

  public Chrome getContainerChrome() {
    return (Chrome) getProperty(containerChromePropDef);
  }

  /**
   * Sets or returns selected item.
   */
  public void setSelectedItem(Object value) {
    setProperty(selectedItemPropDef, value);
  }

  public Object getSelectedItem() {
    return getProperty(selectedItemPropDef);
  }

  /**
   * Sets or returns if combobox support multiple selection.
   */
  public boolean getMultiSelect() {
    return (Boolean) getProperty(multiSelectPropDef);
  }

  public void setMultiSelect(boolean value) {
    setProperty(multiSelectPropDef, value);
  }

  /**
   * Sets or returns index of selected item.
   */
  public void setSelectedIndex(int index) {
    setProperty(selectedItemPropDef, index);
    if (index != -1 && (getItems().get(index) instanceof Item)) {
      ((Item) getItems().get(index)).setSelected(true);
    }
  }

  public int getSelectedIndex() {
    return ((Integer) getProperty(selectedItemPropDef)).intValue();
  }


  /**
   * Sets/returns whether list should hide partially visible items.
   */
  public void setHidePartialItems(boolean value) {
    setProperty(hidePartialItemsPropDef, value);
  }

  public boolean getHidePartialItems() {
    return ((Boolean) getProperty(hidePartialItemsPropDef)).booleanValue();
  }

  @Override
  public void close() {
    super.close();
    itemsContainer = null;
  }

  /**
   * @see IItemsHost
   */
  @Override
  public void attachContainer(ItemsContainer container) {
    itemsContainer = container;
    containerChromeBinding = new PropertyBinding(container,
        ItemsContainer.containerChromePropDef, this, new Object[] {containerChromePropDef});
    itemChromeBinding = new PropertyBinding(container, ItemsContainer.itemChromePropDef,
        this, new Object[] {itemChromePropDef});
    itemChromeBindingRev = new PropertyBinding(this, itemChromePropDef,
        container, new Object[] {ItemsContainer.itemChromePropDef});
    itemsBinding = new PropertyBinding(container, ItemsContainer.itemsPropDef,
        this, new Object[]{itemsPropDef});
  }

  /**
   * @see IItemsHost
   */
  @Override
  public void detachContainer(ItemsContainer container) {
    itemsBinding.clear();
    itemsBinding = null;
    itemChromeBinding.clear();
    itemChromeBinding = null;
    itemChromeBindingRev.clear();
    itemChromeBindingRev = null;
    containerChromeBinding.clear();
    containerChromeBinding = null;
    itemsContainer = null;
  }

  /**
   * @see IItemsHost
   */
  @Override
  public boolean isContainerAttached() {
    return itemsContainer != null;
  }

  /**
   * @see IItemsHost
   */
  @Override
  public void itemSelectionChanging(UIElement item, boolean isSelected) {
  }

  /**
   * Returns selection state of element.
   */
  public static boolean getChildSelected(UIElement element) {
    return ((Boolean) element.getProperty(selectedPropDef)).booleanValue();
  }

  /**
   * Sets selection state of element.
   */
  public static void setChildSelected(UIElement element, boolean select) {
    element.setProperty(selectedPropDef, select);
  }
}
