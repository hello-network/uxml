part of alltests;

class ButtonTest extends AppTestCase {
  bool clickFired;

  ButtonTest();

  void testIsPressed() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Button button = new Button();
    button.width = 200;
    button.height = 100;
    Canvas.setChildLeft(button, 50);
    Canvas.setChildTop(button, 60);
    canvas.addChild(button);
    app.content = canvas;
    UpdateQueue.flush();
    expect(button.isPressed, isFalse);
    Application.current.sendMouseEvent(button, 400, 0,
        UIElement.mouseDownEvent);
    expect(button.isPressed, isFalse);
    Application.current.sendMouseEvent(button, 400, 0, UIElement.mouseUpEvent);
    expect(button.isPressed, isFalse);
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseDownEvent);
    expect(button.isPressed, isTrue);
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseUpEvent);
    app.shutdown();
  }

  void testClickEvent() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Button button = new Button();
    button.width = 200;
    button.height = 100;
    Canvas.setChildLeft(button, 50);
    Canvas.setChildTop(button, 60);
    canvas.addChild(button);
    app.content = canvas;
    UpdateQueue.flush();
    button.addListener(Button.clickEvent, clickTest);
    clickFired = false;
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseUpEvent);
    expect(clickFired, isTrue);
    clickFired = false;
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button, 400, 0, UIElement.mouseUpEvent);
    expect(clickFired, isFalse);
    app.shutdown();
  }

  // Create 2 buttons side by side. Mousedown on button1, mouse up on button2.
  void testTwoButtonClick() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Button button1 = new Button();
    button1.width = 200;
    button1.height = 100;
    Button button2 = new Button();
    button2.width = 200;
    button2.height = 100;
    Canvas.setChildLeft(button2, 250);
    Canvas.setChildTop(button2, 60);
    canvas.addChild(button1);
    canvas.addChild(button2);
    app.content = canvas;
    UpdateQueue.flush();
    button1.addListener(Button.clickEvent, clickTest);
    clickFired = false;
    Application.current.sendMouseEvent(button1, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button1, 0, 0, UIElement.mouseUpEvent);
    expect(clickFired, isTrue);
    clickFired = false;
    Application.current.sendMouseEvent(button2, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button1, 0, 0, UIElement.mouseUpEvent);
    expect(clickFired, isFalse);
    clickFired = false;
    // Repeat down and up to make sure state is properly cleared.
    Application.current.sendMouseEvent(button1, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button1, 0, 0, UIElement.mouseUpEvent);
    expect(clickFired, isTrue);
    app.shutdown();
  }

  void testClickWithMutationEvent() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Button button = new Button();
    button.width = 200;
    button.height = 100;
    RectShape shape1 = new RectShape();
    shape1.fill = new SolidBrush(Color.BLACK);
    EllipseShape shape2 = new EllipseShape();
    shape2.fill = new SolidBrush(Color.BLACK);
    button.content = shape1;
    Canvas.setChildLeft(button, 50);
    Canvas.setChildTop(button, 60);
    canvas.addChild(button);
    app.content = canvas;
    UpdateQueue.flush();
    button.addListener(Button.clickEvent, clickTest);
    clickFired = false;
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseDownEvent);
    // mutate content of button.
    button.content = shape2;
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseUpEvent);
    expect(clickFired, isTrue);
    app.shutdown();
  }

  void clickTest(EventArgs e) {
    clickFired = true;
  }

  void testAll() {
    group("Button", () {
      test("IsPressed", testIsPressed);
      test("ClickEvent", testClickEvent);
      test("TwoButtonClick", testTwoButtonClick);
      test("ClickMutationEvent", testClickWithMutationEvent);
    });
  }
}
