part of alltests;

class LayoutSystemTest extends AppTestCase {

  LayoutSystemTest() : super() {
  }

  void testEmptyContainer() {
    Application app = createApplication();
    MyUIContainer container = new MyUIContainer();
    app.content = container;
    UpdateQueue.flush();
    expect(container.measureCallCount, equals(1));
    expect(container.layoutCallCount, equals(1));
    expect(container.measuredWidth, equals(0));
    expect(container.measuredHeight, equals(0));
    app.shutdown();
  }

  void testContainerWithElementsAtStartup() {
    Application app = createApplication();
    MyUIContainer container = new MyUIContainer();
    MyUIElement child1 = new MyUIElement();
    MyUIElement child2 = new MyUIElement();
    container.addChild(child1);
    container.addChild(child2);
    app.content = container;
    UpdateQueue.flush();
    expect(container.measureCallCount, equals(1));
    expect(container.layoutCallCount, equals(1));
    expect(child1.measureCallCount, equals(1));
    expect(child1.layoutCallCount, equals(1));
    expect(child2.measureCallCount, equals(1));
    expect(child2.layoutCallCount, equals(1));
    expect(container.measuredWidth, equals(MyUIElement.ITEM_WIDTH));
    expect(container.measuredHeight, equals(MyUIElement.ITEM_HEIGHT * 2));
    app.shutdown();
  }

  void testContainerChildSizeChange() {
    Application app = createApplication();
    MyUIContainer container = new MyUIContainer();
    MyUIElement child1 = new MyUIElement();
    MyUIElement child2 = new MyUIElement();
    container.addChild(child1);
    container.addChild(child2);
    app.content = container;
    child1.height = 123;
    UpdateQueue.flush();
    expect(container.measureCallCount, equals(2));
    expect(container.layoutCallCount, equals(2));
    expect(child1.measureCallCount, equals(2));
    expect(child1.layoutCallCount, equals(2));
    expect(child2.measureCallCount, equals(1));
    expect(child2.layoutCallCount, equals(2));
    expect(container.measuredWidth, equals(MyUIElement.ITEM_WIDTH));
    expect(container.measuredHeight, equals(MyUIElement.ITEM_HEIGHT + 123));
    app.shutdown();
  }

  void testWidthConstraints() {
    Application app = createApplication();
    HBox container = new HBox();
    MyUIElement child1 = new MyUIElement();
    child1.margins = new Margin(10, 0, 10, 0);
    child1.minWidth = MyUIElement.ITEM_WIDTH + 50.0;
    MyUIElement child2 = new MyUIElement();
    child2.margins = new Margin(10, 0, 10, 0);
    child2.maxWidth = MyUIElement.ITEM_WIDTH - 50.0;
    container.addChild(child1);
    container.addChild(child2);
    app.content = container;
    UpdateQueue.flush();
    expect(child1.measuredWidth, equals(MyUIElement.ITEM_WIDTH + 50.0 + 20.0));
    expect(child2.measuredWidth, equals(MyUIElement.ITEM_WIDTH - 50.0 + 20.0));
    app.shutdown();
  }

  void testHeightConstraints() {
    Application app = createApplication();
    VBox container = new VBox();
    MyUIElement child1 = new MyUIElement();
    child1.margins = new Margin(0, 10, 0, 10);
    child1.minHeight = MyUIElement.ITEM_HEIGHT + 50.0;
    MyUIElement child2 = new MyUIElement();
    child2.margins = new Margin(0, 10, 0, 10);
    child2.maxHeight = MyUIElement.ITEM_HEIGHT - 50.0;
    container.addChild(child1);
    container.addChild(child2);
    app.content = container;
    UpdateQueue.flush();
    expect(child1.measuredHeight, equals(MyUIElement.ITEM_HEIGHT + 50.0 +
        20.0));
    expect(child2.measuredHeight, equals(MyUIElement.ITEM_HEIGHT - 50.0 +
        20.0));
    app.shutdown();
  }

  void testAll() {
    group("LayoutSystem", () {
      test("EmptyContainer", testEmptyContainer);
      test("ContainerWithElementsAtStartup",
          testContainerWithElementsAtStartup);
      test("ContainerChildSizeChange", testContainerChildSizeChange);
      test("WidthConstraints", testWidthConstraints);
      test("HeightConstraints", testHeightConstraints);
    });
  }
}

/**
 * Helper class for testing layout.
 */
class MyUIContainer extends UIElementContainer {
  int layoutCallCount = 0;
  int measureCallCount = 0;
  int redrawCallCount = 0;
  bool stackItems = true;

   MyUIContainer() : super() {
  }

  bool onMeasure(num availableWidth, num availableHeight) {
    ++measureCallCount;
    num totalHeight = 0;
    num maxWidth = 0;
    for (int i = 0; i < childCount; ++i) {
      childAt(i).measure(availableWidth, availableHeight);
      maxWidth = max(maxWidth, childAt(i).measuredWidth);
      if (stackItems) {
        totalHeight += childAt(i).measuredHeight;
      } else {
        totalHeight = max(totalHeight, childAt(i).measuredHeight);
      }
    }
    setMeasuredDimension(maxWidth, totalHeight);
    return false;
  }

  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    ++layoutCallCount;
    num yPos = 0;
    for (int i = 0; i < childCount; ++i) {
      if (stackItems) {
        childAt(i).layout(0, yPos, targetWidth, childAt(i).measuredHeight);
        yPos = childAt(i).measuredHeight;
      } else {
        childAt(i).layout(0, 0, targetWidth, targetHeight);
      }
    }
  }
}
