package com.hello.uxml.tools.framework.platform;

import com.google.common.collect.Lists;
import com.hello.uxml.tools.framework.Application;
import com.hello.uxml.tools.framework.BlendMode;
import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.UIElement;
import com.hello.uxml.tools.framework.UpdateQueue;
import com.hello.uxml.tools.framework.events.EventDefinition;
import com.hello.uxml.tools.framework.events.MouseEventArgs;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Filter;
import com.hello.uxml.tools.framework.graphics.HitTestResult;
import com.hello.uxml.tools.framework.graphics.MouseButton;
import com.hello.uxml.tools.framework.graphics.Path;
import com.hello.uxml.tools.framework.graphics.Pen;
import com.hello.uxml.tools.framework.graphics.UISurface;
import com.hello.uxml.tools.framework.graphics.UISurfaceTarget;
import com.hello.uxml.tools.framework.graphics.android.IRenderItem;
import com.hello.uxml.tools.framework.graphics.android.RenderContext;
import com.hello.uxml.tools.framework.graphics.android.RenderEllipse;
import com.hello.uxml.tools.framework.graphics.android.RenderLine;
import com.hello.uxml.tools.framework.graphics.android.RenderPath;
import com.hello.uxml.tools.framework.graphics.android.RenderRect;
import com.hello.uxml.tools.framework.graphics.android.RenderRoundedRect;
import com.hello.uxml.tools.framework.graphics.android.UIImageSurfaceImpl;
import com.hello.uxml.tools.framework.graphics.android.UISurfaceImpl;

import android.app.Activity;
import android.content.Context;
import android.util.DisplayMetrics;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import java.util.List;

/**
 * Defines Android hosted hts framework application.
 *
 * @author ferhat
 *
 */
public class AndroidApplication extends Application {

  private Context context;
  private double hostWidth;
  private double hostHeight;

  /**
   * Constructor.
   */
  public AndroidApplication() {
  }

  /**
   * Initializes application.
   */
  public void initialize(Activity hostActivity) {
    setContainer(hostActivity);
    hostActivity.setContentView(getRootView());
    context = hostActivity.getApplicationContext();
    WindowManager wm  = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    DisplayMetrics metrics = new DisplayMetrics();
    wm.getDefaultDisplay().getMetrics(metrics);
    setHostSize(metrics.widthPixels, metrics.heightPixels);
    hostContent();
  }

  /**
   * Resizes root application element.
   */
  public void setHostSize(double width, double height) {
    hostWidth = width;
    hostHeight = height;
    relayoutRoot();
  }

  /**
   * Returns root view.
   */
  public View getRootView() {
    if (rootSurface == null) {
      rootSurface = new RootSurface(this);
    }
    return (View) rootSurface;
  }

  /**
   * Returns context.
   */
  public Context getContext() {
    return this.context;
  }

  /**
   * Creates child surface.
   */
  @Override
  public UISurface createSurface() {
    UISurfaceImpl uiSurface = new UISurfaceImpl();
    return uiSurface;
  }

  @Override protected void hostContent() {
    if (rootElement != null) {
      rootElement.initSurface(rootSurface);
      rootElement.invalidateLayout();
    }
  }

  /** Measures and applies new layout to root element */
  @Override
  protected void relayoutRoot() {
    double width = hostWidth;
    double height = hostHeight;
    if (!Double.isNaN(rootElement.getWidth())) {
      width = rootElement.getWidth();
    }
    if (!Double.isNaN(rootElement.getHeight())) {
      height = rootElement.getHeight();
    }
    rootElement.measure(width, height);

    // center root element on screen
    rootElement.layout(new Rectangle((hostWidth - width) / 2 ,
          (hostHeight - height) / 2, width, height));
  }

  /**
   * Routes mouse event. Returns true if the event was handled.
   */
  private boolean routeMouseEvent(android.view.MotionEvent e, MouseButton mouseButton,
      int mouseEventType, EventDefinition eventDef) {
      return routeMouseEvent(e.getX(), e.getY(), mouseButton.ordinal(), mouseEventType,
          eventDef);
  }

  /**
   * Implements an android custom view that serves as root UISurface.
   */
  static class RootSurface extends android.view.View implements UISurface {
    public RootSurface(AndroidApplication app) {
      super(app.getContext());
      this.app = app;
    }

    private double opacity = 1.0;

    /** List of persistent drawable items */
    private List<IRenderItem> renderList;

    /** List of child surfaces */
    private List<UISurfaceImpl> rawChildren = Lists.newArrayList();

    private UISurfaceTarget uiTarget;

    private AndroidApplication app;

