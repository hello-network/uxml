package com.hello.uxml.tools.framework.graphics;

/**
 * Represent ARGB color value.
 *
 * @author ferhat
 */
public class Color {

  /** ARGB value of color*/
  private int color;
  private String colorText;

  public static final Color EMPTY = new Color(0);
  public static final Color BLACK = new Color(0xFF000000);
  public static final Color BLUE = new Color(0xFF0000FF);
  public static final Color CYAN = new Color(0xFF00FFFF);
  public static final Color DARK_GRAY = new Color(0xFF404040);
  public static final Color GRAY = new Color(0xFF808080);
  public static final Color GREEN = new Color(0xFF00FF00);
  public static final Color LIGHT_GRAY = new Color(0xFFC0C0C0);
  public static final Color MAGENTA = new Color(0xFFFF00FF);
  public static final Color ORANGE = new Color(0xFFFFC800);
  public static final Color PINK = new Color(0xFFFFAFAF);
  public static final Color RED = new Color(0xFFFF0000);
  public static final Color WHITE = new Color(0xFFFFFFFF);
  public static final Color YELLOW = new Color(0xFFFFFF00);

  /**
   * private Constructor.
   */
  private Color(int value) {
    color = value;
  }

  /**
   * Creates color from ARGB value.
   */
  public static Color fromARGB(int argb) {
    return new Color(argb);
  }

  /**
   * Creates color from RGB value.
   */
  public static Color fromRGB(int rgb) {
    return new Color(0xFF000000 | rgb);
  }

  /**
   * Creates color from ARGB components.
   */
  public static Color fromARGB(int a, int r, int g, int b) {
    return new Color((a << 24) | (r << 16) | (g << 8) | b);
  }

  /**
   * Returns alpha component of color.
   */
  public double getAlpha() {
    return ((color >> 24) & 0xFF) / 255.0;
  }

  public void setAlpha(double value) {
    color = (color & 0xFFFFFF) | (((int) (value * 255.0)) << 24);
    colorText = null;
  }

  /**
   * Returns alpha component of color.
   */
  public int getA() {
    return (color >> 24) & 0xFF;
  }

  public void setA(int value) {
    color = (color & 0xFFFFFF) | ((value & 0xFF) << 24);
    colorText = null;
  }

  /**
   * Returns red component of color.
   */
  public int getR() {
    return (color >> 16) & 0xFF;
  }

  public void setR(int value) {
    color = (color & 0xFF00FFFF) | ((value & 0xFF) << 16);
    colorText = null;
  }

  /**
   * Returns green component of color.
   */
  public int getG() {
    return ((color >> 8) & 0xFF);
  }

  public void setG(int value) {
    color = (color & 0xFFFF00FF) | ((value & 0xFF) << 8);
    colorText = null;
  }

  /**
   * Returns blue component of color.
   */
  public int getB() {
    return color & 0xFF;
  }

  public void setB(int value) {
    color = (color & 0xFFFFFF00) | (value & 0xFF);
    colorText = null;
  }

  /**
   * Returns ARGB value of color.
   */
  public int getARGB() {
    return color;
  }

  /**
   * Returns RGB value of color.
   */
  public int getRGB() {
    return color & 0xFFFFFF;
  }

  /**
   * Creates a new color by mixing colors.
   *
   * @param mixColor Color to mix and alpha as mixing ratio.
   */
  public Color mix(Color mixColor) {
    int ratio = mixColor.getA();
    int ratio2 = 255 - ratio;
    return Color.fromARGB(getA(),
         (((getR() * ratio2) + (mixColor.getR() * ratio)) / 255) & 0xFF,
         (((getG() * ratio2) + (mixColor.getG() * ratio)) / 255) & 0xFF,
         (((getB() * ratio2) + (mixColor.getB() * ratio)) / 255) & 0xFF);
  }

  @Override
  public int hashCode() {
    return color;
  }

  @Override
  public boolean equals(Object value) {
    if ((value == null) || (!(value instanceof Color))) {
      return false;
    }
    return ((Color) value).color == color;
  }

  private String pad (String in) {
    if (in.length() == 0) {
      return "00";
    }
    if (in.length() == 1) {
      return "0" + in;
    }
    return in;
  }

