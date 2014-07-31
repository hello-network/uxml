part of alltests;

class UISurfaceTest {
  UISurfaceTest() {
  }

  void testSurfaceLocation() {
    Application app = new Application();
    app.initialize(window);
    UISurface container = app.rootSurface.addChild(UIPlatform.createSurface());
    expect(container, isNotNull);
    container.setBackground(new SolidBrush(Color.RED));
    container.setLocation(50, 60, 100, 100);
    UpdateQueue.flush();

    UISurfaceImpl c = container;
    expect(c.hostElement.style.left, equals("50px"));
    expect(c.hostElement.offset.top, equals(60));

    UISurfaceImpl item = container.addChild(UIPlatform.createSurface());
    item.setLocation(8, 8, 16, 16);
    item.setBackground(new SolidBrush(Color.YELLOW));
    UpdateQueue.flush();

    expect(item.hostElement.style.left, equals("8px"));
    expect(item.hostElement.offset.top, equals(8));

    app.shutdown();
  }

  void testAll() {
    group("UISurface", () {
      test("Location", testSurfaceLocation);
    });
  }
}
