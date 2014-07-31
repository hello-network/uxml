part of alltests;

class PathShapeTest extends AppTestCase {

  VecPath testPath;

  PathShapeTest() {
    testPath = new VecPath();
    testPath.content = "M14.272,0H1.727C0.776,0,0,0.902,0,2.006v7.869v2.381"
        "v1.739C0,15.099,0.776,16,1.727,16h5.741h1.064h5.741"
        "C15.224,16,16,15.099,16,13.995v-1.739V9.875V2.006"
        "C16,0.902,15.223,0,14.272,0z M9.8,2.969c0.164-0.355,0.449-0.371,"
        "0.637-0.032l3.241,5.824c0.189,0.337,0.06,0.614-0.287,0.614H9.021"
        "L7.448,6.75L9.8,2.969z";
  }

  void testContent() {
    PathShape shape = new PathShape();
    expect(shape.content, isNull);
    VecPath data = new VecPath();
    shape.content = data;
    expect(shape.content, equals(data));
  }

  void testMeasure() {
    Application app = createApplication();
    Panel panel = new Panel();
    PathShape shape = new PathShape();
    shape.content = testPath;
    panel.content = shape;
    app.content = panel;
    UpdateQueue.flush();
    expect(shape.measuredWidth, equals(16.0));
    expect(shape.measuredHeight, equals(16.0));
    app.shutdown();
  }

  void testAll() {
    group("PathShape", () {
      test("Content", testContent);
      test("Measure", testMeasure);
    });
  }
}
