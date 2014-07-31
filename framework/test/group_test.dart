part of alltests;

class GroupTest extends AppTestCase {

  GroupTest();

  void testMeasure() {
    Group group = new Group();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    group.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    group.addChild(rect2);
    group.measure(1600, 1200);
    expect(group.measuredWidth, equals(300));
    expect(group.measuredHeight, equals(200));
  }

  void testLayout() {
    Application app = createApplication();
    Group group = new Group();
    group.hAlign = UIElement.HALIGN_LEFT;
    group.vAlign = UIElement.VALIGN_TOP;
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    group.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    group.addChild(rect2);
    RectShape rect3 = new RectShape();
    group.addChild(rect3);
    app.content = group;
    UpdateQueue.flush();
    expect(rect3.layoutWidth, equals(300));
    expect(rect3.layoutHeight, equals(200));
    app.shutdown();
  }

  void testAll() {
    group("Group", () {
      test("Measure", testMeasure);
      test("Layout", testLayout);
    });
  }
}
