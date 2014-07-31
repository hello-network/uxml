part of alltests;

class UIElementTest {

  UIElementTest();

  void testMeasure() {
    MyUIElement element = new MyUIElement();
    element.measure(1600, 1200);
    expect(element.measuredWidth, equals(400));
    expect(element.measuredHeight, equals(200));
  }

  void testWidthDefault() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.widthProperty), isFalse);
  }

  void testHeightDefault() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.heightProperty), isFalse);
  }

  void testWidth() {
    MyUIElement element = new MyUIElement();
    element.width = 64;
    expect(element.width, equals(64));
  }

  void testHeight() {
    MyUIElement element = new MyUIElement();
    element.height = 127;
    expect(element.height, equals(127));
  }

  void testHAlign() {
    MyUIElement element = new MyUIElement();
    element.hAlign = UIElement.HALIGN_CENTER;
    expect(element.hAlign, equals(UIElement.HALIGN_CENTER));
  }

  void testVAlign() {
    MyUIElement element = new MyUIElement();
    element.vAlign = UIElement.VALIGN_BOTTOM;
    expect(element.vAlign, equals(UIElement.VALIGN_BOTTOM));
  }

  void testOpacity() {
    MyUIElement element = new MyUIElement();
    expect(element.opacity, equals(1));
    element.opacity = 0.4;
    expect(element.opacity, equals(0.4));
  }

  void testMinWidth() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.minWidthProperty), isFalse);
    element.minWidth = 5.0;
    expect(element.minWidth, equals(5.0));
  }

  void testMaxWidth() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.maxWidthProperty), isFalse);
    element.maxWidth = 7.0;
    expect(element.maxWidth, equals(7.0));
  }

  void testMinHeight() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.minHeightProperty), isFalse);
    element.minHeight = 5.0;
    expect(element.minHeight, equals(5.0));
  }

  void testMaxHeight() {
    MyUIElement element = new MyUIElement();
    expect(element.overridesProperty(UIElement.maxHeightProperty), isFalse);
    element.maxHeight = 7.0;
    expect(element.maxHeight, equals(7.0));
  }

  void testAll() {
    group("UIElement", () {
      test("Measure", testMeasure);
      test("WidthDefault", testWidthDefault);
      test("HeightDefault", testHeightDefault);
      test("Width", testWidth);
      test("Height", testHeight);
      test("HAlign", testHAlign);
      test("VAlign", testVAlign);
      test("Opacity", testOpacity);
      test("MinWidth", testMinWidth);
      test("MaxWidth", testMaxWidth);
      test("MinHeight", testMinHeight);
      test("MaxHeight", testMaxHeight);
    });
  }
}
