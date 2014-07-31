part of alltests;

class BrushTest {

  BrushTest() {
  }

  void testSolidBrush() {
    SolidBrush brush = new SolidBrush(new Color(0xff9988));
    expect(brush.color.rgb, equals(0xff9988));
    brush.color = new Color(0x440055);
    expect(brush.color.rgb, equals(0x440055));
  }

  void testSolidBrushCloning() {
    SolidBrush solid = new SolidBrush(new Color(0xff99bb));
    SolidBrush solidClone = solid.clone();
    expect(solidClone.color.argb, equals(solid.color.argb));
    solid = new SolidBrush(Color.fromARGB(0x10203040));
    solidClone = solid.clone();
    expect(solidClone.color.argb, equals(solid.color.argb));
  }

  void testLinearBrushConstructor() {
    LinearBrush brush = new LinearBrush();
    expect(brush.start.equals(new Coord(0, 0)), isTrue);
    expect(brush.end.equals(new Coord(0, 1)), isTrue);
    expect(brush.stops.length, equals(0));
    LinearBrush brush2 = LinearBrush.create(new Coord(0, 0), new Coord(1, 1),
        Color.fromRGB(0xff0000), Color.fromRGB(0xff00));
    expect(brush2.stops.length, equals(2));
  }

  void testLinearBrushGettersSetters() {
    LinearBrush brush = new LinearBrush();
    brush.start = new Coord(23, 23);
    expect(brush.start.equals(new Coord(23, 23)), isTrue);
    brush.end = new Coord(0.4, 0.5);
    expect(brush.end.equals(new Coord(0.4, 0.5)), isTrue);
    brush.stops.add(new GradientStop(Color.BLACK, 0.0));
    expect(brush.stops.length, equals(1));
  }

  void testRadialBrushConstructor() {
    RadialBrush brush = new RadialBrush();
    expect(brush.origin.equals(new Coord(0.5, 0.5)), isTrue);
    expect(brush.center.equals(new Coord(0.5, 0.5)), isTrue);
    expect(brush.radius.equals(new Coord(0.5, 0.5)), isTrue);
    expect(brush.stops.length, equals(0));
  }

  void testRadialBrushGettersSetters() {
    RadialBrush brush = new RadialBrush();
    brush.origin = new Coord(2, 2);
    expect(brush.origin.equals(new Coord(2, 2)), isTrue);
    brush.center = new Coord(0.1, 0.1);
    expect(brush.center.equals(new Coord(0.1, 0.1)), isTrue);
    brush.radius = new Coord(1, 1);
    expect(brush.radius.equals(new Coord(1, 1)), isTrue);
    expect(brush.stops.length, equals(0));
    brush.stops.add(new GradientStop(Color.BLACK, 0.0));
    expect(brush.stops.length, equals(1));
  }

  void testBrushCloning() {
    LinearBrush linear = LinearBrush.create(new Coord(1, 1), new Coord(2, 2),
        new Color(0xff0000), new Color(0xff00));
    LinearBrush linearClone = linear.clone();
    expect(linear.start.equals(linearClone.start), isTrue);
    expect(linear.end.equals(linearClone.end), isTrue);
    expect(linear.stops.length, equals(2));
    expect(linear.stops[0].color.rgb, equals(0xff0000));
    expect(linear.stops[1].color.rgb, equals(0xff00));
    RadialBrush radial = RadialBrush.create(new Coord(1, 1), new Coord(2, 2),
        new Coord(3, 3), new Color(0xff0000), new Color(0xff00));
    RadialBrush radialClone = radial.clone();
    expect(radial.origin.equals(radialClone.origin), isTrue);
    expect(radial.center.equals(radialClone.center), isTrue);
    expect(radial.radius.equals(radialClone.radius), isTrue);
    expect(radial.stops.length, equals(2));
    expect(radial.stops[0].color.rgb, equals(0xff0000));
    expect(radial.stops[1].color.rgb, equals(0xff00));
  }

  void testAll() {
    group("Brush", () {
      test("SolidBrush", testSolidBrush);
      test("SolidBrushCloning", testSolidBrushCloning);
      test("LinearBrushConstructor", testLinearBrushConstructor);
      test("LinearBrushGettersSetters", testLinearBrushGettersSetters);
      test("RadialBrushConstructor", testRadialBrushConstructor);
      test("RadialBrushGettersSetters", testRadialBrushGettersSetters);
      test("BrushCloning", testBrushCloning);
    });
  }
}
