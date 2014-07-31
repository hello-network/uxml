part of alltests;

class GridDefTest {

  GridDefTest();

  void testDefaultLayoutType() {
    GridDef gridDef = new GridDef();
    expect(gridDef.layoutType, equals(LayoutType.AUTO));
  }

  void testLayoutType() {
    GridDef gridDef = new GridDef();
    gridDef.layoutType = LayoutType.FIXED;
    expect(gridDef.layoutType, equals(LayoutType.FIXED));
  }

  void testFixedLayoutInitWithNoLength() {
    GridDef gridDef = new GridDef();
    gridDef.layoutType = LayoutType.FIXED;
    gridDef.minLength = 20;
    gridDef.initLayoutSizes();
    expect(gridDef.minLayoutSize, equals(20));
    expect(gridDef.minLayoutSize, equals(gridDef.layoutSize));
    GridDef gridDef2 = new GridDef();
    gridDef2.layoutType = LayoutType.FIXED;
    gridDef2.minLength = 10;
    gridDef2.maxLength = 30;
    gridDef2.initLayoutSizes();
    expect(gridDef2.minLayoutSize, equals(10));
    expect(gridDef2.minLayoutSize, equals(gridDef2.layoutSize));
  }

  void testFixedLayoutInitWithLength() {
    GridDef gridDef = new GridDef();
    gridDef.layoutType = LayoutType.FIXED;
    gridDef.length = 50;
    gridDef.minLength = 20;
    gridDef.initLayoutSizes();
    expect(gridDef.minLayoutSize, equals(50));
    expect(gridDef.layoutSize, equals(50));
    GridDef gridDef2 = new GridDef();
    gridDef2.layoutType = LayoutType.FIXED;
    gridDef2.length = 50;
    gridDef2.minLength = 10;
    gridDef2.maxLength = 30;
    gridDef2.initLayoutSizes();
    expect(gridDef2.minLayoutSize, equals(30));
    expect(gridDef2.layoutSize, equals(30));
    GridDef gridDef3 = new GridDef();
    gridDef3.layoutType = LayoutType.FIXED;
    gridDef3.length = 20;
    gridDef3.minLength = 10;
    gridDef3.maxLength = 30;
    gridDef3.initLayoutSizes();
    expect(gridDef3.minLayoutSize, equals(20));
    expect(gridDef3.layoutSize, equals(20));
  }

  void testAutoLayoutWithoutLength() {
    GridDef gridDef = new GridDef();
    gridDef.layoutType = LayoutType.PERCENT;
    gridDef.length = 50;
    gridDef.minLength = 20;
    gridDef.initLayoutSizes();
    expect(gridDef.minLayoutSize, equals(20));
    expect(gridDef.layoutSize, equals(20));
    GridDef gridDef2 = new GridDef();
    gridDef2.layoutType = LayoutType.PERCENT;
    gridDef2.length = 50;
    gridDef2.minLength = 10;
    gridDef2.maxLength = 30;
    gridDef2.initLayoutSizes();
    expect(gridDef2.minLayoutSize, equals(10));
    expect(gridDef2.layoutSize, equals(30));
    GridDef gridDef3 = new GridDef();
    gridDef3.layoutType = LayoutType.PERCENT;
    gridDef3.length = 20;
    gridDef3.minLength = 10;
    gridDef3.maxLength = 30;
    gridDef3.initLayoutSizes();
    expect(gridDef3.minLayoutSize, equals(10));
    expect(gridDef3.layoutSize, equals(30));
  }

  void testAll() {
    group("GridDef", () {
      test("DefaultLayoutType", testDefaultLayoutType);
      test("LayoutType", testLayoutType);
      test("FixedLayoutInitWithNoLength", testFixedLayoutInitWithNoLength);
      test("FixedLayoutInitWithLength", testFixedLayoutInitWithLength);
      test("AutoLayoutWithoutLength", testAutoLayoutWithoutLength);
    });
  }
}
