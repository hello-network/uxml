package com.hello.uxml.tools.framework;

/**
 * Enumerates the scaling mode of Shape and Image objects.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public enum ScaleMode {
  None,    // No scaling, item is rendered in natual size.
  Fill,    // Items is scaled to fit layout area.
  Uniform, // Item is scale to fit layout area with original aspect ratio.
  Zoom,    // Item is scaled up uniformly until it fills layout area.
  ZoomOut  // fills layout but doesn't upscale the image  but keeps aspect ratio.
}
