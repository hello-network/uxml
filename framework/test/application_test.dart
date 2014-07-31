part of alltests;

class ApplicationTest extends AppTestCase {

  ApplicationTest();

  void testGetCurrent() {
    Application app = createApplication();
    expect(app, equals(Application.current));
    app.shutdown();
  }

  void testAssignContent() {
    Application app = createApplication();
    expect(app.content, isNull);
    Button myButton = new Button();
    app.content = myButton;
    expect(myButton, equals(app.content));
    Canvas myCanvas = new Canvas();
    app.content = myCanvas;
    expect(myCanvas, equals(app.content));
  }

  void testResetContent() {
    Application app = createApplication();
    Canvas myCanvas = new Canvas();
    app.content = myCanvas;
    expect(myCanvas, equals(app.content));
    app.content = null;
    expect(app.content, isNull);
    app.shutdown();
  }

  void testResources() {
    Application app = createApplication();
    app.resources.add("MySpecialBrush", new SolidBrush(
        Color.fromRGB(0xa0b0c0)));
    expect(app.resources.getResource("MySpecialBrush"), isNotNull);
    app.shutdown();
  }

  void testHostSize() {
    Application app = createApplication();
    Canvas rootCanvas = new Canvas();
    app.content = rootCanvas;
    app.setHostSize(1200, 800);
    UpdateQueue.flush();
    expect(rootCanvas.layoutWidth, equals(1200.0));
    expect(rootCanvas.layoutHeight, equals(800.0));
    app.setHostSize(800, 600);
    UpdateQueue.flush();
    expect(rootCanvas.layoutWidth, equals(800.0));
    expect(rootCanvas.layoutHeight, equals(600.0));
    app.shutdown();
  }

  void testKeyRouting() {
    Application app = createApplication();
    MyUIElement myElement = new MyUIElement();
    app.content = myElement;
    app.sendKeyboardEvent(65, 65, KeyboardEventArgs.KEY_DOWN,
        UIElement.keyDownEvent);
    expect(myElement.keyEventArgs.charCode, equals(65));
    app.shutdown();
  }

  void testFindResource() {
    Application app = createApplication();
    app.resources.add("Test1", Color.fromRGB(0x112233));
    Color res = Application.findResource("Test1", "");
    expect(res.rgb, equals(0x112233));
    app.shutdown();
  }

  void testFindResourceInInterface() {
    Application app = createApplication();
    Resources interfaceImpl = new Resources();
    interfaceImpl.add("TestColor", Color.fromRGB(0x112244));
    app.resources.add("MySkin", interfaceImpl);
    Color res = Application.findResource("TestColor", "MySkin");
    expect(res.rgb, equals(0x112244));
    app.shutdown();
  }

  void testAll() {
    group("Application", () {
      test("GetCurrent", testGetCurrent);
      test("AssignContent", testAssignContent);
      test("ResetContent", testResetContent);
      test("Resources", testResources);
      test("HostSize", testHostSize);
      test("KeyRouting", testKeyRouting);
      test("FindResource", testFindResource);
      test("FindResourceInInterface", testFindResourceInInterface);
    });
  }
}

class MyUIElement extends UIElement {
  static final num ITEM_HEIGHT = 200;
  static final num ITEM_WIDTH = 400;
  KeyboardEventArgs keyEventArgs;
  int layoutCallCount = 0;
  int measureCallCount = 0;
  int redrawCallCount = 0;

  MyUIElement() : super();

  bool onMeasure(num availableWidth, num availableHeight) {
    ++measureCallCount;
    setMeasuredDimension(ITEM_WIDTH, ITEM_HEIGHT);
    return false;
  }

  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    ++layoutCallCount;
    super.onLayout(targetX, targetY, targetWidth, targetHeight);
  }

  void onRedraw(UISurface surface) {
    ++redrawCallCount;
    RadialBrush br = RadialBrush.create(new Coord(0.9, 0.5),
        new Coord(0.5, 0.5), new Coord(1.2, 0.5), Color.fromRGB(0xff0000),
        Color.fromRGB(0xff));
    Matrix transform = new Matrix.identity();
    transform.translate(-0.5, -0.5);
    transform.rotate(PI / 4);
    br.transform = transform;
    surface.drawRect(0, 0, layoutWidth, layoutHeight, br, null, null);
  }

  void onKeyDown(KeyboardEventArgs keyArgs) {
    keyEventArgs = keyArgs;
  }

  void onKeyUp(KeyboardEventArgs keyArgs) {
    keyEventArgs = keyArgs;
  }
}
