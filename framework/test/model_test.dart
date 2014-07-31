part of alltests;

class ModelTest extends AppTestCase {
  bool changed;
  int count;
  int index;
  Object newValue;
  Object oldValue;
  Object property;
  Object source;
  Object type;

  ModelTest() : super() {
  }

  void onPropChange(PropertyChangedEvent event) {
    this.changed = true;
    this.source = event.source;
    this.property = event.property;
    this.oldValue = event.oldValue;
    this.newValue = event.newValue;
  }

  void onCollChange(CollectionChangedEvent event) {
    this.changed = true;
    this.source = event.source;
    this.type = event.type;
    this.index = event.index;
    this.count = event.count;
  }

  void testConstructor() {
    List arr = [];
    Model model = Model.fromObject(arr);
    expect(model.length, equals(0));
  }

  void testSetSource() {
    List arr = [];
    Model model = Model.fromObject(arr);
    expect(model.length, equals(0));
  }

  void testIndexOf() {
    Model m = new Model();
    Model i1 = new Model();
    Model i2 = new Model();
    Model i3 = new Model();
    m.addChild(i1);
    m.addChild(i2);
    m.addChild("x");
    m["prop1"] = "y";
    m.addChild(i3);
    expect(m.indexOf(i2), equals(1));
  }

  void testGetSetProperty() {
    changed = false;
    Map data = const {"prop":5, "subObj":const {"a":0, "b":5}};
    Model model = Model.fromObject(data);
    expect(model.length, equals(2));
    model.addListener("prop", onPropChange);
    expect(model['prop'], equals(5));
    model['prop'] = 10;
    expect(model['prop'], equals(10));
    expect(changed, isTrue);
    expect(oldValue, equals(5));
    expect(newValue, equals(10));
    expect(model['subObj'] is Model, isTrue);
    expect(model['subObj']['b'], equals(5));
    Model subModel = new Model();
    subModel['subProp'] = 3;
    model['subObj'] = subModel;
    expect(model.length, equals(2));
    expect(model['subObj']['subProp'], equals(3));
  }

  void testUndefinedProperty() {
    Model model = new Model();
    expect(model['foo'], isNull);
    expect(model.overridesProperty("foo"), isFalse);
  }

  void testGetSetXmlProperty() {
    changed = false;
    Model model = Model.fromObject({"foo": {"a":"bar"}});
    expect(model['a'], equals("bar"));
    model.addListener("a", onPropChange);
    model['a'] = "char";
    expect(model['a'], equals("char"));
    expect(changed, isTrue);
    expect(oldValue, equals("bar"));
    expect(newValue, equals("char"));
  }

  void testAddItems() {
    changed = false;
    Model model = new Model();
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    model.insertChildren(-1 , [101, 201, 301]);
    expect(type, equals(CollectionChangedEvent.CHANGETYPE_ADD));
    expect(changed, isTrue);
    expect(index, equals(0));
    expect(count, equals(3));
    expect(model.getChildAt(0) is Model, isFalse);
    expect(model.getChildAt(0), equals(101));
  }

  void testInsertItem() {
    Model model = Model.fromObject([101, 102, 103]);
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    model.insertChild(1, 101.5);
    expect(type, equals(CollectionChangedEvent.CHANGETYPE_ADD));
    expect(changed, isTrue);
    expect(index, equals(1));
    expect(count, equals(1));
    expect(model.getChildAt(1), equals(101.5));
  }

  void testInsertItemOutOfBounds() {
    bool exceptionCaught = false;
    Model model = new Model();
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    try {
      model.insertChild(20, 101);
    } on Error catch (e) {
      exceptionCaught = true;
    }
    expect(exceptionCaught, isTrue);
  }

  void testRemoveItems() {
    changed = false;
    Model model = new Model();
    model.insertChildren(-1, [101, 201, 301, {"n":401}]);
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    model.removeChildren(1, 2);
    expect(CollectionChangedEvent.CHANGETYPE_REMOVE, type);
    expect(changed, isTrue);
    expect(index, equals(1));
    expect(count, equals(2));
    expect(model.getChildAt(0) is Model, isFalse);
    expect(model.getChildAt(1) is Model, isTrue);
    expect(model.getChildAt(0), equals(101));
    Model child = model.getChildAt(1);
    expect(child['n'], equals(401));
  }

  void testRemoveAll() {
    changed = false;
    Model model = new Model();
    model.insertChildren(-1, [101, 201, 301, 401]);
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    model.removeChildren(0, -1);
    expect(type, equals(CollectionChangedEvent.CHANGETYPE_REMOVE));
    expect(changed, isTrue);
    expect(model.length, equals(0));
  }

