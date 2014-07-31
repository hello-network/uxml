part of uxml;

/**
 * Handles tab order processing for FocusManager.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class FocusScopeData {

  // Holds element that owns this focus group data.
  UIElement _owner;
  // Holds a list of tabIndex,y,x sorted focusable elements.
  List<UIElement> tabStops;
  static Object _rootGroup;

  // When an element node has IsFocusGroup set to true, the FocusScopeData
  // for that element will be created on demand and assigned to
  // focusDataPropDef for caching (so we don't have to visually re-sort items
  // every time tab is pressed.
  static PropertyDefinition focusScopeProperty;

  static const int DIRECTION_FORWARD = 1;
  static const int DIRECTION_BACK = 2;
  static const num SMALLEST_FOCUS_AREA = 8;

  FocusScopeData(UIElement element) {
    _owner = element;
  }

  /**
   * Returns the focus group parent of an element.
   */
  static FocusScopeData findFocusGroup(UIElement element) {
    while (element != null) {
      if (element.isFocusGroup) {
        if (element.overridesProperty(focusScopeProperty)) {
          return element.getProperty(focusScopeProperty);
        }
        FocusScopeData data = new FocusScopeData(element);
        element.setProperty(focusScopeProperty, data);
        return data;
      }
      element = element.parent;
    }

    if (element == null) {
      if (_rootGroup == null) {
        _rootGroup = new FocusScopeData(null);
      }
      return _rootGroup;
    }
    return null;
  }

  /**
   * Returns the next tab stop relative to currentFocus.
   */
  UIElement getNextTabStop(UIElement currentFocus) {
    return getTabStop(currentFocus, DIRECTION_FORWARD);
  }

  /**
   * Returns the prior tab stop relative to currentFocus.
   */
  UIElement getPrevTabStop(UIElement currentFocus) {
    return getTabStop(currentFocus, DIRECTION_BACK);
  }

  UIElement getTabStop(UIElement currentFocus, int direction) {
    UIElement newFocus;
    _buildTabstopList();
    if (tabStops.length == 0) {
      return null;
    }
    int index = (currentFocus == null) ? -1 : tabStops.indexOf(currentFocus, 0);
    int startSearchIndex = index;
    do {
      if (direction == DIRECTION_FORWARD) {
        if (index == -1) {
          index = 0;
        } else {
          index++;
          if (index == tabStops.length) {
            if (this == _rootGroup) {
              index = 0;
            } else {
              return FocusScopeData.findFocusGroup(
                this._owner.visualParent).getTabStop(this._owner, direction);
            }
          }
        }
      } else {
        // backward tab
        if (index == -1) {
          index = tabStops.length - 1;
        } else {
          if (index == 0) {
            if (this == _rootGroup) {
              index = tabStops.length - 1; // return last item
            } else {
              return FocusScopeData.findFocusGroup(
                this._owner.visualParent).getTabStop(this._owner, direction);
            }
          } else {
            index--;
          }
        }
      }

      UIElement potential = tabStops[index];

      // TODO(ferhat): Revert the following code when dart compiler bug 8084574
      // is fixed.
//
//      // skip textedit/textbox that are linked.
//      if (potential is TextBox && currentFocus is TextEdit) {
//        if (potential.isVisualChild(currentFocus)) {
//          continue;
//        }
//      } else if (potential is TextEdit && currentFocus is TextBox) {
//        if (currentFocus.isVisualChild(potential)) {
//          continue;
//        }
//      }
//
//      if (_isValidTabStop(potential)) {
//        break;
//      }
//      // If the node is not a valid tab stop but represents a focus group,
//      // check if we can traverse into child to get the next tab stop.
//      if (potential.isFocusGroup) {
//        newFocus = findFocusGroup(potential).getTabStop(potential, direction);
//        if (newFocus != null) {
//          return newFocus;
//        }
//      }

      // skip textedit/textbox that are linked.
      if (!(((potential is TextBox) && (currentFocus is TextEdit) &&
          potential.isVisualChild(currentFocus)) ||
          (potential is TextEdit && currentFocus is TextBox &&
          currentFocus.isVisualChild(potential)))) {

        if (_isValidTabStop(potential)) {
          break;
        }
        // If the node is not a valid tab stop but represents a focus group,
        // check if we can traverse into child to get the next tab stop.
        if (potential.isFocusGroup) {
          newFocus = findFocusGroup(potential).getTabStop(potential, direction);
          if (newFocus != null) {
            return newFocus;
          }
        }
      }
    } while (index != startSearchIndex);
    if (index == startSearchIndex) {
      return null;
    }
    newFocus = tabStops[index];
    if (newFocus == currentFocus) {
      return FocusScopeData.findFocusGroup(
          this._owner.visualParent).getTabStop(this._owner, direction);
    }
    return newFocus;
  }

  void _buildTabstopList() {
    tabStops = [];
    UIElement startNode = (_owner == null) ? Application.current.content :
        _owner;
    if (startNode != null) {
      _addTabStops(startNode);
    }
    tabStops.sort(visualSort);
  }

  int visualSort(UIElement a, UIElement b) {
    num ax = 0;
    num ay = 0;
    num bx = 0;
    num by = 0;
    UIElement element = a;
    while (element != null) {
      ax += element.layoutX;
      ay += element.layoutY;
      element = element.visualParent;
    }
    element = b;
    while (element != null) {
      bx += element.layoutX;
      by += element.layoutY;
      element = element.visualParent;
    }
    ay = (ay / SMALLEST_FOCUS_AREA).ceil();
    by = (by / SMALLEST_FOCUS_AREA).ceil();
    if (ay < by) {
      return -1;
    } else if (ay > by) {
      return 1;
    }
    if (ax < bx) {
      return -1;
    } else if (ax > bx) {
      return 1;
    }

    // If 2 items are on top of each other (example:TextBox/Edit)
    // Use hierarchy to order the items.
    if (a.isVisualChild(b)) {
      return -1;
    } else if (b.isVisualChild(a)) {
      return 1;
    }
    return 0;
  }

  void _addTabStops(UIElement node) {
    if (node.getRawChildCount() != 0) {
      for (int i = 0; i < node.getRawChildCount(); i++) {
        _addChildTabs(node.getRawChild(i));
      }
    }
  }

  void _addChildTabs(UIElement node) {
    if (node.visible == false || node.opacity == 0.0) {
      return;
    }
    if (node.focusEnabled || node.isFocusGroup) {
      tabStops.add(node);
    }
    if (node.isFocusGroup) {
      // don't add children of a focus group.
      return;
    }
    if (node.getRawChildCount() != 0) {
      for (int i = 0; i < node.getRawChildCount(); i++) {
        _addChildTabs(node.getRawChild(i));
      }
    }
  }

  /** Returns true if element is still valid tab stop. */
  static bool _isValidTabStop(UIElement element) {
    UIElement visElement = element;
    if (visElement.focusEnabled == false) {
      return false;
    }
    if ((visElement.enabled == false) || (visElement.opacity == 0.0)) {
      return false;
    }
    while (visElement != null) {
      if ((visElement.visible == false) || (visElement.opacity == 0.0)) {
        return false;
      }
      // There are instances where the element or one of it's parent
      // are collapsed using a disclosurebox but still visible.
      // Need to explicitely check for height to catch case.
      if (visElement.layoutHeight == 0) {
        return false;
      }
      visElement = visElement.parent;
    }
    return true;
  }
}
