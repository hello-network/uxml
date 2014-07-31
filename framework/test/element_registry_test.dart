part of alltests;

// @author ferhat@ (Ferhat Buyukkokten)

class ElementRegistryTest {
  void testCreateElement() {
    ElementDef registeredElement = ElementRegistry.register("MyElement", null,
        null, null);
    ElementDef def = ElementRegistry.getElement("MyElement");
    expect(def, isNotNull);
    expect(def.name, equals("MyElement"));
    expect(def, equals(registeredElement));
  }
  void testRegisterProperty() {
    ElementDef registeredElement = ElementRegistry.register("MyElement1", null,
        null, null);
    PropertyDefinition prop = ElementRegistry.registerProperty("TabIndex",
        PropertyType.INT, PropertyFlags.ATTACHED, null, -1);
    expect(prop.name, equals("TabIndex"));
    expect(prop.getDefaultValue(registeredElement), equals(-1));
    expect(prop.flags, equals(PropertyFlags.ATTACHED));
  }

  void testRegisterPropertyNoDefault() {
    ElementDef registeredElement = ElementRegistry.register("MyElement2", null,
        null, null);
    PropertyDefinition prop = ElementRegistry.registerPropertyNoDefault(
        "MyProp1", PropertyType.OBJECT, PropertyFlags.ATTACHED, null);
    expect(prop.name, equals("MyProp1"));
    expect(prop.getDefaultValue(registeredElement), equals(
        PropertyDefaults.NO_DEFAULT));
    expect(prop.flags, equals(PropertyFlags.ATTACHED));
  }

  void testAll() {
    group("ElementRegistry", () {
      test("CreateElement", testCreateElement);
      test("RegisterProperty", testRegisterProperty);
      test("RegisterPropertyNoDefault", testRegisterPropertyNoDefault);
    });
  }
}

