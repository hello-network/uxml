part of alltests;

class ItemsContainerTest extends AppTestCase {
  static final int ITEM_SHAPE_SIZE = 50;
  static final int ITEM_SHAPE_SIZE2 = 17;

  ItemsContainerTest();

  void testItems() {
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    Items items = new Items();
    container.items = items;
    Item item = new Item();
    container.items.add(item);
    expect(container.items.length, equals(1));
    Items newItems = new Items();
    container.items = newItems;
    expect(container.items.length, equals(0));
  }

  void testDefaultContainerChrome() {
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    Items items = new Items();
    container.items = items;
    Item item = new Item();
    container.items.add(item);
    expect(item.parent is VBox, isTrue);
  }

  void testRemoveItem() {
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    Items items = new Items();
    container.items = items;
    Item item1 = new Item();
    container.items.add(item1);
    Item item2 = new Item();
    container.items.add(item2);
    UIElementContainer elementContainer = item1.parent;
    expect(elementContainer.childCount, equals(2));
    container.items.removeAt(0);
    expect(elementContainer.childCount, equals(1));
    container.items.removeAt(0);
    expect(elementContainer.childCount, equals(0));
  }

  void testContainerChrome() {
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    Chrome hBoxChrome = new Chrome("chromeId",
        UIElementContainer.uielementcontainerElementDef,
        createHBoxContainerChrome);
    container.containerChrome = hBoxChrome;
    Items items = new Items();
    container.items = items;
    Item item = new Item();
    container.items.add(item);
    expect(item.parent is HBox, isTrue);
  }

  UIElement createHBoxContainerChrome(UIElement targetElement) {
    return new HBox();
  }

  void testItemChrome() {
    Application app = createApplication();
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    container.itemChrome = new Chrome("itemChromeId", UIElement.elementDef,
        createItemChrome);
    Items items = new Items();
    container.items = items;
    Item item = new Item();
    container.items.add(item);
    Item item2 = new Item();
    container.items.add(item2);
    app.content = container;
    UpdateQueue.flush();
    expect(container.measuredWidth, equals(ITEM_SHAPE_SIZE));
    expect(container.measuredHeight, equals(ITEM_SHAPE_SIZE * 2));
  }

  void testItemChromeChange() {
    Application app = createApplication();
    ItemsContainer container = new ItemsContainer();
    expect(container.items, isNull);
    container.itemChrome = new Chrome("itemChromeId", UIElement.elementDef,
        createItemChrome);
    Items items = new Items();
    container.items = items;
    Item item = new Item();
    container.items.add(item);
    Item item2 = new Item();
    container.items.add(item2);
    app.content = container;
    UpdateQueue.flush();
    expect(container.measuredWidth, equals(ITEM_SHAPE_SIZE));
    expect(container.measuredHeight, equals(ITEM_SHAPE_SIZE * 2));
    container.itemChrome = new Chrome("itemChromeId2", UIElement.elementDef,
        createItemChrome2);
    UpdateQueue.flush();
    expect(container.measuredWidth, equals(ITEM_SHAPE_SIZE2));
    expect(container.measuredHeight, equals(ITEM_SHAPE_SIZE2 * 2));
  }

  UIElement createItemChrome(UIElement targetElement) {
    VBox element = new VBox();
    RectShape shape = new RectShape();
    shape.width = ITEM_SHAPE_SIZE;
    shape.height = ITEM_SHAPE_SIZE;
    element.addChild(shape);
    element.addChild(new ContentContainer());
    return element;
  }

  UIElement createItemChrome2(UIElement targetElement) {
    VBox element = new VBox();
    RectShape shape = new RectShape();
    shape.width = ITEM_SHAPE_SIZE2;
    shape.height = ITEM_SHAPE_SIZE2;
    element.addChild(shape);
    element.addChild(new ContentContainer());
    return element;
  }

  void testAll() {
    group("ItemsContainer", () {
      test("Items", testItems);
      test("DefaultContainerChrome", testDefaultContainerChrome);
      test("RemoveItem", testRemoveItem);
      test("ContainerChrome", testContainerChrome);
      test("ItemChrome", testItemChrome);
      test("ItemChromeChange", testItemChromeChange);
    });
  }
}