  /**
   * Transforms a color's hue, saturation, value in HSLSpace.
   */
  public static Color transform(Color baseColor,
      double lighten, double saturate, double opacity) {
    int ri = baseColor.getR();
    int gi = baseColor.getG();
    int bi = baseColor.getB();

    // Find min and max values from RGB
    double r = ri / 255.0;
    double g = gi / 255.0;
    double b = bi / 255.0;
    double maxVal = Math.max(Math.max(r, g), b);
    double minVal = Math.min(Math.min(r, g), b);
    double chroma = maxVal - minVal;
    double h = 0.0;
    double s = 0.0;
    // lightness = center of min and max
    double l = (maxVal + minVal) / 2.0;

    // if M == m, we know the color is strictly
    // lightness based (black, white, gray) so s,h stay 0;
    if (!(Math.abs(chroma) < 0.000001)) {
      // Find S. keep within 0.0 - 1.0 range.
      s = (l < 0.5) ? (chroma / (maxVal + minVal)) :
        (chroma / (2.0 - maxVal - minVal));
    }

    // Find H. end result is 0.0 - 1.0 range.
    // 1.0 represents one full rotation 360deg.
    if (chroma != 0) {
      if (r == maxVal) {
        h = (g - b) / chroma;
      }
      if (g == maxVal) {
        h = 2.0 + ((b - r) / chroma);
      }
      if (b == maxVal) {
        h = 4.0 + ((r - g) / chroma);
      }
    }
    h /= 6.0;

    // adjust l and s
    l *= (1.0 + lighten);
    s *= (1.0 + saturate);
    if (s > 1.0) {
      s = 1.0;
    }

    // Convert back to rgb space
    r = 0;
    g = 0;
    b = 0;

    // If S=0, define R, G, and B all to L
    if (s == 0.0) {
      r = l;
      g = l;
      b = l;
    } else {
      double temp1 = 0.0;
      double temp2 = 0.0;
      double temp3r = 0.0;
      double temp3g = 0.0;
      double temp3b = 0.0;

      temp2 = (l < 0.5) ? l * (1.0 + s) : (l + s) - (l * s);
      temp1 = (2.0 * l) - temp2;

      // R temp
      temp3r = h + (1.0 / 3.0);
      if (temp3r < 0.0) {
        temp3r += 1.0;
      } else if (temp3r > 1.0) {
        temp3r -= 1.0;
      }

      // G temp
      temp3g = h;
      if (temp3g < 0.0) {
        temp3g += 1.0;
      } else if (temp3g > 1.0) {
        temp3g -= 1.0;
      }

      // B temp
      temp3b = h - (1.0 / 3.0);
      if (temp3b < 0.0) {
        temp3b += 1.0;
      } else if (temp3b > 1.0) {
        temp3b -= 1.0;
      }

      // for each color component: if 6.0*temp3x < 1, color = temp1 + (temp2
      // - temp1)*6.0*temp3x
      // else if 2.0*temp3 < 1, color=temp2
      // else if 3.0*temp3 < 2,
      //         color=temp1+(temp2-temp1)*((2.0/3.0)-temp3)*6.0
      // else color = temp1

      // R
      if ((6.0 * temp3r) < 1.0) {
        r = (temp1 + (temp2 - temp1) * 6.0 * temp3r);
      } else if ((2.0 * temp3r) < 1.0) {
        r = temp2;
      } else if ((3.0 * temp3r) < 2.0) {
        r = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp3r) * 6.0;
      } else {
        r = temp1;
      }

      // G
      if ((6.0 * temp3g) < 1.0) {
        g = (temp1 + (temp2 - temp1) * 6.0 * temp3g);
      } else if ((2.0 * temp3g) < 1.0) {
        g = temp2;
      } else if ((3.0 * temp3g) < 2.0) {
        g = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp3g) * 6.0;
      } else {
        g = temp1;
      }

      // B
      if ((6.0 * temp3b) < 1.0) {
        b = (temp1 + (temp2 - temp1) * 6.0 * temp3b);
      } else if ((2.0 * temp3b) < 1.0) {
        b = temp2;
      } else if ((3.0 * temp3b) < 2.0) {
        b = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp3b) * 6.0;
      } else {
        b = temp1;
      }
    }
    return Color.fromARGB(((int) (255 * opacity) << 24) |
        ((int) (255 * r) << 16) | ((int) (255 * g) << 8) |
        (int) (255 * b));
  }


  @Override
  public String toString() {
    if (colorText == null) {
      colorText = "#";
      if (getA() != 255) {
        colorText += pad(Integer.toHexString(((color >> 25) & 0xFF)));
      }
      colorText += pad(Integer.toHexString(((color >> 16) & 0xFF))) +
          pad(Integer.toHexString(((color >> 8) & 0xFF))) +
          pad(Integer.toHexString(color & 0xFF));
    }
    return colorText;
  }
}
