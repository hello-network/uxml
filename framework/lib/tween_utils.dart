part of uxml;

/**
 * This class contains public functions implementing tweens between Number,
 * int and Color.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class TweenUtils {
  /**
   * Tweens between two Color objects. It returns the result in the third
   * parameter in order to avoid creating another Color object.
   *
   * @param start The start Color object.
   * @param end The end Color object.
   * @param result The Color object holding the tweened color.
   * @param tween A value between 0.0 - 0.1.
   */
  static void tweenColor(Color start,
                         Color end,
                         Color result,
                         num tween) {
    if (tween == 0.0) {
      result.argb = start.argb;
      return;
    }
    if (tween == 1.0) {
      result.argb = end.argb;
      return;
    }
    int a = tweenInt(start.A, end.A, tween);
    int r = tweenInt(start.R, end.R, tween);
    int g = tweenInt(start.G, end.G, tween);
    int b = tweenInt(start.B, end.B, tween);
    result.argb = (a << 24) | (r << 16) | (g << 8) | b;
  }

  /**
   * Tweens between two point objects. It returns the result in the third
   * parameter in order to avoid creating another Point object.
   *
   * @param start The start point.
   * @param end The end point.
   * @param result The Coord object holding the tweened point coordinates.
   * @param tween A value between 0.0 - 0.1.
   */
  static void tweenPoint(Coord start,
                         Coord end,
                         Coord result,
                         num tween) {
    if (tween == 0) {
      result.x = start.x;
      result.y = start.y;
      return;
    }
    if (tween == 1) {
      result.x = end.x;
      result.y = end.y;
      return;
    }
    result.x = tweenNumber(start.x, end.x, tween);
    result.y = tweenNumber(start.y, end.y, tween);
  }

  /**
   * Retuns a tween between two Numbers.
   */
  static num tweenNumber(num start,
                            num end,
                            num tween) {
    return (start * (1.0 - tween)) + (end * tween);
  }

  /**
   * Returns a tween between two ints.
   */
  static int tweenInt(int start, int end, num tween) {
    num a = (1.0 - tween)  * start;
    return (a + (end * tween) + 0.5).toInt();
  }
}


typedef num TweenFunction(num val);
