// White Mountain Green Mountain 
// Simulation code by David Hunter

// Thanks to Daniel Shiffman 
// for sharing so  much on forces 
// http://natureofcode.com

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

Kinect2 kinect2;


Mover[] movers = new Mover[500]; // array of how many particles you want to be moving
Attractor[] attractors; // grid to store forces
RainMap[] rainMapArr; // grid of tiles for storing rain on surface

int scl; // size of grid square
int cols; // number of columns in grid
int rows; // number of rows in grid

PVector wind; // vector of wind
float albedoTotal = 0;  // track albedo total of all grid squares
float albedoAverage = 0; // track average of albedo 


PImage img; // to load test images if needed

PGraphics dep; // store depth image
PGraphics cam; // store rgb image
PGraphics cal; // store depth image for selecting
PImage caf; // store depth image for selecting

float xup; // upscale x axis from grid based on kinect depth image size to render size
float yup; // upscale y axis from grid based on kinect depth image size to render size

float simWidth = 512.0; // define width of simulation as same as kinect depth image size
float simHeight = 424.0; // define height of simulation as same as kinect depth image size

// visibility toggles for different layers
Boolean showDepth = false;
Boolean showCam = false;
Boolean showAttractor = false;
Boolean showWind = false;
Boolean showRain = true;
Boolean showSelect = false;
Boolean selecting = false;

// store position and size of selection rectangle
int selX;
int selY;
int selW;
int selH;

// calibrate/tune depth to sense blocks and tabletop
depthTop = 40;
depthBot = 60;

void setup() {
  //fullScreen();
  size(1024, 848); // consider kinect image sizes and projection sizes
  // kinect 2 depth cam resolution: 512 x 424 -> 1024 x 848
  // kinect 2 rgb cam resolution: 1920 x 1080

  kinect2 = new Kinect2(this);
  //kinect2.initVideo();
  //kinect2.initIR();
  kinect2.initDepth(); // setup depth camera
  kinect2.initRegistered(); // setup video camera to match depth image
  
  kinect2.initDevice(); // start device
  
  // create graphic buffers to store kinect feeds
  dep = createGraphics((int)simWidth, (int)simHeight);
  cam = createGraphics((int)simWidth, (int)simHeight);
  cal = createGraphics((int)simWidth, (int)simHeight);

  // define variables
  selX = 0;
  selY = 0;
  selW = (int)simWidth;
  selH = (int)simHeight;
  
  // load a test image
  img = loadImage("blob2.png");

  // define grid
  scl = 20;
  cols = floor(simWidth/scl);
  rows = floor(simHeight/scl);
  attractors = new Attractor[cols*rows];
  rainMapArr = new RainMap[cols*rows];
  
  // define upscale
  xup = width/simWidth;
  yup = height/simHeight;

  // make grid of attractors and rain map
  for (int y=0; y<rows; y++) {
    for (int x=0; x<cols; x++) {
      int index = x + y * cols;
      attractors[index] = new Attractor(random(100), (x*scl)+scl/2.0, (y*scl)+scl/2.0); // random value is temporary, value is updated by kinect depth image
      rainMapArr[index] = new RainMap(0, (x*scl)+scl/2.0, (y*scl)+scl/2.0);
    }
  }

  // make movers
  for (int i = 0; i < movers.length; i++) {
    movers[i] = new Mover(random(5, 3.5), random(simWidth), random(simHeight), 1.0, 100); // first param good value also: new Mover(random(2, 3.5)
  }


  background(255);

  caf = loadImage("blob2.png"); // load an image so it isn't empty
  // draw something into buffer
  cal.beginDraw();
  cal.background(0);
  cal.endDraw();
}

