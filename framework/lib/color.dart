part of uxml;

/**
 * Handles ARGB color value.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Color {

  /** ARGB value of color*/
  int color;
  String _colorText;

  static Color EMPTY;
  static Color BLACK;
  static Color BLUE;
  static Color CYAN;
  static Color DARK_GRAY;
  static Color GRAY;
  static Color GREEN;
  static Color LIGHT_GRAY;
  static Color MAGENTA;
  static Color ORANGE;
  static Color PINK;
  static Color RED;
  static Color WHITE;
  static Color YELLOW;

  static void initialize() {
    EMPTY = new Color(0);
    BLACK = new Color(0xFF000000);
    BLUE = new Color(0xFF0000FF);
    CYAN = new Color(0xFF00FFFF);
    DARK_GRAY = new Color(0xFF404040);
    GRAY = new Color(0xFF808080);
    GREEN = new Color(0xFF00FF00);
    LIGHT_GRAY = new Color(0xFFC0C0C0);
    MAGENTA = new Color(0xFFFF00FF);
    ORANGE = new Color(0xFFFFC800);
    PINK = new Color(0xFFFFAFAF);
    RED = new Color(0xFFFF0000);
    WHITE = new Color(0xFFFFFFFF);
    YELLOW = new Color(0xFFFFFF00);
  }

  Color(this.color);

  /**
   * Creates color from ARGB value.
   */
  static Color fromARGB(int argb) {
    return new Color(argb);
  }

  /**
   * Creates color from RGB value.
   */
  static Color fromRGB(int rgb) {
    return new Color(0xFF000000 | rgb);
  }

  /**
   * Creates color from another color by multiplying alpha.
   */
  static Color fromColor(Color c, num alphaMult) {
    int newAlpha = (255.0 * alphaMult).toInt();
    if (newAlpha > 255) { newAlpha = 255; };
    return new Color((newAlpha << 24) | c.rgb);
  }

  /**
   * Creates color from ARGB components.
   */
  static Color from(int a, int r, int g, int b) {
    return new Color((a << 24) | (r << 16) | (g << 8) | b);
  }

  /**
   * Returns alpha component of color.
   */
  num get alpha => ((color >> 24) & 0xFF) / 255.0;

  set alpha(num value) {
    color = (color & 0xFFFFFF) | ((value * 255.0).toInt() << 24);
    _colorText = null;
  }

  /**
   * Returns alpha component of color.
   */
  int get A => (color >> 24) & 0xFF;

  set A(int value) {
    color = (color & 0xFFFFFF) | ((value & 0xFF) << 24);
    _colorText = null;
  }

  /**
   * Returns red component of color.
   */
  int get R => (color >> 16) & 0xFF;

  set R(int value) {
    color = (color & 0xFF00FFFF) | ((value & 0xFF) << 16);
    _colorText = null;
  }

  /**
   * Returns green component of color.
   */
  int get G => ((color >> 8) & 0xFF);

  set G(int value) {
    color = (color & 0xFFFF00FF) | ((value & 0xFF) << 8);
    _colorText = null;
  }

  /**
   * Returns blue component of color.
   */
  int get B => color & 0xFF;

  set B(int value) {
    color = (color & 0xFFFFFF00) | (value & 0xFF);
    _colorText = null;
  }

  /**
   * Returns ARGB value of color.
   */
  int get argb => color;

  /**
   * Sets ARGB value of color.
   */
  set argb(int value) {
    color = value;
    _colorText = null;
  }

  /**
   * Returns RGB value of color.
   */
  int get rgb => color & 0xFFFFFF;

  set rgb(int val) {
    color = val | 0xFF000000;
  }

  /**
   * Creates a new color by mixing colors.
   *
   * @param mixColor Color to mix and alpha as mixing ratio.
   */
  Color mix(Color mixColor) {
    int ratio = mixColor.A;
    int ratio2 = 255 - ratio;
    int r = (((R * ratio2) + (mixColor.R * ratio)) ~/ 255);
    int g = (((G * ratio2) + (mixColor.G * ratio)) ~/ 255);
    int b = (((B * ratio2) + (mixColor.B * ratio)) ~/ 255);
    return Color.fromARGB((A << 24) | (r << 16) | (g << 8) | b);
  }

  int get hashCode => color;

  bool operator ==(Object other) {
    if (other == null) {
      return false;
    }
    if (other is Color) {
      Color c = other;
      return c.color == color;
    }
    return false;
  }

  String pad(String input) {
    if (input.length == 0) {
      return "00";
    }
    if (input.length == 1) {
      return "0$input";
    }
    return input;
  }

  /**
   * Transforms a color's hue, saturation, value in HSLSpace.
   */
  static Color transform(Color baseColor, num lighten, num saturate,
      num opacity) {
    int ri = baseColor.R;
    int gi = baseColor.G;
    int bi = baseColor.B;

    // Find min and max values from RGB
    num r = ri / 255.0;
    num g = gi / 255.0;
    num b = bi / 255.0;
    num maxVal = max(max(r, g), b);
    num minVal = min(min(r, g), b);
    num chroma = maxVal - minVal;
    num h = 0.0;
    num s = 0.0;
    // lightness = center of min and max
    num l = (maxVal + minVal) / 2.0;

    // if M == m, we know the color is strictly
    // lightness based (black, white, gray) so s,h stay 0;
    if (!(((chroma < 0) ? -chroma : chroma) < 0.000001)) {
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
    r = 0.0;
    g = 0.0;
    b = 0.0;

    // If S=0, define R, G, and B all to L
    if (s == 0.0) {
      r = l;
      g = l;
      b = l;
    } else {
      num temp1 = 0.0;
      num temp2 = 0.0;
      num temp3r = 0.0;
      num temp3g = 0.0;
      num temp3b = 0.0;

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

      // For each color component do: if 6.0*temp3x < 1, color = temp1 + (temp2
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
    return Color.fromARGB(((255 * opacity).toInt() << 24) |
        ((255 * r).toInt() << 16) | ((255 * g).toInt() << 8) |
        (255 * b).toInt());
  }

  Color clone() => new Color(color);

  String toString() {
    if (_colorText == null) {
      StringBuffer sb = new StringBuffer();
      if (A != 255) {
        sb.write("rgba(");
        sb.write(((color >> 16) & 0xFF).toString());
        sb.write(",");
        sb.write(((color >> 8) & 0xFF).toString());
        sb.write(",");
        sb.write((color & 0xFF).toString());
        sb.write(",");
        sb.write(alpha.toString());
        sb.write(")");
      } else {
        sb.write("#");
        sb.write(pad(((color >> 16) & 0xFF).toRadixString(16)));
        sb.write(pad(((color >> 8) & 0xFF).toRadixString(16)));
        sb.write(pad((color & 0xFF).toRadixString(16)));
      }
      _colorText = sb.toString();
    }
    return _colorText;
  }
}
