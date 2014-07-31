package com.hello.uxml.tools.framework.graphics.android;
import com.hello.uxml.tools.framework.Size;
import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.UITextSurface;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Rect;
import android.graphics.Typeface;

/**
 * Provides surface for rendering and editing text
 *
 * @author ferhat
 */
public class UITextSurfaceImpl extends UISurfaceImpl implements UITextSurface {

  private String text;
  private String fontName;
  private double fontSize;
  private Color textColor;
  private boolean fontBold;
  private Rect measuredTextBounds = new Rect();

  /**
   * Renders contents and children.
   */
  @Override
  public void paintControl(RenderContext context) {
    if (!visible) {
      return;
    }
    if (renderList != null) {
      super.paintControl(context);
    }
    Paint paint = context.getPaint();
    paint.setTypeface(Typeface.create(fontName, fontBold ? Typeface.BOLD : Typeface.NORMAL));
    paint.setTextSize((float) fontSize);
    paint.setColor(textColor.getARGB());
    paint.setStyle(Style.FILL);
    paint.setShader(null);
    Canvas canvas = context.getCanvas();
    canvas.drawText(text, 0, -measuredTextBounds.top, paint);
  }

  /**
   * Sets text.
   */
  @Override
  public void setText(String text) {
    this.text = text;
  }

  /**
   * Sets font name.
   */
  @Override
  public void setFontName(String fontName) {
    this.fontName = fontName;
  }

  /**
   * Sets font size.
   */
  @Override
  public void setFontSize(double fontSize) {
    this.fontSize = fontSize;
  }

  /**
   * Sets font bold.
   */
  @Override
  public void setFontBold(boolean fontBold) {
    this.fontBold = fontBold;
  }

  /**
   * Sets text color.
   */
  @Override
  public void setTextColor(Color textColor) {
    this.textColor = textColor;
  }


  /**
   * Measures size of image given width constraint.
   */
  @Override
  public Size measureText(String textValue, double availWidth, double availHeight) {
    try {
      Paint paint = new Paint();
      paint.setTypeface(Typeface.create(fontName, fontBold ? Typeface.BOLD : Typeface.NORMAL));
      paint.setTextSize((float) fontSize);
      measuredTextBounds.left = 0;
      measuredTextBounds.top = 0;
      measuredTextBounds.right = (int) availWidth;
      measuredTextBounds.bottom = (int) availHeight;
      paint.getTextBounds(text, 0, text.length(), measuredTextBounds);
      return new Size(measuredTextBounds.right - measuredTextBounds.left,
        measuredTextBounds.bottom - measuredTextBounds.top);
    } catch (RuntimeException e) {
      return new Size(0, 0);
    }
  }

  /**
   * @see UISurfaceImpl
   */
  @Override
  public void setHitTestMode(int mode) {
    // Nothing to do here
  }

  @Override
  public void updateTextView() {
    // nothing to do since paintControl handles this on android platf.
  }
}
