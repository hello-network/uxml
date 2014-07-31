part of alltests;

class PathTokenizerTest {

  PathTokenizerTest();

  void testMove() {
    PathTokenizer t = new PathTokenizer("M100,-20");
    int type = t.nextToken();
    String cmd = t.command;
    expect(type, equals(PathTokenizer.TOKENTYPE_CMD));
    expect(cmd, equals("M"));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    num x = t.number;
    expect(x, equals(100));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    num y = t.number;
    expect(y, equals(-20));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_EOF));
  }

  void testNumbers() {
    PathTokenizer t = new PathTokenizer("1.2 2.5,-.3-20");
    int type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(1.2));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(2.5));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(-0.3));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(-20));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_EOF));
  }

  void testClosePath() {
    PathTokenizer t = new PathTokenizer("M100,-20zM0-1z");
    int type = t.nextToken();
    String cmd = t.command;
    expect(type, equals(PathTokenizer.TOKENTYPE_CMD));
    expect(cmd, equals("M"));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    num x = t.number;
    expect(x, equals(100));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    num y = t.number;
    expect(y, equals(-20));
    type = t.nextToken();
    cmd = t.command;
    expect(type, equals(PathTokenizer.TOKENTYPE_CMD));
    expect(cmd, equals("z"));
    type = t.nextToken();
    cmd = t.command;
    expect(type, equals(PathTokenizer.TOKENTYPE_CMD));
    expect(cmd, equals("M"));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(0));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_NUMBER));
    expect(t.number, equals(-1));
    type = t.nextToken();
    cmd = t.command;
    expect(type, equals(PathTokenizer.TOKENTYPE_CMD));
    expect(cmd, equals("z"));
    type = t.nextToken();
    expect(type, equals(PathTokenizer.TOKENTYPE_EOF));
  }

  void testAll() {
    group("PathTokenizer", () {
      test("Move", testMove);
      test("Numbers", testNumbers);
      test("ClosePath", testClosePath);
    });
  }
}
