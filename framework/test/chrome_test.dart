part of alltests;

class ChromeTest extends AppTestCase {

  ChromeTest();

  void testConstructor() {
    Chrome buttonChrome = new Chrome("glowingButton", Button.buttonElementDef,
        createButtonElements);
    expect(buttonChrome.id, equals("glowingButton"));
    expect(buttonChrome.type, equals(Button.buttonElementDef));
  }

  UIElement createButtonElements(UIElement targetElement) {
    Group border = new Group();
    border.margins = new Margin(1, 2, 3, 4);
    ContentContainer container = new ContentContainer();
    container.bindings.add(new PropertyBinding(container,
        ContentContainer.contentProperty, targetElement, ["content"]));
    border.addChild(container);
    return border;
  }

  void testCreateElements() {
    Application app = createApplication();
    app.setHostSize(1024, 768);
    Canvas canvas = new Canvas();
    Button button = new Button();
    RectShape rectShape = new RectShape();
    rectShape.width = 32;
    rectShape.height = 16;
    button.content = rectShape;
    canvas.addChild(button);
    app.content = canvas;
    UpdateQueue.flush();
    expect(button.measuredWidth, equals(32));
    expect(button.measuredHeight, equals(16));
    Button button2 = new Button();
    button2.chrome = new Chrome("buttonWithBorder", Button.buttonElementDef,
        createButtonElements);
    RectShape rectShape2 = new RectShape();
    rectShape2.width = 32;
    rectShape2.height = 16;
    button2.content = rectShape2;
    canvas.addChild(button2);
    UpdateQueue.flush();
    expect(button2.measuredWidth, equals(32 + 1 + 3));
    expect(button2.measuredHeight, equals(16 + 2 + 4));
    app.shutdown();
  }

  void testAll() {
    group("Chrome", () {
      test("Constructor", testConstructor);
      test("CreateElements", testCreateElements);
    });
  }
}
