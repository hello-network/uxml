part of alltests;

// TODO(ferhat): Add tests for tab key processing.
class FocusManagerTest extends AppTestCase {

  FocusManagerTest();

  void testInitialFocus() {
    Application app = createApplication();
    expect(Application.focusManager.focusedElement, isNull);
    app.shutdown();
  }

  void testSetFocus() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    app.content = canvas;
    canvas.setFocus();
    expect(Application.focusManager.focusedElement, equals(canvas));
    app.shutdown();
  }

  void testAll() {
    group("FocusManager", () {
      test("InitialFocus", testInitialFocus);
      test("SetFocus", testSetFocus);
    });
  }
}
