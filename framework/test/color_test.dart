part of alltests;

class ColorTest {

  ColorTest();

  void testColorConstructor() {
    Color c = new Color(0x554433);
    expect(c.R, equals(0x55));
    expect(c.G, equals(0x44));
    expect(c.B, equals(0x33));
  }

  void testFromRGB() {
    Color c = Color.fromRGB(0x554433);
    expect(c.R, equals(0x55));
    expect(c.G, equals(0x44));
    expect(c.B, equals(0x33));
  }

  void testFromARGB() {
    Color c = Color.fromARGB(0xaa554433);
    expect(c.A, equals(0xaa));
    expect(c.R, equals(0x55));
    expect(c.G, equals(0x44));
    expect(c.B, equals(0x33));
  }

  void testColorValueSetter() {
    Color c = new Color(0x0);
    c.argb = 0xaa554433;
    expect(c.A, equals(0xaa));
    expect(c.R, equals(0x55));
    expect(c.G, equals(0x44));
    expect(c.B, equals(0x33));
    c.rgb = 0x113344;
    expect(c.A, equals(0xff));
    expect(c.R, equals(0x11));
    expect(c.G, equals(0x33));
    expect(c.B, equals(0x44));
  }

  void testColorSetters() {
    Color c = new Color(0x0);
    c.A = 234;
    expect(c.A, equals(234));
    c.R = 233;
    expect(c.R, equals(233));
    c.G = 232;
    expect(c.G, equals(232));
    c.B = 231;
    expect(c.B, equals(231));
    c.alpha = 0.5;
    expect(c.alpha, closeTo(0.5, 0.002));
    expect(127, c.A);
    c.alpha = 1;
    expect(c.alpha, equals(1));
    expect(c.A, equals(255));
  }

  void testAll() {
    group("Color", () {
      test("ColorConstructor", testColorConstructor);
      test("FromRGB(", testFromRGB);
      test("FromARGB", testFromARGB);
      test("ColorValueSetter", testColorValueSetter);
      test("ColorSetters", testColorSetters);
    });
  }
}
