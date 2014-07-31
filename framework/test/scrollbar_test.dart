part of alltests;

class ScrollBarTest {

  ScrollBarTest();

  void testOrientation() {
    ScrollBar s = new ScrollBar();
    expect(s.orientation, equals(UIElement.VERTICAL));
    s.orientation = UIElement.HORIZONTAL;
    expect(s.orientation, equals(UIElement.HORIZONTAL));
    s.orientation = UIElement.VERTICAL;
    expect(s.orientation, equals(UIElement.VERTICAL));
  }

  void testValue() {
    ScrollBar s = new ScrollBar();
    s.value = 20;
    expect(s.value, equals(20));
    s.value = 10;
    expect(s.value, equals(10));
  }

  void testMinValue() {
    ScrollBar s = new ScrollBar();
    s.minValue = 20;
    expect(s.minValue, equals(20));
    s.minValue = 10;
    expect(s.minValue, equals(10));
  }

  void testMaxValue() {
    ScrollBar s = new ScrollBar();
    s.maxValue = 200;
    expect(s.maxValue, equals(200));
    s.maxValue = 100;
    expect(s.maxValue, equals(100));
  }

  void testAll() {
    group("ScrollBar", () {
      test("Orientation", testOrientation);
      test("Value", testValue);
      test("MinValue", testMinValue);
      test("MaxValue", testMaxValue);
    });
  }
}
