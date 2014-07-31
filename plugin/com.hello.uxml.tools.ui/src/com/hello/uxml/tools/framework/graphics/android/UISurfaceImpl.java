package com.hello.uxml.tools.framework.graphics.android;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.BlendMode;
import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Filter;
import com.hello.uxml.tools.framework.graphics.HitTestResult;
import com.hello.uxml.tools.framework.graphics.Path;
import com.hello.uxml.tools.framework.graphics.Pen;
import com.hello.uxml.tools.framework.graphics.UISurface;
import com.hello.uxml.tools.framework.graphics.UISurfaceTarget;

import java.util.List;

/**
 * Implements UISurface on android view class.
 *
 * @author ferhat
 */
public class UISurfaceImpl implements UISurface {
  private static final int HITTEST_MODE_CONTENT = 0;
  @SuppressWarnings("unused")
  private static final int HITTEST_MODE_BOUNDS = 1;

  protected UISurfaceTarget uiTarget;

  /** List of persistent drawable items */
  protected List<IRenderItem> renderList;

  /** List of child surfaces */
  private List<UISurfaceImpl> rawChildren = Lists.newArrayList();

  /** Parent surface */
  UISurface parent;

  /** Surface visibility */
  protected boolean visible = true;

  /** Surface relative offset/size to parent*/
  public Rectangle layoutRect = new Rectangle(0, 0, 0, 0);

  /** Surface opacity */
  private double opacity = 1.0;

  /**
   * @see UISurface
   */
  private int hitTestMode = 0;

  /**
   * Constructor.
   */
  public UISurfaceImpl() {
  }

  /**
   * Returns parent surface.
   */
  public UISurface getParent() {
    return parent;
  }

  @Override
  public void setParentSurface(UISurface parentSurface) {
    parent = parentSurface;
  }

  /**
   * Renders contents and children.
   */
  public void paintControl(RenderContext context) {
    if (!visible) {
      return;
    }
    if (renderList != null) {
      for (IRenderItem item : renderList) {
       item.draw(context);
      }
    }
    if (rawChildren != null) {
      for (UISurfaceImpl child : rawChildren) {
        float tx = (float) child.layoutRect.x;
        float ty = (float) child.layoutRect.y;
        context.getCanvas().translate(tx, ty);
        child.paintControl(context);
        context.getCanvas().translate(-tx, -ty);
      }
    }
  }

  /**
   * Sets mouse/keyboard/touch event target.
   */
  @Override
  public void setTarget(UISurfaceTarget target) {
    uiTarget = target;
  }

  @Override
  public boolean hitTest(double x, double y, HitTestResult hitTestResult) {
    hitTestResult.setTarget(null);
    int childCount = this.getChildCount();

    // Check front to back.
    for (int i = childCount - 1; i >= 0; --i) {
      UISurfaceImpl child = rawChildren.get(i);
      if (child.hitTest(x - child.layoutRect.x, y - child.layoutRect.y, hitTestResult)) {
        return true;
      }
    }
    if ((x >= 0) && (x < this.layoutRect.width) && (y >= 0 && y < this.layoutRect.height)) {
      hitTestResult.setTarget((UIElement) uiTarget);
      hitTestResult.setX(x);
      hitTestResult.setY(y);
      if (hitTestMode == HITTEST_MODE_CONTENT &&
          ((renderList == null) || renderList.isEmpty())) {
        return false;
      }
      return true;
    }
    return false;
  }

  /**
   * Clears the render list.
   */
  @Override
  public void clearRenderList() {
    if (renderList != null) {
      renderList.clear();
    }
  }

  /**
   * Add rectangle to render list.
   */
  @Override
  public void drawRect(Brush brush, Pen pen, Rectangle rect) {
    if (renderList == null) {
      renderList = Lists.newArrayList();
    }
    renderList.add(new RenderRect(brush, pen, rect));
  }

  /**
   * Add rounded rectangle to render list.
   */
  @Override
  public void drawRect(Brush brush, Pen pen, Rectangle rect, BorderRadius borderRadius) {
    if (renderList == null) {
      renderList = Lists.newArrayList();
    }
    renderList.add(new RenderRoundedRect(brush, pen, rect, borderRadius));
  }

  /**
   * Add ellipse to render list.
   */
  @Override
  public void drawEllipse(Brush brush, Pen pen, Rectangle rect) {
    if (renderList == null) {
      renderList = Lists.newArrayList();
    }
    renderList.add(new RenderEllipse(brush, pen, rect));
  }

