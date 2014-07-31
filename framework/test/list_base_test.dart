part of alltests;

class ListBaseTest extends AppTestCase {

  ListBaseTest();
  int selectionEventCount;

  void testAddItem() {
    ListBase list = new ListBase();
    list.addItem(new Item());
    list.addItem(new Item());
    expect(list.items.length, equals(2));
  }

  void testModelFill() {
    Model data = new Model();
    data.addChild(new Model());
    data.addChild(new Model());
    data.addChild(new Model());
    data.addChild(new Model());
    data.addChild(new Model());
    ListBase list = new ListBase();
    list.data = data;
    expect(list.items.length, equals(5));
  }

  void testModelChange() {
    Model data = new Model();
    Model m = new Model();
    m.setMember("id", "1");
    data.addChild(m);
    m = new Model();
    m.setMember("id", "2");
    data.addChild(m);
    m = new Model();
    m.setMember("id", "3");
    data.addChild(m);
    m = new Model();
    m.setMember("id", "4");
    data.addChild(m);
    m = new Model();
    m.setMember("id", "5");
    data.addChild(m);
    ListBase list = new ListBase();
    list.data = data;
    expect(5, list.items.length);
    Item item = list.items.getItemAt(2);
    expect(item.data.getMember("id"), equals("3"));
    data.removeChild(data.getChildAt(2));
    item = list.items.getItemAt(2);
    expect(item.data.getMember("id"), equals("4"));
  }

  void testAddStrings() {
    ListBase list = new ListBase();
    list.addItem("Item1");
    list.addItem("Item2");
    expect(list.items.length, equals(2));
  }

  void testSelectedIndexForStrings() {
    ListBase list = new ListBase();
    list.addItem("Item1");
    list.addItem("Item2");
    list.selectedIndex = 1;
    expect(list.selectedIndex, equals(1));
    expect(list.selectedItem, equals("Item2"));
  }

  UIElement createListChromeElements(UIElement targetElement) {
    return new ItemsContainer();
  }

  void testSelectedIndexUpdate() {
    Application app = createApplication();
    ListBase list = new ListBase();
    list.chrome = new Chrome("simpleListChrome", ListBase.listbaseElementDef,
        createListChromeElements);
    list.addItem(new Item("Item1"));
    list.addItem(new Item("Item2"));
    list.addItem(new Item("Item3"));
    app.content = list;
    UpdateQueue.flush();
    expect(list.selectedIndex, equals(-1));
    Item item = list.items.getItemAt(2);
    item.selected = true;
    expect(list.selectedIndex, equals(2));
    app.shutdown();
  }

  void testSelectedIndexClear() {
    Application app = createApplication();
    ListBase list = new ListBase();
    list.chrome = new Chrome("simpleListChrome", ListBase.listbaseElementDef,
        createListChromeElements);
    list.addItem(new Item("Item1"));
    list.addItem(new Item("Item2"));
    list.addItem(new Item("Item3"));
    app.content = list;
    UpdateQueue.flush();
    expect(list.selectedIndex, equals(-1));
    Item item = list.items.getItemAt(2);
    item.selected = true;
    expect(list.selectedIndex, equals(2));
    list.items.clear();
    expect(list.selectedIndex, equals(-1));
    expect(list.selectedItems.length, equals(0));
    app.shutdown();
  }

  /** Test selectionChangedEvent firing once when selectAll is called. */
  void testSelectAll() {
    Application app = createApplication();
    ListBase list = new ListBase();
    list.chrome = new Chrome("simpleListChrome", ListBase.listbaseElementDef,
        createListChromeElements);
    list.addItem(new Item("Item1"));
    list.addItem(new Item("Item2"));
    list.addItem(new Item("Item3"));
    list.multiSelect = true;
    app.content = list;
    UpdateQueue.flush();

    selectionEventCount = 0;

    list.addListener(ListBase.selectionChangedEvent,
        (EventArgs e) => selectionEventCount++);

    list.selectAll();
    expect(selectionEventCount, equals(1));
    app.shutdown();
  }

  void testAll() {
    group("ListBase", () {
      test("AddItem", testAddItem);
      test("ModelFill", testModelFill);
      test("ModelChange", testModelChange);
      test("AddStrings", testAddStrings);
      test("SelectedIndexForStrings", testSelectedIndexForStrings);
      test("SelectedIndexUpdate", testSelectedIndexUpdate);
      test("SelectedIndexClear", testSelectedIndexClear);
      test("SelectAll", testSelectAll);
    });
  }
}
