part of alltests;

class ClipboardDataTest {

  ClipboardDataTest();

  void testSetData() {
    ClipboardData d = new ClipboardData();
    d.setData(ClipboardData.DATA_FORMAT_TEXT, "Hello1");
    d.setData(ClipboardData.DATA_FORMAT_URL, "http://www.hello.com");
    expect(d.getData(ClipboardData.DATA_FORMAT_TEXT), equals("Hello1"));
    expect(d.getData(ClipboardData.DATA_FORMAT_URL), equals(
        "http://www.hello.com"));
  }

  void testClearData() {
    ClipboardData d = new ClipboardData();
    d.setData(ClipboardData.DATA_FORMAT_TEXT, "Hello1");
    d.setData(ClipboardData.DATA_FORMAT_TEXT, null);
    expect(d.getData(ClipboardData.DATA_FORMAT_TEXT), isNull);
  }

  void testDataOnDemand() {
    bool handlerCalled = false;
    String formatRequested = "";
    ClipboardData d = new ClipboardData();
    d.addListener(ClipboardData.loadDataEvent,
      (ClipboardLoadDataEventArgs e) {
        handlerCalled = true;
        formatRequested = e.dataFormat;
        d.setData("Format2", "On demand data");
      });
    d.setData("Format1", "ABC");
    expect(d.getData("Format1"), equals("ABC"));
    expect(handlerCalled, isFalse);
    Object res = d.getData("Format2");
    expect(res, equals("On demand data"));
    expect(handlerCalled, isTrue);
    res = d.getData("InvalidFormat");
    expect(res, isNull);
  }

  void testAll() {
    group("ClipboardData", () {
      test("SetData", testSetData);
      test("ClearData", testClearData);
      test("DataOnDemand", testDataOnDemand);
    });
  }
}
