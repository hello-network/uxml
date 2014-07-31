part of alltests;

class MarginTest {

  MarginTest();

  void testMarginConstructor() {
    Margin m = new Margin(1, 2, 3, 4);
    expect(m.left, equals(1));
    expect(m.top, equals(2));
    expect(m.right, equals(3));
    expect(m.bottom, equals(4));

    Margin m2 = new Margin.uniform(9);
    expect(m2.left, equals(9));
    expect(m2.top, equals(9));
    expect(m2.right, equals(9));
    expect(m2.bottom, equals(9));

    Margin m3 = new Margin.topLeft(4, 3);
    expect(m3.left, equals(3));
    expect(m3.top, equals(4));
    expect(m3.right, equals(0));
    expect(m3.bottom, equals(0));
  }

  void testLeft() {
    Margin m = new Margin(1, 2, 3, 4);
    expect(m.left, equals(1));
    m.left = -20;
    expect(m.left, equals(-20));
  }

  void testTop() {
    Margin m = new Margin(1, 2, 3, 4);
    expect(m.top, equals(2));
    m.top = 5;
    expect(m.top, equals(5));
  }

  void testRight() {
    Margin m = new Margin(1, 2, 3, 4);
    expect(m.right, equals(3));
    m.right = 50;
    expect(m.right, equals(50));
  }

  void testBottom() {
    Margin m = new Margin(1, 2, 3, 4);
    expect(m.bottom, equals(4));
    m.bottom = 100;
    expect(m.bottom, equals(100));
  }

  void testGrow() {
    Margin m = new Margin(1, 2, 3, 4);
    Rect source = new Rect(10, 20, 100, 200);
    Rect t = m.grow(source);
    expect(t.x, equals(10));
    expect(t.y, equals(20));
    expect(t.width, equals(104));
    expect(t.height, equals(206));
  }

  void testShrink() {
    Margin m = new Margin(1, 2, 3, 4);
    Rect source = new Rect(10, 20, 100, 200);
    Rect t = m.shrink(source);
    expect(t.x, equals(10));
    expect(t.y, equals(20));
    expect(t.width, equals(96));
    expect(t.height, equals(194));
  }

  void testInflate() {
    Margin m = new Margin(1, 2, 3, 4);
    Rect source = new Rect(10, 20, 100, 200);
    Rect t = m.inflate(source);
    expect(t.x, equals(9));
    expect(t.y, equals(18));
    expect(t.width, equals(104));
    expect(t.height, equals(206));
  }

  void testDeflate() {
    Margin m = new Margin(1, 2, 3, 4);
    Rect source = new Rect(10, 20, 100, 200);
    Rect t = m.deflate(source);
    expect(t.x, equals(11));
    expect(t.y, equals(22));
    expect(t.width, equals(96));
    expect(t.height, equals(194));
  }

  void testAll() {
    group('Margin', () {
      test("MarginConstructor", testMarginConstructor);
      test("Left", testLeft);
      test("Top", testTop);
      test("Right", testRight);
      test("Bottom", testBottom);
      test("Grow", testGrow);
      test("Shrink", testShrink);
      test("Inflate", testInflate);
      test("Deflate", testDeflate);
    });
  }
}
