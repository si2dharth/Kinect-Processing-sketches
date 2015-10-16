static ArrayList<BreadCrumb> breadcrumbList;

static float BREADCRUMB_LIFE = 5000.0;

class BreadCrumb {
  Vector position;
  float dir;
  int R, G, B;
  long creationTime;
  
  BreadCrumb(float x, float y, float orientation, int r, int g, int b) {
    if (breadcrumbList == null) 
      breadcrumbList = new ArrayList<BreadCrumb>();
    
    breadcrumbList.add(this);
    position = new Vector(x,y);
    dir = orientation;
    creationTime = millis();
    R = r;
    B = b;
    G = g;
  }
  
  void draw() {
    pushMatrix();
    float frac = 255*((millis() - creationTime)/BREADCRUMB_LIFE);
    fill (R + frac, G + frac, B + frac);
    translate(position.x, position.y);
    rotate(dir);
    ellipse(0,0, 10,5);
    popMatrix();
  }
};

void drawBreadcrumbs() {
  if (breadcrumbList == null) return;
  ArrayList<BreadCrumb> removeList = new ArrayList<BreadCrumb>();
  long time = millis();
  for  (BreadCrumb b : breadcrumbList) {
    b.draw();
    if (time - b.creationTime > BREADCRUMB_LIFE) removeList.add(b); 
  }
  for (BreadCrumb b : removeList) {
    breadcrumbList.remove(b);
  }
}
