package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Implements transform properties for UIElement render and layout transforms.
 *
 * @author ferhat
 */
public class Transform extends UxmlElement {

  /** owner of transform */
  private UIElement target;

  /** ScaleX Property Definition */
  public static PropertyDefinition scaleXPropDef = PropertySystem.register("ScaleX",
      Double.class, Transform.class, new PropertyData(1.0, EnumSet.of(PropertyFlags.None)));

  /** ScaleY Property Definition */
  public static PropertyDefinition scaleYPropDef = PropertySystem.register("ScaleY",
      Double.class, Transform.class, new PropertyData(1.0, EnumSet.of(PropertyFlags.None)));

  /** TranslateX Property Definition */
  public static PropertyDefinition translateXPropDef = PropertySystem.register("TranslateX",
      Double.class, Transform.class, new PropertyData(0.0, EnumSet.of(PropertyFlags.None)));

  /** TranslateY Property Definition */
  public static PropertyDefinition translateYPropDef = PropertySystem.register("TranslateY",
      Double.class, Transform.class, new PropertyData(0.0, EnumSet.of(PropertyFlags.None)));

  /** Rotate Property Definition */
  public static PropertyDefinition rotatePropDef = PropertySystem.register("Rotate",
      Double.class, Transform.class, new PropertyData(0.0, EnumSet.of(PropertyFlags.None)));

  /** OriginX Property Definition */
  public static PropertyDefinition originXPropDef = PropertySystem.register("OriginX",
      Double.class, Transform.class, new PropertyData(0.5, EnumSet.of(PropertyFlags.None)));

  /** OriginY Property Definition */
  public static PropertyDefinition originYPropDef = PropertySystem.register("OriginY",
      Double.class, Transform.class, new PropertyData(0.5, EnumSet.of(PropertyFlags.None)));

  /**
   * Constructor.
   */
  public Transform() {
  }

  /**
   * Constructor.
   */
  public Transform(UIElement target) {
    this.target = target;
  }

  /** Sets target of transform */
  public void setTarget(UIElement target) {
    this.target = target;
  }

  /** Sets or returns scaleX */
  public double getScaleX() {
    return ((Double) getProperty(scaleXPropDef)).doubleValue();
  }

  public void setScaleX(double value) {
    setProperty(scaleXPropDef, value);
  }

  /** Sets or returns scaleY */
  public double getScaleY() {
    return ((Double) getProperty(scaleYPropDef)).doubleValue();
  }

  public void setScaleY(double value) {
    setProperty(scaleYPropDef, value);
  }

  /** Sets or returns rotation in degrees */
  public double getRotate() {
    return ((Double) getProperty(rotatePropDef)).doubleValue();
  }

  public void setRotate(double value) {
    setProperty(rotatePropDef, value);
  }

  /** Sets or returns translateX */
  public double getTranslateX() {
    return ((Double) getProperty(translateXPropDef)).doubleValue();
  }

  public void setTranslateX(double value) {
    setProperty(translateXPropDef, value);
  }

  /** Sets or returns translateY */
  public double getTranslateY() {
    return ((Double) getProperty(translateYPropDef)).doubleValue();
  }

  public void setTranslateY(double value) {
    setProperty(translateYPropDef, value);
  }

  /** Sets or returns x origin of transform */
  public double getOriginX() {
    return ((Double) getProperty(originXPropDef)).doubleValue();
  }

  public void setOriginX(double value) {
    setProperty(originXPropDef, value);
  }

  /** Sets or returns y origin of transform */
  public double getOriginY() {
    return ((Double) getProperty(originYPropDef)).doubleValue();
  }

  public void setOriginY(double value) {
    setProperty(originYPropDef, value);
  }

  @Override
  protected void onPropertyChanged(PropertyDefinition propDef, Object oldValue,
      Object newValue) {
      target.onTransformChanged(this);
  }
}
