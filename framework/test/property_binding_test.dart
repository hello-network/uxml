part of alltests;

class PropertyBindingTest extends AppTestCase {

  PropertyBindingTest();

  void testBindToModel() {
    Model album = new Model();
    Model songs = new Model();
    album['songs'] = songs;
    Model song = new Model();
    song['title'] = "January";
    songs.addChild(song);
    song = new Model();
    song['title'] = "ABC";
    songs.addChild(song);
    song = new Model();
    song['title'] = "DEF";
    songs.addChild(song);
    songs['num_songs'] = 3;

    Label label = new Label();
    label.bindings.add(new PropertyBinding(label, Label.textProperty,
        album, ["songs", "num_songs"]));
    expect(label.text, equals("3"));
    songs['num_songs'] = 5;
    expect(label.text, equals("5"));
  }

  void testNegateTransform() {
    Model album = new Model();
    album['title'] = "MyTitle";
    album['isOutOfStock'] = true;
    Label label = new Label();
    label.bindings.add(new PropertyBinding(label, Label.textProperty,
        album, ["isOutOfStock"], PropertyBinding.negateBoolean));
    expect(label.text, equals("false"));
  }

  void testInheritedPropertyChange() {
    Model model = new Model();
    model['subModel'] = new Model();
    model['subModel']['aName'] = "vv";
    UIElementContainer parent = new UIElementContainer();
    parent.data = model;
    UIElement child = new UIElement();
    parent.addChild(child);
    PropertyBinding binding = new PropertyBinding(child,
        UxmlElement.dataProperty, child, [UxmlElement.dataProperty,
        "subModel"]);
    expect(child.data['aName'], equals("vv"));
    Model m2 = new Model();
    m2['subModel'] =  new Model();
    m2['subModel']['aName'] = "kk";
    parent.data = m2;
    expect(child.data['aName'], equals("kk"));
  }

  void testAll() {
    group("PropertyBinding", () {
      test("BindToModel", testBindToModel);
      test("NegateTransform", testNegateTransform);
      test("InheritedPropertyChange", testInheritedPropertyChange);
      // TODO(ferhat): Add tests for type coercion.
      // Add tests for two way property binding startup.
    });
  }
}
