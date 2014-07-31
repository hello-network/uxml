part of alltests;

class GridRowTest {

  GridRowTest();

  void testHeight() {
    GridRow gridRow = new GridRow();
    expect(gridRow.overridesProperty(GridRow.heightProperty), isFalse);
    gridRow.height = 20;
    expect(gridRow.height, equals(20.0));
  }

  void testHeightContraints() {
    GridRow gridRow = new GridRow();
    expect(gridRow.minHeight, equals(0));
    expect(gridRow.overridesProperty(GridRow.maxHeightProperty), isFalse);
    gridRow.minHeight = 10;
    gridRow.maxHeight = 30;
    expect(gridRow.minHeight, equals(10));
    expect(gridRow.maxHeight, equals(30));
  }

  void testAll() {
    group("GridRow", () {
      test("Height", testHeight);
      test("HeightContraints", testHeightContraints);
    });
  }
}
