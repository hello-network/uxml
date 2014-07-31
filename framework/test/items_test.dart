part of alltests;

class ItemsTest {
  CollectionChangedEvent curEvent = null;

  ItemsTest();

  void testAddChild() {
    Items items = new Items();
    curEvent = null;
    items.addListener(Items.itemsChangedEvent,
        (CollectionChangedEvent e) {
          curEvent = e;
        });
    expect(items.length, equals(0));
    items.add("Item1");
    expect(curEvent.type, equals(CollectionChangedEvent.CHANGETYPE_ADD));
    expect(curEvent.index, equals(0));
    expect(curEvent.count, equals(1));
    expect(items.length, equals(1));
    items.add("Item2");
    expect(curEvent.type, equals(CollectionChangedEvent.CHANGETYPE_ADD));
    expect(curEvent.index, equals(1));
    expect(curEvent.count, equals(1));
    expect(items.length, equals(2));
  }

  void testRemoveAt() {
    Items items = new Items();
    curEvent = null;
    items.addListener(Items.itemsChangedEvent,
      (CollectionChangedEvent e) {
        curEvent = e;
      });
    items.add("Item1");
    items.add("Item2");
    items.removeAt(0);
    expect(curEvent.type, equals(CollectionChangedEvent.CHANGETYPE_REMOVE));
    expect(curEvent.index, equals(0));
    expect(curEvent.count, equals(1));
    expect(items.length, equals(1));
    expect(items.getItemAt(0), equals("Item2"));
  }

  void testRemove() {
    Items items = new Items();
    curEvent = null;
    items.addListener(Items.itemsChangedEvent,
      (CollectionChangedEvent e) {
        curEvent = e;
      });
    Item item1 = new Item("label1");
    Item item2 = new Item("label2");
    items.add(item1);
    items.add(item2);
    items.remove(item2);
    expect(curEvent.type, equals(CollectionChangedEvent.CHANGETYPE_REMOVE));
    expect(curEvent.index, equals(1));
    expect(curEvent.count, equals(1));
    expect(items.length, equals(1));
    expect(items.getItemAt(0), equals(item1));
  }

  void testInsert() {
    Items items = new Items();
    curEvent = null;
    items.addListener(Items.itemsChangedEvent,
      (CollectionChangedEvent e) {
        curEvent = e;
      });
    items.add("Item1");
    items.add("Item2");
    items.insert(0, "Item 0");
    items.insert(2, "Item1.5");
    items.insert(items.length, "Last item");
    expect(items.length, equals(5));
    expect(items.getItemAt(0), equals("Item 0"));
    expect(items.getItemAt(1), equals("Item1"));
    expect(items.getItemAt(2), equals("Item1.5"));
    expect(items.getItemAt(3), equals("Item2"));
    expect(items.getItemAt(4), equals("Last item"));
  }

  void testClear() {
    Items items = new Items();
    curEvent = null;
    items.addListener(Items.itemsChangedEvent,
      (CollectionChangedEvent e) {
        curEvent = e;
      });
    items.add("Item1");
    items.add("Item2");
    expect(items.length, equals(2));
    items.clear();
    expect(curEvent.type, equals(CollectionChangedEvent.CHANGETYPE_REMOVE));
    expect(curEvent.index, equals(0));
    expect(curEvent.count, equals(2));
    expect(items.length, equals(0));
    items.clear();
    expect(items.length, equals(0));
  }

  void testAll() {
    group("Items", () {
      test("AddChild", testAddChild);
      test("RemoveAt", testRemoveAt);
      test("Remove", testRemove);
      test("Insert", testInsert);
      test("Clear", testClear);
    });
  }
}
