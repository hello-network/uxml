package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.Color;
import com.hello.uxml.tools.framework.graphics.UIImageSurface;
import com.hello.uxml.tools.framework.graphics.UISurface;

import java.util.EnumSet;

/**
 * Displays an image.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public class Image extends Control {

  /** Text Property Definition */
  public static PropertyDefinition sourcePropDef = PropertySystem.register("Source",
      Object.class,
      Control.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.Resize,
          PropertyFlags.Redraw), new PropertyChangeListener() {
        @Override
        public void propertyChanged(PropertyChangedEvent e) {
          Image element = (Image) e.getSource();
          element.updateImageSurface();
          }
        }
      ));

  /** ScaleMode property definition */
  public static PropertyDefinition scaleModePropDef = PropertySystem.register("ScaleMode",
      ScaleMode.class, Image.class, new PropertyData(ScaleMode.None, null, EnumSet.of(
          PropertyFlags.Redraw)));

  /** MonoChrome Property Definition */
  public static PropertyDefinition monoChromePropDef = PropertySystem.register("MonoChrome",
      Color.class,
      Image.class,
      new PropertyData(null, EnumSet.of(PropertyFlags.Redraw, PropertyFlags.Inherit)));


  /** Tile Property Definition */
  public static PropertyDefinition tilePropDef = PropertySystem.register("Tile",
      Boolean.class, Image.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.Redraw)));

  /** Loaded Property Definition (readonly) */
  public static PropertyDefinition loadedPropDef = PropertySystem.register("Loaded",
      Boolean.class, Image.class,
      new PropertyData(false, EnumSet.of(PropertyFlags.None)));

  /**
   * Returns image source.
   */
  public Object getSource() {
    return getProperty(sourcePropDef);
  }

  /**
   * Sets source of image.
   */
  public void setSource(Object imageSource) {
    setProperty(sourcePropDef, imageSource);
  }

  /**
   * Returns true if image load completed.
   */
  public boolean getLoaded() {
    return ((Boolean) getProperty(loadedPropDef)).booleanValue();
  }

  /** Gets or sets scale mode */
  public ScaleMode getScaleMode() {
    return (ScaleMode) getProperty(scaleModePropDef);
  }

  public void setScaleMode(ScaleMode scaleMode) {
    setProperty(scaleModePropDef, scaleMode);
  }

  /** Gets or sets tile mode */
  public boolean getTile() {
    return ((Boolean) getProperty(tilePropDef)).booleanValue();
  }

  public void setTile(boolean tile) {
    setProperty(tilePropDef, tile);
  }

  /**
   * Sets or returns monochrome color to use for rendering image.
   */
  public Color getMonoChrome() {
    return (Color) getProperty(monoChromePropDef);
  }

  public void setMonoChrome(Color color) {
    setProperty(monoChromePropDef, color);
  }

  @Override
  protected void onMeasure(double availWidth, double availHeight) {
    if (hostSurface == null) {
      setMeasuredDimension(0, 0);
    } else {
      Size imageSize = ((UIImageSurface) hostSurface).measure();
      setMeasuredDimension(imageSize.width, imageSize.height);
    }
  }

  /**
   * Updates text and font properties of text surface
   */
  private void updateImageSurface() {
    if (this.hostSurface != null) {
      UIImageSurface surface = (UIImageSurface) this.hostSurface;
      surface.setTarget(this);
      surface.setSource(getSource());
    }
  }

  @Override
  public void initSurface(UISurface parentSurface) {
    hostSurface = parentSurface.createChildImageSurface();
    if (!getVisible()) {
      hostSurface.setVisible(false);
    }
    updateImageSurface();
  }

  @Override
  public void surfaceContentUpdated() {
    updateImageSurface();
    invalidateSize();
  }
}
