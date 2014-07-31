package com.hello.uxml.tools.framework.graphics.utils;

import com.hello.uxml.tools.framework.Point;
import com.hello.uxml.tools.framework.Rectangle;

/**
 * Implements utility methods for Curve geometry calculations.
 *
 * @author ferhat
 *
 */
public final class CurveUtil {

  /** Sufficiently small number */
  private static final double EPSILON = 0.000000001;

  private CurveUtil() {
  }

  /**
   * Calculate Quadratic bezier curve bounds.
   */
  public static Rectangle calcBezierBounds(Point point1, Point control, Point point2) {

    // Initialize bounds rectangle
    Rectangle bounds = new Rectangle(Math.min(point1.getX(), point2.getX()),
        Math.min(point1.getY(), point2.getY()),
        Math.abs(point2.getX() - point1.getX()),
        Math.abs(point2.getY() - point1.getY()));

    // The Quadratic bezier curve equation is: (1-t)(1-t)P1 + 2t(1-t)PC + t*t*P2.
    // To find the bounds of the curve, we have to find extrema where derivative = 0.
    // derivative dx/dt((1-2t+tt)P1X + 2tPCX-2ttPCX + ttP2X)
    // = -2P1X+2tP1X + 2PCX + 4tPCX + 2tP2X = 0
    // = -2P1X + 2PCX +2t(P1X + 2PCX + P2X) = 0
    // t = (P1X - PCX) / (P1X + 2PCX + P2X)

    double denom = (point1.getX() + (2 * control.getX()) + point2.getX());
    if (Math.abs(denom) > EPSILON) {
      double t1 = (point1.getX() - control.getX()) / denom;
      if ((t1 >= 0) && (t1 <= 1.0)) {
        // If we solve (x,y) for curve at t=tx , we have an extrema
        double tprime = 1 - t1;
        Point ex1 = new Point((tprime * tprime * point1.getX())
            + ((2 * t1 * tprime * control.getX()))
            + (t1 * t1 * point2.getX()), (tprime * tprime * point1.getY())
            + ((2 * t1 * tprime * control.getY())) + (t1 * t1 * point2.getY()));
        bounds.add(ex1);
      }
    }
    // Now calculate dy/dt = 0
    denom = (point1.getY() + (2 * control.getY()) + point2.getY());
    if (Math.abs(denom) > EPSILON) {
      double t2 = (point1.getY() - control.getY()) / denom;
      if ((t2 >= 0) && (t2 <= 1.0)) {
        double tprime = 1 - t2;
        Point ex2 = new Point(tprime * tprime * point1.getX() + (2 * t2 * tprime * control.getX())
            + t2 * t2 * point2.getX(), tprime * tprime * point1.getY()
            + (2 * t2 * tprime * control.getY())
            + t2 * t2 * point2.getY());
        bounds.add(ex2);
      }
    }
    return bounds;
  }