  void testFromMap() {
    Model counters = new Model.fromMap({
        "busy" : false,
        "count" : 5,
        "name" : "hello",
        "state" : { "val" : 123 }
      });
    expect(counters['busy'], isFalse);
    expect(counters['count'], equals(5));
    expect(counters['state']['val'], equals(123));
  }

  void testGetXMLItem() {
    String xml = "<foo><bar a=\"1\"/><bar a=\"2\"/><gum a=\"3\"/></foo>";
    Model model = UIPlatform.protoXmlToModel(xml);
    expect(model['bar']['a'], equals("1"));
    expect((model.getChildAt(0) as Model)['a'], equals("1"));
    expect((model.getChildAt(1) as Model)['a'], equals("2"));
    model = model['foo'];
    expect((model.getChildAt(0) as Model)['a'], equals("1"));
    expect((model.getChildAt(1) as Model)['a'], equals("2"));
    expect((model.getChildAt(0) as Model).getName(), equals("bar"));
    expect((model.getChildAt(2) as Model).getName(), equals("gum"));
  }

  void testSetItem() {
    Model model = new Model();
    model.insertChildren(-1, [11, 22, 33]);
    model.addListener(CollectionChangedEvent.eventDef, onCollChange);
    model.setChildAt(1, 44);
    expect(CollectionChangedEvent.CHANGETYPE_MODIFY, type);
    expect(changed, isTrue);
    expect(index, equals(1));
    expect(count, equals(1));
    expect(model.getChildAt(1), equals(44));
  }

