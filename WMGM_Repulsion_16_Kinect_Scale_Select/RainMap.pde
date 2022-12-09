class RainMap {
  float rainStore; // how much rain has fallen on this square
  float x; // position of square
  float y; // position of square

  RainMap(float rs, float px, float py) {
    rainStore = rs;
    x = px;
    y = py;
  }
  
  void update() {
    if(rainStore >1) {
      rainStore *= 0.975; // reduced rainstore a small amount each time by evaporation
    } else {
      rainStore = 0;
    }
    
  }


  // Method to display
  void display() {
    ellipseMode(CENTER);
    
    fill(#2f4157,100);
    noStroke();
    float s = min(rainStore, scl)*2;
    ellipse(x*xup,y*yup,s,s);
    
  }
  
  void addRain(float n) {
    rainStore += n;
  }
  
}
