class Player {
  Vector pos = new Vector();
  boolean open = true;
  boolean activated = false;
  
  void draw() {
    if (!activated) fill(60); else if (open) fill(255,0,0); else fill(0,255,0);
    pushMatrix();
    //println("Pos : " + pos.x + ","+pos.y);
    translate(pos.x,pos.y);
    if (open) ellipse(0,0,20,20); else ellipse(0,0,10,10);
    popMatrix();
  }
}
