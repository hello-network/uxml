package com.hello.uxml.tools.framework;

/**
 * Enumerates overlay location.
 *
 * @author ferhat
 *
 */
public enum OverlayLocation {
  Default(0),
  Top(1),
  Bottom(2),
  TopEdge(4),
  BottomEdge(8),
  VCenter(0x10),
  BottomOrTop(0x10002),
  TopOrBottom(0x10001),
  Left(0x100),
  Right(0x200),
  LeftEdge(0x400),
  RightEdge(0x800),
  Center(0x1000),
  Custom(0x40000),
  TopLevel(0x80000);

  private final int code;

  private OverlayLocation(int code) {
    this.code = code;
  }

  /**
   * Gets the blend mode value.
   */
   public int getCode() {
     return code;
   }

   /**
    * Returns enum value for code.
    */
   public static OverlayLocation valueOf(int code) {
     for (OverlayLocation c : OverlayLocation.values()) {
       if (c.getCode() == code) {
         return c;
       }
     }
     return OverlayLocation.Default;
   }
}