  /**
   * Calculate bounds of cubic bezier curve
   *
   * @param p1 Start anchor point
   * @param c1 Control point 1
   * @param c2 Control point 2
   * @param p2 End anchor point
   */
  public static Rectangle calcBezierBounds(Point p1, Point c1, Point c2, Point p2) {

    // We can find the bounding box by finding all points on curve where monotonicity changes.

    // initialize max/min bounds based on anchor points
    double minX = Math.min(p1.getX(), p2.getX());
    double minY = Math.min(p1.getY(), p2.getY());
    double maxX = Math.max(p1.getX(), p2.getX());
    double maxY = Math.max(p1.getY(), p2.getY());

    // Check for simple case of strong ordering before calculating extrema
    if (!(((p1.getX() < c1.getX()) && (c1.getX() < c2.getX()) && (c2.getX() < p2.getX()))
        || (((p1.getX() > c1.getX()) && (c1.getX() > c2.getX()) && (c2.getX() > p2.getX()))))) {

      // The extrema point is dx/dt B(t) = 0
      // The derivative of B(t) for cubic bezier is a quadratic equation with multiple roots
      // B'(t) = a*t*t + b*t + c*t
      double a = -p1.getX() + (3 * (c1.getX() - c2.getX())) + p2.getX();
      double b = 2 * (p1.getX() - (2 * c1.getX()) + c2.getX());
      double c = -p1.getX() + c1.getX();

      // Now find roots for quadratic equation with known coefficients a,b,c
      // The roots are (-b+-sqrt(b*b-4*a*c)) / 2a
      double s = (b * b) - (4 * a * c);
      // If s is negative, we have no real roots
      if ((s >= 0.0) && (Math.abs(a) > EPSILON)) {
        if (s == 0.0) {
          // we have only 1 root
          double t = -b / (2 * a);
          double tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValX = ((tprime * tprime * tprime) * p1.getX())
                + ((3 * tprime * tprime * t) * c1.getX())
                + ((3 * tprime * t * t) * c2.getX())
                + (t * t * t * p2.getX());
            minX = Math.min(extremeValX, minX);
            maxX = Math.max(extremeValX, maxX);
          }
        } else {

          // we have 2 roots
          s = Math.sqrt(s);
          double t = (-b - s) / (2 * a);
          double tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValX = ((tprime * tprime * tprime) * p1.getX())
                + ((3 * tprime * tprime * t) * c1.getX())
                + ((3 * tprime * t * t) * c2.getX())
                + (t * t * t * p2.getX());
            minX = Math.min(extremeValX, minX);
            maxX = Math.max(extremeValX, maxX);
          }
          // check 2nd root
          t = (-b + s) / (2 * a);
          tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValX = ((tprime * tprime * tprime) * p1.getX())
                + ((3 * tprime * tprime * t) * c1.getX())
                + ((3 * tprime * t * t) * c2.getX())
                + (t * t * t * p2.getX());

            minX = Math.min(extremeValX, minX);
            maxX = Math.max(extremeValX, maxX);
          }
        }
      }
    }

    // Now calc extremes for dy/dt = 0 just like above
    if (!(((p1.getY() < c1.getY()) && (c1.getY() < c2.getY()) && (c2.getY() < p2.getY()))
        || (((p1.getY() > c1.getY()) && (c1.getY() > c2.getY()) && (c2.getY() > p2.getY()))))) {

      // The extrema point is dy/dt B(t) = 0
      // The derivative of B(t) for cubic bezier is a quadratic equation with multiple roots
      // B'(t) = a*t*t + b*t + c*t
      double a = -p1.getY() + (3 * (c1.getY() - c2.getY())) + p2.getY();
      double b = 2 * (p1.getY() - (2 * c1.getY()) + c2.getY());
      double c = -p1.getY() + c1.getY();

      // Now find roots for quadratic equation with known coefficients a,b,c
      // The roots are (-b+-sqrt(b*b-4*a*c)) / 2a
      double s = (b * b) - (4 * a * c);
      // If s is negative, we have no real roots
      if ((s >= 0.0) && (Math.abs(a) > EPSILON)) {
        if (s == 0.0) {
          // we have only 1 root
          double t = -b / (2 * a);
          double tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValY = ((tprime * tprime * tprime) * p1.getY())
                + ((3 * tprime * tprime * t) * c1.getY())
                + ((3 * tprime * t * t) * c2.getY())
                + (t * t * t * p2.getY());
            minY = Math.min(extremeValY, minY);
            maxY = Math.max(extremeValY, maxY);
          }
        } else {

          // we have 2 roots
          s = Math.sqrt(s);
          double t = (-b - s) / (2 * a);
          double tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValY = ((tprime * tprime * tprime) * p1.getY())
                + ((3 * tprime * tprime * t) * c1.getY())
                + ((3 * tprime * t * t) * c2.getY())
                + (t * t * t * p2.getY());
            minY = Math.min(extremeValY, minY);
            maxY = Math.max(extremeValY, maxY);
          }
          // check 2nd root
          t = (-b + s) / (2 * a);
          tprime = 1.0 - t;
          if ((t >= 0.0) && (t <= 1.0)) {
            double extremeValY = ((tprime * tprime * tprime) * p1.getY())
                + ((3 * tprime * tprime * t) * c1.getY())
                + ((3 * tprime * t * t) * c2.getY())
                + (t * t * t * p2.getY());
            minY = Math.min(extremeValY, minY);
            maxY = Math.max(extremeValY, maxY);
          }
        }
      }
    }
    return new Rectangle(minX, minY, maxX - minX, maxY - minY);
  }
}