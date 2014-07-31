part of alltests;

class EventDefinitionTest {
  static EventDef myEvent;
  bool handlerCallResult;

  EventDefinitionTest() {
    myEvent = new EventDef("MyEvent", Route.DIRECT);
  }

  void testConstructor() {
    EventDef def = new EventDef("TestName", Route.BUBBLE);
    expect(def.name, equals("TestName"));
    expect(def.route, equals(Route.BUBBLE));
  }

  void testHandler() {
    handlerCallResult = false;
    myEvent.addHandler(UIElement.elementDef, myEventHandler);
    expect(handlerCallResult, isFalse);
    myEvent.callHandler(new UIElement(), new EventArgs(this));
    expect(handlerCallResult, isTrue);
  }

  void myEventHandler(Object target, EventArgs args) {
    handlerCallResult = true;
  }

  void testAll() {
    group("EventDefinition", () {
      test("Constructor", testConstructor);
      test("Handler", testHandler);
    });
  }
}
