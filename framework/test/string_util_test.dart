part of alltests;

class StringUtilTest {

  StringUtilTest();

  void testIsWhitespace() {
    expect(StringUtil.isWhitespace(" "), isTrue);
    expect(StringUtil.isWhitespace("\t"), isTrue);
    expect(StringUtil.isWhitespace("\n"), isTrue);
    expect(StringUtil.isWhitespace("\r"), isTrue);
    expect(StringUtil.isWhitespace("\f"), isTrue);
    expect(StringUtil.isWhitespace("0"), isFalse);
    expect(StringUtil.isWhitespace("a"), isFalse);
    expect(StringUtil.isWhitespace("z"), isFalse);
    expect(StringUtil.isWhitespace("A"), isFalse);
    expect(StringUtil.isWhitespace("Z"), isFalse);
    expect(StringUtil.isWhitespace(","), isFalse);
    expect(StringUtil.isWhitespace("."), isFalse);
    expect(StringUtil.isWhitespace(";"), isFalse);
  }

  void testTrimFront() {
    expect(StringUtil.trimFront("  abc"), equals("abc"));
    expect(StringUtil.trimFront(" \t  abc"), equals("abc"));
    expect(StringUtil.trimFront("abc"), equals("abc"));
    expect(StringUtil.trimFront("abc  "), equals("abc  "));
    expect(StringUtil.trimFront(" a b c "), equals("a b c "));
  }

  void testTrimBack() {
    expect(StringUtil.trimBack("abc  "), equals("abc"));
    expect(StringUtil.trimBack(" \t  abc  "), equals(" \t  abc"));
    expect(StringUtil.trimBack("abc"), equals("abc"));
    expect(StringUtil.trimBack("  abc"), equals("  abc"));
    expect(StringUtil.trimBack(" a b c "), equals(" a b c"));
  }

  void testFormatNoArguments() {
    expect(StringUtil.format("hello", []), equals("hello"));
    expect(StringUtil.format("", []), equals(""));
  }

  void testFormatSingleArgumentLeft() {
    expect(StringUtil.format("{0}hello", ["abc"]), equals("abchello"));
  }

  void testFormatSingleArgumentRight() {
    expect(StringUtil.format("hello{0}", ["abc"]), equals("helloabc"));
  }

  void testFormatSingleArgumentMiddle() {
    expect(StringUtil.format("hel{0}lo", ["abc"]), equals("helabclo"));
  }

  void testMultipleArguments() {
    expect(StringUtil.format("{2}hel{1}lo{0}", [3, 2, 1]), equals("1hel2lo3"));
  }

  void testArgumentIndexOutOfRange() {
    bool errorThrown = false;
    try {
      String str = StringUtil.format("{5}hello", [1, 2]);
    } on Error catch (e) {
      errorThrown = true;
    }
    expect(errorThrown, isTrue);
  }

  void testAll() {
    test("StringUtil", () {
      test("IsWhitespace", testIsWhitespace);
      test("TrimFront", testTrimFront);
      test("TrimBack", testTrimBack);
      test("FormatNoArguments", testFormatNoArguments);
      test("FormatSingleArgumentLeft", testFormatSingleArgumentLeft);
      test("FormatSingleArgumentRight", testFormatSingleArgumentRight);
      test("FormatSingleArgumentMiddle", testFormatSingleArgumentMiddle);
      test("MultipleArguments", testMultipleArguments);
      test("ArgumentIndexOutOfRange", testArgumentIndexOutOfRange);
    });
  }
}
