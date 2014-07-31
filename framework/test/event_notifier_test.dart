part of alltests;

class EventNotifierTest extends AppTestCase {
  static EventDef myEventADef = null;
  static EventDef myEventBDef = null;
  bool eventAFired;
  bool eventBFired;
  int eventFireCounter;
  bool handler1Called;
  bool handler2Called;
  EventHandler handler1Closure;

  EventNotifierTest() {
    if (myEventADef == null) {
      myEventADef = new EventDef ("MyEventA", Route.DIRECT);
      myEventBDef = new EventDef("MyEventB", Route.DIRECT);
    }
  }

  void testListener() {
    UxmlElement notifier = new UxmlElement();
    notifier.addListener(myEventADef, onEventAFired);
    notifier.addListener(myEventBDef, onEventBFired);
    eventFireCounter = 0;
    eventAFired = false;
    eventBFired = false;
    notifier.notifyListeners(myEventADef, new EventArgs(this));
    expect(eventAFired, isTrue);
    expect(eventBFired, isFalse);
    eventAFired = false;
    eventBFired = false;
    notifier.notifyListeners(myEventBDef, new EventArgs(this));
    expect(eventAFired, isFalse);
    expect(eventBFired, isTrue);
  }

  void onEventAFired(EventArgs e) {
    eventAFired = true;
    ++eventFireCounter;
  }

  void onEventBFired(EventArgs e) {
    eventBFired = true;
    ++eventFireCounter;
  }

  void testRemoveListener() {
    UxmlElement notifier = new UxmlElement();
    EventHandler closure1 = onEventAFired;
    EventHandler closure2 = onEventBFired;
    notifier.addListener(myEventADef, closure1);
    notifier.addListener(myEventADef, closure2);
    eventFireCounter = 0;
    notifier.notifyListeners(myEventADef, new EventArgs(this));
    expect(eventFireCounter, equals(2));
    notifier.removeListener(myEventADef, closure2);
    eventFireCounter = 0;
    notifier.notifyListeners(myEventADef, new EventArgs(this));
    expect(eventFireCounter, equals(1));
    notifier.removeListener(myEventADef, closure1);
    eventFireCounter = 0;
    notifier.notifyListeners(myEventADef, new EventArgs(this));
    expect(eventFireCounter, equals(0));
  }

  void testRemoveListenerInsideHandler() {
    UxmlElement notifier = new UxmlElement();
    handler1Called = false;
    handler2Called = false;
    handler1Closure = handler1;
    notifier.addListener(myEventADef, handler1Closure);
    notifier.addListener(myEventADef, handler2);
    notifier.notifyListeners(myEventADef, new EventArgs(notifier));
    expect(handler1Called, isTrue);
    expect(handler2Called, isTrue);
    handler1Called = false;
    handler2Called = false;
    notifier.notifyListeners(myEventADef, new EventArgs(notifier));
    expect(handler1Called, isFalse);
    expect(handler2Called, isTrue);
  }

  void handler1(EventArgs e) {
    handler1Called = true;
    UxmlElement notifier = e.source;
    notifier.removeListener(myEventADef, handler1Closure);
  }

  void handler2(EventArgs e) {
    handler2Called = true;
  }

  void testAll() {
    group("EventNotifier", () {
      test("Listener", testListener);
      test("RemoveListener", testRemoveListener);
      test("RemoveListenerInsideHandler", testRemoveListenerInsideHandler);
    });
  }
}
