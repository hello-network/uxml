package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.VecPath;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Defines a shape that is formed using a path definition.
 *
 * @author ferhat@
 *
 */
public class PathShape extends Shape {

  /** Path content property definition */
  public static PropertyDefinition contentPropDef = PropertySystem.register("Content",
      VecPath.class, PathShape.class, new PropertyData(null, null, EnumSet.of(
          PropertyFlags.Resize)));

  /** Nine slice property definition */
  public static PropertyDefinition nineSlicePropDef = PropertySystem.register("nineSlice",
      Margin.class, PathShape.class, new PropertyData(null, null, EnumSet.of(
          PropertyFlags.Redraw)));
  /**
   * Constructor.
   */
  public PathShape() {
    super();
  }

  /** Gets or sets path of shape */
  public VecPath getContent() {
    return (VecPath) getProperty(contentPropDef);
  }

  /**
   * Sets path data.
   */
  @ContentNode
  public void setContent(VecPath value) {
    setProperty(contentPropDef, value);
  }

  /** Gets or sets margins to use for nine slicing path. */
  public Margin getNineSlice() {
    return (Margin) getProperty(nineSlicePropDef);
  }

  public void setNineSlice(Margin value) {
    setProperty(nineSlicePropDef, value);
  }

  /**
   * Returns size of path as desired size.
   */
  @Override
  protected void onMeasure(double availableWidth, double availableHeight) {
    VecPath path = getContent();
    if (path == null) {
      setMeasuredDimension(0, 0);
    } else {
      Rectangle bounds = path.getBounds();
      setMeasuredDimension(Math.min(availableWidth, bounds.width),
          Math.min(availableHeight, bounds.height));
    }
  }

  @Override
  protected void onRedraw(UISurface surface) {
    VecPath path = getContent();
    if (path != null) {
      surface.drawPath(getFill(), getStroke(), path);
    }
  }
}
