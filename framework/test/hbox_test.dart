part of alltests;

class HBoxTest extends AppTestCase {

  HBoxTest();

  void testMeasure() {
    HBox hBox = new HBox();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    hBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    hBox.addChild(rect2);
    hBox.measure(1600, 1200);
    expect(hBox.measuredWidth, equals(316));
    expect(hBox.measuredHeight, equals(200));
  }

  void testSpacing() {
    HBox hBox = new HBox();
    hBox.spacing = 20;
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    hBox.addChild(rect1);
    hBox.measure(1600, 1200);
    expect(hBox.measuredWidth, equals(300));
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    hBox.addChild(rect2);
    hBox.measure(1600, 1200);
    expect(hBox.measuredWidth, equals(300 + 16 + 20));
    expect(hBox.measuredHeight, equals(200));
  }

  void testRelayout() {
    Application app = createApplication();
    HBox hBox = new HBox();
    RectShape rect1 = new RectShape();
    rect1.width = 100;
    rect1.height = 8;
    hBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 100;
    rect2.height = 200;
    hBox.addChild(rect2);
    app.content = hBox;
    hBox.measure(1600, 1200);
    expect(hBox.measuredWidth, equals(200));
    expect(hBox.measuredHeight, equals(200));
    rect1.width = 200;
    UpdateQueue.flush();
    hBox.measure(1600, 1200);
    expect(hBox.measuredWidth, equals(300));
  }

  void testAll() {
    group("HBox", () {
      test("Measure", testMeasure);
      test("Spacing", testSpacing);
      test("Relayout", testRelayout);
    });
  }
}
