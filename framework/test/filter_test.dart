part of alltests;

class FilterTest {

  FilterTest();

  void testFilter() {
    DropShadowFilter shadow = new DropShadowFilter();
    shadow.setProperty(DropShadowFilter.alphaProperty, 0.5);
    expect(shadow.getProperty(DropShadowFilter.alphaProperty), equals(0.5));
  }

  void testFilterChangeEvent() {
    DropShadowFilter shadow = new DropShadowFilter();
    bool changed;
    shadow.addListener(Filter.changedEvent,
      (EventArgs event) {
        DropShadowFilter shadowFilter = event.source;
        changed = true;
        expect(shadow.getProperty(DropShadowFilter.alphaProperty), equals(0.5));
      });
    shadow.setProperty(DropShadowFilter.alphaProperty, 0.5);
    expect(changed, isTrue);
  }

  void testFilterTarget() {
    RectShape rect1 = new RectShape();
    RectShape rect2 = new RectShape();
    Filter glowFilter = new GlowFilter();
    rect1.filters.add(glowFilter);
    bool addFailed = false;
    try {
      rect2.filters.add(glowFilter);
    } on Error catch (e) {
      addFailed = true;
    }
    expect(addFailed, isTrue);
  }

  void testAll() {
    group("Filter", () {
      test("Filter", testFilter);
      test("FilterTarget", testFilterTarget);
    });
  }
}
