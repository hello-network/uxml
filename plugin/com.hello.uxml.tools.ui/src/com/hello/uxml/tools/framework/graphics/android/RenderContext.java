package com.hello.uxml.tools.framework.graphics.android;

import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.GradientStop;
import com.hello.uxml.tools.framework.graphics.LinearBrush;
import com.hello.uxml.tools.framework.graphics.Pen;
import com.hello.uxml.tools.framework.graphics.SolidBrush;
import com.hello.uxml.tools.framework.graphics.SolidPen;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Shader.TileMode;

/**
 * Provides easy to use, persistent brush pen to GC mapping.
 *
 * @author ferhat
 */
public class RenderContext {

  /** Graphics context */
  private Canvas canvas;

  /** Shared paint object */
  private Paint paint;

  /**
   * Constructor.
   */
  public RenderContext(Canvas canvas) {
    this.canvas = canvas;
    paint = new Paint();
    paint.setAntiAlias(true);
  }

  /**
   * Disposes resources.
   */
  public void dispose() {
    canvas = null;
    paint = null;
  }

  /** Returns graphics context */
  public Canvas getCanvas() {
    return canvas;
  }

  /** Returns paint */
  public Paint getPaint() {
    return paint;
  }

  /** Configures GC to pen parameters */
  public void setPen(Pen pen) {
    if (pen != null) {
      paint.setStrokeWidth((float) pen.getThickness());
      paint.setColor(((SolidPen) pen).getColor().getARGB());
      paint.setStyle(Style.STROKE);
      paint.setShader(null);
    }
  }

  /** Configures GC to brush parameters */
  public void setBrush(Brush brush, double x0, double y0, double w, double h) {
    if (brush instanceof SolidBrush) {
      paint.setColor(((SolidBrush) brush).getColor().getARGB());
      paint.setStyle(Style.FILL);
      paint.setShader(null);
    } else if (brush instanceof LinearBrush) {
      LinearBrush lBrush = (LinearBrush) brush;
      int gradientStopCount = lBrush.getStops().size();
      int[] colors = new int[gradientStopCount];
      float[] positions = new float[gradientStopCount];
      for (int s = 0; s < gradientStopCount; ++s) {
        GradientStop stop = lBrush.getStops().get(s);
        colors[s] = stop.getColor().getARGB();
        positions[s] = (float) stop.getOffset();
      }
      LinearGradient shader = new LinearGradient((float) (x0 + (lBrush.getStart().x * w)),
          (float) (y0 + (lBrush.getStart().y * h)), (float) (x0 + (lBrush.getEnd().x * w)),
          (float) (y0 + (lBrush.getEnd().y * h)), colors, positions, TileMode.CLAMP);
      paint.setShader(shader);
      paint.setStyle(Style.FILL);
    }
    // TODO(ferhat): implement gradient and radial brushes
  }

  public void drawImage(Bitmap bitmap, double x, double y) {
    canvas.drawBitmap(bitmap, (float) x, (float) y, paint);
  }

}
