package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements layout element that wraps lines.
 *
 * @author ferhat
 */
public class WrapBox extends UIElementContainer {

  /** UniformWidth Property Definition */
  public static PropertyDefinition uniformWidthPropDef = PropertySystem.register("UniformWidth",
      Boolean.class, WrapBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Resize)));

  /** UniformHeight Property Definition */
  public static PropertyDefinition uniformHeightPropDef = PropertySystem.register("UniformHeight",
      Boolean.class, WrapBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Resize)));

  /** TileChildren Property Definition */
  public static PropertyDefinition tileChildrenPropDef = PropertySystem.register("TileChildren",
      Boolean.class, WrapBox.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Resize)));

  /** Direction Property Definition */
  public static PropertyDefinition directionPropDef = PropertySystem.register("Direction",
      Orientation.class, WrapBox.class,
      new PropertyData(Orientation.Horizontal));

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    double xPos = 0; // current layout position
    double yPos = 0;
    double maxRowHeight = 0;
    double maxColWidth = 0;
    double maxWidth = 0;
    double maxHeight = 0;
    Orientation direction = getDirection();
    UIElement child;

    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      child = getChild(childIndex);
      child.measure(availableWidth, availableHeight);

      double maxChildWidth = 0; // used for uniformWidth.
      double maxChildHeight = 0;

      if (getUniformWidth()) {
        // Calculate optimal item width to use
        double minChildWidth = child.getMinWidth();
        double width = Double.isNaN(minChildWidth) ? child.getMeasuredWidth() :
            Math.max(minChildWidth, child.getMeasuredWidth());
        maxChildWidth = Math.max(maxChildWidth,
            Double.isNaN(child.getMaxWidth()) ? width : Math.min(child.getMaxWidth(), width));
      }
      if (getUniformHeight()) {
        double minChildHeight = child.getMinHeight();
        double height = Double.isNaN(minChildHeight) ? child.getMeasuredHeight() :
            Math.max(minChildHeight, child.getMeasuredHeight());
        maxChildHeight = Math.max(maxChildHeight,
            Double.isNaN(child.getMaxHeight()) ? height : Math.min(child.getMaxHeight(), height));
      }
    }

    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      child = getChild(childIndex);
      if (direction == Orientation.Horizontal) {
        // If item doesn't fit in current row , wrap to next row, otherwise advance
        if (xPos != 0 && (xPos + child.getMeasuredWidth()) > availableWidth) {
          yPos += maxRowHeight;
          xPos = 0;
          maxRowHeight = 0;
        } else {
          xPos += child.getMeasuredWidth();
          maxRowHeight = Math.max(maxRowHeight, child.getMeasuredHeight());
        }
        maxWidth = Math.max(maxWidth, xPos);
        maxHeight = Math.max(maxHeight, yPos + child.getMeasuredHeight());
      } else {
        // If item doesn't fit in current col , wrap to next col, otherwise advance
        if (yPos != 0 && (yPos + child.getMeasuredHeight()) > availableHeight) {
          xPos += maxColWidth;
          yPos = 0;
          maxColWidth = 0;
        } else {
          yPos += child.getMeasuredHeight();
          maxColWidth = Math.max(maxColWidth, child.getMeasuredWidth());
        }
        maxHeight = Math.max(maxHeight, yPos);
        maxWidth = Math.max(maxWidth, xPos + child.getMeasuredWidth());
      }
    }
    if (direction == Orientation.Horizontal) {
      maxHeight = Math.max(maxHeight, yPos + maxRowHeight);
    } else {
      maxWidth = Math.max(maxWidth, xPos + maxColWidth);
    }
    setMeasuredDimension(maxWidth, maxHeight);
  }

  @Override
  protected void onLayout(Rectangle layoutRect) {
    double xPos = 0; // current layout position
    double yPos = 0;
    double maxRowHeight = 0;
    double maxColWidth = 0;
    Orientation direction = getDirection();
    UIElement child;

    int childCount = getChildCount();
    for (int childIndex = 0; childIndex < childCount; ++childIndex) {
      child = getChild(childIndex);

      if (direction == Orientation.Horizontal) {
        // If item doesn't fit in current row , wrap to next row, otherwise advance
        if (xPos != 0 && (xPos + child.getMeasuredWidth()) > layoutRect.width) {
          yPos += maxRowHeight;
          xPos = 0;
          maxRowHeight = 0;
        }
        child.layout(new Rectangle(xPos, yPos, child.getMeasuredWidth(),
            child.getMeasuredHeight()));
        xPos += child.getMeasuredWidth();
        maxRowHeight = Math.max(maxRowHeight, child.getMeasuredHeight());
      } else {
        // If item doesn't fit in current col , wrap to next col, otherwise advance
        if (yPos != 0 && (yPos + child.getMeasuredHeight()) > layoutRect.height) {
          xPos += maxColWidth;
          yPos = 0;
          maxColWidth = 0;
        }
        child.layout(new Rectangle(xPos, yPos, child.getMeasuredWidth(),
            child.getMeasuredHeight()));
        yPos += child.getMeasuredHeight();
        maxColWidth = Math.max(maxColWidth, child.getMeasuredWidth());
      }
    }
  }

  /**
   * Sets/returns if items are sized to equal width.
   */
  public void setUniformWidth(boolean value) {
    setProperty(uniformWidthPropDef, value);
  }

  public boolean getUniformWidth() {
    return ((Boolean) getProperty(uniformWidthPropDef));
  }

  /**
   * Sets/returns if items are sized to equal height.
   */
  public void setUniformHeight(boolean value) {
    setProperty(uniformWidthPropDef, value);
  }

  public boolean getUniformHeight() {
    return ((Boolean) getProperty(uniformWidthPropDef));
  }

  /**
   * Gets or sets whether all items should be sized to largest child size.
   */
  public boolean getTileChildren() {
    return ((Boolean) getProperty(tileChildrenPropDef));
  }

  public void setTileChildren(boolean value) {
    setProperty(tileChildrenPropDef, value);
  }

  /**
   * Sets/returns the direction for tiling the children during layout.
   */
  public void setDirection(Orientation value) {
    setProperty(directionPropDef, value);
  }

  public Orientation getDirection() {
    return ((Orientation) getProperty(directionPropDef));
  }
}
