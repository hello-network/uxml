part of alltests;

// @author ferhat@ (Ferhat Buyukkokten)

class ElementDefTest {
  void testDefineElement() {
    ElementDef baseDef = ElementRegistry.register("ElementBase1", null,
        null, null);
    ElementDef subDef = ElementRegistry.register("ElementSub1", baseDef, null,
        null);
    expect(subDef.parentDef, equals(baseDef));
    expect(baseDef.name, equals("ElementBase1"));
  }

  void testFindProperty() {
    PropertyDefinition prop1 = ElementRegistry.registerProperty("prop1",
        PropertyType.STRING, PropertyFlags.NONE, null, "Hello");
    ElementDef baseDef = ElementRegistry.register("ElementBase2", null, [prop1],
        null);
    expect(baseDef.getPropertyDefinitions().length, equals(1));
    PropertyDefinition res = baseDef.findProperty("prop1");
    expect(res.name, equals("prop1"));
  }

  void testGetPropertyDefinitions() {
    PropertyDefinition prop1 = ElementRegistry.registerProperty("prop1",
        PropertyType.OBJECT, PropertyFlags.NONE, null, "Hello1");
    ElementDef baseDef = ElementRegistry.register("ElementBase3", null, [prop1],
        null);

    PropertyDefinition prop2 = ElementRegistry.registerProperty("prop2",
        PropertyType.OBJECT, PropertyFlags.NONE, null, "Hello2");
    ElementDef subDef = ElementRegistry.register("ElementSub3", baseDef,
        [prop2], null);
    List<PropertyDefinition> propertiesSimple = subDef.getPropertyDefinitions();
    expect(propertiesSimple.length, equals(1));
    List<PropertyDefinition> properties = subDef.getPropertyDefinitions(
        composite:true);
    expect(properties.length, equals(2));
    expect(subDef.findProperty("prop2"), isNotNull);
    expect(subDef.findProperty("prop1"), isNotNull);
    expect(baseDef.findProperty("prop2"), isNull);
  }

  void testAddEvent() {
    EventDef event1 = new EventDef("EventA", Route.BUBBLE);
    EventDef event2 = new EventDef("EventB", Route.BUBBLE);
    ElementDef baseDef = ElementRegistry.register("ElementBase4", null, null,
        [event1]);
    expect(baseDef.events.length, equals(1));
    baseDef.addEvent(event2);
    expect(baseDef.events.length, equals(2));
  }

  void testAll() {
    group("ElementDef", () {
      test("DefineElement", testDefineElement);
      test("FindProperty", testFindProperty);
      test("GetPropertyDefinitions", testGetPropertyDefinitions);
      test("AddEvent", testAddEvent);
    });
  }
}

