part of alltests;

class CheckBoxTest extends AppTestCase {
  bool clickFired;

  CheckBoxTest();

  void testIsPressed() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    CheckBox checkBox = new CheckBox();
    checkBox.width = 200;
    checkBox.height = 100;
    Canvas.setChildLeft(checkBox, 50);
    Canvas.setChildTop(checkBox, 60);
    canvas.addChild(checkBox);
    app.content = canvas;
    UpdateQueue.flush();
    expect(checkBox.isPressed, isFalse);
    Application.current.sendMouseEvent(checkBox, 400, 0,
        UIElement.mouseDownEvent);
    expect(checkBox.isPressed, isFalse);
    Application.current.sendMouseEvent(checkBox, 400, 0,
        UIElement.mouseUpEvent);
    expect(checkBox.isPressed, isFalse);
    Application.current.sendMouseEvent(checkBox, 0, 0,
        UIElement.mouseDownEvent);
    expect(checkBox.isPressed, isTrue);
    Application.current.sendMouseEvent(checkBox, 0, 0, UIElement.mouseUpEvent);
    app.shutdown();
  }

  void testIsChecked() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    CheckBox checkBox = new CheckBox();
    checkBox.width = 200;
    checkBox.height = 100;
    Canvas.setChildLeft(checkBox, 50);
    Canvas.setChildTop(checkBox, 60);
    canvas.addChild(checkBox);
    app.content = canvas;
    UpdateQueue.flush();
    expect(checkBox.isChecked, isFalse);
    Application.current.sendMouseEvent(checkBox, 0, 0,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(checkBox, 0, 0, UIElement.mouseUpEvent);
    expect(checkBox.isChecked, isTrue);
    Application.current.sendMouseEvent(checkBox, 0, 0,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(checkBox, 400, 0,
        UIElement.mouseUpEvent);
    expect(checkBox.isChecked, isTrue);
    Application.current.sendMouseEvent(checkBox, 0, 0,
        UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(checkBox, 0, 0, UIElement.mouseUpEvent);
    expect(checkBox.isChecked, isFalse);
    app.shutdown();
  }

  void clickTest(EventArgs e) {
    expect(e.source, isNotNull);
    clickFired = true;
  }

  void testAll() {
    group("CheckBox", () {
      test("IsPressed", testIsPressed);
      test("IsChecked", testIsChecked);
    });
  }
}
