part of alltests;

class MatrixTest {

   MatrixTest();

  void testMatrixConstructor() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    expect(m.a, equals(1));
    expect(m.b, equals(2));
    expect(m.c, equals(3));
    expect(m.d, equals(4));
    expect(m.tx, equals(5));
    expect(m.ty, equals(6));
  }

  void testClone() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    Matrix m2 = m.clone();
    expect(m2.a, equals(1));
    expect(m2.b, equals(2));
    expect(m2.c, equals(3));
    expect(m2.d, equals(4));
    expect(m2.tx, equals(5));
    expect(m2.ty, equals(6));
  }

  void testTranslate() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    m.translate(10, 20);
    expect(m.a, equals(1));
    expect(m.b, equals(2));
    expect(m.c, equals(3));
    expect(m.d, equals(4));
    expect(m.tx, equals(15));
    expect(m.ty, equals(26));
  }

  void testTransformPoint() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    Coord p = new Coord(100, 200);
    Coord result = m.transformPoint(p);
    expect(result.x, equals(505));
    expect(result.y, equals(1106));
  }

  void testTransformPointX() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    expect(m.transformPointX(100, 200), equals(505));
    expect(m.transformPointXInverse(505, 1106), equals(100));
  }

  void testTransformPointY() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    expect(m.transformPointY(100, 200), equals(1106));
    expect(m.transformPointYInverse(505, 1106), equals(200));
  }

  void testTransformSize() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    Size s = new Size(100, 200);
    Size result = m.transformSize(s);
    expect(result.width, equals(500));
    expect(result.height, equals(1100));
  }

  void testTransformSizeX() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    expect(m.transformSizeX(100, 200), equals(500));
  }

  void testTransformSizeY() {
    Matrix m = new Matrix(1, 2, 3, 4, 5, 6);
    expect(m.transformSizeY(100, 200), equals(1100));
  }

  void testRotate() {
    Matrix m = new Matrix.identity();
    m.a = 2;
    m.d = 3;
    m.tx = 10;
    m.ty = 20;
    m.rotate(PI / 4);
    expect(m.a, closeTo(1.4142135, 0.00001));
    expect(m.b, closeTo(-1.4142135, 0.00001));
    expect(m.c, closeTo(2.12132034, 0.00001));
    expect(m.d, closeTo(2.12132034, 0.00001));
    expect(m.tx, closeTo(21.2132034, 0.00001));
    expect(m.ty, closeTo(7.0710678, 0.00001));
  }

  void testInverse() {
    UITransform t = new UITransform();
    t.scaleX = 2;
    t.scaleY = 2;
    Matrix m = t.matrix;
    expect(m.transformPointX(3, 4), equals(6));
    expect(m.transformPointY(3, 4), equals(8));
    expect(m.transformPointXInverse(6, 8), equals(3));
    expect(m.transformPointYInverse(6, 8), equals(4));
    UITransform t2 = new UITransform();
    t2.scaleX = 2;
    t2.scaleY = 3;
    t2.rotate = 30;
    t2.translateX = 10;
    t2.translateY = 100;
    m = t2.matrix;
    expect(m.transformPointX(3, 4), closeTo(9.1961524, 0.00001));
    expect(m.transformPointY(3, 4), closeTo(113.3923048, 0.00001));
    expect(m.transformPointXInverse(9.1961524, 113.3923048),
        closeTo(3, 0.00001));
    expect(m.transformPointYInverse(9.1961524, 113.3923048),
        closeTo(4, 0.00001));
  }

  void testAll() {
    group("Matrix", () {
      test("MatrixConstructor", testMatrixConstructor);
      test("Clone", testClone);
      test("Translate", testTranslate);
      test("TransformPoint", testTransformPoint);
      test("TransformPointX", testTransformPointX);
      test("TransformPointY", testTransformPointY);
      test("TransformSize", testTransformSize);
      test("TransformSizeX", testTransformSizeX);
      test("TransformSizeY", testTransformSizeY);
      test("Inverse", testInverse);
      test("Rotate", testRotate);
    });
  }
}
