import controlP5.*;
ControlP5 cp5;

XMLElement osm;

ArrayList nodes;
ArrayList ways;

float offsetlat;
float offsetlon;

float minlat;
float minlon;
float maxlat;
float maxlon;

float coordscale;

int offsetx;
int offsety;

int rounding;

void gui() {
  cp5 = new ControlP5(this);
  cp5.addSlider("offsetlat")
     .setPosition(20,50)
     .setRange(minlat,maxlat)
     .setValue(minlat)
     .setDecimalPrecision(7)
     ;
  cp5.addSlider("offsetlon")
     .setPosition(20,70)
     .setRange(minlon,maxlon)
     .setValue(minlon)
     .setDecimalPrecision(7)
     ;
  cp5.addSlider("coordscale")
     .setPosition(20,110)
     .setRange(0,200000)
     .setValue(100000)
     .setDecimalPrecision(7)
     ;
  cp5.addSlider("offsetx")
     .setPosition(20,130)
     .setRange(0,width)
     .setValue(400)
     ;
  cp5.addSlider("offsety")
     .setPosition(20,150)
     .setRange(0,height)
     .setValue(350)
     ;
  cp5.addSlider("rounding")
     .setPosition(20,200)
     .setRange(0,100)
     .setValue(0)
     ;
}

void setup() {
  size(1024, 768);
  smooth();
  
  osm = new XMLElement(this, "small.osm");
  XMLElement bounds = osm.getChild(0);
  minlat = bounds.getFloat("minlat");
  minlon = bounds.getFloat("minlon");
  maxlat = bounds.getFloat("maxlat");
  maxlon = bounds.getFloat("maxlon");
    
  nodes = new ArrayList();
  ways = new ArrayList();
  
  for (int i = 1; i < osm.getChildCount(); i++) {
    
    XMLElement child = osm.getChild(i);
    
    if(child.getName().equals("node")) {
      //println(child.getInt("id") + ": " + child.getFloat("lat") + ", " + child.getFloat("lon"));
      PVector n = new PVector(child.getFloat("lat"), child.getFloat("lon"));
      nodes.add(n);
    }
    
    if(child.getName().equals("way")) {
      boolean ishighway = false;
      
      for (int j = 0; j < child.getChildCount(); j++) {
        if(child.getChild(j).getName().equals("tag") && child.getChild(j).getString("k").equals("highway") ) {
          ishighway = true;
        }
      }
      
      if(ishighway) {
        ArrayList waypoints = new ArrayList();
        for (int j = 0; j < child.getChildCount(); j++) {
          
          if(child.getChild(j).getName().equals("nd")) {
            String id = child.getChild(j).getString("ref");
            for (int k = 0; k < osm.getChildCount(); k++) {
              XMLElement n = osm.getChild(k);
              if(n.getName().equals("node") && n.getString("id").equals(id)) {
                PVector waypoint = new PVector(n.getFloat("lat"), n.getFloat("lon"));
                waypoints.add(waypoint);
              }
            }
          }
        }
        ways.add(waypoints);
      }
    }
    
  }
  
  gui();
}

void draw() {
  background(0);
  stroke(255);
  
  println(r(50.7515109));
  
  for(int i = 0; i < nodes.size(); i++) {
    PVector n = (PVector) nodes.get(i);
    float x = (n.y-offsetlon)*coordscale+offsetx;
    float y = -1 * (n.x-offsetlat)*coordscale+offsety;
    point(r(x), r(y));
  }
  
  stroke(255,0,0);
 
  for(int i = 0; i < ways.size(); i++) {
    ArrayList waypoints = (ArrayList) ways.get(i);
    for (int j = 1; j < waypoints.size(); j++) {
      PVector start = (PVector) waypoints.get(j-1);
      PVector end = (PVector) waypoints.get(j);
      float starty = -1 * (start.x - offsetlat) * coordscale + offsety;
      float startx = (start.y - offsetlon) * coordscale + offsetx;
      float endy = -1 * (end.x - offsetlat) * coordscale + offsety;
      float endx = (end.y - offsetlon) * coordscale + offsetx;
      line(r(startx), r(starty), r(endx), r(endy));
    }
  } 
}

float r(float n) {
  if(rounding > 0) {
    return round(n / rounding) * rounding;
  } else {
    return n;
  }
}
