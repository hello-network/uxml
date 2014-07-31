part of alltests;

class SliderTest extends AppTestCase {

  SliderTest();

  void testMoveThumb() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    canvas.width = 1024;
    canvas.height = 768;
    Slider slider = new Slider();
    slider.width = 120;
    slider.height = 20;
    RectShape thumb = new RectShape();
    thumb.fill = new SolidBrush(Color.fromRGB(0));
    thumb.width = 20;
    slider.thumb = thumb;
    canvas.addChild(slider);
    app.content = canvas;
    UpdateQueue.flush();
    slider.minValue = 0;
    slider.maxValue = 100;
    expect(slider.value, equals(0.0));
    int thumbPosY = 10;
    Application.current.sendMouseEvent(slider, 1, thumbPosY,
        UIElement.mouseDownEvent);
    expect(slider.value, equals(0.0));
    Application.current.sendMouseEvent(slider, 10, thumbPosY,
        UIElement.mouseMoveEvent);
    Application.current.sendMouseEvent(slider, 30, thumbPosY,
        UIElement.mouseMoveEvent);
    Application.current.sendMouseEvent(slider, 30, thumbPosY,
        UIElement.mouseUpEvent);
    UpdateQueue.flush();
    expect(slider.value, equals(29.0));
    app.shutdown();
  }

  void testTickMarks() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    canvas.width = 1024;
    canvas.height = 768;
    Slider slider = new Slider();
    slider.width = 120;
    slider.height = 20;
    RectShape thumb = new RectShape();
    thumb.fill = new SolidBrush(Color.fromRGB(0));
    thumb.width = 20;
    slider.thumb = thumb;
    expect(slider.ticks, equals(0));
    slider.ticks = 10;
    canvas.addChild(slider);
    app.content = canvas;
    UpdateQueue.flush();
    slider.minValue = 0;
    slider.maxValue = 100;
    expect(slider.value, equals(0.0));
    int thumbPosY = 10;
    Application.current.sendMouseEvent(slider, 1, thumbPosY,
        UIElement.mouseDownEvent);
    expect(slider.value, equals(0.0));
    Application.current.sendMouseEvent(slider, 10, thumbPosY,
        UIElement.mouseMoveEvent);
    Application.current.sendMouseEvent(slider, 27, thumbPosY,
        UIElement.mouseMoveEvent);
    Application.current.sendMouseEvent(slider, 27, thumbPosY,
        UIElement.mouseUpEvent);
    UpdateQueue.flush();
    expect(slider.value, equals(30.0));
    app.shutdown();
  }

  void testAll() {
    group("Slider", () {
      testMoveThumb();
      testTickMarks();
    });
  }
}
