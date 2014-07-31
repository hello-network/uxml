part of alltests;

class VBoxTest {

  VBoxTest();

  void testMeasure() {
    VBox vBox = new VBox();
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    vBox.addChild(rect1);
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    vBox.addChild(rect2);
    vBox.measure(1600, 1200);
    expect(vBox.measuredWidth, equals(300));
    expect(vBox.measuredHeight, equals(208));
  }

  void testSpacing() {
    VBox vBox = new VBox();
    vBox.spacing = 20;
    RectShape rect1 = new RectShape();
    rect1.width = 300;
    rect1.height = 8;
    vBox.addChild(rect1);
    vBox.measure(1600, 1200);
    expect(vBox.measuredHeight, equals(8));
    RectShape rect2 = new RectShape();
    rect2.width = 16;
    rect2.height = 200;
    vBox.addChild(rect2);
    vBox.measure(1600, 1200);
    expect(vBox.measuredWidth, equals(300));
    expect(vBox.measuredHeight, equals(200 + 8 + 20));
  }

  void testAll() {
    group("VBox", () {
      test("Measure", testMeasure);
      test("Spacing", testSpacing);
    });
  }
}
