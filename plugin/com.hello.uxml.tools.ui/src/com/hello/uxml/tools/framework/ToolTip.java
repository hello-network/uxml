package com.hello.uxml.tools.framework;

/**
 * Provides class for styling tooltips and manages single tooltip overlay across
 * application.
 *
 * @author ferhat
 */
public class ToolTip extends ContentContainer {
  // TODO(ferhat): Port actionscript impl. once its ready.
  /** Location Property Definition */
  public static PropertyDefinition locationPropDef = PropertySystem.register("Location",
      OverlayLocation.class, ToolTip.class, new PropertyData(0));

  /**
   * Sets or returns location of tooltip relative to it's target.
   */
  public OverlayLocation getLocation() {
    return (OverlayLocation) getProperty(locationPropDef);
  }

  public void setLocation(OverlayLocation value) {
    setProperty(locationPropDef, value);
  }
}
