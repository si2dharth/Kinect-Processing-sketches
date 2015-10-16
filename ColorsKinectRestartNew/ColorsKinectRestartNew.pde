/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/146380*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */

import processing.net.*;
Client myClient;
String ip = "10.139.58.163";
char dataIn;
String data;

//ball configurations
int numBalls = 500;//500
float startingVelocity = 5.0;//5.0
float minSize = 5;//3
float maxSize = 12;//10
float attraction = 3;//3
float nonTrackVelocity = 0.4;
float nonTrackSize = 4;

PVector targets[];
boolean followTargets[];


final int msgLength = 32;

String prevReceivedData = "";
int nThrown = 0;

String receive() {
  int nChars = 0;
  String receivedData = "";
  while (myClient.available() > 0) {
    receivedData += (char)myClient.read();
    //receivedData = myClient.readString();
  }
  //print("Recieved : " + receivedData); 
  String fullMsg = prevReceivedData + receivedData; 
  int nMsgs = fullMsg.length() / msgLength;
  if (nMsgs == 0) {
    prevReceivedData = receivedData;
    return "";
  }
  nThrown += nMsgs - 1;
  String lastData = fullMsg.substring((nMsgs-1)*msgLength,nMsgs*msgLength);
  prevReceivedData = fullMsg.substring(nMsgs*msgLength);  
  
  return lastData;
}


void collectData() {
  String reply = receive();
  if (reply == "") return;
 
  //println("Received : " + reply.length() + " : " + reply);
  //println("Thrown : " + nThrown);
  //JHxxyyzzJHxxyyzzJHxxyyzzJHxxyyzz
 
  for (int i = 0; i < reply.length(); i += 8) {
    if (reply.charAt(i) == 'N') {
      followTargets[i/8] = false;
      continue;
    } else {
      followTargets[i/8] = (reply.charAt(i + 1) == 'C') ;
      targets[i/8] = new PVector();
      targets[i/8].x = (((int(reply.charAt(i+2)) << 8) + int(reply.charAt(i+3))) * width) >> 16;
      targets[i/8].y = height - (((int(reply.charAt(i+4)) << 8) + int(reply.charAt(i+5))) / 65535.0 * height);
      if (reply.charAt(i + 1) == 'C') println(reply.substring(i,i+8) + "->" + targets[i/8].x + " , " + targets[i/8].y);
    }
  }
}

//other configurations
boolean tracking = true;
boolean trails = true;
boolean displayCam = false;

Ball[] balls = new Ball[numBalls];
PVector p = new PVector(0, 0, 0);
PFont font;

void setup() {
  size(displayWidth, displayHeight, JAVA2D);
  /*minSize = height/60;
  maxSize = height/40;
  nonTrackSize = minSize / 4;*/
  data = "";
  myClient = new Client(this, ip, 10005);
  myClient.write("get|1|HandRight|1|HandLeft|2|HandRight|2|HandLeft");
  //myClient.write("Bodies|6|Width|" + width + "|Height|" + height + "|HandRight|HandLeft|RightState|LeftState|Output|2");
  background (204, 204, 255, 1);

  targets = new PVector[12];
  followTargets = new boolean[12];
  for (int i = 0; i < 12; i++) {
    targets[i] = null;
    followTargets[i] = false;
  }

  //loading font
  PFont font;
  font = loadFont("Arial-BoldItalicMT-48.vlw");// loadFont("AdobeArabic-BoldItalic-48.vlw");
  textFont(font);


  for (int i = 0; i < balls.length; i++)
    balls[i] = new Ball(random(displayWidth), random(displayHeight), random(-startingVelocity, startingVelocity), random(-startingVelocity, startingVelocity), random(minSize, maxSize), random(255), random(255), random(255), random(attraction));
}

void draw() {
  //re/adStream();
  collectData();
  fill(0);
  text("Art Through Motion", 50, 50);

  if (trails) {
    //
   // fill(204, 204, 255, 2);
    //rect(0, 0, width, height);
  } else {
    background(204, 204, 255, 1);
  }

  for (int i = 0; i < balls.length; i++) {
    //  for(int i = 0; i < 1; i++) {
    balls[i].update();
    balls[i].display();
  }
}




class Ball {
  PVector position;
  PVector velocity;
  PVector Bcolor;
  float size;
  float attract;

  Ball(float x, float y, float xv, float yv, float s, float r, float g, float b, float a) {
    position = new PVector(x, y);
    velocity = new PVector(xv, yv);
    Bcolor = new PVector(r, g, b);
    size = s;
    println(size);
    attract = a;
  }

  void update() {
    //   println("p : " + p);
    position.x += velocity.x;
    position.y += velocity.y;
    velocity.x /= 1.05;
    velocity.y /= 1.05;


    PVector p = null;
    float dist = 0;
    for (int i = 0; i < targets.length; i++) {
      if (followTargets[i]) {
        if (p == null || targets[i].dist(position) < dist) {
          p = targets[i];
          dist = targets[i].dist(position);
        }
      }
    }


    // if(p != null){
    if (p != null) {
      //println(p);
      velocity.x += (p.x-position.x)*0.00001*attract*dist(position.x, position.y, p.x, p.y);
      velocity.y += (p.y-position.y)*0.00003*attract*dist(position.x, position.y, p.x, p.y);
    } else {
      velocity.x += random(-nonTrackVelocity, nonTrackVelocity);
      velocity.y += random(-nonTrackVelocity, nonTrackVelocity);
      Bcolor.x=Bcolor.x+random(-3, 3);
      Bcolor.y=Bcolor.y+random(-3, 3);
      Bcolor.z=Bcolor.z+random(-3, 3);
      size=size+random(-nonTrackSize, nonTrackSize);
      if (size>maxSize || size<minSize) {
        size=(maxSize + minSize)/2;
      }
    }
  }

  void display() {
    noStroke();
    fill (Bcolor.x, Bcolor.y, Bcolor.z);
    ellipse(position.x, position.y, size, size);
  }
}  

