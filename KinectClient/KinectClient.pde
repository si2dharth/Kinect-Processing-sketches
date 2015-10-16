import processing.net.*;
String ip = "127.0.0.1";
Client myClient;
char dataIn;
String data;
Boid boids[];
Player left,right;
DataParser dp;

PVector leftHandPos = new PVector(0,0), rightHandPos = new PVector();
boolean leftClosed = false, rightClosed = false;

int uncompress(String s) {
  return int(s.charAt(0)) * 255 + int(s.charAt(1));
}

PVector uncompressVector(String s) {
  PVector res = new PVector(uncompress(s.substring(0,2)), uncompress(s.substring(2,4)));
  //println(res.toString());
  return res;
}

void setup() { //<>//
  size(displayWidth, displayHeight);
  dp = new DataParser();
  background(255);
  data = "";
  
  myClient = new Client(this,ip,8000);
  myClient.write("Width|"+width+"|Height|" + height + "|HandLeft|HandRight|LeftState|RightState|Output|0|Bodies|1");
  
  left = new Player();
  right = new Player();
  
  boids=  new Boid[50];
  for (int i  = 0 ; i < boids.length; i++) {
    boids[i] = new Boid();
    boids[i].size = width/200;
    boids[i].position.set(random(width), random(height));
  }
}




String readBytes(int nBytes) {
  String data = "";
  for (int i = 0; i < nBytes; i++) {
    while (myClient.available() <= 0) ;
    data += (char) myClient.read();
    
  }
  return data;
}

void readCompressedData() {
  while (myClient.available() > 0) {
    
    String bodyStr = readBytes(1);
    if (bodyStr.equals("\n")) break;

    String Joint = readBytes(2);
    if (Joint.equals("07")) leftHandPos = uncompressVector(readBytes(4));
    if (Joint.equals("11")) rightHandPos = uncompressVector(readBytes(4));
    if (Joint.equals("HL")) leftClosed = (readBytes(1).equals("C"));
    if (Joint.equals("HR")) rightClosed = (readBytes(1).equals("C"));
  }
}




void draw() {
  background(255);
  
  readCompressedData();
  left.pos.set(leftHandPos.x, leftHandPos.y);
  right.pos.set(rightHandPos.x, rightHandPos.y);
  left.open = !leftClosed;
  right.open = !rightClosed;
  if (!left.open) left.activated = true;
  if (!right.open) right.activated = true;
  
  Vector centroid = new Vector();
  for (int i = 0 ; i < boids.length; i++) {
    boids[i].update();
    centroid.addVector(boids[i].position);
  }
  centroid.divide(boids.length);
  for (int i = 0 ; i < boids.length; i++) {
    boids[i].update();
    
    boids[i].startNewAvoidCalc();
    for (int j = 0 ; j < boids.length; j++) {
      if (i == j) continue;
      boids[i].avoid(boids[j]);
    }
    
    Vector seekAcc;
    Vector leftDist = new Vector(0,0), rightDist = new Vector(0,0);
    if (left.activated) leftDist = boids[i].position.sub(left.pos);
    if (right.activated) rightDist = boids[i].position.sub(right.pos);
    
    if (!left.open && !right.open) {
      if (leftDist.magnitude() < rightDist.magnitude()) {
        seekAcc = boids[i].seek(left.pos);
      } else {
        seekAcc = boids[i].seek(right.pos);
      }
    } else if (!left.open) {
      seekAcc = boids[i].seek(left.pos);
    } else if (!right.open) {
      seekAcc = boids[i].seek(right.pos);
    } else seekAcc = boids[i].wander();
    
    boids[i].applyAcceleration(seekAcc.add(boids[i].avoidAcc));
    boids[i].draw();
    left.draw();
    right.draw();
  }  
}
