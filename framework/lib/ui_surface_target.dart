part of uxml;

abstract class UISurfaceTarget {
  /**
   * Called when surface property change requires the element to
   * repaint contents.
   */
  void invalidateDrawing();
  /** Called when surface requests focus */
  bool surfaceFocusChanged(bool hasFocus);
  /** Called when surface text content is updated. */
  void surfaceTextChanged(String text);
}
