class Vector {
  float x, y;

  Vector() {
    set(0,0);
  }

  Vector(float X, float Y) {
    set(X,Y);
  }
  
  Vector(String s) {
   // print(s);
    if (s.charAt(s.length() - 1) == ')') 
      s = s.substring(1,s.length()-1);
    else s = s.substring(1);
    int commaIndex = s.indexOf(',');
    x = parseInt(s.substring(0,commaIndex));
    y = parseInt(s.substring(commaIndex + 1));
   // println("->" + x + " , " + y); 
  }
  
  void set(float X, float Y) {
    x = X;
    y = Y;
  }
  
  void set(Vector v) {
    x = v.x;
    y = v.y;
  }
  
  float dot(Vector V) {
    return x*V.x + y*V.y;
  }

  float magnitude() {
    return sqrt(x * x + y * y);
  }

  void normalize() {
    float mag = magnitude();
    x /= mag;
    y /= mag;
  }

  Vector add(Vector v) {
    return new Vector(x+v.x, y+v.y);
  }
  
  void addVector(Vector v) {
    x += v.x;
    y += v.y;
  }

  Vector neg() {
    return new Vector(-x, -y);
  }
  
  void reverseDir() {
    x = -x;
    y = -y;
  }

  Vector sub(Vector v) {
    return add(v.neg());
  }
  
  void subVector(Vector v) {
    x -= v.x;
    y -= v.y;
  }

  Vector mul(float f) {
    return new Vector(x * f, y * f);
  }
  
  void multiply(float f) {
    x *= f;
    y *= f;
  }

  Vector div(float f) {
    return mul(1/f);
  }
  
  void divide(float f) {
    x /= f;
    y /= f;
  }
  
  String toString() {
    return ("(" + x + "," + y + ")");
  }
  
  float getAngle() {
    return atan2(y,x);
  }
  
  Vector rotate(float angle) {
    float r = magnitude();
    float curAngle = getAngle();
    return new Vector(r * cos(angle + curAngle), r * sin(angle + curAngle)); 
  }
};
