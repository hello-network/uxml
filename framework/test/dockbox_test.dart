part of alltests;

class DockBoxTest extends AppTestCase {

  DockBoxTest();

  void testMeasure() {
    DockBox dockBox = new DockBox();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    DockBox.setChildDock(rect1, Dock.LEFT);
    dockBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    DockBox.setChildDock(rect2, Dock.TOP);
    dockBox.addChild(rect2);
    dockBox.measure(1600, 1200);
    expect(dockBox.measuredWidth, equals(316));
    expect(dockBox.measuredHeight, equals(200));
  }

  void testLayout() {
    Application app = createApplication();
    app.setHostSize(1024, 768);
    DockBox dockBox = new DockBox();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    DockBox.setChildDock(rect1, Dock.LEFT);
    dockBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    DockBox.setChildDock(rect2, Dock.TOP);
    dockBox.addChild(rect2);
    Canvas canvas = new Canvas();
    dockBox.addChild(canvas);
    app.content = dockBox;
    UpdateQueue.flush();
    expect(canvas.layoutWidth, equals(724));
    expect(canvas.layoutHeight, equals(568));
    app.shutdown();
  }

  void testAll() {
    group("DockBox", () {
      test("Measure", testMeasure);
      test("Layout", testLayout);
    });
  }
}
