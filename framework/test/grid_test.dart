part of alltests;

class GridTest extends AppTestCase {

  GridTest();

  void testRowCollection() {
    Grid grid = new Grid();
    grid.rows.add(new GridRow());
    grid.rows.add(new GridRow());
    expect(grid.rows.length, equals(2));
  }

  void testColumnCollection() {
    Grid grid = new Grid();
    grid.columns.add(new GridColumn());
    grid.columns.add(new GridColumn());
    grid.columns.add(new GridColumn());
    expect(grid.columns.length, equals(3));
  }

  void testRowColumnSetters() {
    Grid grid = new Grid();
    UIElement element = new UIElement();
    grid.addChild(element);
    Grid.setChildColumn(element, 2);
    Grid.setChildRow(element, 1);
  }

  void testFixedColumnsLayout() {
    Application app = createApplication();
    Grid grid = new Grid();
    grid.hAlign = UIElement.HALIGN_CENTER;
    grid.vAlign = UIElement.VALIGN_CENTER;
    grid.rows.add(new GridRow());
    GridColumn column = new GridColumn();
    column.layoutType = LayoutType.FIXED;
    column.width = 30;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.FIXED;
    column.width = 40;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.FIXED;
    grid.columns.add(column);
    column.width = 50;
    List<RectShape> rectShapes = [new RectShape(), new RectShape(),
        new RectShape()];
    for (int i = 0; i < 3; ++i) {
      RectShape rectShape = rectShapes[i];
      rectShape.fill = new SolidBrush(Color.fromRGB(i * 0x303030));
      Grid.setChildColumn(rectShape, i);
      rectShape.height = 30 + (i * 20);
      grid.addChild(rectShape);
    }
    app.content = grid;
    app.shutdown();
  }

  void testPercentColumnsLayout() {
    Application app = createApplication();
    Grid grid = new Grid();
    grid.vAlign = UIElement.VALIGN_CENTER;
    grid.rows.add(new GridRow());
    GridColumn column = new GridColumn();
    column.layoutType = LayoutType.PERCENT;
    column.width = 20;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.PERCENT;
    column.width = 30;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.PERCENT;
    grid.columns.add(column);
    column.width = 50;
    List<RectShape> rectShapes = [new RectShape(), new RectShape(),
        new RectShape()];
    for (int i = 0; i < 3; ++i) {
      RectShape rectShape = rectShapes[i];
      rectShape.fill = new SolidBrush(Color.fromRGB(i * 0x303030));
      Grid.setChildColumn(rectShape, i);
      rectShape.height = 30 + (i * 20);
      grid.addChild(rectShape);
    }
    app.content = grid;
    UpdateQueue.flush();
    num w1 = rectShapes[0].layoutWidth;
    num w2 = rectShapes[1].layoutWidth;
    num w3 = rectShapes[2].layoutWidth;
    expect(100 * w1 / (w1 + w2 + w3), equals(20));
    expect(100 * w2 / (w1 + w2 + w3), equals(30));
    expect(100 * w3 / (w1 + w2 + w3), equals(50));
    app.shutdown();
  }

  void testAutoColumnsLayout() {
    Application app = createApplication();
    Grid grid = new Grid();
    grid.width = 700;
    grid.hAlign = UIElement.HALIGN_CENTER;
    grid.vAlign = UIElement.VALIGN_CENTER;
    grid.rows.add(new GridRow());
    GridColumn column = new GridColumn();
    column.layoutType = LayoutType.PERCENT;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.FIXED;
    column.width = 30;
    grid.columns.add(column);
    column = new GridColumn();
    column.layoutType = LayoutType.FIXED;
    grid.columns.add(column);
    column.width = 50;
    List<RectShape> rectShapes = [new RectShape(), new RectShape(),
        new RectShape()];
    for (int i = 0; i < 3; ++i) {
      RectShape rectShape = rectShapes[i];
      rectShape.fill = new SolidBrush(Color.fromRGB(i * 0x303030));
      Grid.setChildColumn(rectShape, i);
      rectShape.height = 30 + (i * 20);
      grid.addChild(rectShape);
    }
    app.content = grid;
    UpdateQueue.flush();
    num w1 = rectShapes[0].layoutWidth;
    num w2 = rectShapes[1].layoutWidth;
    num w3 = rectShapes[2].layoutWidth;
    expect(w1, equals(620));
    expect(w2, equals(30));
    expect(w3, equals(50));
    app.shutdown();
  }

  void testEmptyColumnRow() {
    Application app = createApplication();
    Grid grid = new Grid();
    grid.hAlign = UIElement.HALIGN_CENTER;
    grid.vAlign = UIElement.VALIGN_CENTER;
    List<RectShape> rectShapes = [new RectShape(), new RectShape(),
        new RectShape(), new RectShape()];
    for (int i = 0; i < 4; ++i) {
      if (i != 2) {
        RectShape rectShape = rectShapes[i];
        rectShape.fill = new SolidBrush(Color.fromRGB(i * 0x303030));
        Grid.setChildColumn(rectShape, i);
        Grid.setChildRow(rectShape, i);
        rectShape.width = 10;
        rectShape.height = 20;
        grid.addChild(rectShape);
      }
    }
    app.content = grid;
    UpdateQueue.flush();
    expect(grid.measuredWidth, equals(30.0));
    expect(grid.measuredHeight, equals(60.0));
    app.shutdown();
  }

  void testAll() {
    group("Grid", () {
      test("RowCollection", testRowCollection);
      test("ColumnCollection", testColumnCollection);
      test("RowColumnSetters", testRowColumnSetters);
      test("FixedColumnsLayout", testFixedColumnsLayout);
      test("PercentColumnsLayout", testPercentColumnsLayout);
      test("AutoColumnsLayout", testAutoColumnsLayout);
      test("EmptyColumnRow", testEmptyColumnRow);
    });
  }
}
