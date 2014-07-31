package com.hello.uxml.tools.framework.graphics.android;

import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Pen;

/**
 * Renders a line to output device.
 *
 * <p> This item is used by persistent render list on UISurfaceImpl.
 *
 * @author ferhat
 */
public class RenderLine implements IRenderItem {
  private double xFrom;
  private double yFrom;
  private double xTo;
  private double yTo;
  private Brush brush;
  private Pen pen;

  /**
   * Constructor.
   **/
  public RenderLine(Brush brush, Pen pen, double xFrom, double yFrom, double xTo, double yTo) {
    this.xFrom = xFrom;
    this.yFrom = yFrom;
    this.xTo = xTo;
    this.yTo = yTo;
    this.brush = brush;
    this.pen = pen;
  }

  /**
   * Draw rectangle to render context.
   */
  @Override
  public void draw(RenderContext g) {
    if (brush != null) {
      g.setBrush(brush, Math.min(xFrom, xTo), Math.min(yFrom, yTo), Math.abs(xFrom - xTo),
          Math.abs(yFrom - yTo));
      g.getCanvas().drawLine((float) xFrom, (float) yFrom, (float) xTo, (float) yTo,
          g.getPaint());
    }

    if (pen != null) {
      g.setPen(pen);
      g.getCanvas().drawLine((float) xFrom, (float) yFrom, (float) xTo, (float) yTo,
          g.getPaint());
    }
  }
}
