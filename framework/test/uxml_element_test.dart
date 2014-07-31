part of alltests;

class UxmlElementTest {
  ElementTest(String methodName) {
  }

  void testGetPropertyFromSetProperty() {
    BaseClass e = new BaseClass();
    PropertyDefinition propDef = ElementRegistry.registerPropertyNoDefault("w",
        PropertyType.INT, PropertyFlags.NONE, null);
    e.setProperty(propDef, 5);
    expect(e.getProperty(propDef), equals(5));
  }

  void testGetPropertyWithNoDefinition() {
    BaseClass e = new BaseClass();
    expect(e.getProperty(ElementRegistry.registerPropertyNoDefault("unk",
        PropertyType.OBJECT, PropertyFlags.NONE, null)) ==
        PropertyDefaults.NO_DEFAULT, isTrue);
  }

  void testGetPropertyDefaultValue() {
    DerivedClass e = new DerivedClass();
    PropertyDefinition p1 = ElementRegistry.registerProperty("w",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 10);
    PropertyDefinition p2 = ElementRegistry.registerProperty("h",
        PropertyType.NUMBER, PropertyFlags.NONE, null, 15);
    expect(e.getProperty(p1), equals(10));
    expect(e.getProperty(p2), equals(15));
  }

  void testGetPropertyInheritedValue() {
    BaseClass child = new BaseClass();
    BaseClass parent = new BaseClass();
    child.parent = parent;
    PropertyDefinition propDef = ElementRegistry.registerPropertyNoDefault(
        "fontSize", PropertyType.NUMBER, PropertyFlags.INHERIT, null);
    parent.setProperty(propDef, 12.0);
    expect(child.getProperty(propDef), equals(12.0));
    PropertyDefinition propDef2 = ElementRegistry.registerProperty("color",
        PropertyType.INT, PropertyFlags.INHERIT, null, 0xA0A0FF);
    expect(child.getProperty(propDef2), equals(0xA0A0FF));
  }

  void testGetPropertyInheritedValueSetToDefault() {
    BaseClass child = new BaseClass();
    BaseClass parent = new BaseClass();
    PropertyDefinition propDef = ElementRegistry.registerProperty(
        "fontBold", PropertyType.BOOL, PropertyFlags.INHERIT, null, false);
    parent.setProperty(propDef, true);
    child.setProperty(propDef, false);
    // Now wire up parent/child to check property again.
    child.parent = parent;
    expect(child.getProperty(propDef), equals(false));
  }

  void testSetPropertyCallChangeFunction() {
    BaseClass e = new BaseClass();
    bool changed = false;
    PropertyDefinition propDef = ElementRegistry.registerProperty("fontSize",
        PropertyType.NUMBER, PropertyFlags.NONE, (IKeyValue element,
          Object key, Object oldValue, Object newValue) {
          changed = true;
        }, 10);
    e.setProperty(propDef, 12);
    expect(changed, isTrue);
    changed = false;
    DerivedClass d = new DerivedClass();
    d.setProperty(propDef, 1);
    expect(changed, isTrue);
    bool changed2 = false;

    propDef.overrideCallback(d.getDefinition(),
        (IKeyValue element, Object key, Object oldValue,
            Object newValue) {
          changed2 = true;
        });
    propDef.overrideDefaultValue(d.getDefinition(), 5);
    d.setProperty(propDef, 5);
    expect(d.getProperty(propDef), equals(5));
    expect(changed2, isTrue);
  }

  void testNullValueSupport() {
    BaseClass e = new BaseClass();
    PropertyDefinition nullDefaultProp = ElementRegistry.registerProperty(
        "nullDefaultProp", PropertyType.OBJECT, PropertyFlags.NONE, null, null);
    PropertyDefinition nullableProp = ElementRegistry.registerPropertyNoDefault(
        "nullableProp", PropertyType.OBJECT, PropertyFlags.NONE, null);
    expect(e.overridesProperty(nullableProp), isFalse);
    e.setProperty(nullableProp, null);
    expect(e.getProperty(nullableProp), isNull);
    expect(e.overridesProperty(nullableProp), isTrue);
  }

  void testNullValuePropertyChange() {
    UxmlElement element = new UxmlElement();
    element.setProperty(UxmlElement.dataProperty, "blah");
    bool listenerCalled = false;
    element.addListener(UxmlElement.dataProperty,
      (PropertyChangedEvent event) {
        expect(event.newValue, isNull);
        listenerCalled = true;
      });
    element.setProperty(UxmlElement.dataProperty, null);
    expect(listenerCalled, isTrue);
  }