void draw() {
  //frameRate(30);
  //println(frameRate);
  
  // draw faded background
  fill(0, 50);
  noStroke();
  rect(0, 0, width, height);
  
  // draw selected region to depth buffer
  dep.beginDraw();
  caf.copy(cal, selX, selY, selW, selH, 0, 0, dep.width, dep.height);
  dep.image(caf, 0, 0);
  dep.endDraw();
  
  // if you need to find the depth of any single pixel uncomment the below two lines
  //color ms = dep.get(mouseX/int(xup), mouseY/int(yup));
  //println("x:" + mouseX/int(xup) + " | y:" + mouseY/int(yup) + " | b: " + brightness(ms));

  // draw video image to buffer
  cam.beginDraw(); 
  cam.scale(-1, 1); //flip image, very important!
  cam.image(kinect2.getRegisteredImage(), -cam.width, 0);
  cam.endDraw();


  albedoTotal = 0; //reset albedo variable


  // update depth forces and color forces
  for (int y=0; y<rows; y++) {
    for (int x=0; x<cols; x++) {
      int index = x + y * cols;

      // depth = topography
      color dc = dep.get( x*scl, y*scl );
      float db = brightness(dc);
      // things that are too far away can appear as 0 
      // which means they are very close and can cause issues
      // set anything at 0 to 255 (far away)
      if (db == 0) {
        db = 255;
      }
      
      // important section for calibrating the depth
      // so the system is tuned to create forces where 
      // the blocks are and not the tabletop
      // calibrate to max/min range so excess numbers aren't produced
      db = max(db, depthBot); //40 works well
      db = min(db, depthTop); //60 works well
      float dv = map(db, depthTop, depthBot, 0, 100); // change the last value according to how much force you want each force point to have
      
      // get rid of extra forces below a certain threshold
      // can be useful if there are too many forces in play
      if (dv<0) {
        dv=0;
      }
      attractors[index].mass = dv; // set the mass of the attractor in this grid

      // color = albedo
      color cc = cam.get( x*scl, y*scl );
      float cb = brightness(cc); // get brightness
      albedoTotal += cb; // add all grid square together

    }
  }

  albedoAverage = albedoTotal/(cols*rows); // divide total to get average albedo


  float albd = map(albedoAverage, 0, 255, -20, 40); // map albedo to direction. South bias programmed in as map will likely never be filled in with white blocks.
  float angle = radians(albd+random(-2.5, 2.5)); // convert to radians and add a little random fluctuation to angle for more organic
  PVector v = PVector.fromAngle(angle); // store as a vector
  v.setMag(random(0.02, 2)); // set wind with random value to simulate gusting
  wind = v; // assign to wind


  if (showCam) {
    image(cam, 0, 0, width, height); // show video image
  }
  if (showDepth) {
    image(dep, 0, 0, width, height); // show depth image
  }
  
  // display rain map
  for (int i=0; i<rainMapArr.length; i++) {
    rainMapArr[i].update();
    if (showRain) {
      rainMapArr[i].display();
    }
  }


  // display attractors
  if (showAttractor) {
    for (int i=0; i<attractors.length; i++) {
      attractors[i].display();
    }
  }

  // run movers
  for (int i = 0; i < movers.length; i++) {

    movers[i].applyForce(wind);

    for (int j=0; j<attractors.length; j++) {
      PVector force = attractors[j].attract(movers[i]);
      movers[i].applyForce(force);
    }
    movers[i].checkEdges();
    movers[i].update();
    movers[i].display();
  }
  
  // display wind indicator
  if (showWind) {
    //
    PVector windDirection = v.copy(); // copy earlier v vector for wind direction from albedo
    // A vector that points to the center of the window
    PVector center = new PVector(0, 0);
    windDirection.sub(center); // Subtract center which results in a vector that points from center to v
    windDirection.normalize(); // Normalize the vector
    windDirection.mult(150); // Multiply its length by 150 (Scaling its length)
    pushMatrix();
    translate(width/2, height/2); // translate to centre of screen
    stroke(255);
    strokeWeight(4);
    line(0, 0, windDirection.x, windDirection.y);
    popMatrix();
  }

  // get depth image for selecting region of interest
  cal.beginDraw();
  cal.scale(-1, 1);
  cal.image(kinect2.getDepthImage(), -simWidth, 0);
  cal.endDraw();
  
  if (showSelect) {
    image(cal, 0, 0, width, height); // show whole depth image to select from
  }

  if (selecting) {
    fill(255, 255, 0, 50);
    rect(selX*xup, selY*yup, mouseX-selX*xup, mouseY-selY*yup); // draw rectangle 
  }
}




// toggle visible layers
void keyPressed() {
  if (key == 'd') {
    showDepth = !showDepth;
  }

  if (key == 'c') {
    showCam = !showCam;
  }

  if (key == 'f') {
    showAttractor = !showAttractor;
  }

  if (key == 'w') {
    showWind = !showWind;
  }
  if (key == 'r') {
    showRain = !showRain;
  }
  if (key == 's') {
    showSelect = !showSelect;
  }
}

// functions for drawing selection rectangle
void mousePressed() {
  if (showSelect) {
    selW = 0;
    selH = 0;

    selX = mouseX/int(xup);
    selY = mouseY/int(yup);

    selecting = true;
  }
}

void mouseReleased() {
  if (showSelect) {
    selW = mouseX/int(xup) - selX;
    selH = mouseY/int(yup) - selY;


    selecting = false;
  }
}
