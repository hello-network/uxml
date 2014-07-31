part of alltests;

class PopupTest extends AppTestCase {

  PopupTest();

  void testIsOpen() {
    Application app = createApplication();
    Group group = new Group();
    group.hAlign = UIElement.HALIGN_LEFT;
    Popup popup = new Popup();
    group.addChild(popup);
    Button button = new Button();
    RectShape rectShape = new RectShape();
    rectShape.width = 100;
    rectShape.height = 24;
    button.content = rectShape;
    popup.content = button;
    app.content = group;
    UpdateQueue.flush();
    expect(button.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    expect(button.layoutWidth, equals(100));
    expect(button.hasSurface, isTrue);
    popup.isOpen = false;
    expect(button.hasSurface, isFalse);
    app.shutdown();
  }

  void testLocationDefault() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.width = 100;
    popup.height = 40;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = 32;
    rectShape.minHeight = 16;
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(40));
    expect(rectShape.hasSurface, isTrue);
    popup.isOpen = false;
    expect(rectShape.hasSurface, isFalse);
    app.shutdown();
  }

  void testLocationTop() {
    final int RECT_WIDTH = 32;
    final int RECT_HEIGHT = 16;
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.location = OverlayLocation.TOP;
    popup.width = 100;
    popup.height = 40;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = RECT_WIDTH;
    rectShape.minHeight = RECT_HEIGHT;
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100 - RECT_HEIGHT));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(RECT_HEIGHT));
    expect(rectShape.hasSurface, isTrue);
    app.shutdown();
  }

  void testLocationBottom() {
    final int RECT_WIDTH = 32;
    final int RECT_HEIGHT = 16;
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.location = OverlayLocation.BOTTOM;
    popup.width = 100;
    popup.height = 40;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = RECT_WIDTH;
    rectShape.minHeight = RECT_HEIGHT;
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100 + 40));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(RECT_HEIGHT));
    expect(rectShape.hasSurface, isTrue);
    app.shutdown();
  }

  void testLocationTopOrBottom() {
    final int RECT_WIDTH = 32;
    final int RECT_HEIGHT = 16;
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.location = OverlayLocation.TOP_OR_BOTTOM;
    popup.width = 100;
    popup.height = 40;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = RECT_WIDTH;
    rectShape.minHeight = RECT_HEIGHT;
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();

    // There is enough space to open popup upwards.
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100 - RECT_HEIGHT));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(RECT_HEIGHT));
    expect(rectShape.hasSurface, isTrue);

    // Move popup very close to bottom of screen.
    num yPos = Application.current.content.layoutHeight -
        20;
    Canvas.setChildTop(popup, yPos);
    UpdateQueue.flush();
    rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    // Make sure the popup flipped up.
    expect(rectPos.y, equals(yPos - RECT_HEIGHT));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(RECT_HEIGHT));
    app.shutdown();
  }

  void testClickOutsideClosesPopup() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.width = 100;
    popup.height = 40;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = 32;
    rectShape.minHeight = 16;
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(40));
    expect(rectShape.hasSurface, isTrue);

    app.sendMouseEvent(canvas, 5, 5, UIElement.mouseDownEvent);
    app.sendMouseEvent(canvas, 5, 5, UIElement.mouseUpEvent);

    expect(popup.isOpen, isFalse);
  }

  void testClickInsideDoesntClosePopup() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    Popup popup = new Popup();
    popup.width = 100;
    popup.height = 40;
    popup.autoFocus = false;
    canvas.addChild(popup);
    Canvas.setChildLeft(popup, 200);
    Canvas.setChildTop(popup, 100);

    RectShape rectShape = new RectShape();
    rectShape.minWidth = 32;
    rectShape.minHeight = 16;
    rectShape.fill = new SolidBrush(Color.BLACK);
    popup.content = rectShape;
    app.content = canvas;
    UpdateQueue.flush();
    expect(rectShape.layoutWidth, equals(0));
    popup.isOpen = true;
    UpdateQueue.flush();
    Coord rectPos = rectShape.localToScreen(new Coord(0, 0));
    expect(rectPos.x, equals(200));
    expect(rectPos.y, equals(100));
    expect(rectShape.layoutWidth, equals(100));
    expect(rectShape.layoutHeight, equals(40));
    expect(rectShape.hasSurface, isTrue);

    app.sendMouseEvent(rectShape, 2, 2, UIElement.mouseDownEvent);
    app.sendMouseEvent(rectShape, 2, 2, UIElement.mouseUpEvent);

    expect(popup.isOpen, isTrue);
  }

  void testAll() {
    group("Popup", () {
      test("IsOpen", testIsOpen);
      test("LocationDefault", testLocationDefault);
      test("LocationTop", testLocationTop);
      test("LocationBottom", testLocationBottom);
      test("LocationTopOrBottom", testLocationTopOrBottom);
      test("ClickOutsideClosesPopup", testClickOutsideClosesPopup);
      test("ClickInsideDoesntClosePopup", testClickInsideDoesntClosePopup);
    });
  }
}
