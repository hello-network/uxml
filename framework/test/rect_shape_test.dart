part of alltests;

class RectShapeTest {

  RectShapeTest();

  void testRadius() {
    RectShape shape = new RectShape();
    expect(shape.borderRadius, isNull);
    shape.borderRadius = new BorderRadius(5.0, 0, 0, 0);
    expect(shape.borderRadius.topLeft, equals(5.0));
    expect(shape.borderRadius.topRight, equals(0.0));
    shape.borderRadius = new BorderRadius(5.0, 7.0, 0, 0);
    expect(shape.borderRadius.topRight, equals(7.0));
  }

  void testDraw() {
    RectShape shape = new RectShape();
    shape.width = 100;
    shape.height = 50;
    shape.fill = new SolidBrush(Color.BLACK);
    MyUISurfaceImpl surface = new MyUISurfaceImpl();
    shape.onRedraw(surface);
    expect(surface.setBorderRadiusCounter, equals(1));
    expect(surface.setBackgroundCounter, equals(1));
  }

  void testAll() {
    group("RectShape", () {
      test("Radius", testRadius);
      test("Draw", testDraw);
    });
  }
}

class MyUISurfaceImpl extends UISurfaceImpl {
  int setBorderRadiusCounter = 0;
  int setBackgroundCounter = 0;

  void setBorderRadius(BorderRadius borderRadius) {
    super.setBorderRadius(borderRadius);
    ++setBorderRadiusCounter;
  }

  void setBackground(Brush brush) {
    super.setBackground(brush);
    ++setBackgroundCounter;
  }
}