  void testDeepXml() {
    Model model = UIPlatform.protoXmlToModel("""<result id="9">
            <user name="sanjay"/>
            <address>
              <city>Mountain View</city>
            </address>
            <friendlinks>
              <friend id="0" name="ferhat"/>
              <friend id="1" name="orkut"/>
            </friendlinks>
          </result>""");
    expect(model['id'], equals("9"));
    expect(model['user']['name'], equals("sanjay"));
    expect(model['friendlinks']['friend']['name'], equals("ferhat"));
    expect(model['friendlinks'].getChildAt(1)['name'], equals("orkut"));
    expect(model['address.city'], equals("Mountain View"));
  }

// TODO(ferhat): port remaining tests.
//  void testUndefined() {
//    XML xml = "<foo><bar a="1"/><bar a="2"/></foo>";
//    Model model = new Model();
//    model.setSource(xml);
//    expect(undefined, model.getChildAt(0).attr);
//    expect(undefined, model.attr);
//    expect(undefined, model.element);
//  }
//
//  void testLeafNodeToBranch() {
//    XML xml = "<result>
//                      <address>
//                        <city>Sunnyvale</city>
//                      </address>
//                    </result>";
//    Model model = new Model(xml);
//    expect("Sunnyvale", model.address.city);
//    model.address.city = "<result>
//                             <population>
//                               <temporary>600000</temporary>
//                               <permanent>1200000</permanent>
//                             </population>;
//                           </result>";
//    expect("600000", model.address.city.population.temporary);
//  }
//
//  void testAttributePrecedenceOverElement() {
//    XML xml = "<result>
//                      <error id="300" description="inside attribute">
//                        <description>inside element</description>
//                      </error>
//                    </result>";
//    Model model = new Model(xml);
//    expect("inside attribute", model.error.description);
//  }
//
//  void testGetChildByName() {
//    XML xml = "<result>
//                      <error id="300" description="not found"/>
//                    </result>";
//    Model model = new Model(xml);
//    expect("300", model.getChildByName("error").id);
//  }
//
//  void testSetChildAt() {
//    XML xml = "<result>
//                      <error id="300" description="not found"/>
//                    </result>";
//    Model model = new Model(xml);
//    model.setChildAt(1, "<error id="400" description="failed"/>");
//    expect("400", model.getChildAt(1).id);
//  }
//
//  void testSetObject() {
//    DateTime dt = new DateTime(2000, 0, 15);
//    Model model = new Model(dt);
//    expect(undefined, model.fullYear);
//    expect(undefined, model.month);
//    expect(undefined, model.date);
//    expect(dt, model.value);
//  }
//
//  void testEmptyXml() {
//    XML xml = "<result>
//                      <blah/>
//                      <geoinfo>
//                        <city/>
//                        <state>0</state>
//                        <country>0</country>
//                        <zipcode/>
//                      </geoinfo>
//                    </result>";
//    Model model = new Model(xml);
//    expect("", model.geoinfo.city);
//  }
//
//  void testAddMultipleProperties() {
//    Model model = new Model();
//    model.name = "SomeName";
//    model.rating = 5;
//    model.description = "SomeDescription";
//    expect("SomeName", model.name);
//    expect(5, model.rating);
//    expect("SomeDescription", model.description);
//  }
//
//  void testSetValue() {
//    Model model = new Model();
//    expect(undefined, model.value);
//    model.value = "SomeValue";
//    expect("SomeValue", model.value);
//  }
//
//  void testDeleteProperty() {
//    Model model = new Model();
//    model.foo = "bar";
//    assertTrue(delete model.foo);
//    assertFalse(delete model.foo);
//    model.setChildByName("search", "google");
//    assertTrue(delete model.search);
//    assertFalse(delete model.search);
//    assertFalse(delete model.nonexisting);
//  }
//
//  void testFromProtoXml() {
//    XML proto = "<toplevel>
//                        <item_key data="9667D6A4CC4AA55"/>
//                        <item>
//                          <item_vertical int="1"/>
//                          <name data="Endup"/>
//                          <category data="bar" index="0"/>
//                          <category data="lounge" index="1"/>
//                          <added_date long="1265667899639"/>
//                          <user_id long="29115108063"/>
//                          <user_name data="Sanjay"/>
//                          <expired bool="false"/>
//                          <available bool="1"/>
//                          <subrating float="0.5"/>
//                          <item>
//                            <social_hello_proto.Location>
//                              <name data="Endup"/>
//                              <postal_address>
//                                <country_name data="United States"/>
//                                <administrative_area_name data="CA"/>
//                                <locality_name data="San Francisco"/>
//                                <postal_code_number data=""/>
//                                <address_line data="401 6th St"/>
//                              </postal_address>
//                              <latitude_e6 long="377772821"/>
//                              <longitude_e6 long="-12240405390000000"/>
//                            </social_hello_proto.Location>
//                          </item>
//                        </item>
//                        <rating double="9.0"/>
//                        <num_ratings int="1"/>
//                        <num_reviews int="1"/>
//                        <primary_image_id long="1265156400545"/>
//                        <secondary_image_id long="1264814965367"/>
//                      </toplevel>";
//    Model model = Model.fromProtoXml(proto);
//    expect("9667D6A4CC4AA55", model.item_key);
//    expect(1, model.item.item_vertical);
//    expect("Sanjay", model.item.user_name);
//    expect("Endup", model.item.item.Location.name);
//    expect("United States", model.item.item.Location.postal_address.country_name);
//    expect(-12240405390000000, model.item.item.Location.longitude_e6);
//    expect(1264814965367, model.secondary_image_id);
//    expect(9.0, model.rating);
//    expect(true, model.item.available);
//    expect(false, model.item.expired);
//    expect(0.5, model.item.subrating);
//    expect(2, model.item.category.length);
//    expect("bar", model.item.category.getChildAt(0));
//    expect("lounge", model.item.category.getChildAt(1));
//    Model categories = model.item.getChildrenByName("category");
//    expect(2, categories.length);
//    expect("bar", categories.getChildAt(0));
//    expect("lounge", categories.getChildAt(1));
//  }
//
//  void testRepeatableGroupFieldsInProtoXml() {
//    XML proto = "<toplevel>
//                        <item_key data="9667D6A4CC4AA55"/>
//                        <item>
//                          <postal_address index="0">
//                            <country_name data="United States"/>
//                            <administrative_area_name data="CA"/>
//                            <locality_name data="San Francisco"/>
//                            <postal_code_number data=""/>
//                            <address_line data="401 6th St"/>
//                          </postal_address>
//                          <postal_address index="1">
//                            <country_name data="United States"/>
//                            <administrative_area_name data="CA"/>
//                            <locality_name data="San Jose"/>
//                            <postal_code_number data=""/>
//                            <address_line data="401 6th St"/>
//                          </postal_address>
//                        </item>
//                      </toplevel>";
//    Model model = Model.fromProtoXml(proto);
//    expect(2, model.item.postal_address.length);
//    expect("San Francisco", model.item.postal_address.getChildAt(0).locality_name);
//    expect("San Jose", model.item.postal_address.getChildAt(1).locality_name);
//  }
//
//  void testIteratingProperties() {
//    Model model = new Model();
//    model.a = 1;
//    model.b = 3;
//    model.addChild({c:1});
//    Object result = {};
//    for (String prop in model) {
//      result[prop] = model[prop];
//    }
//    expect(1, result.a);
//    expect(3, result.b);
//    expect(1, model.length);
//    expect(1, model.getChildAt(0).c);
//  }
//
//  void testGetChildrenByName() {
//    XML result = "<toplevel>
//          <totalSlots int="2"/>
//          <availableSlots int="2"/>
//          <foo int="1" index="0"/>
//          <foo int="2" index="1"/>
//          <persona index="0">
//            <persona_id int="2"/>
//            <status int="1"/>
//            <level int="1"/>
//            <mature bool="false"/>
//          </persona>
//          <persona index="1">
//            <persona_id int="3"/>
//            <status int="1"/>
//            <level int="1"/>
//            <mature bool="false"/>
//          </persona>
//        </toplevel>";
//    Model personaResult = Model.fromProtoXml(result);
//    Model personas = personaResult.getChildrenByName("persona");
//    Model foos = personaResult.getChildrenByName("foo");
//    Model slots = personaResult.getChildrenByName("totalSlots");
//    Model missing = personaResult.getChildrenByName("missing");
//    expect(2, foos.length);
//    expect("1", foos.getChildAt(0));
//    expect("2", foos.getChildAt(1));
//    expect(1, slots.length);
//    expect(0, missing.length);
//    expect(2, personas.length);
//    expect(false, personas.getChildAt(1).mature);
//  }
//
//  void testChildOrder() {
//    XML result = "<toplevel>
//          <totalSlots int="2"/>
//          <availableSlots int="2"/>
//          <foo int="1" index="0"/>
//          <foo int="2" index="1"/>
//          <persona index="0">
//            <persona_id int="2"/>
//            <status int="1"/>
//            <level int="1"/>
//            <mature bool="false"/>
//          </persona>
//          <persona index="1">
//            <persona_id int="3"/>
//            <status int="1"/>
//            <level int="1"/>
//            <mature bool="false"/>
//          </persona>
//        </toplevel>";
//    Model personaResult = Model.fromProtoXml(result);
//    expect(6, personaResult.length);
//    expect(2, personaResult.getChildAt(0));
//    expect(1, personaResult.getChildAt(4).status);
//  }
//
//  void testChildOrderNameValue() {
//    XML result = "<toplevel>
//          <section index="0">
//            <section_id data="base-about"/>
//            <section_name data="about"/>
//            <question index="0">
//              <question_id int="1"/>
//              <display_label data="about-me"/>
//              <edit_label data="Tell us a little bit about you."/>
//              <type data="multitext"/>
//            </question>
//            <question_group index="0"/>
//            <question_group index="1"/>
//            <question index="1">
//              <question_id int="2"/>
//              <display_label data="hometown"/>
//              <edit_label data="Where is your hometown?"/>
//              <type data="text"/>
//            </question>
//          </section>
//        </toplevel>";
//    Model editSpec = Model.fromProtoXml(result);
//    Model sections = editSpec.getChildrenByName("section");
//    expect(1, sections.length);
//    Model section = Model(sections.getChildAt(0));
//    Model questions = section.getChildrenByName("question");
//    expect(2, questions.length);
//    int questionCount = 0;
//    for (int c = 0; c < section.length; c++) {
//      if (section.getChildAt(c) is Model) {
//        Model child = section.getChildAt(c);
//        if (child.getName() == "question") {
//          questionCount++;
//        }
//      }
//    }
//    expect(2, questionCount);
//  }
//
//  void testBigNumber() {
//    XML result = "<toplevel>
//          <membership>
//            <group>
//              <id long="7592496455413066887"/>
//              <name data="SF Leica Group"/>
//              <profile_image bool="true"/>
//            </group>
//          </membership>
//          <membership>
//            <group>
//              <id long="4636666093178119691"/>
//              <name data="Bay Area Linux Users Group"/>
//              <profile_image bool="true"/>
//            </group>
//          </membership>
//        </toplevel>";
//    Model model = Model.fromProtoXml(result).getChildrenByName("membership");
//    assertTrue(model.getChildAt(0).group.id is Long);
//    expect(7592496455413066887, model.getChildAt(0).group.id);
//    expect(4636666093178119691, model.getChildAt(1).group.id);
//  }
//
//  void testDynamicGetOnValue() {
//    Sprite s = new Sprite();
//    Model m = new Model(s);
//    expect(s, m.value);
//    expect(s, m["value"]);
//  }
//

  void testAll() {
    group("Model", () {
      test("Constructor", testConstructor);
      test("GetSetProperty", testGetSetProperty);
      test("SetSource", testSetSource);
      test("UndefinedProperty", testUndefinedProperty);
      test("AddItems", testAddItems);
      test("InsertItem", testInsertItem);
      test("InsertItemOutOfBounds", testInsertItemOutOfBounds);
      test("RemoveItems", testRemoveItems);
      test("RemoveAll", testRemoveAll);
      test("Map constructor", testFromMap);
      test("IndexOf", testIndexOf);
    });
  }
}
