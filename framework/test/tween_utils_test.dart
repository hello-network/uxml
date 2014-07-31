part of alltests;

class TweenUtilsTest {

  TweenUtilsTest();

  void testTweenNumbers() {
    expect(TweenUtils.tweenNumber(1, 9, 0.0), equals(1));
    expect(TweenUtils.tweenNumber(1, 9, 0.5), equals(5));
    expect(TweenUtils.tweenNumber(1, 9, 1.0), equals(9));
  }

  void testTweenInts() {
    expect(TweenUtils.tweenInt(1, 9, 0.0), equals(1));
    expect(TweenUtils.tweenInt(1, 9, 0.5), equals(5));
    expect(TweenUtils.tweenInt(1, 9, 1.0), equals(9));
  }

  void testTweenPoints() {
    Coord p1 = new Coord(0, 0);
    Coord p2 = new Coord(1, 1);
    Coord p3 = new Coord(0, 0);
    TweenUtils.tweenPoint(p1, p2, p3, 0.0);
    expect(p3.equals(p1), isTrue);
    TweenUtils.tweenPoint(p1, p2, p3, 1.0);
    expect(p3.equals(p2), isTrue);
    TweenUtils.tweenPoint(p1, p2, p3, 0.5);
    expect(p3.equals(new Coord(0.5, 0.5)), isTrue);
  }

  void testTweenColors() {
    Color c1 = new Color(0xFF000000);
    Color c2 = new Color(0xffffffff);
    Color c3 = new Color(0x0);
    TweenUtils.tweenColor(c1, c2, c3, 0);
    expect(c3.rgb, equals(c1.rgb));
    TweenUtils.tweenColor(c1, c2, c3, 1);
    expect(c3.rgb, equals(c2.rgb));
    TweenUtils.tweenColor(c1, c2, c3, 0.5);
    expect(c3.argb, equals(0xff808080));
  }

  void testAll() {
    group("TweenUtils", () {
      test("TweenNumbers", testTweenNumbers);
      test("TweenInts", testTweenInts);
      test("TweenPoints", testTweenPoints);
      test("TweenColors", testTweenColors);
    });
  }
}
