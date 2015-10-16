//Boid

final int ARRIVAL_DECELERATE = 0;
final int ARRIVAL_STOP = 1;
final int ARRIVAL_HARD_BRAKE = 2;      //RADIUS_OF_DECELERATION CALCULATED

final int ALIGN_NONE = 0;
final int ALIGN_SMOOTH = 1;

int BOID_ARRIVE_METHOD = ARRIVAL_DECELERATE;
int BOID_ALIGN_METHOD = ALIGN_SMOOTH;

class Boid {
  public Boid() {
    size = 25;
    r = g = b = 0;
    position = new Vector();
    velocity = new Vector();
    acceleration = new Vector();
    orientation = 0;
    rotation = 0;
    angular = 0;
    lastUpdateTime = millis();
    lastBreadcrumbTime = millis();
  }
  
  public float align() {
    if (BOID_ALIGN_METHOD == ALIGN_NONE) {
       orientation = atan2(velocity.y, velocity.x);
       return 0;
    } else {
      float angle = atan2(velocity.y, velocity.x);
      float difference = angle - orientation;
      float absDiff;
      float absTargetRotation = 0, targetRotation = 0;  
      
      while (difference >= PI) difference -= 2*PI;
      while (difference < -PI) difference += 2*PI;
     
       absDiff = abs(difference);
       
       if (absDiff < ANGLE_OF_SATISFACTION) return 0; 
      
      if (absDiff > ANGLE_OF_DECELERATION)
        absTargetRotation =  maxRotationSpeed;
       else
         absTargetRotation = maxRotationSpeed * (absDiff - ANGLE_OF_SATISFACTION)/(ANGLE_OF_DECELERATION - ANGLE_OF_SATISFACTION);
      
      targetRotation = absTargetRotation * difference / absDiff;
       
       float ang = targetRotation - rotation;
       //println(difference);
      if (abs(ang) > maxAngular) ang = ang / abs(ang) * maxAngular;
      
      return ang;
    }
  }
  
  public Vector seek(Vector seekLocation) {
    Vector direction = seekLocation.sub(position);
    float distance = direction.magnitude();
    float goalSpeed = 0;
    Vector goalVelocity = new Vector();
    
    if (BOID_ARRIVE_METHOD == ARRIVAL_DECELERATE) {
      if (distance < RADIUS_OF_SATISFACTION) { return new Vector(); }
      if (distance > RADIUS_OF_DECELERATION) 
        goalSpeed = maxSpeed;
      else
        goalSpeed = maxSpeed * (distance - RADIUS_OF_SATISFACTION) / (RADIUS_OF_DECELERATION - RADIUS_OF_SATISFACTION); 
     } else if (BOID_ARRIVE_METHOD == ARRIVAL_STOP) {
       if (distance < RADIUS_OF_SATISFACTION) {  
         velocity.set(0,0);  
         return new Vector();
       } else goalSpeed = maxSpeed;
     } else if (BOID_ARRIVE_METHOD == ARRIVAL_HARD_BRAKE) {
       if (distance < RADIUS_OF_SATISFACTION) { 
         return new Vector();
       } else if (distance < maxSpeed * maxSpeed/2/maxAcceleration + 10)
         goalSpeed = 0;
       else
         goalSpeed = maxSpeed;
     }
    goalVelocity.set(direction);
    goalVelocity.normalize();
    goalVelocity.multiply(goalSpeed);
    
    Vector acc = goalVelocity.sub(velocity);
    acc.divide(TIME_TO_TARGET_VELOCITY);
    return acc;
  }
  
  public Vector flee(Vector fleeLocation) {
    return seek(fleeLocation).neg();
  }
  
  public Vector matchVelocity(Vector targetVelocity) {
    Vector goalVel = targetVelocity;
    if (goalVel.magnitude() > maxSpeed) {
      goalVel.normalize();
      goalVel.multiply(maxSpeed);
    }
    Vector reqAcc = goalVel.sub(velocity);
    reqAcc.divide(TIME_TO_TARGET_VELOCITY);
   /*
    if (reqAcc.magnitude() > maxAcceleration) {
      reqAcc.normalize();
      reqAcc.multiply(maxAcceleration);
    }
    */
    return reqAcc;
  }
  
