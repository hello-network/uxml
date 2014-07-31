package com.hello.uxml.tools.framework.graphics.android;

import com.hello.uxml.tools.framework.BorderRadius;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Pen;

import android.graphics.RectF;

/**
 * Renders a rounded rectangle to output device.
 *
 * <p> This item is used by persistent render list on UISurfaceImpl.
 *
 * @author ferhat
 */
public class RenderRoundedRect implements IRenderItem {
  private double x;
  private double y;
  private double width;
  private double height;
  private BorderRadius borderRadius;
  private Brush brush;
  private Pen pen;

  /**
   * Constructor.
   **/
  public RenderRoundedRect(Brush brush, Pen pen, Rectangle rect, BorderRadius borderRadius) {
    this.x = rect.getX();
    this.y = rect.getY();
    this.width = rect.getWidth();
    this.height = rect.getHeight();
    this.borderRadius = borderRadius;
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
      g.getCanvas().drawRoundRect(new RectF((float) x, (float) y, (float) width, (float) height),
          (float) borderRadius.getTopLeft(), (float) borderRadius.getTopLeft(), g.getPaint());
    }

    if (pen != null) {
      g.setPen(pen);
      g.getCanvas().drawRoundRect(new RectF((float) x, (float) y, (float) width, (float) height),
          (float) borderRadius.getTopLeft(), (float) borderRadius.getTopLeft(), g.getPaint());
    }
  }
}
