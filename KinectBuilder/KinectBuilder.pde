import processing.net.*;
String ip = "10.139.59.61";
final float block_height = 0.4;
final float block_width = 0.5;
Client myClient;

RectPiece rects[];

PVector leftHandPos = null, rightHandPos = null;
boolean leftClosed = false, rightClosed = false;

int uncompress(String s) {
  return int(s.charAt(0)) * 255 + int(s.charAt(1));
}

PVector uncompressVector(String s) {
  PVector res = new PVector(uncompress(s.substring(0,2)), uncompress(s.substring(2,4)));
  //println(res.toString());
  return res;
}

void setup() {
  size(displayWidth, displayHeight);
  background(255);
  myClient = new Client(this, ip, 8000);
  myClient.write("Width|" + width + "|Height|" + height + "|HandLeft|HandRight|LeftState|RightState|Output|0|Bodies|1");
  
  rects = new RectPiece[2];
  for (int i = 0 ; i < rects.length; i++) {
    rects[i] = new RectPiece();
    rects[i].position.set(width - block_width*width/2, height - i*block_height*height);
    rects[i].size.set(block_width*width - 1,block_height*height - 1);
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
  
  for (int i = 0 ; i < rects.length; i++)
  rects[i].draw();
  
  if (leftHandPos != null) {
  pushMatrix();
  if (leftClosed) fill(255,0,0); else fill(60);
  translate(leftHandPos.x, leftHandPos.y);
  ellipse(0,0,20,20);
  popMatrix();
  }
  
  if (rightHandPos != null) {
  pushMatrix();
  if (rightClosed) fill(255,0,0); else fill(60);
  translate(rightHandPos.x, rightHandPos.y);
  ellipse(0,0,20,20);
  popMatrix(); 
  }
  Vector lh = null, rh = null;
  if (leftClosed) lh = new Vector(leftHandPos.x, leftHandPos.y);
  if (rightClosed) rh = new Vector(rightHandPos.x, rightHandPos.y);
  
  for (int i = 0; i < rects.length; i++) {
    rects[i].setHandPositions(lh, rh);
  }
}
