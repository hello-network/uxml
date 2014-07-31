package com.hello.uxml.tools.framework;

/**
 * Defines a transformation matrix.
 *
 * @author ferhat
 *
 */
public class Matrix {

  /** m11 of matrix */
  public double a;
  /** m12 of matrix */
  public double b;
  /** m21 of matrix */
  public double c;
  /** m22 of matrix */
  public double d;
  /** translate x of matrix */
  public double tx;
  /** translate y of matrix */
  public double ty;


  /**
   * Constructs an identity matrix.
   */
  public Matrix() {
    a = 1.0;
    b = 0.0;
    c = 0.0;
    d = 1.0;
    tx = 0.0;
    ty = 0.0;
  }

  /**
   * Constructor.
   */
  public Matrix(double a, double b, double c, double d, double tx, double ty) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
  }

  /**
   * Sets or returns m11 of matrix
   */
  public double getA() {
    return a;
  }

  public void setA(double value) {
    a = value;
  }

  /**
   * Sets or returns m12 of matrix
   */
  public double getB() {
    return b;
  }

  public void setB(double value) {
    b = value;
  }

  /**
   * Sets or returns m21 of matrix
   */
  public double getC() {
    return c;
  }

  public void setC(double value) {
    c = value;
  }

  /**
   * Sets or returns m22 of matrix
   */
  public double getD() {
    return d;
  }


  public void setD(double value) {
    d = value;
  }

  /**
   * Sets or returns tx of matrix
   */
  public double getTx() {
    return tx;
  }

  public void setTx(double value) {
    tx = value;
  }

  /**
   * Sets or returns ty of matrix
   */
  public double getTy() {
    return ty;
  }

  public void setTy(double value) {
    ty = value;
  }

  /**
   * Rotates matrix by angle (radian).
   */
  public void rotate(double angle) {
    double cosVal = Math.cos(angle);
    double sinVal = Math.sin(angle);
    double tmp = (a * cosVal) + (b * sinVal);
    b = (-a * sinVal) + (b * cosVal);
    a = tmp;
    tmp = (c * cosVal) + (d * sinVal);
    d = (-c * sinVal) + (d * cosVal);
    c = tmp;
    tmp = (tx * cosVal) + (ty * sinVal);
    ty = (-tx * sinVal) + (ty * cosVal);
    tx = tmp;
  }

  /** Translate matrix */
  public void translate(double translateX, double translateY) {
    tx += translateX;
    ty += translateY;
  }

  /** Scale matrix */
  public void scale(double scaleX, double scaleY) {
    a *= scaleX;
    b *= scaleY;
    c *= scaleX;
    d *= scaleY;
    tx *= scaleX;
    ty *= scaleY;
  }

  /** Multiplies matrix */
  public void multiply(Matrix m) {
    double tmp = (a * m.a) + (b * m.c);
    b = (a * m.b) + (b * m.d);
    a = tmp;
    tmp = (c * m.a) + (d * m.c);
    d = (c * m.b) + (d * m.d);
    c = tmp;
    tmp = (tx * m.a) + (ty * m.c) + m.tx;
    ty = (tx * m.b) + (ty * m.d) + m.ty;
    tx = tmp;
  }

  /** Multiplies 2 matrices and returns (m1 x m2) */
  public static Matrix multiply(Matrix m1, Matrix m2) {
    return new Matrix((m1.a * m2.a) + (m1.b * m2.c) , (m1.a * m2.b) + (m1.b * m2.d),
        (m1.c * m2.a) + (m1.d * m2.c), (m1.c * m2.b) + (m1.d * m2.d),
        (m1.tx * m2.a) + (m1.ty * m2.c) + m2.tx, (m1.tx * m2.b) + (m1.ty * m2.d) + m2.ty);
  }

  /**
   * Transforms a point using matrix.
   */
  public Point transformPoint(Point value) {
    return new Point(tx + (a * value.x) + (b * value.y),
        ty + (c * value.x) + (d * value.y));
  }

  /**
   * Transforms a size using matrix.
   */
  public Size transformSize(Size value) {
    return new Size((a * value.width) + (b * value.height),
        (c * value.width) + (d * value.height));
  }

  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof Matrix)) {
      return false;
    }
    Matrix m = (Matrix) obj;
    return (m.a == a) && (m.b == b) && (m.c == c) && (m.d == d)
        && (m.tx == tx) && (m.ty == ty);
  }

  @Override
  public int hashCode() {
    // TODO(ferhat) : implement
    return super.hashCode();
  }

  @Override
  public String toString() {
    // Not using String.format due to GWT
    StringBuilder sb = new StringBuilder();
    sb.append("Matrix(");
    sb.append(a);
    sb.append(", ");
    sb.append(b);
    sb.append(", ");
    sb.append(c);
    sb.append(", ");
    sb.append(d);
    sb.append(", ");
    sb.append(tx);
    sb.append(", ");
    sb.append(ty);
    sb.append(")");
    return sb.toString();
  }
}
