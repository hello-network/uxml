part of alltests;

class CanvasTest extends AppTestCase {

  CanvasTest();

  void testMeasure() {
    Application app = createApplication();
    app.setHostSize(1024, 768);
    Canvas canvas = new Canvas();
    RectShape rectShape = new RectShape();
    rectShape.width = 200;
    rectShape.height = 100;
    Canvas.setChildLeft(rectShape, 50);
    Canvas.setChildTop(rectShape, 60);
    canvas.addChild(rectShape);
    app.content = canvas;
    UpdateQueue.flush();
    expect(canvas.measuredWidth, equals(250));
    expect(canvas.measuredHeight, equals(160));
    app.shutdown();
  }

  void testSetGetChildLeftTop() {
    Canvas canvas = new Canvas();
    RectShape rectShape = new RectShape();
    rectShape.width = 200;
    rectShape.height = 100;
    expect(Canvas.getChildLeft(rectShape), equals(0.0));
    expect(Canvas.getChildTop(rectShape), equals(0.0));
    Canvas.setChildLeft(rectShape, 50);
    Canvas.setChildTop(rectShape, 60);
    expect(Canvas.getChildLeft(rectShape), equals(50.0));
    expect(Canvas.getChildTop(rectShape), equals(60.0));
  }

  void testLayout() {
    Application app = createApplication();
    app.setHostSize(1024, 768);
    Canvas canvas = new Canvas();
    RectShape rectShape = new RectShape();
    rectShape.width = 200;
    rectShape.height = 100;
    Canvas.setChildLeft(rectShape, 50);
    Canvas.setChildTop(rectShape, 60);
    canvas.addChild(rectShape);
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(200));
    expect(rectShape.layoutHeight, equals(100));
    Coord p = rectShape.localToScreen(new Coord(0, 0));
    expect(p.x, equals(50));
    expect(p.y, equals(60));
    app.shutdown();
  }

  void testAll() {
    group("Canvas", () {
      test("Measure", testMeasure);
      test("SetGetChildLeftTop", testSetGetChildLeftTop);
      test("Layout", testLayout);
    });
  }
}
