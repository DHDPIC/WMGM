// White Mountain Green Mountain 
// Simulation code by David Hunter

// Thanks to Daniel Shiffman 
// for sharing so  much on forces 
// http://natureofcode.com


class Attractor {
  float mass;    // Mass, tied to size
  float G;       // Gravitational Constant
  PVector position;   // position
  int strengthDivider;

  Attractor(float m, float x, float y) {
    position = new PVector(x,y);
    mass = m;//1;
    G = 1.5;
    strengthDivider = 6;
  }

  PVector attract(Mover m) {
    PVector force = PVector.sub(position,m.position);  // Calculate direction of force
    float d = force.mag();                             // Distance between objects
    d = constrain(d*1.0,20.0,300.0);//d,5,25 //d,1,30  // Limiting the distance to eliminate "extreme" results for very close or very far objects
    force.normalize();                                 // Normalize vector (distance doesn't matter here, we just want this vector for direction)
    float strength = (G * mass * m.mass) / (d * d);    // Calculate gravitional force magnitude
    force.mult(strength/strengthDivider);              // Get force vector --> magnitude * direction
    force.mult(-1); // make it a repulsor, very important
    return force;
  }

  // Method to display force
  void display() {
    ellipseMode(CENTER);
    stroke(153);
    noFill();
    strokeWeight(2);
    ellipse(position.x*xup,position.y*yup,mass/strengthDivider,mass/strengthDivider);
  }
  
}
