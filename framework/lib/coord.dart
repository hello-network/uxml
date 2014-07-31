part of uxml;

class Coord {
  Coord(this.x, this.y);
  num x;
  num y;

  bool equals(Coord c) => (c != null) && (c.x == x) && (c.y == y);
}

class Size {
  num width;
  num height;
  Size(this.width, this.height);
}
