package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.ChangeType;
import com.hello.uxml.tools.framework.events.CollectionChangedEvent;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventManager;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.EnumSet;

/**
 * Provides base class for controls that contain a collection of elements.
 *
 * @author ferhat
 */
public class ItemsContainer extends Control {

  /**
   * Cached value of items property.
   */
  private Items cachedItems;
  private UIElementContainer visualContainer;
  private EventHandler collectionListener;

  public static PropertyDefinition itemsPropDef = PropertySystem.register("Items", Items.class,
      ItemsContainer.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          ItemsContainer element = (ItemsContainer) e.getSource();
          element.setSource((Items) e.getNewValue());
        }
      }));

  /** ItemChrome Property Definition */
  public static PropertyDefinition itemChromePropDef = PropertySystem.register("ItemChrome",
      Chrome.class, ItemsContainer.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
          @Override
          public void propertyChanged(PropertyChangedEvent e) {
              ItemsContainer element = (ItemsContainer) e.getSource();
              element.itemChromeChangedHandler((Chrome) e.getNewValue());
          }
      }));

  /** ContainerChrome Property Definition */
  public static PropertyDefinition containerChromePropDef = PropertySystem.register(
      "ContainerChrome", Chrome.class, ItemsContainer.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.None), new PropertyChangeListener() {
          @Override
          public void propertyChanged(PropertyChangedEvent e) {
              ItemsContainer element = (ItemsContainer) e.getSource();
              element.containerChromeChangedHandler((Chrome) e.getNewValue());
          }
      }));

  /** IsFirst property definition */
  public static PropertyDefinition isFirstPropDef = PropertySystem.register("IsFirst",
      Boolean.class, ItemsContainer.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached)));

  /** IsLast property definition */
  public static PropertyDefinition isLastPropDef = PropertySystem.register("IsLast",
      Boolean.class, ItemsContainer.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached)));

  /** IsAlternateRow property definition */
  public static PropertyDefinition isAlternateRowPropDef = PropertySystem.register(
      "IsAlternateRow", Boolean.class, ItemsContainer.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Attached)));

  /** SelectionChanged event definition */
  public static EventDefinition selectionChangedEvent = EventManager.register(
      "SelectionChanged", ItemsContainer.class, EventArgs.class, ItemsContainer.class, null);

  public ItemsContainer() {
    super();
    collectionListener = new EventHandler() {
      @Override
      public void handleEvent(EventNotifier targetObject, EventArgs e) {
        CollectionChangedEvent changeEvent = (CollectionChangedEvent) e;
        if (changeEvent.getType() == ChangeType.Add) {
          generateElements(changeEvent.getIndex(), changeEvent.getCount());
        } else if (changeEvent.getType() == ChangeType.Remove) {
          int startIndex = changeEvent.getIndex();
          int itemCount = changeEvent.getCount();
          for (int i = (startIndex + itemCount) - 1; i >= startIndex; --i) {
            UIElement child = visualContainer.getChild(i);
            Object item;
            if (i == 0) {
              // removing first item
              if (child instanceof Item) {
                ((Item) child).setProperty(isFirstPropDef, false);
              }
              visualContainer.removeChild(child);
              if (getItems().size() != 0) {
                item = getItems().get(0);
                if (item instanceof Item) {
                  ((Item) item).setProperty(isFirstPropDef, true);
                }
              }
            } else if (i == (getItems().size() - 1)) {
              // removing last item
              visualContainer.removeChild(child);
            } else {
              if (child instanceof Item) {
                ((Item) child).setProperty(isLastPropDef, false);
              }
              visualContainer.removeChild(child);
              if (getItems().size() != 0) {
                item = getItems().get(getItems().size() - 1);
                if (item instanceof Item) {
                  ((Item) item).setProperty(isLastPropDef, true);
                }
              }
              visualContainer.removeChild(child);
            }
          }
        } else {
          // TODO(ferhat) implement itemscontainer modified handler when Items gets modify method
        }
      }
    };
  }

  /**
   * Returns true if element is first item in container.
   */
  public static boolean getChildIsFirst(UIElement element) {
    return ((Boolean) element.getProperty(isFirstPropDef)).booleanValue();
  }

  /**
   * Returns true if element is last item in container.
   */
  public static boolean getChildIsLast(UIElement element) {
    return ((Boolean) element.getProperty(isLastPropDef)).booleanValue();
  }

  /**
   * Returns true if item is alternating row.
   */
  public static boolean getIsAlternateRow(UIElement element) {
    return ((Boolean) element.getProperty(isAlternateRowPropDef)).booleanValue();
  }

  /**
   * Sets item state to alternating row.
   */
  public static void setIsAlternateRow(UIElement element, boolean isAlternate) {
    element.setProperty(isAlternateRowPropDef, isAlternate);
  }

  private void generateElements(int startIndex, int count) {
    Object item;

    if (startIndex != 0) {
      item = cachedItems.get(cachedItems.size() - 1);
      if (item instanceof Item) {
        ((Item) item).setProperty(isLastPropDef, false);
      }
    }
    for (int i = startIndex; i < count; ++i) {
      item = cachedItems.get(i);
      if ((i == 0) && (item instanceof Item)) {
        ((Item) item).setProperty(isFirstPropDef, true);
      }
      if ((i == (count - 1)) && (item instanceof Item)) {
        ((Item) item).setProperty(isLastPropDef, true);
      }
      visualContainer.addChild(generateElement(item));
    }
  }

  /**
   * Generates a visual element from items collection member.
   * Subclasses should override to host custom element wrappers.
   */
  protected UIElement generateElement(Object item) {
    Chrome chrome = getItemChrome();
    if (item instanceof UIElement) {
      if (chrome != null && (item instanceof Control)) {
        ((Control) item).setChrome(chrome);
      }
      return (UIElement) item;
    } else {
      if (chrome == null) {
        Label label = new Label();
        label.setText(item.toString());
        return label;
      } else {
        UIElement newItem = chrome.apply(this);
        if (newItem instanceof ContentContainer) {
          ((ContentContainer) newItem).setContent(item);
        }
        return newItem;
      }
    }
  }

  private void itemChromeChangedHandler(Chrome newChrome) {
    if (visualContainer != null) {
      visualContainer.removeAllChildren();
    }

    Items items = getItems();
    if (items != null) {
      generateElements(0, items.size());
    }
  }

  /**
   * Creates element to serve as visual container. Subclasses should override to provide custom
   * containers.
   */
  protected void createVisualContainer() {
    if (visualContainer == null) {
      if (getContainerChrome() != null) {
        visualContainer = (UIElementContainer) getContainerChrome().apply(this);
      } else {
        visualContainer = new VBox();
      }
      addRawChild(visualContainer);
    }
  }

  /**
   * Updates visual container with new items and adds listener to collection.
   */
  private void setSource(Items newItems) {
    if (cachedItems != null) {
      cachedItems.removeListener(CollectionChangedEvent.changeEvent, collectionListener);
    }
    if (visualContainer != null) {
      visualContainer.removeAllChildren();
    }
    cachedItems = newItems;
    if (newItems != null) {
      if (visualContainer == null) {
        createVisualContainer();
      }
      generateElements(0, newItems.size());
      newItems.addListener(CollectionChangedEvent.changeEvent, collectionListener);
    }
  }

  /**
   * Sets or returns items collection.
   */
  public Items getItems() {
    return cachedItems;
  }

  public void setItems(Items items) {
    setProperty(itemsPropDef, items);
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

  @Override
  protected int getRawChildCount() {
    return visualContainer == null ? 0 : 1;
  }

  @Override
  protected UIElement getRawChild(int index) {
    return visualContainer;
  }

  protected void containerChromeChangedHandler(Chrome chrome) {
  }
}
