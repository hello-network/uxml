part of alltests;

class PenTest {

  PenTest();

  void testPenConstructor() {
    Pen pen = new Pen(10);
    expect(pen.thickness, equals(10));
  }

  void testSolidPen() {
    SolidPen pen = new SolidPen(new Color(0xff9988), 1);
    expect(pen.color.rgb, equals(0xff9988));
    pen.color = new Color(0x440055);
    expect(pen.color.rgb, equals(0x440055));
  }

  void testPenCloning() {
    SolidPen solid = new SolidPen(new Color(0xff99bb), 1);
    SolidPen solidClone = solid.clone();
    expect(solidClone.thickness, equals(solid.thickness));
    expect(solidClone.color.argb, equals(solid.color.argb));
  }

  void testAll() {
    group("Pen", () {
      test("PenConstructor", testPenConstructor);
      test("SolidPen", testSolidPen);
      test("PenCloning", testPenCloning);
    });
  }
}
