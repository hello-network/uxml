package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Pen;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Implements border that decorates an inner element and provides padding properties.
 *
 * @author ferhat
 */
public class Border extends Control {

  static {
    Shape.strokePropDef.addPropData(Border.class, new PropertyData(null,
        EnumSet.of(PropertyFlags.Redraw)));
  }

  /** child control */
  private UIElement child;

  /** Sets child element */
  @ContentNode
  public void setChild(UIElement value) {
    if (child != null) {
      removeRawChild(child);
    }
    child = value;
    if (child != null) {
      addRawChild(child);
    }
  }

  /**
   * Returns child element.
   */
  public UIElement getChild() {
    return child;
  }

  @Override
  protected int getRawChildCount() {
    return (child == null) ? 0 : 1;
  }

  @Override
  protected UIElement getRawChild(int index) {
    if (index != 0) {
      throw new IndexOutOfBoundsException();
    }
    return child;
  }

  /** Gets or sets border stroke */
  public Pen getStroke() {
    return (Pen) getProperty(Shape.strokePropDef);
  }

  public void setStroke(Pen value) {
    setProperty(Shape.strokePropDef, value);
  }

  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    if (child != null) {
      child.measure(availableWidth, availableHeight);
      setMeasuredDimension(child.getMeasuredWidth() + getPadding().getWidth(),
          child.getMeasuredHeight() + getPadding().getHeight());
    }
  }

  @Override
  protected void onLayout(Rectangle layoutRectangle) {
    if (child != null) {
      child.layout(new Rectangle(getPadding().getLeft(),
          getPadding().getTop(),
          layoutRectangle.width - getPadding().getWidth(),
          layoutRectangle.height - getPadding().getHeight()));
    }
  }

  @Override
  protected void onRedraw(UISurface surface) {
    Brush br = getBackground();
    Pen pen = getStroke();
    if ((br == null) && (pen == null)) {
      return;
    }
    if (getBorderRadius().equals(BorderRadius.EMPTY)) {
      surface.drawRect(br, pen, new Rectangle(0, 0, this.getLayoutRect().width,
          this.getLayoutRect().height));
    } else {
      surface.drawRect(br, pen, new Rectangle(0, 0, this.getLayoutRect().width,
          this.getLayoutRect().height), getBorderRadius());
    }
  }
}
