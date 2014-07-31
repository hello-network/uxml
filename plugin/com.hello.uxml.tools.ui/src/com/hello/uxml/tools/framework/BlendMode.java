package com.hello.uxml.tools.framework;

/**
 * Enumerates Surface blend modes.
 */
public enum BlendMode {
  Normal(1),
  Layer(2),
  Multiply(3),
  Screen(4),
  Lighten(5),
  Darken(6),
  Difference(7),
  Add(8),
  Subtract(9),
  Invert(10),
  Alpha(11),
  Erase(12),
  Overlay(13),
  Hardlight(14),
  INVALID_MODE(0xFFFFFFFF);

  private final int code;

  private BlendMode(int code) {
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
  public static BlendMode valueOf(int code) {
    for (BlendMode c : BlendMode.values()) {
      if (c.getCode() == code) {
        return c;
      }
    }
    return BlendMode.INVALID_MODE;
  }
}

