part of alltests;

class ProtocolBufferTest {

  ProtocolBufferTest();

  void testPrimitiveFields() {
    ProtocolBuffer address = new ProtocolBuffer("hello.test");
    address['street'] = "1600 Amphitheatre Pkwy";
    address['city'] = "Mountain View";
    address['state'] = new ProtoEnum("CA");
    address['zipcode'] = 94043;
    address['latitude'] = 37.423021;
    address['longitude'] = -122.083739;
    address['isPOBox'] = false;
    String proto = address.toString();
    expect(proto, equals("city:\"Mountain View\"\nisPOBox:0\n"
        "latitude:37.423021\nlongitude:-122.083739\n"
        "state:CA\n"
        "street:\"1600 Amphitheatre Pkwy\"\nzipcode:94043\n"));
  }

  void testEnumField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['gender'] = new ProtoEnum("MALE");
    expect(profile.toString(), equals("gender:MALE\n"));
  }

  void testGroupField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['address'] = new ProtoGroup();
    profile['address']['city'] = "Mountain View";
    profile['address']['zipcode'] = 94043;
    expect(profile.toString(), equals("address {\n  city:\"Mountain View\"\n"
        "  zipcode:94043\n}\n"));
  }

  void testNestedGroupField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['address'] = new ProtoGroup();
    profile['address']['city'] = "Mountain View";
    profile['address']['geo'] = new ProtoGroup();
    profile['address']['geo']['latitude'] = 37.423021;
    profile['address']['geo']['longitude'] = -122.083739;
    profile['address']['zipcode'] = 94043;
    expect(profile.toString(), equals("address {\n  city:\"Mountain View\"\n"
        "  geo {\n"
        "    latitude:37.423021\n"
        "    longitude:-122.083739\n"
        "  }\n"
        "  zipcode:94043\n"
        "}\n"));
  }

  void testMessageSet() {
    ProtocolBuffer person = new ProtocolBuffer("hello.test");
    person['name'] = "Sanjay";
    person['pets'] = new MessageSet();
    ProtocolBuffer dog = new ProtocolBuffer("hello.pet.dog");
    dog['name'] = "fluffy";
    dog['collar'] = true;
    ProtocolBuffer cat = new ProtocolBuffer("hello.pet.cat");
    cat['name'] = "garfield";
    cat['toys'] = 5;
    person['pets'].add(dog);
    person['pets'].add(cat);
    expect(person.toString(), equals("name:\"Sanjay\"\n"
        "pets <\n"
        "  [hello.pet.dog] <\n"
        "    collar:1\n"
        "    name:\"fluffy\"\n"
        "  >\n"
        "  [hello.pet.cat] <\n"
        "    name:\"garfield\"\n"
        "    toys:5\n"
        "  >\n"
        ">\n"));
  }

  void testArrayField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['scores'] = [23, 67];
    String proto = profile.toString();
    expect(proto.indexOf("scores:23\n") > -1, isTrue);
    expect(proto.indexOf("scores:67\n") > -1, isTrue);
  }

  void testEmbeddedQuotes() {
    ProtocolBuffer proto = new ProtocolBuffer("hello.test");
    proto['str'] = "Hello \"World\"";
    expect(proto.toString(), equals("str:\"Hello \\\"World\\\"\"\n"));
  }

  void testArrayEnumField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['activities'] = [new ProtoEnum("SOCCER"), new ProtoEnum("SWIMMING")];
    String proto = profile.toString();
    expect(proto.indexOf("activities:SOCCER\n") > -1, isTrue);
    expect(proto.indexOf("activities:SWIMMING\n") > -1, isTrue);
  }

  void testLongField() {
    ProtocolBuffer profile = new ProtocolBuffer("hello.test");
    profile['bignumber'] = new ProtoLong("5890544855796036345");
    expect(profile.toString(), equals("bignumber:5890544855796036345\n"));
  }

  void testAll() {
    group("ProtocolBuffer", () {
      test("PrimitiveFields", testPrimitiveFields);
      test("EnumField", testEnumField);
      test("GroupField", testGroupField);
      test("NestedGroupField", testNestedGroupField);
      test("MessageSet", testMessageSet);
      test("ArrayField", testArrayField);
      test("EmbeddedQuotes", testEmbeddedQuotes);
      test("ArrayEnumField", testArrayEnumField);
      test("LongField", testLongField);
    });
  }
}
