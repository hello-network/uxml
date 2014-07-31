package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.BlendMode;
import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Represents a basic 2D compositing element for rendering and UI input.
 *
 * @author ferhat
 */
public interface UISurface {

  /**
   * Sets the target to be called for input events on the surface.
   */
  void setTarget(UISurfaceTarget target);

  /**
   * Clears the render list.
   */
  void clearRenderList();

  /**
   * Add rectangle to render list.
   */
  void drawRect(Brush brush, Pen pen, Rectangle rect);

  /**
   * Add rounded rectangle to render list.
   */
  void drawRect(Brush brush, Pen pen, Rectangle rect, BorderRadius borderRadius);

  /**
   * Add ellipse to render list.
   */
  void drawEllipse(Brush brush, Pen pen, Rectangle rect);

  /**
   * Add path to render list.
   */
  void drawPath(Brush brush, Pen pen, VecPath path);

  /**
   * Add line to render list.
   */
  void drawLine(Pen pen, double xFrom, double yFrom, double xTo, double yTo);

  /**
   * Add child surface.
   */
  void addChild(UISurface surface);

  /**
   * Remove child surface.
   */
  void removeChild(UISurface surface);

  /**
   * Changes child's zorder.
   */
  void setChildDepth(UISurface child, int depth);

  /**
   * Returns number of children.
   */
  int getChildCount();

  /**
   * Returns child at index.
   */
  UISurface getChild(int index);

  /**
   * Returns parent surface.
   */
  UISurface getParentSurface();

  /**
   * Sets parent surface.
   */
  void setParentSurface(UISurface parentSurface);

  /**
   * Removes item from display list.
   */
  void close();

  /**
   * Creates a child UISurface
   */
  UISurface createChildSurface();

  /**
   * Creates a child UITextSurface
   */
  UISurface createChildTextSurface();

  /**
   * Creates a child UIImageSurface
   */
  UISurface createChildImageSurface();

  /**
   * Gets or sets surface location.
   */
  void setLayout(Rectangle layoutRect);

  /**
   * Sets surface visibility.
   */
  void setVisible(boolean visible);

  /**
   * Refreshes view.
   */
  void updateView();

  /**
   * Refreshes view area.
   */
  void updateView(double x, double y, double width, double height);

  /**
   * Sets opacity of surface 0(transparent)..1(opaque)
   */
  void setOpacity(double opacity);

  /**
   * Sets blend mode of surface.
   */
  void setBlendMode(BlendMode blendMode);

  /**
   * Adds a filter to surface.
   */
  void addFilter(Filter filter);
  /**
   * Removes a filter from surface.
   */
  void removeFilter(Filter filter);

  /**
   * Performs hit testing on self and child elements. If successful,
   * return true and fills the hitResult object.
   */
  boolean hitTest(double x, double y, HitTestResult hitResult);

  /**
   * Sets hit testing strategy.
   * <p>HITTEST_CONTENT = 0 , checks for visible items
   * <p>HITTEST_BOUNDS = 1, checks against surface bounds. Typically used for
   * invisible areas that are buttons.
   */
  public void setHitTestMode(int mode);
}
