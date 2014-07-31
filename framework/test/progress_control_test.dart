part of alltests;

class ProgressControlTest {

  ProgressControlTest();

  void testPercentComplete() {
    ProgressControl control = new ProgressControl();
    control.value = 20.0;
    expect(control.percentComplete, equals(0.2));
    expect(control.percentRemaining, equals(0.8));
    control.minValue = 2.0;
    control.maxValue = 6.0;
    control.value = 4.0;
    expect(control.percentComplete, equals(0.5));
    expect(control.percentRemaining, equals(0.5));
  }

  void testPercentText() {
    ProgressControl control = new ProgressControl();
    control.value = 20.0;
    expect(control.percentText, equals("%20"));
  }

  void testPercentFormat() {
    ProgressControl control = new ProgressControl();
    control.percentFormat = "{0} percent";
    control.value = 20.0;
    expect(control.percentText, equals("20 percent"));
  }

  void testAll() {
    group("ProgressControl", () {
      test("PercentComplete", testPercentComplete);
      test("PercentText", testPercentText);
      test("PercentFormat", testPercentFormat);
    });
  }
}
