part of alltests;

class OverlayContainerTest extends AppTestCase {

  OverlayContainerTest();

  void testMoveOverlay() {
    Application app = createApplication();
    app.setHostSize(1024, 768);
    Canvas canvas = new Canvas();
    OverlayContainer container = new OverlayContainer();
    container.content = canvas;
    RectShape rectShape = new RectShape();
    rectShape.width = 100;
    rectShape.height = 200;
    rectShape.hAlign = UIElement.HALIGN_LEFT;
    rectShape.vAlign = UIElement.VALIGN_TOP;
    Canvas.setChildLeft(rectShape, 16);
    Canvas.setChildTop(rectShape, 16);
    canvas.addChild(rectShape);
    app.content = container;
    UpdateQueue.flush();
    expect(container.layoutWidth, equals(1024));
    expect(container.layoutHeight, equals(768));
    RectShape overlayShape = new RectShape();
    overlayShape.width = 200;
    overlayShape.height = 300;
    rectShape.addOverlay(overlayShape);
    UpdateQueue.flush();
    Coord oldLocation = overlayShape.localToScreen(new Coord(0, 0));
    Canvas.setChildLeft(rectShape, 32);
    Canvas.setChildTop(rectShape, 20);
    UpdateQueue.flush();
    Coord newLocation = overlayShape.localToScreen(new Coord(0, 0));
    expect(newLocation.x - oldLocation.x, equals(16));
    expect(newLocation.y - oldLocation.y, equals(4));
    app.shutdown();
  }

  void testFindOverlay() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    OverlayContainer container = new OverlayContainer();
    container.content = canvas;
    RectShape rectShape = new RectShape();
    canvas.addChild(rectShape);
    RectShape overlayShape = new RectShape();
    overlayShape.id = "myId";
    rectShape.addOverlay(overlayShape);
    app.content = container;
    expect(container.getOverlay("invalidId"), isNull);
    expect(container.findOverlay(rectShape, "myId"), equals(overlayShape));
    app.shutdown();
  }

  void testAll() {
    group("OverlayContainer", () {
      test("MoveOverlay", testMoveOverlay);
      test("testFindOverlay", testFindOverlay);
    });
  }
}
