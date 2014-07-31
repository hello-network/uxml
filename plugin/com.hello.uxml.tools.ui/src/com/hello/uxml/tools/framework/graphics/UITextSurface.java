package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Size;

/**
 * Provides access to surface for displaying and editing text
 *
 * @author ferhat@(Ferhat Buyukkokten)
 *
 */
public interface UITextSurface {

  /**
   * Sets text.
   */
  void setText(String text);

  /**
   * Sets font name.
   */
  void setFontName(String fontName);

  /**
   * Sets font size.
   */
  void setFontSize(double fontSize);

  /**
   * Sets text color.
   */
  void setFontBold(boolean bold);

  /**
   * Sets text color.
   */
  void setTextColor(Color color);

  /**
   * Measures size of text given width constraint.
   */
  Size measureText(String text, double availWidth, double availHeight);

  /**
   * Re-renders text.
   */
  void updateTextView();
}
