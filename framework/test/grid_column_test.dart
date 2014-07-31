part of alltests;

class GridColumnTest {

  GridColumnTest();

  void testWidth() {
    GridColumn gridColumn = new GridColumn();
    expect(gridColumn.overridesProperty(GridColumn.widthProperty), isFalse);
    gridColumn.width = 30;
    expect(gridColumn.width, equals(30.0));
  }

  void testWidthContraints() {
    GridColumn gridColumn = new GridColumn();
    expect(gridColumn.minWidth, equals(0.0));
    expect(gridColumn.overridesProperty(GridColumn.maxWidthProperty), isFalse);
    gridColumn.minWidth = 10;
    gridColumn.maxWidth = 30;
    expect(gridColumn.minWidth, equals(10));
    expect(gridColumn.maxWidth, equals(30));
  }

  void testAll() {
    group("GridColumn", () {
      test("Width", testWidth);
      test("WidthContraints", testWidthContraints);
    });
  }
}
