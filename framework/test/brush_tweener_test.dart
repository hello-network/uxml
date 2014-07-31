part of alltests;

class BrushTweenerTest {

  BrushTweenerTest();

  void testSolidBrushTween() {
    SolidBrush start = new SolidBrush(new Color(0xff000000));
    SolidBrush end = new SolidBrush(new Color(0xffffffff));
    BrushTweener brushTweener = new BrushTweener(start, end);
    brushTweener.tween = 0;
    SolidBrush tweenBrush = brushTweener.brush;
    expect(tweenBrush.color.argb, equals(start.color.argb));
    brushTweener.tween = 1;
    tweenBrush = brushTweener.brush;
    expect(tweenBrush.color.argb, equals(end.color.argb));
    brushTweener.tween = 0.5;
    tweenBrush = brushTweener.brush;
    expect(tweenBrush.color.argb, equals(0xff808080));
  }

  void testSolid2LinearWithStops() {
    SolidBrush solid = new SolidBrush(new Color(0xffff0000));
    LinearBrush linear = LinearBrush.create(new Coord(0, 0), new Coord(1, 1),
        new Color(0xffffffff), new Color(0xff000000));
    linear.stops[1].offset = 0.85;
    BrushTweener tweener = new BrushTweener(solid, linear);
    tweener.tween = 0;
    expect(tweener.brush is SolidBrush, isTrue);
    tweener.tween = 1;
    expect(tweener.brush is LinearBrush, isTrue);
    tweener.tween = 1.0E-9;
    expect(tweener.brush is LinearBrush, isTrue);
    LinearBrush tweenBrush = tweener.brush;
    expect(tweenBrush.stops.length, equals(3));
    expect(tweenBrush.stops[1].offset, equals(0.85));
  }

  void testSolid2LinearTween() {
    SolidBrush solid = new SolidBrush(new Color(0xffff0000));
    LinearBrush linear = LinearBrush.create(new Coord(0, 0), new Coord(1, 1),
        new Color(0xffffffff), new Color(0xff000000));
    BrushTweener tweener = new BrushTweener(solid, linear);
    tweener.tween = 0;
    expect(tweener.brush is SolidBrush, isTrue);
    tweener.tween = 1;
    expect(tweener.brush is LinearBrush, isTrue);
    tweener.tween = 1.0E-9;
    expect(tweener.brush is LinearBrush, isTrue);
    LinearBrush tweenBrush = tweener.brush;
    expect(tweenBrush.start.equals(new Coord(0, 0)), isTrue);
    expect(tweenBrush.end.equals(new Coord(1, 1)), isTrue);
    expect(tweenBrush.stops.length, equals(2));
    tweenBrush = tweener.brush;
    expect(tweenBrush.stops[0].offset, equals(0));
    expect(tweenBrush.stops[0].color.argb, equals(0xffff0000));
    expect(tweenBrush.stops[1].offset, equals(1));
    expect(tweenBrush.stops[1].color.argb, equals(0xffff0000));
    tweener.tween = 0.5;
    tweenBrush = tweener.brush;
    expect(tweenBrush.stops[0].color.argb, equals(0xffff8080));
    expect(tweenBrush.stops[1].color.argb, equals(0xff800000));
  }

  void testSolid2RadialTween() {
    SolidBrush solid = new SolidBrush(new Color(0xffff0000));
    RadialBrush radial = RadialBrush.create(new Coord(0, 0), new Coord(1, 1),
        new Coord(0.5, 0.5), new Color(0xffffffff), new Color(0xff000000));
    BrushTweener tweener = new BrushTweener(solid, radial);
    tweener.tween = 0;
    expect(tweener.brush is SolidBrush, isTrue);
    tweener.tween = 1;
    expect(tweener.brush is RadialBrush, isTrue);
    tweener.tween = 1.0E-9;
    expect(tweener.brush is RadialBrush, isTrue);
    RadialBrush rb = tweener.brush;
    expect(rb.origin.equals(new Coord(0, 0)), isTrue);
    expect(rb.center.equals(new Coord(1, 1)), isTrue);
    expect(rb.radius.x, closeTo(1, 0.000001));
    expect(rb.radius.y, closeTo(1, 0.000001));
    expect(rb.stops.length, equals(2));
    expect(rb.stops[0].offset, equals(0));
    expect(rb.stops[0].color.argb, equals(0xffff0000));
    expect(rb.stops[1].offset, equals(1));
    expect(rb.stops[1].color.argb, equals(0xffff0000));
    rb = tweener.brush;
    tweener.tween = 0.5;
    expect(rb.stops[0].color.argb, equals(0xffff8080));
    expect(rb.stops[1].color.argb, equals(0xff800000));
  }

