part of uxml;

class UIEditSurfaceImpl extends UISurfaceImpl implements UIEditSurface {
  UIEditSurfaceImpl() : super() {
    _textColor = Color.BLACK;
    TextAreaElement textArea = hostElement;
  }

  String _text;
  String _fontName;
  num _fontSize;
  Color _textColor;
  bool _fontBold;
  bool _divDirty = false;
  bool _wrap = true;

  num measuredWidth;
  num measuredHeight;
  int _maxChars;
  static TextMeasureUtils _measureUtils = null;

  bool _multiline = false;
  bool _isHtmlText = false;
  StreamSubscription<Event> _keyboardSub = null;
  StreamSubscription<Event> _blurSub = null;

  void _createElementOnDemand() {
    TextAreaElement textArea = new Element.tag('textarea');
    textArea.autofocus = false;
    hostElement = textArea;
    parentSurface._hostElementCreated(this);
    _onInitSurface();
  }

  void close() {
    if (_keyboardSub != null) {
      _keyboardSub.cancel();
      _keyboardSub = null;
    }
    if (_blurSub != null) {
      _blurSub.cancel();
      _blurSub = null;
    }
    super.close();
  }

  /**
   * Sets text.
   */
  set text(String value) {
    if (value != _text) {
      if (UISurfaceImpl.OPTIMIZE_DIVS) {
        _createElementOnDemand();
      }
      _isHtmlText = false;
      _text = value;
      TextAreaElement textArea = hostElement;
      textArea.value = _text;
      hostElement.style.left = "${layoutX}px";
      hostElement.style.top = "${layoutY}px";
    }
  }

  String get text {
    return _text;
  }

  /**
   * Sets text.
   */
  set htmlText(String value) {
    if (value != _text) {
      if (UISurfaceImpl.OPTIMIZE_DIVS) {
        _createElementOnDemand();
      }
      _isHtmlText = true;
      String sanitizedText = HtmlSanitizer.sanitize(value, useWhiteList:true);
      hostElement.innerHtml = HtmlSanitizer.sanitize(sanitizedText);
      hostElement.style.left = "${layoutX}px";
      hostElement.style.top = "${layoutY}px";
    }
  }

  set promptMessage(String prompt) {
    if (UISurfaceImpl.OPTIMIZE_DIVS) {
      _createElementOnDemand();
    }
    TextAreaElement textArea = hostElement;
    textArea.placeholder = prompt;
  }

  /**
   * Sets font name.
   */
  set fontName(String fontName) {
    _fontName = fontName;
    _divDirty = true;
  }

  /**
   * Sets font size.
   */
  set fontSize(num fontSize) {
    _fontSize = fontSize;
    _divDirty = true;
  }

  /**
   * Sets font bold.
   */
  set fontBold(bool fontBold) {
    _fontBold = fontBold;
    _divDirty = true;
  }

  /**
   * Sets text color.
   */
  set textColor(Color textColor) {
    _textColor = textColor;
    _divDirty = true;
  }

  set maxChars(int length) {
    _maxChars = length;
    // TODO(ferhat): wire maxchars to input ctrl.
  }

  void _onInitSurface() {
    // TODO(ferhat): add onchange for paste etc..
    _keyboardSub = hostElement.onKeyUp.listen(
        (Event event) {
          if (_surfaceTarget != null) {
            TextAreaElement t = hostElement;
            UpdateQueue.doLater((Object param) {
              if (_surfaceTarget != null) {
                _surfaceTarget.surfaceTextChanged(t.value);
              }
            }, null, null);
          }
        });
    hostElement.style.border = "none";
    hostElement.style.resize = "none";
    // remove blue glow around text when focused.
    hostElement.style.outline = "none";
    hostElement.style.backgroundColor = "transparent";
    if (Application.isIE) {
      hostElement.style.overflow = "auto";
    }
    if (!(_multiline || _wrap)) {
      TextAreaElement textArea = hostElement;
      textArea.rows = 1;
      textArea.style.overflowX = "hidden";
      textArea.style.whiteSpace = "nowrap";
    }
    hostElement.style.cursor = "default";
  }

  void setBackground(Brush brush) {
    if (UISurfaceImpl.OPTIMIZE_DIVS) {
      _createElementOnDemand();
    }
    if (brush == null) {
      hostElement.style.backgroundColor = "transparent";
    } else {
      UIPlatform.applyBrush(hostElement, brush);
      _painted = true;
    }
  }

