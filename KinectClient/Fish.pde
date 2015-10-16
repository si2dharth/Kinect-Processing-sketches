class Fish {
  float x, y;
  float velX, velY;
  int r, g, b;
  
  Fish(float X, float Y) {
    x = X;
    y = Y;
    r = g = b = 0;
  }
  
  void draw() {
    pushMatrix();
    float orientation = atan2(velY, velX);
    translate(x, y);
    rotate(orientation);
    fill(r,g,b);
    ellipse(0,0,4 * DRAW_SIZE,2 * DRAW_SIZE);
    //fill(128,128,128);
    triangle(-2 * DRAW_SIZE,-DRAW_SIZE,-DRAW_SIZE, 0,-2 * DRAW_SIZE, DRAW_SIZE);
    popMatrix();
  }
  
  void wander() {
    
  }
  
  void seek(float X, float Y) {
    float targetVx = X - x, targetVy = Y - y; 
    float velMag = sqrt(targetVx * targetVx + targetVy * targetVy);
    if (velMag > MAX_VELOCITY) {
      targetVx *= MAX_VELOCITY/velMag;
      targetVy *= MAX_VELOCITY/velMag;
    } 
    float accX = targetVx - velX, accY = targetVy - velY;
    float accMag = sqrt(accX*accX + accY*accY);
    if (accMag > MAX_ACCELERATION) {
      accX *= MAX_ACCELERATION / accMag;
      accY *= MAX_ACCELERATION / accMag;
    }
    velX += accX;
    velY += accY;
    x += velX;
    y += velY;
  }
  
  void flee(float x, float y) {
    
  }
}

float MAX_ACCELERATION = 2;
float MAX_VELOCITY = 20;
float DRAW_SIZE = 10;
