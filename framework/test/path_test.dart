part of alltests;

class PathTest {

  PathTest();

  void testInvalidStartSegment() {
    VecPath path = new VecPath();
    try {
      // path can only start with m or M moveto commands
      path.content = "L 200,500";
      List cmds = path.commands;
      // this should not be reached
      throw "path.content succeeded when it should fail";
    } on Error catch (e) {
      expect(e is ArgumentError, isTrue);
    }
  }

  void testParseFailure() {
    VecPath path = new VecPath();
    try {
      // path can only start with m or M moveto commands
      path.content = "m100,100 m200,200 zz";
      List cmds = path.commands;
      // this should not be reached
      throw "path.content succeeded when it should fail";
    } on Error catch (e) {
      expect(e is ArgumentError, isTrue);
    }

    // test with invalid string data
    try {
      // path can only start with m or M moveto commands
      path.content = "m100,100 m200,200 zi n val id data";
      List cmds = path.commands;
      // this should not be reached
      throw "path.content succeeded when it should fail";
    } on Error catch (e) {
      expect(e is ArgumentError, isTrue);
    }

    // test with two consecutive move commands
    try {
      // path can only start with m or M moveto commands
      path.content = "mm100,100 m200,200 z";
      List cmds = path.commands;
      // this should not be reached
      throw "path.content succeeded when it should fail";
    } on Error catch (e) {
      expect(e is ArgumentError, isTrue);
    }
  }

  void testAbsoluteMoveSegment() {
    VecPath path = new VecPath();
    path.content = "M 200,500";
    expect(path.commands.length, equals(1));
    expect(path.commands[0] is MoveCommand, isTrue);
    MoveCommand cmd = path.commands[0];
    expect(cmd.x, equals(200));
    expect(cmd.y, equals(500));
  }

  void testRelativeMoveSegment() {
    VecPath path = new VecPath();
    path.content = "M 200,500 m4 5";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is MoveCommand, isTrue);
    expect(path.commands[1].x, equals(204));
    expect(path.commands[1].y, equals(505));
  }

  void testAbsoluteLineSegment() {
    VecPath path = new VecPath();
    path.content = "m0,0L 200,500";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(200));
    expect(path.commands[1].y, equals(500));
  }

  void testRelativeLineSegment() {
    VecPath path = new VecPath();
    path.content = "M 200,500 l4 5";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(204));
    expect(path.commands[1].y, equals(505));
  }

  void testAbsoluteHorizontalLine() {
    VecPath path = new VecPath();
    path.content = "m0,0H 200";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(200));
    expect(path.commands[1].y, equals(0));
  }

  void testRelativeHorizontalLine() {
    VecPath path = new VecPath();
    path.content = "M 200,500 h4";
    expect(2, path.commands.length);
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(204));
    expect(path.commands[1].y, equals(500));
  }

  void testAbsoluteVerticalLine() {
    VecPath path = new VecPath();
    path.content = "m0,0V 200z";
    expect(path.commands.length, equals(3));
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(0));
    expect(path.commands[1].y, equals(200));
  }

  void testRelativeVerticalLine() {
    VecPath path = new VecPath();
    path.content = "M 200,500 v4";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is LineCommand, isTrue);
    expect(path.commands[1].x, equals(200));
    expect(path.commands[1].y, equals(504));
  }

  void testQuadraticBezier() {
    VecPath path = new VecPath();
    path.content = "M 200,500 q100,100,50,50";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is QuadraticBezierCommand, isTrue);
    QuadraticBezierCommand qc = path.commands[1];
    expect(qc.controlPointX, equals(300));
    expect(qc.controlPointY, equals(600));
    expect(path.commands[1].x, equals(250));
    expect(path.commands[1].y, equals(550));
  }

  void testSmoothQuadraticBezier() {
    VecPath path = new VecPath();
    path.content = "M 200,500 q100,100,50,50 t 200 200";
    expect(path.commands.length, equals(3));
    expect(path.commands[2] is QuadraticBezierCommand, isTrue);
    Coord testPoint;
    QuadraticBezierCommand qc = path.commands[2];
    expect(qc.controlPointX, equals(200));
    expect(qc.controlPointY, equals(500));
    expect(qc.x, equals(450));
    expect(qc.y, equals(750));
  }

  void testCubicBezier() {
    VecPath path = new VecPath();
    path.content = "M 200,500 c100,100,200,200,50,50";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is CubicBezierCommand, isTrue);
    CubicBezierCommand cmd = path.commands[1];
    expect(cmd.controlPoint1X, equals(300));
    expect(cmd.controlPoint1Y, equals(600));
    expect(cmd.controlPoint2X, equals(400));
    expect(cmd.controlPoint2Y, equals(700));
    expect(cmd.x, equals(250));
    expect(cmd.y, equals(550));
  }

  void testSmoothCubicBezier() {
    VecPath path = new VecPath();
    path.content = "M 200,500 c100,100,200,200,50,50 s 100 100 200 200";
    expect(path.commands.length, equals(3));
    expect(path.commands[2] is CubicBezierCommand, isTrue);
    CubicBezierCommand cmd = path.commands[2];
    expect(cmd.controlPoint1X, equals(100));
    expect(cmd.controlPoint1Y, equals(400));
    expect(cmd.controlPoint2X, equals(350));
    expect(cmd.controlPoint2Y, equals(650));
    expect(cmd.x, equals(450));
    expect(cmd.y, equals(750));
  }

  void testCloseSegment() {
    VecPath path = new VecPath();
    path.content = "M 200,500z";
    expect(path.commands.length, equals(2));
    expect(path.commands[1] is CloseCommand, isTrue);
  }

  void testDirection() {
    VecPath path = new VecPath();
    expect(path.direction, equals(VecPath.DIRECTION_UNKNOWN));

    path.content = "M 0 50 L 25 0 L 50 50z";
    expect(path.direction, equals(VecPath.DIRECTION_CLOCKWISE));

    VecPath path2 = new VecPath();
    path2.content = "M 100 0 L 0 0 L 0 50 L 50 50 L 50 0";
    expect(path2.direction, equals(VecPath.DIRECTION_COUNTER_CLOCKWISE));
  }

  void testAll() {
    group("Path", () {
      test("InvalidStartSegment", testInvalidStartSegment);
      test("ParseFailure", testParseFailure);
      test("AbsoluteMoveSegment", testAbsoluteMoveSegment);
      test("RelativeMoveSegment", testRelativeMoveSegment);
      test("AbsoluteLineSegment", testAbsoluteLineSegment);
      test("RelativeLineSegment", testRelativeLineSegment);
      test("AbsoluteHorizontalLine", testAbsoluteHorizontalLine);
      test("RelativeHorizontalLine", testRelativeHorizontalLine);
      test("AbsoluteVerticalLine", testAbsoluteVerticalLine);
      test("RelativeVerticalLine", testRelativeVerticalLine);
      test("QuadraticBezier", testQuadraticBezier);
      test("SmoothQuadraticBezier", testSmoothQuadraticBezier);
      test("CubicBezier", testCubicBezier);
      test("SmoothCubicBezier", testSmoothCubicBezier);
      test("CloseSegment", testCloseSegment);
      test("Direction", testDirection);
    });
  }
}
