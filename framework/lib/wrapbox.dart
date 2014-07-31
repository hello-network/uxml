part of uxml;

/**
 * Implements a container of UIElement(s) that wraps.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class WrapBox extends UIElementContainer {

  static ElementDef wrapboxElementDef;
  static PropertyDefinition uniformWidthProperty;
  static PropertyDefinition uniformHeightProperty;
  static PropertyDefinition tileChildrenProperty;
  static PropertyDefinition directionProperty;

  static const int MAX_COMPRESS_FACTOR = 3;
  static const int MAX_EXPAND_FACTOR = 3;

  /*
   * Sets/returns maximum number of columns for uniformWidth.
   */
  int maxColumns;
  int _firstVisibleChildIndex = -1;

  WrapBox() : super() {
    maxColumns = -1;
  }

  /**
   * Sets or returns whether items should be sized to equal width to fill
   * container width.
   */
  bool get uniformWidth {
    return getProperty(uniformWidthProperty);
  }

  set uniformWidth(bool val) {
    setProperty(uniformWidthProperty, val);
  }

  /**
   * Sets or returns whether items should be sized to equal height to fill
   * container height.
   */
  bool get uniformHeight {
    return getProperty(uniformHeightProperty);
  }

  set uniformHeight(bool val) {
    setProperty(uniformHeightProperty, val);
  }

  /**
   * Sets or returns the direction for tiling the children during layout.
   */
  int get direction => getProperty(directionProperty);

  set direction(int value) {
    setProperty(directionProperty, value);
  }

  /**
   * Sets or returns whether all items should be sized to largest child size.
   */
  bool get tileChildren {
    return getProperty(tileChildrenProperty);
  }

  set tileChildren(bool val) {
    setProperty(tileChildrenProperty, val);
  }

  /** Overrides UIElement.onMeasure to return size of element. */
  bool onMeasure(num availableWidth, num availableHeight) {
    if (childCount == 0) {
      setMeasuredDimension(0.0, 0.0);
      return false;
    }

    // else calculate width and height from child layout
    num xPos = 0.0;
    num yPos = 0.0;
    num maxHeightRow = 0.0;
    num maxWidthRow = 0.0;
    UIElement child;
    num w = 0.0;
    num h = 0.0;

    num availableWidthForMeasure = availableWidth;
    num availableHeightForMeasure = availableHeight;

    bool widthIsUniform = uniformWidth;
    bool heightIsUniform = uniformHeight;
    _firstVisibleChildIndex = -1;
    if (widthIsUniform || heightIsUniform) {
      // Find first child that is visible and use measured width/height.
      for (int c = 0; c < childCount; c++) {
        if (childAt(c).visible) {
          _firstVisibleChildIndex = c;
          childAt(c).measure(availableWidth, availableHeight);
          break;
        }
      }
    }

    num optimalWidth;
    if (widthIsUniform) {
      optimalWidth = _calcUniformWidth(availableWidth);
      availableWidthForMeasure = optimalWidth;
    }
    num optimalHeight;
    if (heightIsUniform) {
      optimalHeight = _calcUniformHeight(availableHeight);
      availableHeightForMeasure = optimalHeight;
    }

    int numRows = 1;
    int rowIndex = 0;
    int columnIndex = 0;
    int numColumns = 0;
    num maxChildWidth = 0.0;
    num maxChildHeight = 0.0;
    int dir = direction;

    if (tileChildren) {
      for (int m = 0; m < childCount; m++) {
        child = childAt(m);
        child.measure(availableWidthForMeasure, availableHeightForMeasure);
        if (child.measuredWidth > maxChildWidth) {
          maxChildWidth = child.measuredWidth;
        }
        if (child.measuredHeight > maxChildHeight) {
          maxChildHeight = child.measuredHeight;
        }
      }
    }

    for (int i = 0; i < childCount; i++) {
      child = childAt(i);
      child.measure(availableWidthForMeasure, availableHeightForMeasure);
      num childWidth = tileChildren ? maxChildWidth :
          (widthIsUniform ? optimalWidth : child.measuredWidth);
      num childHeight = tileChildren ? maxChildHeight :
          (heightIsUniform ? optimalHeight : child.measuredHeight);

      if (dir == UIElement.HORIZONTAL) {
        if (xPos != 0 && (xPos + childWidth) > availableWidth) {
          // Item doesn't fit in current row , so wrap to next row
          yPos += maxHeightRow;
          xPos = childWidth;
          columnIndex = 0;
          maxHeightRow = childHeight;
          ++numRows;
        }
        else {
          ++columnIndex;
          if (columnIndex > numColumns) {
            numColumns = columnIndex;
          }
          xPos += childWidth;
          maxHeightRow = max(maxHeightRow, childHeight);
        }
        w = max(w, xPos);
        h = max(h, yPos + childHeight);
      } else {
        // Vertical.
        if (yPos != 0 && (yPos + childHeight) > availableHeight) {
          // Item doesn't fit in current col , so wrap to next col
          xPos += maxWidthRow;
          yPos = childHeight;
          rowIndex = 0;
          maxWidthRow = childWidth;
          ++numColumns;
        }
        else {
          ++rowIndex;
          if (rowIndex > numRows) {
            numRows = rowIndex;
          }
          yPos += childHeight;
          maxWidthRow = max(maxWidthRow, childWidth);
        }
        h = max(h, yPos);
        w = max(w, xPos + childWidth);
      }
    }
    if (dir == UIElement.HORIZONTAL) {
      h = max(h, yPos + maxHeightRow);
    } else {
      w = max(w, xPos + maxWidthRow);
    }
    if (uniformWidth) {
      w = optimalWidth * numColumns;
    }
    if (uniformHeight) {
      h = optimalHeight * numRows;
    }
    setMeasuredDimension(w, h);
    return false;
  }

  // Calculates best width for uniform width distribution based on
  // measure of first child.
  num _calcUniformWidth(num availableWidth) {
    UIElement child = childAt(_firstVisibleChildIndex);
    num minVal;
    if (child.overridesProperty(UIElement.minWidthProperty)) {
      minVal = child.minWidth;
    } else {
      minVal = child.measuredWidth / MAX_COMPRESS_FACTOR;
    }
    num maxVal;
    if (child.overridesProperty(UIElement.maxWidthProperty)) {
      maxVal = child.maxWidth;
    } else {
      maxVal = child.measuredWidth * MAX_EXPAND_FACTOR;
    }
    int maxCol = max(1, (availableWidth / minVal).floor().toInt());
    int minCol = max(1, (availableWidth / maxVal).floor().toInt());
    int avgCol = ((maxCol + minCol) ~/ 2);
    if (child.measuredWidth != 0) {
      avgCol = (availableWidth / child.measuredWidth).floor().toInt();
    }
    // Now we have minColumns, maxColumns and mid value.
    if (avgCol < minCol) {
      avgCol = minCol;
    }
    if (avgCol > maxCol) {
      avgCol = maxCol;
    }
    if (maxColumns != -1) {
      if (avgCol > maxColumns) {
        maxColumns = avgCol;
      }
    }
    return availableWidth / avgCol;
  }

  num _calcUniformHeight(num availableHeight) {
    UIElement child = childAt(_firstVisibleChildIndex);
    num minVal;
    if (child.overridesProperty(UIElement.minHeightProperty)) {
      minVal = child.minHeight;
    } else {
      minVal = (child.measuredHeight / MAX_COMPRESS_FACTOR);
    }
    num maxVal;
    if (child.overridesProperty(UIElement.maxHeightProperty)) {
      maxVal = child.maxHeight;
    } else {
      maxVal = child.measuredHeight * MAX_EXPAND_FACTOR;
    }
    int maxRows = max(1, (availableHeight / minVal).floor().toInt());
    int minRows = max(1, (availableHeight / maxVal).floor().toInt());
    int midRows = ((maxRows + minRows) ~/ 2);
    if (child.measuredHeight != 0) {
      midRows = (availableHeight / child.measuredHeight).floor().toInt();
    }
    // Now we have minColumns, maxColumns and mid value.
    if (midRows < minRows) {
      midRows = minRows;
    }
    if (midRows > maxRows) {
      midRows = maxRows;
    }
    return availableHeight / midRows;
  }

  /** Overrides UIElement.onLayout. */
  void onLayout(num targetX, num targetY, num targetWidth, num targetHeight) {
    // else calculate width and height from child layout
    num maxHeightRow = 0.0;
    num maxWidthRow = 0.0;
    UIElement child;
    num childWidth;
    num childHeight;
    num w = 0.0;
    num h = 0.0;
    num xPos = 0.0;
    num yPos = 0.0;
    int dir = direction;
    if (childCount == 0) {
      return;
    }

    num availableWidthForMeasure = targetWidth;
    num availableHeightForMeasure = targetHeight;

    bool widthIsUniform = uniformWidth;
    bool heightIsUniform = uniformHeight;

    if (widthIsUniform || heightIsUniform) {
      childAt(_firstVisibleChildIndex).measure(targetWidth, targetHeight);
    }

    num optimalWidth;
    if (widthIsUniform) {
      optimalWidth = _calcUniformWidth(targetWidth);
      availableWidthForMeasure = optimalWidth;
    }
    num optimalHeight;
    if (heightIsUniform) {
      optimalHeight = _calcUniformHeight(targetHeight);
      availableHeightForMeasure = optimalHeight;
    }

    num maxChildWidth = 0.0;
    num maxChildHeight = 0.0;

    if (tileChildren) {
      for (int m = 0; m < childCount; m++) {
        child = childAt(m);
        child.measure(availableWidthForMeasure, availableHeightForMeasure);
        if (child.measuredWidth > maxChildWidth) {
          maxChildWidth = child.measuredWidth;
        }
        if (child.measuredHeight > maxChildHeight) {
          maxChildHeight = child.measuredHeight;
        }
      }
    }

    for (int i = 0; i < childCount; i++) {
      child = childAt(i);
      childWidth = tileChildren ? maxChildWidth :
          (widthIsUniform ? optimalWidth : child.measuredWidth);
      childHeight = tileChildren ? maxChildHeight :
          (heightIsUniform ? optimalHeight : child.measuredHeight);
      if (dir == UIElement.HORIZONTAL) {
        if (xPos != 0 && (xPos + childWidth) > targetWidth) {
          // Item doesn't fit in current row , so wrap to next row
          yPos += maxHeightRow;
          xPos = 0.0;
          maxHeightRow = 0.0;
        }
        child.layout(xPos, yPos, childWidth, childHeight);
        xPos += childWidth;
        maxHeightRow = max(maxHeightRow, childHeight);
      } else {
        if (yPos != 0 && (yPos + childHeight) > targetHeight) {
          // Item doesn't fit in current col , so wrap to next col
          xPos += maxWidthRow;
          yPos = 0;
          maxWidthRow = 0;
        }
        child.layout(xPos, yPos, childWidth, childHeight);
        yPos += childHeight;
        maxWidthRow = max(maxWidthRow, childWidth);
      }
    }
  }

  /** Returns the number of children that can fit in this container. */
  int estimateCapacity() {
    // If we have no children, then we are done.
    if (childCount == 0) {
      return 0;
    }

    // Else calculate width and height from child layout.
    num maxHeightRow = 0;
    num maxWidthRow = 0;
    UIElement child;
    num maxChildWidth = 0;
    num maxChildHeight = 0;
    int direction = this.direction;
    num xPos = 0;
    num yPos = 0;
    num targetWidth = layoutWidth;
    num targetHeight = layoutHeight;

    maxHeightRow = 0;
    maxWidthRow = 0;

    int capacity = 0;
    int i = 0;

    if (direction == UIElement.HORIZONTAL) {
      while (xPos < targetWidth && yPos < targetHeight) {
        if (i < childCount) {
          child = childAt(i++);
          maxChildWidth = max(child.measuredWidth, maxChildWidth);
          maxChildHeight = max(child.measuredHeight, maxChildHeight);
        } else if (maxChildWidth == 0 || maxHeightRow == 0) {
          // We are out of children to measure so max values used to advance
          // xPos and yPos will be stuck at zero resulting in an endless loop.
          break;
        }

        if (xPos != 0 && (xPos + maxChildWidth) > targetWidth) {
          // Item doesn't fit in current row , so wrap to next row
          yPos += maxHeightRow;
          xPos = 0;
          maxHeightRow = 0;
        }

        if (yPos + maxChildHeight < targetHeight) {
          capacity++;
        }

        xPos += maxChildWidth;
        maxHeightRow = max(maxHeightRow, maxChildHeight);
      }
      return capacity;
    }
    // Else we are vertical.
    while (xPos < targetWidth && yPos < targetHeight) {
      if (i < childCount) {
        child = childAt(i++);
        maxChildWidth = max(child.measuredWidth, maxChildWidth);
        maxChildHeight = max(child.measuredHeight, maxChildHeight);
      } else if (maxWidthRow == 0 || maxChildHeight == 0) {
        // We are out of children to measure so max values used to advance
        // xPos and yPos will be stuck at zero resulting in an endless loop.
        break;
      }

      if (yPos != 0 && (yPos + maxChildHeight) > targetHeight) {
        // Item doesn't fit in current col , so wrap to next col
        xPos += maxWidthRow;
        yPos = 0;
        maxWidthRow = 0;
      }

      if (xPos + maxChildWidth < targetWidth) {
        capacity++;
      }

      yPos += maxChildHeight;
      maxWidthRow = max(maxWidthRow, maxChildWidth);
    }
    return capacity;
  }

  /** Registers component. */
  static void registerWrapBox() {
    uniformWidthProperty = ElementRegistry.registerProperty("uniformWidth",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    uniformHeightProperty = ElementRegistry.registerProperty("uniformHeight",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    tileChildrenProperty = ElementRegistry.registerProperty("tileChildren",
        PropertyType.BOOL, PropertyFlags.RESIZE, null, false);
    directionProperty = ElementRegistry.registerProperty("direction",
        PropertyType.ORIENTATION, PropertyFlags.RESIZE, null,
        UIElement.HORIZONTAL);

    wrapboxElementDef = ElementRegistry.register("WrapBox",
        UIElementContainer.uielementcontainerElementDef, [uniformWidthProperty,
        uniformHeightProperty, tileChildrenProperty, directionProperty], null);
  }

  /** @see UxmlElement.getDefinition. */
  ElementDef getDefinition() => wrapboxElementDef;
}
