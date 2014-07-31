package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.ContentNode;
import com.hello.uxml.tools.framework.Matrix;
import com.hello.uxml.tools.framework.Point;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a brush with a radial gradient.
 *
 * @author ferhat
 */
public class RadialBrush extends Brush {

  /** list of gradient stops */
  private List<GradientStop> stops = new ArrayList<GradientStop>();

  /** Holds Size of gradient */
  private Point radius;

  /** Center of radial gradient (0..1), (0..1) */
  private Point center;

  /** Origin of radial gradient (focal point) */
  private Point origin;

  /** Transform for gradient */
  private Matrix transform;

  /**
   * Constructor.
   */
  public RadialBrush() {
  }

  /**
   * Sets/returns center.
   */
  public void setCenter(Point value) {
    center = value;
  }

  public Point getCenter() {
    return center;
  }

  /**
   * Sets/returns origin.
   */
  public void setOrigin(Point value) {
    origin = value;
  }

  public Point getOrigin() {
    return origin;
  }

  /**
   * Sets/returns transform.
   */
  public void setTransform(Matrix value) {
    transform = value;
  }

  public Matrix getTransform() {
    return transform;
  }

  /**
   * Sets/returns radius.
   */
  public void setRadius(Point value) {
    radius = value;
  }

  public Point getRadius() {
    return radius;
  }

  /**
   * Adds a gradient stop to the brush.
   */
  @ContentNode
  public void addStop(GradientStop stop) {
    stops.add(stop);
  }

   /**
   * Returns a list of gradient stops.
   */
  public List<GradientStop> getStops() {
    return stops;
  }

  public void setStops(List<GradientStop> stops) {
    this.stops = stops;
  }
}
