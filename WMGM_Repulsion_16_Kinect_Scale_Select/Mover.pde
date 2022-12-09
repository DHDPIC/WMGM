// White Mountain Green Mountain 
// Simulation code by David Hunter

// Thanks to Daniel Shiffman 
// for sharing so  much on forces 
// http://natureofcode.com

class Mover {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  // rain
  float rainStore;
  float rainThreshold;
  boolean isRaining;
  // track where in array
  int currIndex;

  Mover(float m, float x, float y, float rs, float rt) {
    mass = m;
    position = new PVector(x, y);
    velocity = new PVector(0,0);
    acceleration = new PVector(0, 0);
    //
    rainStore = rs;
    rainThreshold = rt;
    isRaining = false;
    //
    currIndex = 0;
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit( 3.0 );
    position.add(velocity);
    acceleration.mult(0);
    
    // update rain threshold
    float x = position.x;
    float y = position.y;
    int index = floor(x)/scl + floor(y)/scl * cols;
    index = min(index, attractors.length-1);
    currIndex = index;
    Attractor a = attractors[index];
    float h = a.mass;
    rainThreshold = map(h,0,80, 200,50);
    
    // decide to rain
    rainStore += random(-0.1,2);
    if(rainStore > rainThreshold && isRaining == false) {
      isRaining = true;
    } else if(rainStore <=0) {
      isRaining = false;
    }
    
    
    
  }

  void display() {
    /*// uncomment below if you want to check that no particles exceed the max velocity
    if(velocity.x > 3 || velocity.x < -3) {
      stroke(255,0,0);
    } else {
      stroke(#ffa6bb);
    }*/
    noStroke();
    fill(#ffa6bb);
    ellipse(position.x*xup, position.y*yup, 5, 5);
   
    // check if it is raining and if so, generate rain drops
    if(isRaining) {
      stroke(#8DDEFF);
      strokeWeight(3);
      for(int i=0; i<3; i+=1) {
        rainStore-=1;
        point(position.x*xup+random(-10,10), position.y*yup+random(-10,10));
      }
      // update rain map
      int index = floor(position.x)/scl + floor(position.y)/scl * cols;
      if(index < rainMapArr.length) {
        int ci = max(0,currIndex-1);
        rainMapArr[ci].addRain(2);
      }
    }
    
  }
  
  void checkEdges() {

    if (position.x*xup >= width) {
      position = new PVector(0, random(simHeight));
      velocity.mult(0);
      rainStore = 0;
      isRaining = false;
      
    } else if (position.x*xup < 0) {
      position = new PVector(0, random(simHeight));
      velocity.mult(0);
      rainStore = 0;
      isRaining = false;
    }

    if (position.y*yup >= height) {
      position = new PVector(0, random(simHeight));
      velocity.mult(0);
      rainStore = 0;
      isRaining = false;
      
    } else if (position.y*yup < 0) {
      position = new PVector(0, random(simHeight));
      velocity.mult(0);
      rainStore = 0;
      isRaining = false;
    }

  }
  
}
