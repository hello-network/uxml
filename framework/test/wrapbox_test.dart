part of alltests;

class WrapBoxTest extends AppTestCase {

  WrapBoxTest();

  void testMeasure() {
    WrapBox wrapBox = new WrapBox();
    RectShape rect1 = new RectShape();
    rect1.width = 100;
    rect1.height = 8;
    wrapBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 100;
    rect2.height = 200;
    wrapBox.addChild(rect2);
    RectShape rect3 = new RectShape();
    rect3.width = 100;
    rect3.height = 150;
    wrapBox.addChild(rect3);
    wrapBox.measure(250, 400);
    expect(wrapBox.measuredWidth, equals(200));
    expect(wrapBox.measuredHeight, equals(350));
  }

  void testMeasureOnVerticalTiling() {
    WrapBox wrapBox = new WrapBox();
    wrapBox.direction = UIElement.VERTICAL;
    RectShape rect1 = new RectShape();
    rect1.width = 8;
    rect1.height = 100;
    wrapBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 200;
    rect2.height = 100;
    wrapBox.addChild(rect2);
    RectShape rect3 = new RectShape();
    rect3.width = 150;
    rect3.height = 100;
    wrapBox.addChild(rect3);
    wrapBox.measure(400, 250);
    expect(wrapBox.measuredWidth, equals(350));
    expect(wrapBox.measuredHeight, equals(200));
  }

  void testEmptyUniformWrapBoxMeasure() {
    WrapBox wrapBox = new WrapBox();
    wrapBox.measure(250, 400);
    expect(wrapBox.measuredWidth, equals(0));
    expect(wrapBox.measuredHeight, equals(0));
    wrapBox.uniformWidth = true;
    wrapBox.measure(250, 400);
    expect(wrapBox.measuredWidth, equals(0));
    expect(wrapBox.measuredHeight, equals(0));
  }

  void testLayout() {
    Application app = createApplication();
    app.setHostSize(250, 768);
    WrapBox wrapBox = new WrapBox();
    wrapBox.hAlign = UIElement.HALIGN_LEFT;
    wrapBox.vAlign = UIElement.VALIGN_TOP;
    RectShape rect1 = new RectShape();
    rect1.width = 100;
    rect1.height = 8;
    wrapBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 100;
    rect2.height = 200;
    wrapBox.addChild(rect2);
    RectShape rect3 = new RectShape();
    rect3.width = 100;
    rect3.height = 150;
    wrapBox.addChild(rect3);
    app.content = wrapBox;
    UpdateQueue.flush();
    expect(wrapBox.measuredWidth, equals(200));
    expect(wrapBox.measuredHeight, equals(350));
    expect(rect2.layoutX, equals(100));
    expect(rect3.layoutX, equals(0));
    app.shutdown();
  }

  void testLayoutOnVerticalTiling() {
    Application app = createApplication();
    app.setHostSize(768, 250);
    WrapBox wrapBox = new WrapBox();
    wrapBox.direction = UIElement.VERTICAL;
    wrapBox.hAlign = UIElement.HALIGN_LEFT;
    wrapBox.vAlign = UIElement.VALIGN_TOP;
    RectShape rect1 = new RectShape();
    rect1.width = 8;
    rect1.height = 100;
    wrapBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 200;
    rect2.height = 100;
    wrapBox.addChild(rect2);
    RectShape rect3 = new RectShape();
    rect3.width = 150;
    rect3.height = 100;
    wrapBox.addChild(rect3);
    app.content = wrapBox;
    UpdateQueue.flush();
    expect(wrapBox.measuredWidth, equals(350));
    expect(wrapBox.measuredHeight, equals(200));
    expect(rect2.layoutY, equals(100));
    expect(rect3.layoutY, equals(0));
    app.shutdown();
  }

  void testAll() {
    group("WrapBox", () {
      test("Measure", testMeasure);
      test("MeasureOnVerticalTiling", testMeasureOnVerticalTiling);
      test("EmptyUniformWrapBoxMeasure", testEmptyUniformWrapBoxMeasure);
      test("Layout", testLayout);
      test("LayoutOnVerticalTiling", testLayoutOnVerticalTiling);
    });
  }
}
