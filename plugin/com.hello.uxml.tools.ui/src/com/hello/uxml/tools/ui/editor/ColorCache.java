package com.hello.uxml.tools.ui.editor;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Display;

import java.util.HashMap;
import java.util.Iterator;

/**
 * Implements a color table cache for editor.
 *
 * @author ferhat
 */
public class ColorCache {
  protected HashMap<RGB, Color> colorTable = new HashMap<RGB, Color>(10);

  public void dispose() {
    Iterator<Color> e = colorTable.values().iterator();
    while (e.hasNext()) {
      (e.next()).dispose();
    }
  }

  public Color getColor(RGB rgb) {
    Color color = colorTable.get(rgb);
    if (color == null) {
      color = new Color(Display.getCurrent(), rgb);
      colorTable.put(rgb, color);
    }
    return color;
  }
}

