part of uxml;

/**
 * Defines a transformation matrix.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class Matrix {

  /** m11 of matrix */
  num a;
  /** m12 of matrix */
  num b;
  /** m21 of matrix */
  num c;
  /** m22 of matrix */
  num d;
  /** translate x of matrix */
  num tx;
  /** translate y of matrix */
  num ty;

  /**
   * Constructor
   */
  Matrix(this.a, this.b, this.c, this.d, this.tx, this.ty);

  /** Constructs an identity matrix. */
  Matrix.identity() {
    a = 1.0;
    b = 0.0;
    c = 0.0;
    d = 1.0;
    tx = 0.0;
    ty = 0.0;
  }

  /** Rotates matrix by angle (radian). */
  void rotate(num angle) {
    num cosVal = cos(angle);
    num sinVal = sin(angle);
    num tmp = (a * cosVal) + (b * sinVal);
    b = (-a * sinVal) + (b * cosVal);
    a = tmp;
    tmp = (c * cosVal) + (d * sinVal);
    d = (-c * sinVal) + (d * cosVal);
    c = tmp;
    tmp = (tx * cosVal) + (ty * sinVal);
    ty = (-tx * sinVal) + (ty * cosVal);
    tx = tmp;
  }

  /** Translates matrix. */
  void translate(num translateX, num translateY) {
    tx += translateX;
    ty += translateY;
  }

  /** Transforms a coordinate using matrix. */
  Coord transformPoint(Coord value) {
    return new Coord(tx + (a * value.x) + (b * value.y),
        ty + (c * value.x) + (d * value.y));
  }

  /** Transforms a coordinate using matrix without allocation. */
  num transformPointX(num x, num y) {
    return tx + (a * x) + (b * y);
  }


  /** Transforms a coordinate using matrix without allocation. */
  num transformPointY(num x, num y) {
    return ty + (c * x) + (d * y);
  }

  /** Transforms a point using inverse of matrix. */
  num transformPointXInverse(num x, num y) {
    num det = a * d - b * c;
    num newA = d / det;
    num newB = -b / det;
    num newC = -c / det;
    num newD = a / det;
    num newTx = (b * ty - d * tx) / det;
    num newTy = (c * tx - a * ty) / det;
    return newTx + (newA * x) + (newB * y);
  }

  /** Transforms a point using inverse of matrix. */
  num transformPointYInverse(num x, num y) {
    num det = a * d - b * c;
    num newA = d / det;
    num newB = -b / det;
    num newC = -c / det;
    num newD = a / det;
    num newTx = (b * ty - d * tx) / det;
    num newTy = (c * tx - a * ty) / det;
    return newTy + (newC * x) + (newD * y);
  }


  /** Transforms a size using matrix. */
  Size transformSize(Size value) {
    return new Size((a * value.width) + (b * value.height),
        (c * value.width) + (d * value.height));
  }

  /** Transforms width using matrix. */
  num transformSizeX(num width, num height) {
    return (a * width) + (b * height);
  }

  /** Transforms height using matrix. */
  num transformSizeY(num width, num height) {
    return (c * width) + (d * height);
  }

  /** Creates clone of matrix. */
  Matrix clone() => new Matrix(a, b, c, d, tx, ty);
}
