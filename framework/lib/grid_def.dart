part of uxml;

/**
 * Implements shared layout processing for GridColumn and GridRow objects.
 * TODO(ferhat): implement column and row spans
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class GridDef extends UxmlElement {

  /**
   * Gets or sets the type of layout to use for this column or row.
   */
  int layoutType;

  num _length = 0.0;
  bool lengthDefined;

  // min/maxLength and length are defined internal so that the grid layout
  // algorithm can access these directly and treat columns/rows uniformly.

  // Gets or sets minimum length of a column or row.
  num minLength;

  // Gets or sets maximum length of a column or row.
  num _maxLength;
  bool maxLengthDefined;

  // minumum size for content used by layout.
  num minLayoutSize;

  // measure size for content used by layout.
  num layoutSize;

  // final position of column or row after layout.
  num position;

  // final length of column or row after layout.
  num size;

  /** Sets or returns owner of definition used to notify grid of changes. */
  Grid owner;

  /**
   * Constructor.
   */
  GridDef() : super() {
    layoutType = LayoutType.AUTO;
    minLength = 0.0;
    maxLengthDefined = false;
    lengthDefined = false;
  }

  /**
   * Initializes layout parameters by using column/row definition specified
   * by user.
   * If column type is auto or percent, minimum size is set to minLength.
   * For fixed size columns the minimum size is the greater of minwidth and
   * the minimum of fixed width and maxwidth.
   */
  void initLayoutSizes() {
    if (layoutType == LayoutType.FIXED) {
      if (!lengthDefined) {
        minLayoutSize = maxLengthDefined ? min(minLength, maxLength) :
            minLength;
      } else {
        minLayoutSize = maxLengthDefined ? max(minLength,
            min(maxLength, length)) : max(minLength, length);
      }
      layoutSize = minLayoutSize;
    } else {
      minLayoutSize = minLength;
      layoutSize = maxLengthDefined ? max(maxLength, minLength) :
          minLength;
    }
  }

  /**
   * Sets or returns the length of a column or row for Percent and
   * Fixed layout types.
   */
  set length(num value) {
    if (!(value is num)) {
      throw new ArgumentError();
    }
    _length = value;
    lengthDefined = true;
  }

  num get length => _length;

  /**
   * Sets or returns the max length of a column or row for Percent and
   * fixed layout types.
   */
  set maxLength(num value) {
    _maxLength = value;
    maxLengthDefined = true;
  }

  num get maxLength => _maxLength;
}

abstract class LayoutType {
  /**
   * Constant for automatic layout.
   */
  static const int AUTO = 1;

  /**
   * Constant for percentage based layout.
   */
  static const int PERCENT = 2;

  /**
   * Constant for fixed pixel size layout.
   */
  static const int FIXED = 4;
}
