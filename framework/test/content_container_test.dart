part of alltests;

class ContentContainerTest extends AppTestCase {

  ContentContainerTest();

  void testMeasure() {
    ContentContainer container = new ContentContainer();
    container.measure(1600, 1200);
    expect(container.measuredWidth, equals(0));
    expect(container.measuredHeight, equals(0));
    RectShape rectShape = new RectShape();
    rectShape.width = 16;
    rectShape.height = 8;
    rectShape.hAlign = UIElement.HALIGN_LEFT;
    rectShape.vAlign = UIElement.VALIGN_TOP;
    container.content = rectShape;
    container.measure(1600, 1200);
    expect(container.measuredWidth, equals(16));
    expect(container.measuredHeight, equals(8));
  }

  void testLayout() {
    Application app = createApplication();
    ContentContainer container = new ContentContainer();
    RectShape rectShape = new RectShape();
    rectShape.width = 100;
    rectShape.height = 200;
    rectShape.hAlign = UIElement.HALIGN_LEFT;
    rectShape.vAlign = UIElement.VALIGN_TOP;
    container.content = rectShape;
    app.content = container;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(200));
    app.shutdown();
  }

  void testAll() {
    group("ContentContainer", () {
      test("Measure", testMeasure);
      test("Layout", testLayout);
    });
  }
}
