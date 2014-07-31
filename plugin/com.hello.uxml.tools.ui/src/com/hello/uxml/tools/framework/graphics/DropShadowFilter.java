package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.PropertyData;
import com.hello.uxml.tools.framework.PropertyDefinition;
import com.hello.uxml.tools.framework.PropertySystem;

/**
 * Holds DropShadow graphics filter parameters.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class DropShadowFilter extends Filter {

  /** The alpha transparency of the value of the shadow color. */
  public static PropertyDefinition alphaPropDef =
      PropertySystem.register("alpha", Double.class, DropShadowFilter.class,
          new PropertyData(1.0));

  /** The angle of the shadow. */
  public static PropertyDefinition anglePropDef =
      PropertySystem.register("angle", Double.class, DropShadowFilter.class,
          new PropertyData(45));

  /** The amount of horizontal blur. */
  public static PropertyDefinition blurXPropDef =
      PropertySystem.register("blurX", Double.class, DropShadowFilter.class,
          new PropertyData(4.0));

  /** The amount of vertical blur. */
  public static PropertyDefinition blurYPropDef =
      PropertySystem.register("blurY", Double.class, DropShadowFilter.class,
          new PropertyData(4.0));

  /** The color of the shadow. */
  public static PropertyDefinition colorPropDef =
      PropertySystem.register("color", Color.class, DropShadowFilter.class,
          new PropertyData(0));

  /** The offset distance for the shadow, in pixels. */
  public static PropertyDefinition distancePropDef =
      PropertySystem.register("distance", Double.class, DropShadowFilter.class,
          new PropertyData(4.0));

  /** Indicates whether or not the object is hidden. */
  public static PropertyDefinition hideObjectPropDef =
      PropertySystem.register("hideObject", Boolean.class, DropShadowFilter.class,
          new PropertyData(false));

  /** Indicates whether or not the shadow is an inner shadow. */
  public static PropertyDefinition innerPropDef =
      PropertySystem.register("inner", Boolean.class, DropShadowFilter.class,
          new PropertyData(false));

  /**
   * Applies a knockout effect (true), which effectively makes the object's
   * fill transparent and reveals the background color of the document.
   */
  public static PropertyDefinition knockoutPropDef =
      PropertySystem.register("knockout", Boolean.class, DropShadowFilter.class,
          new PropertyData(false));

  /** The number of times to apply the filter. */
  public static PropertyDefinition qualityPropDef =
      PropertySystem.register("quality", Integer.class, DropShadowFilter.class,
          new PropertyData(1));

  /** The strength of the imprint or spread. */
  public static PropertyDefinition strengthPropDef =
      PropertySystem.register("strength", Double.class, DropShadowFilter.class,
          new PropertyData(1.0));

  /**
   * Constructor.
   */
  public DropShadowFilter() {
  }


  /**
   * Sets or returns bevel lighting angle.
   */
   public void setAngle(double value) {
     setProperty(anglePropDef, value);
   }

   public double getAngle() {
     return ((Double) getProperty(anglePropDef)).doubleValue();
   }

   /**
   * Sets or returns alpha.
   */
   public void setAlpha(double value) {
     setProperty(alphaPropDef, value);
   }

   public double getAlpha() {
     return ((Double) getProperty(alphaPropDef)).doubleValue();
   }

   /**
   * Sets or returns x axis blur.
   */
   public void setBlurX(double value) {
     setProperty(blurXPropDef, value);
   }

   public double getBlurX() {
     return ((Double) getProperty(blurXPropDef)).doubleValue();
   }

   /**
   * Sets or returns y axis blur.
   */
   public void setBlurY(double value) {
     setProperty(blurYPropDef, value);
   }

   public double getBlurY() {
     return ((Double) getProperty(blurYPropDef)).doubleValue();
   }

   /**
   * Sets or returns strength of the glow
   */
   public void setStrength(double value) {
     setProperty(strengthPropDef, value);
   }

   public double getStrength() {
     return ((Double) getProperty(strengthPropDef)).doubleValue();
   }

   /**
   * Sets or returns shadow distance.
   */
   public void setDistance(double value) {
     setProperty(distancePropDef, value);
   }

   public double getDistance() {
     return ((Double) getProperty(distancePropDef)).doubleValue();
   }

   /**
    * Sets/returns blur quality.
    *
    * <li>1 = normal
    * <li>2 = 2x2 4x sampling
    * <li>3 = 4x4 16x sampling
    */
   public void setQuality(int value) {
     setProperty(qualityPropDef, value);
   }

   public int getQuality() {
     return ((Integer) getProperty(qualityPropDef)).intValue();
   }

   /**
   * Sets or returns if knockout.
   */
   public void setKnockout(boolean value) {
     setProperty(knockoutPropDef, value);
   }

   public boolean getKnockout() {
     return ((Boolean) getProperty(knockoutPropDef)).booleanValue();
   }

   /**
   * Sets or returns if object is hidden.
   */
   public void setHideObject(boolean value) {
     setProperty(hideObjectPropDef, value);
   }

   public boolean getHideObject() {
     return ((Boolean) getProperty(hideObjectPropDef)).booleanValue();
   }

   /**
   * Sets or returns if filter is inner glow.
   */
   public void setInner(boolean value) {
     setProperty(innerPropDef, value);
   }

   public boolean getInner() {
     return ((Boolean) (getProperty(innerPropDef))).booleanValue();
   }

    /**
   * Sets or returns glow filter color.
   */
   public void setColor(Color value) {
     setProperty(colorPropDef, value);
   }

   public Color getColor() {
     return (Color) getProperty(colorPropDef);
   }
}
