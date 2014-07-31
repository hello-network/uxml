part of alltests;

class LabeledControlTest extends AppTestCase {

  LabeledControlTest();

  void testMeasure() {
    Chrome chrome1 = new Chrome("labelControlChrome",
        LabeledControl.labeledcontrolElementDef, createElementsForChrome);
    Application app = createApplication();
    Canvas canvas = new Canvas();
    canvas.width = 300;
    canvas.height = 200;
    LabeledControl labeledControl = new LabeledControl();
    labeledControl.chrome = chrome1;
    RectShape rect1 = new RectShape();
    rect1.width = 100;
    rect1.height = 4;
    rect1.fill = new SolidBrush(Color.fromRGB(0xff0000));
    RectShape rect2 = new RectShape();
    rect2.width = 32;
    rect2.height = 4;
    rect2.fill = new SolidBrush(Color.fromRGB(0xff00));
    RectShape rect3 = new RectShape();
    rect3.width = 2;
    rect3.height = 4;
    rect3.fill = new SolidBrush(Color.fromRGB(0xff));
    labeledControl.content = rect1;
    labeledControl.label = rect2;
    labeledControl.picture = rect3;
    canvas.addChild(labeledControl);
    app.content = canvas;
    UpdateQueue.flush();
    expect(labeledControl.layoutWidth, equals(134));
    app.shutdown();
  }

  UIElement createElementsForChrome(UIElement target) {
    HBox hBox = new HBox();
    ContentContainer contentContainer = new ContentContainer();
    ContentContainer labelContainer = new ContentContainer();
    ContentContainer pictureContainer = new ContentContainer();
    hBox.addChild(pictureContainer);
    hBox.addChild(contentContainer);
    hBox.addChild(labelContainer);
    target.bindings.add(new PropertyBinding(contentContainer, "content",
        target, ["content"]));
    target.bindings.add(new PropertyBinding(labelContainer, "content",
        target, ["label"]));
    target.bindings.add(new PropertyBinding(pictureContainer, "content",
        target, ["picture"]));
    return hBox;
  }

  void testAll() {
    group("LabeledControl", () {
      test("Measure", testMeasure);
    });
  }
}
