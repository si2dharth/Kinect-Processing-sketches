class RectPiece {
  Vector position, size;
  float orientation;
  Vector handle1, handle2;
  
  RectPiece() {
    position = new Vector();
    size = new Vector();
    orientation = 0;
    handle1 = null;
    handle2 = null;
  }
  
  boolean checkHandle(Vector hand) {
    if (hand == null) return false;
    Vector handle = hand.rotate(-orientation);
    if (handle.x < -size.x/2) return false;
    if (handle.x > size.x/2) return false;
    if (handle.y < -size.y/2) return false;
    if (handle.y > size.y/2) return false;
    return true;
  }
  
  void setLeftHandle(Vector handle) {
    handle1 = handle;//.rotate(orientation);
  }
  
  void setRightHandle(Vector handle) {
    handle2 = handle;//.rotate(orientation);
  }
  
  void setHandPositions(Vector LeftPosition, Vector RightPosition) {
    Vector leftPosition = null;
    if (LeftPosition != null) leftPosition = LeftPosition.sub(position);
    Vector rightPosition = null;
    if (RightPosition != null) rightPosition = RightPosition.sub(position);
    
    if (handle1 == null) if (checkHandle(leftPosition)) setLeftHandle(leftPosition); else handle1 = null;
    if (handle2 == null) if (checkHandle(rightPosition)) setRightHandle(rightPosition); else handle2 = null;
    if (leftPosition == null) handle1 = null;
    if (rightPosition == null) handle2 = null;
    
    Vector move = null;
    float resize = 1, rotate = 0;

    if (handle1 == null && handle2 == null) return;
    else if (handle1 != null && handle2 == null) {
      move = leftPosition.sub(handle1);
      //println("Left : " + move.toString());
    }
    else if (handle1 == null && handle2 != null) {
      move = rightPosition.sub(handle2);
      //println("Right : " + move.toString());
    }
    else {
      
      resize = (leftPosition.sub(rightPosition).magnitude())/(handle1.sub(handle2).magnitude());
      rotate = atan2(rightPosition.y - leftPosition.y, rightPosition.x - leftPosition.x) - atan2(handle2.y - handle1.y, handle2.x - handle1.x); 
      //handle1 = leftPosition;
      //handle2 = rightPosition;
      handle1.multiply(resize);
      handle2.multiply(resize);
      handle1 = handle1.rotate(rotate);
      handle2 = handle2.rotate(rotate);
    /*
      float phi = atan2(handle1.y, handle1.x);
      float r = handle1.magnitude();
      handle1.x += r * (cos(-phi) + cos(rotate + phi));
      handle1.y += r * (sin(-phi) + sin(rotate + phi));
      
      phi = atan2(handle2.y, handle2.x);
      r = handle2.magnitude();
      handle2.x += r * (cos(-phi) + cos(rotate + phi));
      handle2.y += r * (sin(-phi) + sin(rotate + phi));
    */  
      Vector oldCenter = handle1.add(handle2).div(2);
      Vector newCenter = leftPosition.add(rightPosition).div(2);
      move = newCenter.sub(oldCenter);
      size.multiply(resize);
      //position.subVector(oldCenter);
      orientation += rotate;
    }
    
    if (move != null) position.addVector(move);
    
    
  }
  
  void draw() {
    fill(0);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    pushMatrix();
    rotate(orientation);
    rect(-size.x/2, -size.y/2, size.x, size.y);
    popMatrix();
    fill(0,255,0);
    if (handle1 != null) ellipse(handle1.x, handle1.y, 50, 50);
    fill(0,0,255);
    if (handle2 != null) ellipse(handle2.x, handle2.y, 50, 50);
    popMatrix();
  }
  
}
