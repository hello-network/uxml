package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.Size;

/**
 * Provides access to surface for displaying images.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 *
 */
public interface UIImageSurface {

  /**
   * Sets surface target.
   */
  void setTarget(UISurfaceTarget target);

  /**
   * Sets image source.
   */
  void setSource(Object source);

  /**
   * Measures size of text given width constraint.
   */
  Size measure();
}
