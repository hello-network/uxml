part of alltests;

class EventArgsTest {

  EventDef myEvent;

  EventArgsTest() {
    myEvent = new EventDef("MyEvent", Route.DIRECT);
  }

  void testHandled() {
    EventArgs e = new EventArgs(this);
    expect(e.handled, isFalse);
    e.handled = true;
    expect(e.handled, isTrue);
    e.handled = false;
    expect(e.handled, isFalse);
  }

  void testEvent() {
    EventArgs e = new EventArgs(this);
    expect(e.event, isNull);
    e.event = myEvent;
    expect(myEvent, equals(e.event));
  }

  void testAll() {
    group("EventArgs", () {
      test("Handled", testHandled);
      test("Event", testEvent);
    });
  }
}
