part of alltests;

class EllipseShapeTest {

   EllipseShapeTest();

  void testMeasure() {
    EllipseShape shape = new EllipseShape();
    shape.width = 200;
    shape.height = 100;
    shape.measure(400, 500);
    expect(shape.measuredWidth, equals(200));
    expect(shape.measuredHeight, equals(100));
  }

  void testAll() {
    group("EllipseShape", () {
      test("Measure", testMeasure);
    });
  }
}