  /**
   * Add path to render list.
   */
  @Override
  public void drawPath(Brush brush, Pen pen, Path path) {
    if (renderList == null) {
      renderList = Lists.newArrayList();
    }
    renderList.add(new RenderPath(brush, pen, path));
  }

  /**
   * Add line to render list.
   */
  @Override
  public void drawLine(Pen pen, double xFrom, double yFrom,
      double xTo, double yTo) {
    if (renderList == null) {
      renderList = Lists.newArrayList();
    }
    renderList.add(new RenderLine(null, pen, xFrom, yFrom, xTo, yTo));
  }

  /**
   * Add child surface.
   */
  @Override
  public void addChild(UISurface child) {
    UISurfaceImpl surface = (UISurfaceImpl) child;
    surface.parent = this;
    rawChildren.add(surface);
  }

  /**
   * Remove child surface.
   */
  @Override
  public void removeChild(UISurface child) {
    rawChildren.remove(child);
    updateView();
  }

  /**
   * Changes child's zorder.
   */
  @Override
  public void setChildDepth(UISurface child, int depth) {
    // TODO(ferhat): implement zorder change.
  }

  /**
   * Returns number of children.
   */
  @Override
  public int getChildCount() {
    return rawChildren.size();
  }

  /**
   * Returns child at index.
   */
  @Override
  public UISurface getChild(int index) {
    return rawChildren.get(index);
  }

  /**
   * Returns parent surface.
   */
  @Override
  public UISurface getParentSurface() {
    return parent;
  }


  /**
   * Remove item from display list.
   */
  @Override
  public void close() {
    clearRenderList();
    updateView();
    if (parent != null) {
      // prevent potentially recursive call to close by parent
      UISurface temp = parent;
      parent = null;
      temp.removeChild(this);
    }
  }

  public void setParentInternal(UISurface parentSurface) {
    this.parent = parentSurface;
  }

  /**
   * Creates a child UISurface.
   */
  @Override
  public UISurface createChildSurface() {
    UISurfaceImpl child = new UISurfaceImpl();
    addChild(child);
    return child;
  }

  /**
   * Creates a child UITextSurface.
   */
  @Override
  public UISurface createChildTextSurface() {
    UISurfaceImpl child = new UITextSurfaceImpl();
    addChild(child);
    return child;
  }

  /**
   * Creates a child UIImageSurface.
   */
  @Override
  public UISurface createChildImageSurface() {
    UISurfaceImpl child = new UIImageSurfaceImpl();
    addChild(child);
    return child;
  }

  /**
   * Gets or sets surface location.
   */
  @Override
  public void setLayout(Rectangle layoutRectangle) {
    layoutRect.x = layoutRectangle.x;
    layoutRect.y = layoutRectangle.y;
    layoutRect.width = layoutRectangle.width;
    layoutRect.height = layoutRectangle.height;
  }

  /**
   * Refreshes view contents.
   */
  @Override
  public void updateView() {
    UISurface parentSurface = parent;
    if (parentSurface != null) {
      while (parentSurface.getParentSurface() != null) {
        parentSurface = parentSurface.getParentSurface();
      }
      parentSurface.updateView();
    }
  }

  /**
   * Refresh view contents in given area.
   */
  @Override
  public void updateView(double x, double y, double width, double height) {
    if ((width == 0) || (height == 0)) {
      return; // nothing to update
    }
    // translate to parent coordinates
    x += layoutRect.x;
    y += layoutRect.y;
    if (parent == null) {
      Application.getCurrent().getRootSurface().updateView(
          x, y, width, height);
    } else  {
      parent.updateView(x, y, width, height);
    }
  }

  /**
   * Adds a filter to surface.
   */
  @Override
  public void addFilter(Filter filter) {
  }

  /**
   * Removes a filter from surface.
   */
  @Override
  public void removeFilter(Filter filter) {
  }

  /**
   * Sets or returns opacity of surface 0(transparent)..1(opaque)
   */
  @Override
  public void setOpacity(double opacity) {
    this.opacity = opacity;
  }

  public double getOpacity() {
    return opacity;
  }

  /**
   * Sets surface visibility.
   */
  @Override
  public void setVisible(boolean visible) {
    if (this.visible != visible) {
      this.visible = visible;
      updateView();
    }
  }

  /**
   * @see UISurface
   */
  @Override
  public void setHitTestMode(int mode) {
    hitTestMode = mode;
  }

  /**
   * @see UISurface
   */
  @Override
  public void setBlendMode(BlendMode blendMode) {
    throw new UnsupportedOperationException();
  }
}
