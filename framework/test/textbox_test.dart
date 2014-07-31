part of alltests;

class TextBoxTest {

  void testDefaultMaxChars() {
    TextBox textBox = new TextBox();
    expect(textBox.maxChars, equals(0));
    expect(textBox.charsRemaining, equals(0x7FFFFFFF));
    textBox.text = "sample";
    expect(textBox.maxChars, equals(0));
    expect(textBox.charsRemaining, equals(0x7FFFFFFF));
  }

  void testCharsRemaining() {
    TextBox textBox = new TextBox();
    textBox.maxChars = 100;
    expect(textBox.charsRemaining, equals(100));
    textBox.text = "sample";
    expect(textBox.charsRemaining, equals(100 - "sample".length));
    textBox.maxChars = 0;
    expect(textBox.charsRemaining, equals(0x7FFFFFFF));
  }

  void testAll() {
    group("TextBox", () {
      test("DefaultMaxChars", testDefaultMaxChars);
      test("CharsRemaining", testCharsRemaining);
    });
  }
}
