package com.hello.uxml.tools.framework.graphics.android;

import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Pen;

import android.graphics.RectF;

/**
 * Renders a rectangle to output device.
 *
 * <p> This item is used by persistent render list on UISurfaceImpl.
 *
 * @author ferhat
 */
public class RenderRect implements IRenderItem {
  private double x;
  private double y;
  private double width;
  private double height;
  private Brush brush;
  private Pen pen;

  /**
   * Constructor.
   **/
  public RenderRect(Brush brush, Pen pen, double x, double y, double width, double height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.brush = brush;
    this.pen = pen;
  }

  /**
   * Constructor.
   **/
  public RenderRect(Brush brush, Pen pen, Rectangle rect) {
    this.x = rect.getX();
    this.y = rect.getY();
    this.width = rect.getWidth();
    this.height = rect.getHeight();
    this.brush = brush;
    this.pen = pen;
  }

  /**
   * Draw rectangle to render context.
   */
  @Override
  public void draw(RenderContext g) {
    if (brush != null) {
      g.setBrush(brush, x, y, width, height);
      g.getCanvas().drawRect(new RectF((float) x, (float) y, (float) width, (float) height),
          g.getPaint());
    }

    if (pen != null) {
      g.setPen(pen);
      g.getCanvas().drawRect(new RectF((float) x, (float) y, (float) width, (float) height),
          g.getPaint());
    }
  }
}
