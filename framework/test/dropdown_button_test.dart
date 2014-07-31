part of alltests;

class DropDownButtonTest extends AppTestCase {

  DropDownButtonTest();

  void testIsOpen() {
    Application app = createApplication();
    Canvas canvas = new Canvas();
    DropDownButton dropDown = new DropDownButton();
    RectShape backRect = new RectShape();
    backRect.width = 80;
    backRect.height = 20;
    backRect.fill = new SolidBrush(Color.fromRGB(0xc0c0c0));
    dropDown.content = backRect;
    VBox dropDownContent = new VBox();
    Button button = new Button();
    RectShape redSquare = new RectShape();
    redSquare.width = 20;
    redSquare.height = 20;
    redSquare.fill = new SolidBrush(Color.fromRGB(0xff0000));
    button.content = redSquare;
    button.addListener(Button.clickEvent, closeDropDown);
    dropDownContent.addChild(button);
    dropDown.popup = dropDownContent;
    canvas.addChild(dropDown);
    app.content = canvas;
    UpdateQueue.flush();
    expect(dropDown.isOpen, isFalse);
    Application.current.sendMouseEvent(dropDown, 0, 0,
        UIElement.mouseDownEvent);
    expect(dropDown.isOpen, isTrue);
    Application.current.sendMouseEvent(dropDown, 0, 0, UIElement.mouseUpEvent);
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseDownEvent);
    Application.current.sendMouseEvent(button, 0, 0, UIElement.mouseUpEvent);
    expect(dropDown.isOpen, isFalse);
    app.shutdown();
  }

  void closeDropDown(EventArgs e) {
    DropDownButton b = e.source;
    DropDownButton dropDownControl = b.parent.parent;
    dropDownControl.isOpen = false;
  }

  void testAll() {
    group("DropDownButton", () {
      test("IsOpen", testIsOpen);
    });
  }
}
