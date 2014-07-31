package com.hello.uxml.tools.framework.graphics;

import com.hello.uxml.tools.framework.ContentNode;
import com.hello.uxml.tools.framework.Point;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a brush with linear gradient stops
 *
 * @author ferhat
 */
public class LinearBrush extends Brush {

  /** list of gradient stops */
  private List<GradientStop> stops = new ArrayList<GradientStop>();

  /** Start point of gradient */
  private Point startPoint;

  /** End point of gradient */
  private Point endPoint;

  /**
   * Constructor.
   */
  public LinearBrush() {
  }

  /**
   * Constructs a gradient brush from color1 to color2.
   */
  public LinearBrush(Color color1, Color color2, Point startPoint, Point endPoint) {
    this.startPoint = startPoint;
    this.endPoint = endPoint;
    stops.add(new GradientStop(color1, 0.0));
    stops.add(new GradientStop(color2, 1.0));
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

  /**
   * Sets/returns start point of gradient.
   *
   * <p> The gradient box is 0,0 to 1.0,1.0.
   */
  public void setStart(Point value) {
    startPoint = value;
  }

  public Point getStart() {
    return startPoint;
  }

  /**
   * Sets/returns the end point of gradient.
   *
   * <p> The gradient box is 0,0 o 1.0,1.0.
   */
  public void setEnd(Point value) {
    endPoint = value;
  }

  public Point getEnd() {
    return endPoint;
  }
}