    @Override
    public void setTarget(UISurfaceTarget target) {
      uiTarget = target;
    }

    @Override
    protected void onDraw(android.graphics.Canvas canvas) {
      UpdateQueue.flush();
      if (rawChildren == null) {
        return;
      }
      RenderContext context = new RenderContext(canvas);
      for (UISurfaceImpl child : rawChildren) {
        float tx = (float) child.layoutRect.x;
        float ty = (float) child.layoutRect.y;
        canvas.translate(tx, ty);
        child.paintControl(context);
        canvas.translate(-tx, -ty);
      }
      context.dispose();
    }

    /**
     * Performs hit testing on surface and children.
     */
    @Override
    public boolean hitTest(double x, double y, HitTestResult hitResult) {
      hitResult.setTarget(null);
      int childCount = this.getChildCount();

      // Check front to back.
      for (int i = childCount - 1; i >= 0; --i) {
        UISurfaceImpl child = rawChildren.get(i);
        if (child.hitTest(x - child.layoutRect.x, y - child.layoutRect.y, hitResult)) {
          return true;
        }
      }
      if ((x >= 0) && (x < this.app.hostWidth) && (y >= 0 && y < app.hostHeight)) {
        hitResult.setTarget((UIElement) uiTarget);
        hitResult.setX(x);
        hitResult.setY(y);
        return true;
      }
      return false;
    }

    @Override
    public void onMeasure(int w, int h) {
      // use the whole area
      final int widthMode = MeasureSpec.getMode(w);
      if (widthMode == MeasureSpec.EXACTLY) {
        w = MeasureSpec.getSize(w);
      }
      final int heightMode = MeasureSpec.getMode(h);
      if (heightMode == MeasureSpec.EXACTLY) {
        h = MeasureSpec.getSize(h);
      }
      setMeasuredDimension(w, h);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
      app.setHostSize(w, h);
    }

    @Override
    public boolean onTouchEvent(android.view.MotionEvent e) {
      switch (e.getAction()) {
        case MotionEvent.ACTION_DOWN:
          app.routeMouseEvent(e, MouseButton.Left, MouseEventArgs.MOUSE_DOWN,
              UIElement.mouseDownEvent);
          return true;
        case MotionEvent.ACTION_UP:
          app.routeMouseEvent(e, MouseButton.Left, MouseEventArgs.MOUSE_UP,
              UIElement.mouseUpEvent);
          return true;
        case MotionEvent.ACTION_MOVE:
          app.routeMouseEvent(e, MouseButton.Left, MouseEventArgs.MOUSE_MOVE,
              UIElement.mouseMoveEvent);
          return true;
      }
      return false;
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
     * Clears the render list.
     */
    @Override
    public void clearRenderList() {
      if (renderList != null) {
        renderList.clear();
      }
    }

    /**
     * Add child surface.
     */
    @Override
    public void addChild(UISurface child) {
      UISurfaceImpl surface = (UISurfaceImpl) child;
      surface.setParentInternal(this);
      rawChildren.add(surface);
    }

    /**
     * Remove child surface.
     */
    @Override
    public void removeChild(UISurface child) {
      rawChildren.remove(child);
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
      return null;
    }

    @Override
    public void setParentSurface(UISurface parentSurface) {
      // this is root UISurface, nothing to do.
    }

    /**
     * Remove item from display list.
     */
    @Override
    public void close() {
      clearRenderList();
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
      UISurfaceImpl child = new UISurfaceImpl();
      addChild(child);
      return child;
    }

    /**
     * Creates a child UIImageSurface.
     */
    @Override
    public UISurface createChildImageSurface() {
      return new UIImageSurfaceImpl();
    }

    @Override
    public void updateView() {
      postInvalidate();
    }

    @Override
    public void updateView(double x, double y, double width, double height) {
      if ((width == 0) || (height == 0)) {
        return; // nothing to update
      }
      postInvalidate((int) x, (int) y, (int) (width + 0.5), (int) (height + 0.5));
    }

    /**
     * Gets or sets surface location.
     */
    @Override
    public void setLayout(Rectangle layoutRect) {
      // Empty since this is the root
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

    /** Sets visibility, ignored for root surface */
    @Override
    public void setVisible(boolean visible) {
    }

    /**
     * @see UISurface
     */
    @Override
    public void setHitTestMode(int mode) {
      // Nothing to do here
    }

    /**
     * @see UISurface
     */
    @Override
    public void setBlendMode(BlendMode blendMode) {
      throw new UnsupportedOperationException();
    }

    @Override
    public void setChildDepth(UISurface surface, int depth) {
      // TODO(ferhat):implement z order
    }
  }
}