  private long lastTime;
  private float directionAngle;
  Vector wanderLocation;
  public Vector wander() {
    if (wanderLocation != null) if (millis() - lastTime < 350) return seek(wanderLocation);
    lastTime = millis();
    //Take a point at some distance from boyd in some direction. Form a circle. Get a random point on the circle
    directionAngle = orientation;
    Vector circleCenter = new Vector();
    int count = 0;
    while (count++ < 10 && (circleCenter.x <= 0 || circleCenter.x >= width || circleCenter.y <= 0 || circleCenter.y >= height)) {
      directionAngle += random(-PI/4,PI/4); 
      circleCenter.set(position.x + WANDER_CIRCLE_DISTANCE * cos(directionAngle), position.y + WANDER_CIRCLE_DISTANCE * sin(directionAngle));    
    }
    if (count >= 10) {
      directionAngle = PI/2 + atan2(position.y - height/2, position.x - width/2);
      circleCenter.set(position.x + WANDER_CIRCLE_DISTANCE * cos(directionAngle), position.y + WANDER_CIRCLE_DISTANCE * sin(directionAngle));
    }
  float angle = random(0,2*PI);
  wanderLocation = new Vector((circleCenter.x + WANDER_CIRCLE_RADIUS/2 * cos(angle)), (int)(circleCenter.y + WANDER_CIRCLE_RADIUS/2 * sin(angle)));
  return seek(wanderLocation);
  }
  
  float lowestTime = -1;
  Vector avoidAcc;
  
  public void startNewAvoidCalc() {
    lowestTime = -1;
    avoidAcc = new Vector();
  }
  
  public Vector avoid(Boid b) {
      Vector dp = position.sub(b.position);
      Vector dv = velocity.sub(b.velocity);
      if (dv.magnitude() == 0) return avoidAcc;
      Vector pC, pT;
      float t = -dp.dot(dv) / (dv.magnitude() * dv.magnitude());
      
    if ((t > lowestTime && lowestTime > 0) || t < 0)
      return avoidAcc;
    else {
      pC = position.add(velocity.mul(t));
      pT = b.position.add(b.velocity.mul(t));
    }
     
     //println(pC.sub(pT).magnitude());
    if (pC.sub(pT).magnitude() > b.size / 2 + size/2 + PADDING) return avoidAcc;  
       Vector relPos = dv.mul(t).add(dp);
       /* relPos.normalize();
        relPos.multiply(maxAcceleration);*/
        avoidAcc = relPos;
        lowestTime = t;
        return avoidAcc;        
  }
  
  public void draw() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(orientation);
    fill(r,g,b);
    noStroke();
    ellipse(0,0,size,size);
    triangle(sqrt(size), -size/2 + 1, sqrt(size), size/2 - 1 , size, 0);
    popMatrix();
  }  
  
  public void update() {
    long currentTime = millis();
    float mulFactor = (currentTime - lastUpdateTime)/TIME_FACTOR;
    if (velocity.magnitude() > 0) angular = align(); else angular = rotation = 0;
    position.addVector(velocity.mul(mulFactor));
    velocity.addVector(acceleration.mul(mulFactor));
    orientation += rotation * mulFactor;
    rotation += angular * mulFactor;
    
    lastUpdateTime = currentTime;
    if (leaveBreadcrumbs)
    if (velocity.magnitude() > 0) {
      if (currentTime - lastBreadcrumbTime > BREADCRUMB_ADD_TIME) {
        new BreadCrumb(position.x, position.y, orientation, r, g, b);
        lastBreadcrumbTime = currentTime;
      }
    }
  }
  
  public void setColor(int R, int G, int B) {
    r = R;
    g = G;
    b = B;
  }
  
  public void applyAcceleration(Vector value) {
    acceleration = value;
    if (acceleration.magnitude() > maxAcceleration) {
    acceleration.normalize();
    acceleration.multiply(maxAcceleration);
    }
  }
  
  public void applyAngular(float value) {
    angular = value;
  }
  
  private Vector position, velocity, acceleration;
  private float orientation, rotation, angular;
  
  public float size;
 
  private int r,g,b; 
  private long lastUpdateTime;
  private long lastBreadcrumbTime;
  
  private final float TIME_FACTOR = 10.0;
  private final long BREADCRUMB_ADD_TIME = 100;
  
  private final float RADIUS_OF_SATISFACTION = 10;
  private final float RADIUS_OF_DECELERATION = 400;
  private final int TIME_TO_TARGET_VELOCITY = 10;
  
  private final int WANDER_CIRCLE_RADIUS = 100;
  private final int WANDER_CIRCLE_DISTANCE = 200;
  
  private final float ANGLE_OF_SATISFACTION = 0.01;
  private final float ANGLE_OF_DECELERATION = 0.2;
  
  private final int PADDING = 3;
  
  public float maxRotationSpeed = 0.05, maxAngular = 0.01, maxAcceleration = 0.2, maxSpeed = 10;
  public boolean leaveBreadcrumbs = true;
};
