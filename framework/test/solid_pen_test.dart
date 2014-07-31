part of alltests;

class SolidPenTest {

  SolidPenTest();

  void testSolidPenConstructor() {
    SolidPen pen = new SolidPen(new Color(0xff9988), 5);
    expect(pen.thickness, equals(5));
    expect(pen.color.rgb, equals(0xff9988));
  }

  void testInvalidSetColorParam() {
    bool exceptionFired = false;
    try {
      SolidPen pen = new SolidPen(Color.BLACK, 1);
      pen.color = null;
    } on ArgumentError catch (e) {
      exceptionFired = true;
    }
    expect(exceptionFired, isTrue);
  }

  void testAll() {
    group("SolidPen", () {
      test("SolidPenConstructor", testSolidPenConstructor);
      test("InvalidSetColorParam", testInvalidSetColorParam);
    });
  }
}
