part of uxml;

class GradientStop {
  /**
   * Gets or sets the color value.
   */
  Color color;

  /**
   * Gets or sets the stop's offset inside a gradient.
   */
  num offset;

  GradientStop(this.color, this.offset);

  /** Clones Gradient stop and color. */
  GradientStop clone() {
    return new GradientStop(new Color(color.argb), offset);
  }
}
