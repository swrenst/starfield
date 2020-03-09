import oscP5.*;

//OSC receive
OscP5 oscP5;
OscP5 oscP5Send;

ArrayList<Star> stars = new ArrayList<Star>();
float speed = 7.0;
float speedMax = 25;
float speedMin = 1.0;
float freqMin = 0.0005;
float freqMax = 0.008;
float rotateFactor = 0.0;
int tailFactor = 1;

color[][] colorPalettes = {
  {#600b4c, #941153, #ba6c63, #f0915d, #f9c17b},
  {#d77fa1,#e6b2c6, #fef6fb, #d6e5fa, #f6c3e5},
  {#93B5C6, #DDEDAA, #F0CF65, #D7816A, #BD4F6C},
  {#2E294E, #EFBCD5, #BE97C6, #8661C1, #4B5267},
  {#48639C,#4C4C9D,#712F79,#976391,#F7996E}
};
int colorPicker = 0;

// The color palette can be changed by pressing the enter key
// This is intentionally not a very discoverable feature because
//   of the way it interacts with longer star tails
// Best if changed when mouse is in top left corner
void keyPressed(){
  if(key == RETURN || key == ENTER){
    if(colorPicker < 4) colorPicker += 1;
    else colorPicker = 0;
    
    print("colorPicker: ", colorPicker, " ", colorPalettes[colorPicker][0], "\n");
  }
}

void setup() {
  fullScreen();
  background(0);
  noStroke();
  for (int i = 0; i < 500; i++) {
    stars.add(new Star());   
    stars.get(i).setColorIndex(i % 5);
  }
  
  oscP5 = new OscP5(this, 12005);
  oscP5Send = new OscP5(this, 12006);
  
  sendToMax();
}

// Got the physics logic from this open processing sketch:
// https://www.openprocessing.org/sketch/398285
void draw() {
  
  // Make the stars leave more or less of a trail 
  // based on the mouseY position
  fill(0, 50);
  //int tailFactor = int(map(mouseY, 0, height, 1, 300));
  if(frameCount % tailFactor == 0){
    rect(0, 0, width, height);
  }
  
  translate(width / 2, height / 2);
  
  // Make the starfield rotate more or less based on
  // the mouseX position
  //float rotateFactor = map(mouseX, 0, width, freqMin, freqMax);
  rotate(frameCount * rotateFactor);
  
  // Draw each star and update the star by calling 
  // its member function
  for (int i = 0; i < stars.size(); i++) {
    stars.get(i).show();
    stars.get(i).update();
  }
  
  sendToMax();
}

void sendToMax(){
  OscMessage myMessage = new OscMessage("/test");
  
  // sends the mouseX and width to Max to altert the filter cutoff
  myMessage.add(float(mouseX));
  myMessage.add(float(width));
  
  /* send the message */
  oscP5Send.send(myMessage, "127.0.0.1", 12006);
}

class Star {
  int colIndex = 0;
  float z = random(width);
  float y = random(-width / 2, width / 2);
  float x = random(-width / 2, width / 2);
  
  void setColorIndex(int index){
    colIndex = index;
  }

  void update() {
    z = z - speed;
    if (z < 1) {
      z = width;
      x = random(-width / 2, width / 2);
      y = random(-width / 2, width / 2);
    }
  }

  void show() {
    float sx = map(x / z, 0, 1, 0, width);
    float sy = map(y / z, 0, 1, 0, width);
    float r = map(z, 0, width, 16, 0);
    fill(colorPalettes[colorPicker][colIndex]);
    ellipse(sx, sy, r, r);
  }
}

void oscEvent(OscMessage theOscMessage) {
  
  // recieves a value for the speed from MAX based
  // on the note being played (slow = low)
  
  if (theOscMessage.checkAddrPattern("/speed")) {
    
    float value = theOscMessage.get(0).floatValue();
    speed = map(value, 36.0, 96.0, speedMin, speedMax);
    //rotateFactor = map(value, 36.0, 96.0, freqMin, freqMax);
    
    print(value, "\n");
    print(rotateFactor, "\n");
  }
  
  //else if (theOscMessage.checkAddrPattern("/pw")) {
  //  float value = theOscMessage.get(0).floatValue();
  //  print(value, "\n");
    
  //  tailFactor = int(map(value, 0.0, 127.0, 1, 300));

  //}
  
  else if (theOscMessage.checkAddrPattern("/pinch")) {
    float value = theOscMessage.get(0).floatValue();
    print(value, " pinch \n");
    
    tailFactor = int(map(value, 0.0, 1.0, 1, 300));

  }
  
  else if (theOscMessage.checkAddrPattern("/leftX")) {
    float value = theOscMessage.get(0).floatValue();
    print(value, " x \n");
    
    rotateFactor = map(value, -300.0, 300.0, freqMin, freqMax);
  }
  
  else if (theOscMessage.checkAddrPattern("/y")) {
    float value = theOscMessage.get(0).floatValue();
    print(value, " pinch \n");
    
    //tailFactor = int(map(value, 0.0, 1.0, 1, 300));

  }
  
  else if (theOscMessage.checkAddrPattern("/z")) {
    float value = theOscMessage.get(0).floatValue();
    print(value, " pinch \n");
    
    //tailFactor = int(map(value, 0.0, 1.0, 1, 300));

  }
  

}
