package com.hello.uxml.tools.framework;

/**
 * Defines flags of a property for a specific owner class.
 *
 * <p>These flags are used by framework to optimize re-layout and define
 * property inheritance across the element tree.
 */
public enum PropertyFlags {
  None(0),
  Inherit(0x0001),
  Attached(0x0002),
  Redraw(0x0004),
  Resize(0x0008),
  Relayout(0x0010),
  ParentResize(0x0020),
  ParentRelayout(0x0040),

  Localizable(0x1000);

  int value;
  private PropertyFlags(int value) {
    this.value = value;
  }

  /**
   * Returns whether a value is inherited from parent elements.
   */
  public boolean getInherits() {
    return (value & Inherit.value) != 0;
  }

  /**
   * Returns whether a value is attached to child elements
   */
  public boolean getIsAttached() {
    return (value & Attached.value) != 0;
  }
}
