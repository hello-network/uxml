package com.hello.uxml.tools.framework;

import com.hello.uxml.tools.framework.graphics.Color;

import java.util.EnumSet;

/**
 * Displays a spinning progress control.
 *
 * @author ferhat
 */
public class WaitIndicator extends ProgressControl {
  // TODO(ferhat): port as3 framework onRedraw code.

  /** Color Property Definition */
  public static PropertyDefinition colorPropDef = PropertySystem.register("Color",
      Color.class,
      WaitIndicator.class,
      new PropertyData(Color.WHITE, EnumSet.of(PropertyFlags.Redraw)));

}
