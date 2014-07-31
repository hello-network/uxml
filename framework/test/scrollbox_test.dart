part of alltests;

class ScrollBoxTest extends AppTestCase {

  ScrollBoxTest();

  void testPanningEnabled() {
    ScrollBox s = new ScrollBox();
    expect(s.panningEnabled, isFalse);
    s.panningEnabled = true;
    expect(s.panningEnabled, isTrue);
    s.panningEnabled = false;
    expect(s.panningEnabled, isFalse);
  }

  void testScrollPoint() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    ScrollBox scrollBox = new ScrollBox();
    scrollBox.chrome = new Chrome("scrollBoxChrome",
        ScrollBox.scrollboxElementDef, createScrollBoxChrome);
    scrollBox.width = 200;
    scrollBox.height = 100;
    RectShape shapeToScroll = new RectShape();
    shapeToScroll.fill = new SolidBrush(Color.fromRGB(0));
    shapeToScroll.width = 1024;
    shapeToScroll.height = 1024;
    scrollBox.content = shapeToScroll;
    canvas.addChild(scrollBox);
    app.content = canvas;
    UpdateQueue.flush();
    expect(scrollBox.scrollPointX, equals(0));
    expect(scrollBox.scrollPointY, equals(0));
    Coord startPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    scrollBox.scrollPointX = 20.0;
    Coord curPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    expect(curPoint.x - startPoint.x, equals(-20.0));
    expect(curPoint.y - startPoint.y, equals(0.0));
    scrollBox.scrollPointY = 30;
    curPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    expect(curPoint.y - startPoint.y, equals(-30.0));
    expect(curPoint.x - startPoint.x, equals(-20.0));
    app.shutdown();
  }

  void testMissingHorizScrollInChrome() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    ScrollBox scrollBox = new ScrollBox();
    scrollBox.chrome = new Chrome("scrollBoxChromeB",
        ScrollBox.scrollboxElementDef, createScrollBoxChromeB);
    scrollBox.width = 200;
    scrollBox.height = 100;
    RectShape shapeToScroll = new RectShape();
    shapeToScroll.fill = new SolidBrush(Color.fromRGB(0));
    shapeToScroll.width = 100;
    shapeToScroll.height = 1024;
    scrollBox.content = shapeToScroll;
    canvas.addChild(scrollBox);
    app.content = canvas;
    UpdateQueue.flush();
    expect(0, scrollBox.scrollPointX);
    expect(0, scrollBox.scrollPointY);
    Coord startPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    scrollBox.scrollPointY = 20.0;
    Coord curPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    expect(curPoint.y - startPoint.y, equals(-20.0));
    // increase size of shape to scroll to make sure scrollbox still stable.
    shapeToScroll.width = 500;
    shapeToScroll.scrollIntoView();
    UpdateQueue.flush();
    Coord newPoint = shapeToScroll.localToScreen(new Coord(0, 0));
    expect(0.0, newPoint.x);
    app.shutdown();
  }

  UIElement createScrollBoxChrome(UIElement targetElement) {
    DockBox dockBox1 = new DockBox();
    Canvas contentPart = new Canvas();
    contentPart.id = "scrollBoxContentPart";
    dockBox1.addChild(contentPart);
    DockBox dockBox2 = new DockBox();
    dockBox2.setProperty(DockBox.dockProperty, Dock.BOTTOM);
    ScrollBar horizontalScrollBarPart = new ScrollBar();
    horizontalScrollBarPart.id = "horizontalScrollBarPart";
    horizontalScrollBarPart.visible = false;
    horizontalScrollBarPart.orientation = UIElement.HORIZONTAL;
    dockBox2.addChild(horizontalScrollBarPart);
    RectShape rectShape1 = new RectShape();
    rectShape1.width = 16.0;
    rectShape1.setProperty(DockBox.dockProperty, Dock.RIGHT);
    dockBox2.addChild(rectShape1);
    dockBox1.addChild(dockBox2);
    ScrollBar verticalScrollBarPart = new ScrollBar();
    verticalScrollBarPart.id = "verticalScrollBarPart";
    verticalScrollBarPart.setProperty(DockBox.dockProperty, Dock.RIGHT);
    dockBox1.addChild(verticalScrollBarPart);
    targetElement.bindings.add(new PropertyBinding(rectShape1, "visible",
        verticalScrollBarPart, ["visible"]));
    return dockBox1;
  }

  /** Creates a scrollbox without horizontal scrollbar part. */
  UIElement createScrollBoxChromeB(UIElement targetElement) {
    DockBox dockBox1 = new DockBox();
    Canvas contentPart = new Canvas();
    contentPart.id = "scrollBoxContentPart";
    dockBox1.addChild(contentPart);
    DockBox dockBox2 = new DockBox();
    dockBox2.setProperty(DockBox.dockProperty, Dock.BOTTOM);
    RectShape rectShape1 = new RectShape();
    rectShape1.width = 16.0;
    rectShape1.setProperty(DockBox.dockProperty, Dock.RIGHT);
    dockBox2.addChild(rectShape1);
    dockBox1.addChild(dockBox2);
    ScrollBar verticalScrollBarPart = new ScrollBar();
    verticalScrollBarPart.id = "verticalScrollBarPart";
    verticalScrollBarPart.setProperty(DockBox.dockProperty, Dock.RIGHT);
    dockBox1.addChild(verticalScrollBarPart);
    targetElement.bindings.add(new PropertyBinding(rectShape1, "visible",
        verticalScrollBarPart, ["visible"]));
    return dockBox1;
  }

  void testAll() {
    group("ScrollBox", () {
      test("PanningEnabled", testPanningEnabled);
      test("ScrollPoint", testScrollPoint);
      test("MissingHorizScrollInChrome", testMissingHorizScrollInChrome);
    });
  }
}
