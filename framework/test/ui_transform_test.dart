part of alltests;

class TransformTest {

  TransformTest();

  void testTranslate() {
    UITransform t = new UITransform();
    expect(t.translateX, equals(0.0));
    expect(t.translateY, equals(0.0));
    expect(t.originX, equals(0.5));
    expect(t.originY, equals(0.5));
    t.translateX = 3.0;
    t.translateY = 4.0;
    expect(t.translateX, equals(3.0));
    expect(t.translateY, equals(4.0));
  }

  void testRotate() {
    UITransform t = new UITransform();
    expect(t.rotate, equals(0.0));
    t.rotate = 90;
    Matrix m = t.matrix;
    num newX = m.transformPointX(1, 0);
    num newY = m.transformPointY(1, 0);
    expect(newX, closeTo(0, 0.0005));
    expect(newY, closeTo(1, 0.0005));
    t.rotate = 45;
    newX = m.transformPointX(1, 0);
    newY = m.transformPointY(1, 0);
    expect(newX, closeTo(0.70710678, 0.00001));
    expect(newY, closeTo(0.70710678, 0.00001));
  }

  void testScale() {
    UITransform t = new UITransform();
    expect(t.scaleX, equals(1.0));
    expect(t.scaleY, equals(1.0));
    t.scaleX = 3.0;
    t.scaleY = 4.0;
    expect(t.scaleX, equals(3.0));
    expect(t.scaleY, equals(4.0));
  }

  void testTransformSizeX() {
    UITransform t = new UITransform();
    t.scaleX = 3.0;
    expect(t.transformSizeX(10), equals(30.0));
  }

  void testTransformSizeY() {
    UITransform t = new UITransform();
    t.scaleX = 3.0;
    t.scaleY = 4.0;
    expect(t.transformSizeY(10), equals(40.0));
  }

  void testTransformMatrix() {
    UITransform t = new UITransform();
    t.scaleX = 2.0;
    t.scaleY = 3.0;
    t.translateX = 100;
    t.translateY = -20;
    Matrix m = t.matrix;
    expect(m.a, equals(2.0));
    expect(m.b, equals(0));
    expect(m.c, equals(0));
    expect(m.d, equals(3.0));
    expect(m.tx, equals(100.0));
    expect(m.ty, equals(-20.0));
  }

  void testTarget() {
    TestTransformElement element = new TestTransformElement();
    UITransform t = new UITransform();
    t.target= element;
    t.scaleX = 2.0;
    t.scaleY = 3.0;
    t.translateX = 100;
    t.translateY = -20;
    t.rotate = 90;
    t.originX = 0.2;
    t.originY = 0.8;
    expect(element.transformChangeCounter, equals(7));
  }

  void testOrigin() {
    UITransform t = new UITransform();
    t.originX = 0.3;
    t.originY = 0.8;
    expect(t.originX, equals(0.3));
    expect(t.originY, equals(0.8));
  }

  void testAll() {
    group("UITransform", () {
      test("Translate", testTranslate);
      test("Rotate", testRotate);
      test("Scale", testScale);
      test("TransformSizeX", testTransformSizeX);
      test("TransformSizeY", testTransformSizeY);
      test("TransformMatrix", testTransformMatrix);
      test("Origin", testOrigin);
      test("Target", testTarget);
    });
  }
}

class TestTransformElement extends UIElement {
  int transformChangeCounter = 0;
  TestTransformElement() : super() {
  }

  void onTransformChanged(UITransform t) {
    ++transformChangeCounter;
  }
}
