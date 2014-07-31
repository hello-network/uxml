package com.hello.uxml.tools.framework.graphics.android;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.IPathReplay;
import com.hello.uxml.tools.framework.graphics.Path;
import com.hello.uxml.tools.framework.graphics.Pen;

import android.graphics.RectF;

/**
 * Renders a path to output device.
 *
 * <p> This item is used by persistent render list on UISurfaceImpl.
 *
 * @author ferhat
 */
public class RenderPath implements IRenderItem, IPathReplay {
  private Path path;
  private Brush brush;
  private Pen pen;
  private android.graphics.Path nativePath;

  /**
   * Constructor.
   **/
  public RenderPath(Brush brush, Pen pen, Path path) {
    this.path = path;
    this.brush = brush;
    this.pen = pen;
  }

  /**
   * Draw path to render context.
   */
  @Override
  public void draw(RenderContext context) {

    // Generate nativePath from path object and cache.
    if (nativePath == null) {
      nativePath = new android.graphics.Path();
      path.replay(this);
    }

    Rectangle bounds = path.getBounds();

    if (brush != null) {
      context.setBrush(brush, bounds.x, bounds.y, bounds.width, bounds.height);
      context.getCanvas().drawPath(nativePath, context.getPaint());
    }
    if (pen != null) {
      context.setPen(pen);
      context.getCanvas().drawPath(nativePath, context.getPaint());
    }
  }

  /**
   * Adds moveTo instruction to path.
   */
  @Override
  public void moveTo(Point p) {
    nativePath.moveTo((float) p.getX(), (float) p.getY());
  }

  /**
   * Adds lineTo instruction to path.
   */
  @Override
  public void lineTo(Point p) {
    nativePath.lineTo((float) p.getX(), (float) p.getY());
  }

  /**
   * Adds curveTo instruction to path.
   */
  @Override
  public void curveTo(Point c, Point p) {
    nativePath.quadTo((float) c.getX(), (float) c.getY(), (float) p.getX(), (float) p.getY());
  }

  /**
   * Adds curveTo instruction to path.
   */
  @Override
  public void curveTo(Point c1, Point c2, Point p) {
    nativePath.cubicTo((float) c1.getX(), (float) c1.getY(), (float) c2.getX(),
        (float) c2.getY(), (float) p.getX(), (float) p.getY());
  }

  /**
   * Adds arcto instruction to path.
   */
  @Override
  public void arcTo(Point point, Point radius, double startAngle, double arcAngle) {
    nativePath.addArc(new RectF((float) point.getX(), (float) point.getY(), (float) radius.getX(),
        (float) radius.getY()), (float) startAngle, (float) arcAngle);
  }
}