  void testLinear2RadialTween() {
    LinearBrush linear = LinearBrush.create(new Coord(0, 0), new Coord(1, 1),
        Color.BLACK, Color.WHITE);
    RadialBrush radial = RadialBrush.create(new Coord(0, 0), new Coord(1, 1),
        new Coord(0.5, 0.5), new Color(0xffffffff), new Color(0xff000000));
    BrushTweener tweener = new BrushTweener(linear, radial);
    tweener.tween = 0;
    expect(tweener.brush is LinearBrush, isTrue);
    tweener.tween = 1;
    expect(tweener.brush is RadialBrush, isTrue);
    tweener.tween = 1.0E-9;
    expect(tweener.brush is RadialBrush, isTrue);
    RadialBrush rb = tweener.brush;
    expect(rb.origin.equals(new Coord(0, 0)), isTrue);
    expect(rb.center.equals(new Coord(1, 1)), isTrue);
    expect(rb.radius.x, closeTo(1, 0.000001));
    expect(rb.radius.y, closeTo(1, 0.000001));
    expect(rb.stops.length,equals(2));
    expect(rb.stops[0].offset, equals(0));
    expect(rb.stops[0].color.argb, equals(0xff000000));
    expect(rb.stops[1].offset, equals(1));
    expect(rb.stops[1].color.argb, equals(0xffffffff));
    tweener.tween = 0.5;
    rb = tweener.brush;
    expect(rb.stops[0].color.argb, equals(0xff808080));
    expect(rb.stops[1].color.argb, equals(0xff808080));
  }

  void testMergingGradientStops() {
    LinearBrush start = LinearBrush.create(new Coord(0, 0), new Coord(0, 1),
        new Color(0x0), new Color(0xffffff));
    LinearBrush end = LinearBrush.create(new Coord(0, 0), new Coord(0, 1),
        new Color(0xffffff), new Color(0x0));
    GradientStop stop = new GradientStop(new Color(0xff0000), 0.5);
    start.stops.insert(1, stop);
    BrushTweener tweener = new BrushTweener(start, end);
    tweener.tween = 1.0E-8;
    LinearBrush lb = tweener.brush;
    List<GradientStop> stops = lb.stops;
    expect(stops.length,equals(3));
    expect(stops[1].offset, closeTo(0.5, 0.000001));
    expect(stops[1].color.rgb, equals(0xff0000));
    tweener.tween = 0.99999999;
    lb = tweener.brush;
    stops = lb.stops;
    expect(stops.length, equals(3));
    expect(stops[1].offset, closeTo(0.5, 0.000001));
    expect(stops[1].color.rgb, equals(0x808080));
    start = LinearBrush.create(new Coord(0, 0), new Coord(0, 1),
        Color.BLACK, Color.WHITE);
    end = LinearBrush.create(new Coord(0, 0), new Coord(0, 1),
        Color.WHITE, Color.BLACK);
    stop = new GradientStop(Color.BLACK, 0.2);
    // start = 0.0,0.2,0.7,1.0
    start.stops.insert(1, stop);
    stop = new GradientStop(Color.BLACK, 0.7);
    start.stops.insert(2, stop);
    // stop = 0.0,0.4,0.9,1.0
    stop = new GradientStop(Color.BLACK, 0.4);
    end.stops.insert(1, stop);
    stop = new GradientStop(Color.BLACK, 0.9);
    end.stops.insert(2, stop);
    tweener = new BrushTweener(start, end);
    tweener.tween = 1.0E-8;
    lb = tweener.brush;
    stops = lb.stops;
    expect(stops.length,equals(6));
    expect(stops[1].offset, closeTo(0.2, 0.000001));
    expect(stops[2].offset, closeTo(0.4, 0.000001));
    expect(stops[3].offset, closeTo(0.7, 0.000001));
    expect(stops[4].offset, closeTo(0.9, 0.000001));
    tweener.tween = 0.99999999;
    lb = tweener.brush;
    stops = lb.stops;
    expect(stops.length, equals(6));
    expect(stops[1].offset, equals(0.2));
    expect(stops[2].offset, equals(0.4));
    expect(stops[3].offset, equals(0.7));
    expect(stops[4].offset, equals(0.9));
  }

  void testAll() {
    Color.initialize();
    group("BrushTweener", () {
      test("SolidBrushTween", testSolidBrushTween);
      test("Solid2LinearWithStops", testSolid2LinearWithStops);
      test("Solid2LinearTween", testSolid2LinearTween);
      test("Solid2RadialTween", testSolid2RadialTween);
      test("Linear2RadialTween", testLinear2RadialTween);
      test("MergingGradientStops", testMergingGradientStops);
    });
  }
}
