part of alltests;

class AppTestCase {
  static final num HOST_APP_HEIGHT = 1024;
  static final num HOST_APP_WIDTH = 1280;

  Application createApplication() {
    Application app = new Application();
    app.initialize(window);
    app.setHostSize(HOST_APP_WIDTH, HOST_APP_HEIGHT);
    return app;
  }
}
