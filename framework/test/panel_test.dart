part of alltests;

class PanelTest extends AppTestCase {

   PanelTest();

  void testTitle() {
    Panel panel = new Panel();
    expect(panel.title, equals(""));
    panel.title = "My Caption";
    expect(panel.title, equals("My Caption"));
  }

  void testMeasure() {
    Panel panel = new Panel();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    panel.content = rect1;
    panel.measure(1600, 1200);
    expect(panel.measuredWidth, equals(300));
    expect(panel.measuredHeight, equals(8));
  }

  void testLayout() {
    Application app = createApplication();
    Panel panel = new Panel();
    panel.hAlign = UIElement.HALIGN_LEFT;
    panel.vAlign = UIElement.VALIGN_TOP;
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    panel.content = rect1;
    app.content = panel;
    UpdateQueue.flush();
    expect(rect1.layoutWidth, equals(300));
    expect(rect1.layoutHeight, equals(8));
    app.shutdown();
  }

  void testMoveEnabled() {
    Application app = createApplication();
    Canvas desktop = new Canvas();
    app.content = desktop;
    Panel panel = new Panel();
    panel.hAlign = UIElement.HALIGN_LEFT;
    panel.vAlign = UIElement.VALIGN_TOP;
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 100;
    rect1.fill = new SolidBrush(Color.fromRGB(0xffffff));
    panel.content = rect1;
    panel.moveEnabled = true;
    desktop.addChild(panel);
    UpdateQueue.flush();
    Application.current.sendMouseEvent(panel, 1, 1, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(panel, 10, 30, UIElement.mouseMoveEvent);
    Application.current.sendMouseEvent(panel, 10, 30, UIElement.mouseUpEvent);
    expect(Canvas.getChildLeft(panel), equals(9));
    expect(Canvas.getChildTop(panel), equals(29));
    app.shutdown();
  }

  void testAll() {
    group("Panel", () {
      test("Title", testTitle);
      test("Measure", testMeasure);
      test("Layout", testLayout);
      test("MoveEnabled", testMoveEnabled);
    });
  }
}
