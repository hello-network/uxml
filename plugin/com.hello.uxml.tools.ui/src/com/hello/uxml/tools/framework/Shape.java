package com.hello.uxml.tools.framework;
import com.hello.uxml.tools.framework.graphics.Brush;
import com.hello.uxml.tools.framework.graphics.Pen;

import java.util.EnumSet;

/**
 * Defines a generic graphics shape with fill and stroke attributes.
 *
 * @author ferhat
 *
 */
public abstract class Shape extends UIElement {

  /** Fill property definition */
  public static PropertyDefinition fillPropDef = PropertySystem.register("Fill",
      Brush.class, Shape.class, new PropertyData(null, null, EnumSet.of(
          PropertyFlags.Redraw)));

  /** Stroke property definition */
  public static PropertyDefinition strokePropDef = PropertySystem.register("Stroke",
      Pen.class, Shape.class, new PropertyData(null, null, EnumSet.of(
          PropertyFlags.Redraw)));

  /** ScaleMode property definition */
  public static PropertyDefinition scaleModePropDef = PropertySystem.register("ScaleMode",
      ScaleMode.class, Shape.class, new PropertyData(ScaleMode.None, null, EnumSet.of(
          PropertyFlags.Redraw)));

  /**
   * Constructor.
   */
  public Shape() {
    super();
  }

  /** Gets or sets fill brush */
  public Brush getFill() {
    return (Brush) getProperty(fillPropDef);
  }

  public void setFill(Brush value) {
    setProperty(fillPropDef, value);
  }

  /** Gets or sets stroke pen */
  public Pen getStroke() {
    return (Pen) getProperty(strokePropDef);
  }

  public void setStroke(Pen value) {
    setProperty(strokePropDef, value);
  }

  /** Gets or sets scale mode */
  public ScaleMode getScaleMode() {
    return (ScaleMode) getProperty(scaleModePropDef);
  }

  public void setScaleMode(ScaleMode scaleMode) {
    setProperty(scaleModePropDef, scaleMode);
  }
}
