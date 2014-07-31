part of alltests;

class LineShapeTest {

  LineShapeTest();

  void testXFrom() {
    LineShape line = new LineShape();
    expect(line.xFrom, equals(0.0));
    line.xFrom = 2.0;
    expect(line.xFrom, equals(2.0));
  }

  void testYFrom() {
    LineShape line = new LineShape();
    expect(line.yFrom, equals(0.0));
    line.yFrom = 3.0;
    expect(line.yFrom, equals(3.0));
  }

  void testXTo() {
    LineShape line = new LineShape();
    expect(line.xTo, equals(0.0));
    line.xTo = 4.0;
    expect(line.xTo, equals(4.0));
  }

  void testYTo() {
    LineShape line = new LineShape();
    expect(line.yTo, equals(0.0));
    line.yTo = 5.0;
    expect(line.yTo, equals(5.0));
  }

  void testAll() {
    group("LineShape", () {
      test("XFrom", testXFrom);
      test("YFrom", testYFrom);
      test("XTo", testXTo);
      test("YTo", testYTo);
    });
  }
}
