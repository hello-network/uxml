part of alltests;

class RadioButtonTest extends AppTestCase {
  bool clickFired1;
  bool clickFired2;

  RadioButtonTest();

  void testIsPressed() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    RadioButton radio = new RadioButton();
    radio.width = 200;
    radio.height = 100;
    Canvas.setChildLeft(radio, 50);
    Canvas.setChildTop(radio, 60);
    canvas.addChild(radio);
    app.content = canvas;
    UpdateQueue.flush();
    expect(radio.isPressed, isFalse);
    Application.current.sendMouseEvent(radio, 400, 0, UIElement.mouseDownEvent);
    expect(radio.isPressed, isFalse);
    Application.current.sendMouseEvent(radio, 400, 0, UIElement.mouseUpEvent);
    expect(radio.isPressed, isFalse);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseDownEvent);
    expect(radio.isPressed, isTrue);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseUpEvent);
    app.shutdown();
  }

  void testIsChecked() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    RadioButton radio = new RadioButton();
    radio.width = 200;
    radio.height = 100;
    Canvas.setChildLeft(radio, 50);
    Canvas.setChildTop(radio, 60);
    canvas.addChild(radio);
    app.content = canvas;
    UpdateQueue.flush();
    clickFired1 = false;
    radio.addListener(Button.clickEvent, clickHandler1);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(radio, 400, 0, UIElement.mouseUpEvent);
    expect(radio.isChecked, isFalse);
    expect(clickFired1, isFalse);
    expect(radio.isChecked, isFalse);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseUpEvent);
    expect(radio.isChecked, isTrue);
    expect(clickFired1, isTrue);
    clickFired1 = false;
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(radio, 0, 0, UIElement.mouseUpEvent);
    expect(radio.isChecked, isTrue);
    expect(clickFired1, isTrue);
    app.shutdown();
  }

  void testMutualExclusive() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    RadioButton radio1 = new RadioButton();
    radio1.width = 200;
    radio1.height = 100;
    Canvas.setChildLeft(radio1, 50);
    Canvas.setChildTop(radio1, 60);
    canvas.addChild(radio1);
    RadioButton radio2 = new RadioButton();
    radio2.width = 200;
    radio2.height = 100;
    Canvas.setChildLeft(radio2, 50);
    Canvas.setChildTop(radio2, 260);
    canvas.addChild(radio2);
    app.content = canvas;
    UpdateQueue.flush();
    clickFired1 = false;
    radio1.addListener(Button.clickEvent, clickHandler1);
    clickFired2 = false;
    radio2.addListener(Button.clickEvent, clickHandler2);
    expect(radio1.isChecked, isFalse);
    Application.current.sendMouseEvent(radio1, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(radio1, 0, 0, UIElement.mouseUpEvent);
    expect(radio1.isChecked, isTrue);
    expect(clickFired1, isTrue);
    expect(radio2.isChecked, isFalse);
    Application.current.sendMouseEvent(radio2, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(radio2, 0, 0, UIElement.mouseUpEvent);
    expect(radio2.isChecked, isTrue);
    expect(clickFired2, isTrue);
    expect(radio1.isChecked, isFalse);
    app.shutdown();
  }

  void clickHandler1(EventArgs e) {
    clickFired1 = true;
  }

  void clickHandler2(EventArgs e) {
    clickFired2 = true;
  }

  void testAll() {
    group("RadioButton", () {
      test("IsPressed", testIsPressed);
      test("IsChecked", testIsChecked);
      test("MutualExclusive", testMutualExclusive);
    });
  }
}
