package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.events.CollectionChangedEvent;
import com.hello.uxml.tools.framework.events.EventArgs;
import com.hello.uxml.tools.framework.events.EventHandler;
import com.hello.uxml.tools.framework.events.EventNotifier;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

/**
 * Implements grid container control.
 *
 * @author ferhat
 */
public class Grid extends UIElementContainer {

  // Holds grid row definitions specified by user.
  private GridRows externalRows = new GridRows();

  // Holds grid column definitions specified by user.
  private GridColumns externalColumns = new GridColumns();

  // Holds internal collection of rows used during layout.
  private List<GridDef> gridRows = null;

  // Holds internal collection of columns used during layout.
  private List<GridDef> gridColumns = null;

  // Holds current layout size to detect relayout.
  private double prevGridWidth;
  private double prevGridHeight;

  /** Column Property Definition */
  public static PropertyDefinition columnPropDef = PropertySystem.register("Column", Integer.class,
      Grid.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          if (element.parent instanceof Grid) {
            ((Grid) element.parent).childLocationChanged(e);
          }
        }}));

  /** Row Property Definition */
  public static PropertyDefinition rowPropDef = PropertySystem.register("Row", Integer.class,
      Grid.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.Attached), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          UIElement element = (UIElement) e.getSource();
          if (element.parent instanceof Grid) {
            ((Grid) element.parent).childLocationChanged(e);
          }
        }}));

  /** CellPadding Property Definition */
  public static PropertyDefinition cellPaddingPropDef = PropertySystem.register("CellPadding",
      Double.class, Grid.class, new PropertyData(0.0));

  /** Helper function to set child column */
  public static void setChildColumn(UIElement child, int column) {
    child.setProperty(columnPropDef, column);
  }

  /** Helper function to get child column */
  public static int getChildColumn(UIElement child) {
    return ((Integer) child.getProperty(columnPropDef)).intValue();
  }

  /** Helper function to set child column */
  public static void setChildRow(UIElement child, int row) {
    child.setProperty(rowPropDef, row);
  }

  /** Helper function to get child column */
  public static int getChildRow(UIElement child) {
    return ((Integer) child.getProperty(rowPropDef)).intValue();
  }

  /**
   * Constructor.
   */
  public Grid() {
    externalRows.addListener(CollectionChangedEvent.changeEvent,
        new EventHandler() {
          @Override
          public void handleEvent(EventNotifier targetObject, EventArgs e) {
            // force resize/relayout
            gridRows = null;
            gridColumns = null;
            invalidateSize();
          }
        });
  }

  /**
   * Checks if grid layout needs to be recalculated.
   * @param availableWidth The max target area width available for grid.
   * @param availableHeight The target area height available for grid.
   */
  private boolean isGridLayoutDirty(double availableWidth, double availableHeight) {
    return (gridRows == null) || (gridColumns == null) ||
      (prevGridWidth != availableWidth) ||
      (prevGridHeight != availableHeight);
  }


  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    if (isGridLayoutDirty(availableWidth, availableHeight)) {
      relayoutGrid(availableWidth, availableHeight);
    }
    double totalWidth = computeFinalLayoutSize(gridColumns);
    double totalHeight = computeFinalLayoutSize(gridRows);
    setMeasuredDimension(totalWidth, totalHeight);
  }

  /**
   * Using the grid definition minLayoutSize, updates the position
   * and size of GridDefs.
   * @return Returns total minimum layout size.
   */
  private double computeFinalLayoutSize(List<GridDef> array) {
    double totalSize = 0;
    for (int i = 0; i < array.size(); i++) {
      GridDef def = array.get(i);
      def.position = totalSize;
      def.size = def.minLayoutSize;
      totalSize += def.minLayoutSize;
    }
    return totalSize;
  }

  /**
   * @see com.hello.uxml.tools.framework.UIElement#onLayout
   */
  @Override
  protected void onLayout(Rectangle targetRect) {
    int row = 0;
    int column = 0;
    int numChildren = getChildCount();

    if (isGridLayoutDirty(targetRect.getWidth(), targetRect.getHeight())) {
      relayoutGrid(targetRect.getWidth(), targetRect.getHeight());
    }

    for (int c = 0; c < numChildren; c++) {
      UIElement child = getChild(c);
      row = ((Integer) child.getProperty(rowPropDef)).intValue();
      column = ((Integer) child.getProperty(columnPropDef)).intValue();

      if (row > gridRows.size()) {
        row = gridRows.size() - 1;
      }

      if (column > gridColumns.size()) {
        column = gridColumns.size() - 1;
      }

      child.layout(gridColumns.get(column).position,
          gridRows.get(row).position,
          gridColumns.get(column).size,
          gridRows.get(row).size);
    }
  }

  /**
   * Prepares gridRows and gridColumns for grid layout. During the measure
   * step, the grid is asked for optimal size. Since this function is called
   * during final layout, the grid must fit the total area specified by
   * availableWidth/Height parameters otherwise contents will be clipped
   * against parent container depending on parent container clipping/mask
   * settings.
   * @param availableWidth maximum amount of horizontal space available for
   *  grid columns.
   * @param availableHeight maximum amount of vertical space available for
   *  grid rows.
   */
  private void relayoutGrid(double availableWidth, double availableHeight) {

    if (gridRows == null) {
      gridRows = new ArrayList<GridDef>();
      if (externalRows.size() == 0) {
        // create at least 1 row and column if user didn't define any.
        gridRows.add(new GridRow());
      } else {
        for (int r = 0; r < externalRows.size(); ++r) {
          gridRows.add((GridRow) externalRows.get(r));
       }
      }
    }

    if (gridColumns == null) {
      gridColumns = new ArrayList<GridDef>();
      if (externalColumns.size() == 0) {
        // create at least 1 row and column if user didn't define any.
        gridColumns.add(new GridColumn());
      } else {
        for (int c = 0; c < externalColumns.size(); ++c) {
          gridColumns.add((GridColumn) externalColumns.get(c));
        }
      }
    }

    calcFixedGridLayout(availableWidth, availableHeight);
    prevGridWidth = availableWidth;
    prevGridHeight = availableHeight;
  }

  /**
   * Calculates minLayoutSize and layoutSize for all columns and rows.
   */
  private void calcFixedGridLayout(double availableWidth,
      double availableHeight) {
    GridColumn column;
    int columnIndex = 0;

    // First setup minLayoutSize on all columns and rows.
    initLayoutSizes(gridColumns);
    initLayoutSizes(gridRows);

    updateMinimumLayoutSize(false);

    // Process percentage sized columns.
    double totalColumnsPercent = 0;
    double totalColumnsFixedSize = 0;
    int lastColumn = -1;
    int columnCount = gridColumns.size();
    for (columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      column = (GridColumn) gridColumns.get(columnIndex);
      if (column.layoutType == LayoutType.Percent) {
        totalColumnsPercent += column.getWidth();
        lastColumn = columnIndex;
      } else {
        totalColumnsFixedSize += column.minLayoutSize;
      }
    }

    distributeExtraSpace(availableWidth, totalColumnsPercent,
        totalColumnsFixedSize, lastColumn);

    // We now have minLayoutSize and layoutSize calculated for each column and
    // row and can measure cells on percentage based columns/rows.
    updateMinimumLayoutSize(true);
  }

  /**
   * Distributes extra space across columns that have percent based layout.
   *
   * @param availableWidth Total amount of space available.
   * @param totalPercent Total of percent values for all columns.
   * @param totalFixedSize Fixed size used by columns.
   * @param lastColumnIndex Index of last column that has percent
   *  layout.
   */
  private void distributeExtraSpace(double availableWidth, double totalPercent,
      double totalFixedSize, int lastColumnIndex) {

    // If we have more available width than totalFixed minimum size,
    // distribute the extra amount to each percentage based column. To
    // eliminate rounding assign remainder to last column.
    int columnCount = gridColumns.size();
    if (availableWidth > totalFixedSize) {
      double totalDistribAmount = (availableWidth - totalFixedSize);
      double distribAmount = totalDistribAmount;
      for (int columnIndex = 0; columnIndex < columnCount;
          columnIndex++) {
        GridColumn column = (GridColumn) gridColumns.get(columnIndex);
        if (column.layoutType != LayoutType.Percent) {
          continue;
        }
        if (columnIndex == lastColumnIndex) {
          column.minLayoutSize = Math.max(distribAmount,
            column.minLayoutSize);
        } else {
          double s = (column.getWidth() / totalPercent) *
            totalDistribAmount;
          column.minLayoutSize = Math.max(s, column.minLayoutSize);
          distribAmount -= s;
        }
        column.layoutSize = column.minLayoutSize;
      }
    }
  }

  /**
   * Measures children and updates minimum sizes for auto and fixed sized
   * columns for fixed grid layout.
   * @param isPercentLayout whether this is percentage based layout.
   */
  private void updateMinimumLayoutSize(boolean isPercentLayout) {
    int numChildren = getChildCount();
    for (int childIndex = 0; childIndex < numChildren; childIndex++) {

      UIElement child = getChild(childIndex);
      int rowIndex = ((Integer) child.getProperty(rowPropDef)).intValue();
      int columnIndex = ((Integer) child.getProperty(columnPropDef)).intValue();

      if (rowIndex > gridRows.size()) {
        rowIndex = gridRows.size() - 1;
      }
      if (columnIndex > gridColumns.size()) {
        columnIndex = gridColumns.size() - 1;
      }
      GridColumn column = (GridColumn) gridColumns.get(columnIndex);
      GridRow row = (GridRow) gridRows.get(rowIndex);

      if ((isPercentLayout && (column.layoutType == LayoutType.Percent)) ||
          isPercentLayout == false && (column.layoutType != LayoutType.Percent)) {
        child.measure(column.layoutSize, row.layoutSize);
        column.minLayoutSize = Math.max(column.minLayoutSize,
          child.getMeasuredWidth());
        row.minLayoutSize = Math.max(row.minLayoutSize, child.getMeasuredHeight());
      }
    }
  }

  /**
   * Sets minLayoutSize based on a column or row's layout settings
   * such as minLength, maxLength, length and layout type. This step prepares
   * the column and row objects for measuring cell content size and later
   * applying percent based updates.
   */
  private void initLayoutSizes(List<GridDef> array) {
    int length = array.size();
    for (int index = 0; index < length; index++) {
      array.get(index).initLayoutSizes();
    }
  }

  /**
   * Returns grid columns collection.
   */
  @CollectionNode
  public GridColumns getColumns() {
    return externalColumns;
  }

  /**
   * Returns grid rows collection.
   */
  @CollectionNode
  public GridRows getRows() {
    return externalRows;
  }

  /**
   * Sets/returns cell padding.
   */
  public void setCellPadding(double value) {
    setProperty(cellPaddingPropDef, value);
  }

  public double getCellPadding() {
    return ((Double) getProperty(cellPaddingPropDef)).doubleValue();
  }

  private void childLocationChanged(PropertyChangedEvent e) {
    invalidateSize();
  }
}