  /**
   * Measures size of image given width constraint.
   */
  void measureText(String textValue, num availWidth, num availHeight) {
    updateTextView();
    if (_measureUtils == null) {
      _measureUtils = new TextMeasureUtils();
    }
    _measureUtils.setFont(_fontName, _fontSize, _fontBold);
    String text = (_text != null && _text is String && _text != "") ?
        _text : "a";
    _measureUtils.measure(HtmlSanitizer.sanitize(text,
        useWhiteList:_isHtmlText), availWidth, availHeight,
        _multiline);
    measuredWidth = _measureUtils.width;
    measuredHeight = _measureUtils.height;
  }

  void updateTextView() {
    if (UISurfaceImpl.OPTIMIZE_DIVS) {
      _createElementOnDemand();
    }
    if (_divDirty) {
      CssStyleDeclaration style = hostElement.style;
      if (_fontName != "") {
        style.fontFamily = _fontName;
      }
      String colorStr =
      style.color = _textColor.toString();
      if (_fontBold) {
        style.fontWeight = "700";
      } else {
        style.removeProperty("font-weight");
      }
      style.fontSize = "${_fontSize.toInt().toString()}px";
      hostElement.style.left = "${layoutX}px";
      hostElement.style.top = "${layoutY}px";
      _divDirty = false;
    }
  }

  set visible(bool value) {
    if (hostElement != null) {
    }
  }

  set wordWrap(bool value) {
    if (hostElement != null) {
      TextAreaElement textArea = hostElement;
      if (value != _wrap) {
        textArea.wrap = value ? "on" : "off";
        _wrap = value;
        if (_multiline || _wrap) {
          textArea.rows = 0;
          textArea.style.whiteSpace = "normal";
        } else {
          textArea.rows = 1;
          textArea.style.whiteSpace = "nowrap";
        }
      }
    }
  }

  set multiline(bool value) {
    if (_multiline != value) {
      _multiline = value;
      if (hostElement != null) {
        TextAreaElement textArea = hostElement;
        if (_multiline || _wrap) {
          textArea.rows = 0;
          textArea.style.whiteSpace = "normal";
        } else {
          textArea.rows = 1;
          textArea.style.whiteSpace = "nowrap";
        }
      }
    }
  }

  set onTextLink(EventHandler handler) {
  }

  void applyFilters(Filters filters) {
    if (filters == null) {
      // Clear existing filters.
      hostElement.style.removeProperty("text-shadow");
      return;
    }

    for (int f = 0; f < filters.length; f++) {
      Filter filter = filters.getFilter(f);
      if (filter is DropShadowFilter) {
        if (hostElement != null) {
          DropShadowFilter shadowFilter = filter;
          // TODO(ferhat): inner shadow impl using path reversal.
          if (shadowFilter.inner == false) {
            num angleRad = shadowFilter.angle * PI / 180.0;
            num xDist = cos(angleRad) * shadowFilter.distance;
            num yDist = sin(angleRad) * shadowFilter.distance;
            Color filterColor = Color.fromColor(shadowFilter.color,
                shadowFilter.strength);
            String boxShadowValue = "${xDist.toInt().toString()}px "
                "${yDist.toInt().toString()}px "
                "${shadowFilter.blurX.toString()}px "
                "${filterColor.toString()}";
            if (shadowFilter.inner) {
              boxShadowValue = "inset $boxShadowValue";
            }
            hostElement.style.textShadow = boxShadowValue;
          }
        }
      }
    }
  }

  void cursorChanged(Cursor cursor) {
    if (hostElement != null) {
      if (cursor == null) {
        hostElement.style.cursor = "default";
      } else {
        hostElement.style.cursor = _cursorToCursorStyle(cursor);
      }
    }
  }

  void initFocus(bool selectAll) {
    if (hostElement != null) {
      TextAreaElement textArea = hostElement;
      textArea.focus();
      _blurSub = textArea.onBlur.listen((Event e) {
          if (_surfaceTarget != null) {
            _surfaceTarget.surfaceFocusChanged(false);
            if (_blurSub == null) {
              return;
            }
            _blurSub.cancel();
            _blurSub = null;
          }
        });
    }
  }

  void focusChanged(bool isFocused) {
    if (isFocused == false && hostElement != null) {
      hostElement.blur();
    }
  }

  void enableMouseEvents(bool val) {
    // TODO(ferhat): implement readonly mode.
  }
}
