part of alltests;

class ControlTest extends AppTestCase {

  ControlTest();

  void testBackground() {
    Control control = new Control();
    SolidBrush brush = new SolidBrush(Color.fromRGB(0xff0000));
    control.background = brush;
    expect(control.background, equals(brush));
  }

  void testFontName() {
    Control control = new Control();
    control.fontName = "Arial";
    expect(control.fontName, equals("Arial"));
  }

  void testFontBold() {
    Control control = new Control();
    expect(control.fontBold, isFalse);
    control.fontBold = true;
    expect(control.fontBold, isTrue);
    control.fontBold = false;
    expect(control.fontBold, isFalse);
  }

  void testFontSize() {
    Control control = new Control();
    control.fontSize = 10.0;
    expect(control.fontSize, equals(10.0));
    control.fontSize = 16.0;
    expect(control.fontSize, equals(16.0));
  }

  void testTextColor() {
    Control control = new Control();
    control.textColor = Color.fromRGB(0);
    expect(control.textColor.rgb, equals(0));
    control.textColor = Color.fromRGB(0xff0000);
    expect(control.textColor.rgb, equals(0xff0000));
  }

  void testSwitchingChromes() {
    Application app = createApplication();
    Function createElement = (UIElement targetElement) {
      return new UIElement();
    };
    Control control = new Control();
    control.initSurface(app.rootSurface);
    Chrome chrome1 = new Chrome("one", Control.controlElementDef,
        createElement);
    Effect effect1 = new Effect();
    effect1.property = UIElement.stateProperty;
    effect1.value = "one";
    chrome1.effects.add(effect1);
    Chrome chrome2 = new Chrome("two", Control.controlElementDef,
        createElement);
    Effect effect2 = new Effect();
    effect2.property = UIElement.stateProperty;
    effect2.value = "two";
    chrome2.effects.add(effect2);
    control.chrome = chrome1;
    control.initSurface(app.rootSurface);
    expect(control.effects.length, equals(1));
    expect(control.effects[0].value, equals("one"));
    control.chrome = chrome2;
    expect(control.effects.length, equals(1));
    expect(control.effects[0].value, equals("two"));
    app.shutdown();
  }

  void testAddAndRemoveChromes() {
    Application app = createApplication();
    Function createElement = (UIElement targetElement) {
      return new UIElement();
    };
    Control control = new Control();
    control.initSurface(app.rootSurface);
    Effect effect1 = new Effect();
    effect1.property = UIElement.stateProperty;
    effect1.value = "one";
    control.effects.add(effect1);
    Chrome chrome = new Chrome("chrome", Control.controlElementDef,
        createElement);
    Effect effect2 = new Effect();
    effect2.property = UIElement.stateProperty;
    effect2.value = "two";
    chrome.effects.add(effect2);
    control.chrome = chrome;
    expect(control.effects.length, equals(2));
    expect(control.effects[0].value, equals("one"));
    expect(control.effects[1].value, equals("two"));
    control.chrome = null;
    expect(control.effects.length, equals(1));
    expect(control.effects[0].value, equals("one"));
    app.shutdown();
  }

  void testAll() {
    group("Control", () {
      test("Background", testBackground);
      test("FontName", testFontName);
      test("FontBold", testFontBold);
      test("FontSize", testFontSize);
      test("TextColor", testTextColor);
      test("SwitchingChromes", testSwitchingChromes);
      test("AddAndRemoveChromes", testAddAndRemoveChromes);
    });
  }
}
