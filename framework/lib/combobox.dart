part of uxml;

/**
 * Implements ComboBox control.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class ComboBox extends ListBase {
  static ElementDef comboboxElementDef;
  /** Text property definition */
  static PropertyDefinition textProperty;
  /** IsOpen property definition */
  static PropertyDefinition isOpenProperty;
  /** Editable property definition */
  static PropertyDefinition editableProperty;
  /** MaxDropDownHeight property definition */
  static PropertyDefinition maxDropDownHeightProperty;
  /** Holds selected items to track mouse events to close dropdown. */
  List<UIElement> _trackList;
  /** Sets/returns function to use to transform selection to text content. */
  ComboTextTransform textTransform = null;
  int _preOpenSelectedIndex = -1;
  EventHandler _focusClosure;
  EventHandler _childListClosure;
  EventHandler _trackMouseClosure;

  ComboBox() : super() {
    focusEnabled = true;
    // Listen for selection change events on underlying listbox, before anyone
    // else adds it. This allows updating the text property before others are
    // notified.
    _trackList = null;
    _trackMouseClosure = _trackMouseDownHandler;
  }

  /** Overrides UIElement.close to cleanup. */
  void close() {
    if (chromeTree != null) {
      chromeTree.removeListener(ListBase.selectionChangedEvent,
          _childListClosure);
    }
    removeListener(UIElement.isFocusedProperty, _focusClosure);
    _focusClosure = null;
    _childListClosure = null;
    _trackMouseClosure = null;
    super.close();
  }

  void _isFocusedChanged(EventArgs e) {
    // When we loose input focus, close dropdown
    if ((!isFocused) &&
        isVisualChild(Application.focusManager.focusedElement) == false) {
      isOpen = false;
    }
  }

  void onKeyDown(KeyboardEventArgs keyArgs) {
    if (isFocused && ((keyArgs.keyCode == KeyboardEventArgs.KEYCODE_ENTER) ||
        (keyArgs.keyCode == KeyboardEventArgs.KEYCODE_SPACE) ||
        (keyArgs.keyCode == KeyboardEventArgs.KEYCODE_DOWN))) {
      keyArgs.handled = true;
      isOpen = true;
    }
  }

  /**
   * Sets or returns text.
   */
  String get text => getProperty(textProperty);

  set text(String value) {
    setProperty(textProperty, value);
  }

  /**
  * Sets or returns if combobox is editable.
  */
  bool get editable => getProperty(editableProperty);

  set editable(bool value) {
    setProperty(editableProperty, value);
  }

  /**
   * Sets/returns open state.
   */
  bool get isOpen => getProperty(isOpenProperty);

  set isOpen(bool value) {
    return setProperty(isOpenProperty, value);
  }

  /** Gets or sets the maximum height of combo dropdown*/
  num get maxDropDownHeight => getProperty(UIElement.maxHeightProperty);

  set maxDropDownHeight(num value) {
    setProperty(maxDropDownHeightProperty, value);
  }

  /** Overrides UIElement.onMouseDown. */
  void onMouseDown(MouseEventArgs mouseArgs) {
    if (!isOpen) {
      _preOpenSelectedIndex = selectedIndex;
    }
    isOpen = !isOpen;
    mouseArgs.handled = true;
  }

  /** Overrides UIElement.onMouseUp. */
  void onMouseUp(MouseEventArgs mouseArgs) {
    mouseArgs.handled = true;
  }

  /** @see UIElement.initSurface. */
  void initSurface(UISurface parentSurface, [int index = -1]) {
    super.initSurface(parentSurface, index);
    _updateText(selectedItem);
    _focusClosure = _isFocusedChanged;
    addListener(UIElement.isFocusedProperty, _focusClosure);
  }

  void _updateText(Object item) {
    if (textTransform != null) {
      String newText = textTransform(this);
      if (newText == null || newText.length == 0) {
        clearProperty(textProperty);
      } else {
        text = newText;
      }
    } else {
      _defaultTransform(this);
    }
  }

  static String _defaultTransform(ComboBox combo) {
    // Update text to prompt message if specified.
    Object item = combo.selectedItem;
    if (item is Item) {
      Item itemObj = item;
      combo.text = itemObj.content;
    } else if (item is String) {
      combo.text = item;
    }
  }

  void onChromeChanged(Chrome oldChrome,Chrome newChrome) {
    if (chromeTree != null) {
      chromeTree.removeListener(ListBase.selectionChangedEvent,
          _childListClosure);
    }
    super.onChromeChanged(oldChrome, newChrome);
  }

  void onChromeTreeReady() {
    // Attach selectionChanged handler to root of chrome since we
    // want to prevent the event from bubbling up to self which
    // would generate duplicate selectionChanged event firing.
    if (chromeTree != null) {
      _childListClosure = _onChildListSelectionChanged;
      chromeTree.addListener(ListBase.selectionChangedEvent,
          _childListClosure);
    }
  }

  void _onChildListSelectionChanged(EventArgs e) {
    ListBase list = e.source;
    if (list == null || list.items != items || e.source == this) {
      return;
    }
    e.handled = true;
    _selectedList = list._selectedList;
    if (multiSelect == false &&
        (_preOpenSelectedIndex == list.selectedIndex)) {
      return;
    }
    if (!isOpen) {
      _preOpenSelectedIndex = list.selectedIndex;
    }
    if (!multiSelect) {
      isOpen = false;
    }
    _preOpenSelectedIndex = list.selectedIndex;
    if (list.selectedItem == null && (editable == false)) {
      if (textTransform != null) {
        String newText = textTransform(this);
        if (newText.length == 0) {
          clearProperty(textProperty);
        } else {
          text = newText;
        }
      } else {
        clearProperty(textProperty);
      }
    }
    selectedItem = list.selectedItem;
    _updateText(selectedItem);
    _clearTrackList();
    _trackItem(list.selectedItem);
  }

  void _trackItem(item) {
    if (item == null) return;
    if (_trackList == null) {
      _trackList = <UIElement>[];
    }
    if (item is Item) {
      Item selItem = item;
      if (_trackList.indexOf(selItem) == -1) {
        _trackList.add(selItem);
        selItem.addListener(UIElement.mouseDownEvent, _trackMouseClosure);
      }
    }
  }

  void _clearTrackList() {
    if (_trackList == null) {
      return;
    }
    for (int i = 0; i < _trackList.length; i++) {
      _trackList[i].removeListener(UIElement.mouseDownEvent,
          _trackMouseClosure);
    }
    _trackList.length = 0;
  }

  void _trackMouseDownHandler(EventArgs e) {
    e.handled = true;
    isOpen = false;
  }

  static void _textChangeHandler(Object target, Object propDef,
      Object oldValue, Object newValue) {
    ComboBox combo = target;
    if (combo.items != null) {
      String newText = newValue;

      // If new text is in items collection, change selectedIndex
      for (int i = 0; i < combo.items.length; ++i) {
        if ((combo.items.getItemAt(i) is ContentContainer)) {
          ContentContainer contentCont = combo.items.getItemAt(i);
          if (contentCont.content == newText) {
            combo.selectedIndex = i;
            break;
          }
        }
      }
    }
  }

  // Make sure textTransform is called when isOpen state changes giving
  // it a chance to show different text when in dropdown mode.
  static void _isOpenChangedHandler(Object target, Object propDef,
      Object oldValue, Object newValue) {
    ComboBox cb = target;
    cb._updateText(cb);
  }

  void _onSelectedIndexChanged(int oldIndex, int newIndex) {
    super._onSelectedIndexChanged(oldIndex, newIndex);
    _updateText(selectedItem);
    _clearTrackList();
    _trackItem(selectedItem);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => comboboxElementDef;

  /** Registers component. */
  static void registerComboBox() {
    textProperty = ElementRegistry.registerProperty("Text",
        PropertyType.STRING, PropertyFlags.RESIZE, _textChangeHandler, "");
    isOpenProperty = ElementRegistry.registerProperty("IsOpen",
        PropertyType.BOOL, PropertyFlags.NONE, _isOpenChangedHandler, false);
    editableProperty = ElementRegistry.registerProperty("Editable",
        PropertyType.BOOL, PropertyFlags.NONE, null, false);
    maxDropDownHeightProperty = ElementRegistry.registerProperty(
        "MaxDropDownHeight", PropertyType.NUMBER, PropertyFlags.NONE, null,
        1024.0);
    comboboxElementDef = ElementRegistry.register("ComboBox",
        ListBase.listbaseElementDef,
        [textProperty, isOpenProperty, editableProperty,
        maxDropDownHeightProperty], null);
    Cursor.cursorProperty.overrideDefaultValue(comboboxElementDef,
        Cursor.BUTTON);
  }
}

typedef String ComboTextTransform(ComboBox comboBox);
