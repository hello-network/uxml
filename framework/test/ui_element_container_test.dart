part of alltests;

class UIElementContainerTest {

  UIElementContainerTest();

  void testAddChild() {
    UIElementContainer container = new UIElementContainer();
    expect(container.childCount, equals(0));
    RectShape shape1 = new RectShape();
    EllipseShape shape2 = new EllipseShape();
    container.addChild(shape1);
    expect(container.childCount, equals(1));
    container.addChild(shape2);
    expect(container.childCount, equals(2));
  }

  void testRemoveChild() {
    UIElementContainer container = new UIElementContainer();
    RectShape shape1 = new RectShape();
    EllipseShape shape2 = new EllipseShape();
    container.addChild(shape1);
    container.addChild(shape2);
    container.removeChild(shape1);
    expect(container.childCount, equals(1));
    expect(container.childAt(0), equals(shape2));
  }

  void testRemoveAllChildren() {
    UIElementContainer container = new UIElementContainer();
    RectShape shape1 = new RectShape();
    EllipseShape shape2 = new EllipseShape();
    container.addChild(shape1);
    container.addChild(shape2);
    container.removeAllChildren();
    expect(container.childCount, equals(0));
  }

  void testAll() {
    group("UIElementContainer", () {
      test("AddChild", testAddChild);
      test("RemoveChild", testRemoveChild);
      test("RemoveAllChildren", testRemoveAllChildren);
    });
  }
}
