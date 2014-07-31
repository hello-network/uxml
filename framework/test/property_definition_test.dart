part of alltests;

// @author ferhat@ (Ferhat Buyukkokten)

class PropertyDefinitionTest {
  void testDefineProperty() {
    PropertyDefinition myProp = ElementRegistry.registerPropertyNoDefault(
        "myPropName", PropertyType.OBJECT, PropertyFlags.REDRAW |
        PropertyFlags.RESIZE, null);
    expect(myProp.name, equals("myPropName"));
    expect(myProp.flags, equals(PropertyFlags.REDRAW | PropertyFlags.RESIZE));
  }

  void testNoDefaultValue() {
    ElementWithOneProp myObject = new ElementWithOneProp();
    expect(ElementWithOneProp.prop1Property.getDefaultValue(
        myObject.getDefinition()), equals(PropertyDefaults.NO_DEFAULT));
  }

  void testDefaultValue() {
    ElementWithOneProp myObject = new ElementWithOneProp();
    expect(ElementWithOneProp.prop2Property.getDefaultValue(
        myObject.getDefinition()), equals("123454321"));
  }

  void testDefaultValueOverride() {
    ElementWithOnePropSub myObject = new ElementWithOnePropSub();
    expect(ElementWithOneProp.prop2Property.getDefaultValue(
        myObject.getDefinition()), equals("ABC"));
  }

  void testPropCallback() {
    ElementWithOneProp myObject = new ElementWithOneProp();
    myObject.prop2 = "Hello1";
    myObject.prop2 = "Hello2";
    myObject.prop2 = "Hello3";
    expect(myObject.callback1Counter, equals(3));
  }

  void testPropCallbackOverride() {
    ElementWithOnePropSub myObject = new ElementWithOnePropSub();
    myObject.prop2 = "Hello1";
    myObject.prop2 = "Hello2";
    myObject.prop2 = "Hello3";
    expect(myObject.callback1Counter, equals(0));
    expect(myObject.callback2Counter, equals(3));
  }

  void testAll() {
    group("PropertyDefinition", () {
      test("DefineProperty", testDefineProperty);
      test("NoDefaultValue", testNoDefaultValue);
      test("DefaultValue", testDefaultValue);
      test("DefaultValueOverride", testDefaultValueOverride);
      test("PropCallback", testPropCallback);
      test("PropCallbackOverride", testPropCallbackOverride);
    });
  }
}

class ElementWithOneProp extends UxmlElement {
    static ElementDef _elementDef = null;
    static PropertyDefinition prop1Property;
    static PropertyDefinition prop2Property;
    int callback1Counter = 0;

    ElementWithOneProp() {
      if (_elementDef == null) {
        prop1Property = ElementRegistry.registerPropertyNoDefault("myPropName1",
            PropertyType.OBJECT, PropertyFlags.REDRAW | PropertyFlags.RESIZE,
            null);
        prop2Property = ElementRegistry.registerProperty("myPropName2",
            PropertyType.OBJECT, PropertyFlags.REDRAW | PropertyFlags.RESIZE,
            callback1, "123454321");
        _elementDef = ElementRegistry.register("ElementWithOneProp", null,
            [prop1Property, prop2Property], null);
      }
    }

    set prop2(String val) {
      setProperty(prop2Property, val);
    }

    static void callback1(IKeyValue element,PropertyDefinition property,
        Object oldValue, Object newValue) {
      ElementWithOneProp target = element;
      target.callback1Counter++;
    }

    ElementDef getDefinition() {
      return _elementDef;
    }
}

class ElementWithOnePropSub extends ElementWithOneProp {
  static ElementDef _elementDefSub = null;
  int callback2Counter = 0;

  ElementWithOnePropSub() {
    if (_elementDefSub == null) {
      _elementDefSub = ElementRegistry.register("ElementWithOnePropSub",
          null, null, null);
      ElementWithOneProp.prop2Property.overrideDefaultValue(_elementDefSub,
          "ABC");
      ElementWithOneProp.prop2Property.overrideCallback(_elementDefSub,
          callback2);
    }
  }

  void callback2(IKeyValue element,PropertyDefinition property, Object oldValue,
      Object newValue) {
    ElementWithOnePropSub target = element;
    target.callback2Counter++;
  }

  ElementDef getDefinition() {
    return _elementDefSub;
  }
}
