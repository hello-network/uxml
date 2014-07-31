package com.hello.uxml.tools.framework;

/**
 * Implements shared layout processing for GridColumn and GridRow objects.
 *
 * TODO(ferhat): implement column and row spans
 *
 * @author ferhat
 */
public class GridDef extends UxmlElement {

  /** Gets or sets minimum length of a column or row. */
  protected double minLength;

  /** Gets or sets maximum length of a column or row. */
  protected double maxLength;

  /**
  * Gets or sets the length of a column or row for Percent and Fixed layout
  * types
  **/
  protected double length;

  /** minumum size for content used by layout */
  double minLayoutSize;

  /** measure size for content used by layout */
  protected double layoutSize;

  /** final position of column or row after layout */
  protected double position;

  /** final length of column or row after layout */
  protected double size;

  /**
  * Gets or sets the type of layout to use for this column or row.
  */
  protected LayoutType layoutType = LayoutType.Auto;

  /**
  * Constructor.
  */
  public GridDef() {
    length = Double.NaN;
    minLength = 0;
    maxLength = Double.NaN;
  }

  /**
  * Gets or sets layout type.
  */
  public LayoutType getLayoutType() {
    return layoutType;
  }

  public void setLayoutType(LayoutType value) {
    layoutType = value;
  }

  /**
  * Initializes layout parameters by using column/row definition specified
  * by user.
  * <p>If column type is auto or percent, minimum size is set to minLength.
  * For fixed size columns the minimum size is the greater of minwidth and
  * the minimum of fixed width and maxwidth.
  *
  */
  void initLayoutSizes() {
    if (layoutType == LayoutType.Fixed) {
      if (Double.isNaN(length)) {
        minLayoutSize = Double.isNaN(maxLength) ?
            minLength : Math.min(minLength, maxLength);
      } else {
        minLayoutSize = Double.isNaN(maxLength) ?
          Math.max(minLength, length) :
          Math.max(minLength, Math.min(maxLength, length));
      }
      layoutSize = minLayoutSize;
    } else {
      minLayoutSize = minLength;
      layoutSize = Double.isNaN(maxLength) ?
        minLength : Math.max(maxLength, minLength);
    }
  }
}