  void testEventRouting() {
    EventDef myDirectEvent = new EventDef("MyDirectEvent", Route.DIRECT);
    EventDef myBubbleEvent = new EventDef("MyBubbleEvent", Route.BUBBLE);
    List<UIElement> calledNodes = <UIElement>[];

    // Create 4 nested containers.
    List<UIElementContainer> list = <UIElementContainer>[];
    for (int i = 0; i < 4 ; i++) {
      UIElementContainer c = new UIElementContainer();
      list.add(c);
      if (i != 0) {
        list[i - 1].addChild(c);
      }
      c.addListener(myDirectEvent, (EventArgs e) {
          calledNodes.add(c);
        });
      c.addListener(myBubbleEvent, (EventArgs e) {
          calledNodes.add(c);
        });
    }
    EventArgs e = new EventArgs(this);
    e.event = myDirectEvent;
    list[3].routeEvent(e);
    expect(calledNodes.length, equals(1));
    expect(list.indexOf(calledNodes[0]), equals(3));

    calledNodes.clear();
    e.event = myBubbleEvent;
    list[3].routeEvent(e);
    expect(calledNodes.length, equals(4));
    expect(list.indexOf(calledNodes[0]), equals(3));
    expect(list.indexOf(calledNodes[1]), equals(2));
    expect(list.indexOf(calledNodes[3]), equals(0));
  }

  /**
   * Test Event routing to make sure setting handled=true stops propagating
   * the event.
   */
  void testEventBubbling() {
    EventDef myBubbleEvent = new EventDef("MyBubbleEvent", Route.BUBBLE);
    List<UIElement> calledNodes = <UIElement>[];

    // Create 4 nested containers.
    List<UIElementContainer> list = <UIElementContainer>[];
    for (int i = 0; i < 4 ; i++) {
      UIElementContainer c = new UIElementContainer();
      list.add(c);
      if (i != 0) {
        list[i - 1].addChild(c);
      }
      c.addListener(myBubbleEvent, (EventArgs e) {
          calledNodes.add(c);
        });
    }
    EventArgs e = new EventArgs(this);
    e.event = myBubbleEvent;
    list[3].routeEvent(e);
    expect(calledNodes.length, equals(4));

    calledNodes.clear();
    list[1].addListener(myBubbleEvent, (EventArgs e) {
        e.handled = true;
      });
    list[3].routeEvent(e);
    // Event should have bubbled up to node 1 and stopped.
    expect(calledNodes.length, equals(3));
    expect(calledNodes.last, equals(list[1]));
  }

  void testEventCapture() {
    EventDef myBubbleEvent = new EventDef("MyBubbleEvent", Route.BUBBLE);
    List<UIElement> calledNodes = <UIElement>[];

    // Create 4 nested containers.
    List<UIElementContainer> list = <UIElementContainer>[];
    for (int i = 0; i < 4 ; i++) {
      UIElementContainer c = new UIElementContainer();
      list.add(c);
      if (i != 0) {
        list[i - 1].addChild(c);
      }
      c.addListener(myBubbleEvent, (EventArgs e) {
          calledNodes.add(c);
        }, (i == 0) || (i == 1));
    }

    EventArgs e = new EventArgs(this);
    e.event = myBubbleEvent;
    list[3].routeEvent(e);

    // We expect the capture listener to be called on root then child followed
    // by the usual bubbling up of event.
    expect(calledNodes.length, equals(4));
    expect(list.indexOf(calledNodes[0]), equals(0));
    expect(list.indexOf(calledNodes[1]), equals(1));
    expect(list.indexOf(calledNodes[2]), equals(3));
    expect(list.indexOf(calledNodes[3]), equals(2));
  }

  void testAll() {
    group("UxmlElement", () {
      test("GetPropertyFromSetProperty", testGetPropertyFromSetProperty);
      test("GetPropertyWithNoDefinition", testGetPropertyWithNoDefinition);
      test("GetPropertyDefaultValue", testGetPropertyDefaultValue);
      test("GetPropertyInheritedValue", testGetPropertyInheritedValue);
      test("GetPropertyInheritedValueSetToDefault",
          testGetPropertyInheritedValueSetToDefault);
      test("SetPropertyCallChangeFunction", testSetPropertyCallChangeFunction);
      test("NullValueSupport", testNullValueSupport);
      test("NullValuePropertyChange", testNullValuePropertyChange);
      test("Event routing", testEventRouting);
      test("Event bubbling", testEventBubbling);
      test("Event capture", testEventCapture);
    });
  }
}


class BaseClass extends UxmlElement {
  static ElementDef elementDef = null;
  BaseClass() {
    if (elementDef == null) {
      elementDef = ElementRegistry.register("BaseClass", null, null, null);
    }
  }

  ElementDef getDefinition() {
    return elementDef;
  }
}

class DerivedClass extends BaseClass {
  static ElementDef derivedElementDef = null;
  DerivedClass() {
    if (derivedElementDef == null) {
      derivedElementDef = ElementRegistry.register("DerivedClass",
          BaseClass.elementDef, null, null);
    }
  }

  ElementDef getDefinition() {
    return derivedElementDef;
  }
}
