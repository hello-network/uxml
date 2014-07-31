package com.hello.uxml.tools.framework;

import java.util.EnumSet;

/**
 * Provides a container for element overlays.
 *
 * <p>The overlaid items live on top of the contained element and are moved
 * in sync with the source element.
 * <p>UIElement.getOverlayContainer returns this container to host overlays.
 *
 * @author ferhat
 */
public class OverlayContainer extends ContentContainer {

  /** Left Property Definition */
  public static PropertyDefinition finalLocationPropDef = PropertySystem.register("finalLocation",
      Integer.class, OverlayContainer.class,
      new PropertyData(0, EnumSet.of(PropertyFlags.Attached), null));

  /**
   * Hosts overlays.
   */
  private Canvas host;

  /**
   * Overlay constants for placement.
   */
  public static final int OVERLAY_LOCATION_DEFAULT = 0;

  public static final int OVERLAY_LOCATION_VMASK = 0xFF;
  public static final int OVERLAY_LOCATION_TOP = 1;
  public static final int OVERLAY_LOCATION_BOTTOM = 2;
  public static final int OVERLAY_LOCATION_TOP_EDGE = 4;
  public static final int OVERLAY_LOCATION_BOTTOM_EDGE = 8;
  public static final int OVERLAY_LOCATION_VCENTER = 0x10;
  // Locate at bottom of element, if out of space, flip above.
  public static final int OVERLAY_LOCATION_BOTTOM_OR_TOP = 0x10002;
  // Locate above the element, if out of space flip down.
  public static final int OVERLAY_LOCATION_TOP_OR_BOTTOM = 0x10001;

  public static final int OVERLAY_LOCATION_HMASK = 0xFF00;
  public static final int OVERLAY_LOCATION_LEFT = 0x0100;
  public static final int OVERLAY_LOCATION_RIGHT = 0x0200;
  public static final int OVERLAY_LOCATION_LEFT_EDGE = 0x0400;
  public static final int OVERLAY_LOCATION_RIGHT_EDGE = 0x0800;
  public static final int OVERLAY_LOCATION_CENTER = 0x1000;

  public static final int OVERLAY_LOCATION_VFLIP_ENABLED = 0x10000;
  // Custom location is used for modal floating elements that should
  // not be repositioned due to container size/location change.
  public static final int OVERLAY_LOCATION_CUSTOM = 0x40000;
  public static final int OVERLAY_LOCATION_TOPLEVEL = 0x80000;

  /**
   * Constructor.
   */
  public OverlayContainer() {
    host = new Canvas();
    addRawChild(host);
  }

  @Override
  protected int getRawChildCount() {
    return ((cachedContentControl != null) || (chromeTree != null)) ? 2 : 1;
  }

  @Override
  protected UIElement getRawChild(int index) {
    if (index > 1) {
      throw new IndexOutOfBoundsException();
    }
    if (index == 0) {
      if (chromeTree != null) {
        return chromeTree;
      } else if (cachedContentControl != null) {
        return cachedContentControl;
      }
    }
    return host;
  }
  @Override
  protected OverlayContainer getOverlayContainer() {
    return this;
  }

  /**
   * Adds overlay element.
   */
   public void add(UIElement overlay) {
     host.addChild(overlay);
   }

   /**
   * Removes overlay element.
   */
   public void remove(UIElement overlay) {
     host.addChild(overlay);
   }

   @Override
   protected void onMeasure(double availableWidth, double availableHeight) {
     super.onMeasure(availableWidth, availableHeight);
     if (host != null) {
       host.measure(availableWidth, availableHeight);
     }
   }

   @Override
   protected void onLayout(Rectangle layoutRectangle) {
     super.onLayout(layoutRectangle);
     if (host != null) {
       host.layout(layoutRectangle);
     }
  }
}
