part of alltests;

class UIElementHitTest extends AppTestCase {
  UIElementHitTest() {
  }

  int mouseDownCount;

  void testSimpleBoundingBox() {
    mouseDownCount = 0;
    Application app = createApplication();
    // Create shape at 50,60,200,100.
    Canvas canvas = new Canvas();
    RectShape shape = new RectShape();
    shape.addListener(UIElement.mouseDownEvent, (EventArgs e) {
        ++mouseDownCount;
      });
    shape.width = 200;
    shape.height = 100;
    Canvas.setChildLeft(shape, 50);
    Canvas.setChildTop(shape, 60);
    canvas.addChild(shape);
    app.content = canvas;
    UpdateQueue.flush();

    // Test transparent shape.
    // Send mouse event relative to canvas.
    Application.current.sendMouseEvent(canvas, 60, 60,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, 60, 60,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(0));

    // Test filled shape.
    shape.fill = new SolidBrush(Color.BLACK);
    // click outside.
    Application.current.sendMouseEvent(canvas, 40, 40,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, 40, 40,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(0));
    // click inside.
    Application.current.sendMouseEvent(canvas, 60, 60,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, 60, 60,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(0));

    app.shutdown();
  }

  void testHitTestWithTransform() {
    mouseDownCount = 0;
    Application app = createApplication();
    // Create shape at 100,50,200,200.
    Canvas canvas = new Canvas();
    RectShape shape = new RectShape();
    shape.addListener(UIElement.mouseDownEvent, (EventArgs e) {
        ++mouseDownCount;
      });

    const int w = 200;
    const int h = 100;
    const int x = 16;
    const int y = 16;
    shape.width = w;
    shape.height = h;
    shape.fill = new SolidBrush(Color.BLACK);
    Canvas.setChildLeft(shape, x);
    Canvas.setChildTop(shape, y);
    canvas.addChild(shape);
    app.content = canvas;
    UpdateQueue.flush();

    // click inside.
    Application.current.sendMouseEvent(canvas, x, y,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, x, y,
        UIElement.mouseUpEvent);
    Application.current.sendMouseEvent(canvas, x + w - 1, y + h - 1,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, x + w - 1, y + h - 1,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(2));

    mouseDownCount = 0;
    // Now apply transform scale.
    num scaleX = 0.5;
    num scaleY = 0.25;
    shape.transform.scaleX = scaleX;
    shape.transform.scaleY = scaleY;
    Application.current.sendMouseEvent(canvas, x, y,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, x, y,
        UIElement.mouseUpEvent);
    Application.current.sendMouseEvent(canvas, x + w - 1, y + h - 1,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, x + w - 1, y + h - 1,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(0));
    num centerX = x + (w ~/ 2);
    num centerY = y + (h ~/ 2);
    Application.current.sendMouseEvent(canvas, centerX, centerY,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, centerX, centerY,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(1));
    int newWidth = (scaleX * w ~/ 2).toInt();
    int newHeight = (scaleY * h ~/ 2).toInt();
    Application.current.sendMouseEvent(canvas, centerX - newWidth,
        centerY - newHeight,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, centerX - newWidth,
        centerY - newHeight,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(2));

    // Test translate.
    mouseDownCount = 0;
    shape.transform.scaleX = 1.0;
    shape.transform.scaleY = 1.0;
    shape.transform.translateX = 1000;
    Application.current.sendMouseEvent(canvas, 1000 + x, y,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(canvas, 1000 + x, y,
        UIElement.mouseUpEvent);
    expect(mouseDownCount, equals(1));
    app.shutdown();
  }

  void testAll() {
    group("UIElement HitTests", () {
      test("SimpleBoundingBox", testSimpleBoundingBox);
      test("HitTestWithTransform", testHitTestWithTransform);
    });
  }
}
