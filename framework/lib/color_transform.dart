part of uxml;

/**
 * Defines color transform parameters.
 */
class ColorTransform {
  num alphaOffset = 0.0;
  num redOffset = 0.0;
  num greenOffset = 0.0;
  num blueOffset = 0.0;
  num alphaMultiplier = 1.0;
  num redMultiplier = 1.0;
  num greenMultiplier = 1.0;
  num blueMultiplier = 1.0;
  bool monoChrome = false;

  set color(Color value) {
    redMultiplier = 0.0;
    greenMultiplier = 0.0;
    blueMultiplier = 0.0;
    alphaMultiplier = 1.0;
    alphaOffset = 0.0;
    redOffset = value.R / 255.0;
    greenOffset = value.G / 255.0;
    blueOffset = value.B / 255.0;
  }

  void colorize(Color value) {
    monoChrome = true;
    redMultiplier = value.R / 255.0;
    greenMultiplier = value.G / 255.0;
    blueMultiplier = value.B / 255.0;
    alphaMultiplier = 1.0;
    alphaOffset = 0.0;
    redOffset = 0.0;
    greenOffset = 0.0;
    blueOffset = 0.0;
  }
}
