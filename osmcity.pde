import controlP5.*;
ControlP5 cp5;

XMLElement osm;

ArrayList nodes;
ArrayList ways;

int offsetlat;
int offsetlon;

int minlat;
int minlon;
int maxlat;
int maxlon;

float coordscale;

int offsetx;
int offsety;

int rounding;

float zoom;

void gui() {
  cp5 = new ControlP5(this);
  cp5.addSlider("offsetlat")
     .setPosition(20,50)
     .setRange(minlat,maxlat)
     .setValue(minlat)
     ;
  cp5.addSlider("offsetlon")
     .setPosition(20,70)
     .setRange(minlon,maxlon)
     .setValue(minlon)
     ;
  cp5.addSlider("coordscale")
     .setPosition(20,110)
     .setRange(0,0.015)
     .setValue(0.007)
     .setDecimalPrecision(7)
     ;
  cp5.addSlider("rounding")
     .setPosition(20,130)
     .setRange(0,100)
     .setValue(0)
     ;
  cp5.addSlider("offsetx")
     .setPosition(20,200)
     .setRange(0,width)
     .setValue(width/2)
     ;
  cp5.addSlider("offsety")
     .setPosition(20,220)
     .setRange(0,height)
     .setValue(height/2)
     ;
  cp5.addSlider("zoom")
     .setPosition(20,240)
     .setRange(0.001,2)
     .setValue(0.5)
     ;
}

int str2Int(String s) {
  String[] t = split(s, ".");
  if(t[1].length() > 7) {
    t[1] = t[1].substring(0, 7);
  }
  if(t[1].length() < 7) {
    int l = t[1].length();
    for(int i = 0; i < 7-l; i++) {
      t[1] += "0";
    }
  }

  if(t[1].length() != 7) {
    println("#"+t[1]+"#" + t[1].length());
  }
  return parseInt(t[0] + t[1]);
}

void setup() {
  size(1024, 768);
  smooth();

  osm = new XMLElement(this, "big.osm");
  XMLElement bounds = osm.getChild(0);
  minlat = str2Int(bounds.getString("minlat"));
  minlon = str2Int(bounds.getString("minlon"));
  maxlat = str2Int(bounds.getString("maxlat"));
  maxlon = str2Int(bounds.getString("maxlon"));
    
  nodes = new ArrayList();
  ways = new ArrayList();
  
  for (int i = 1; i < osm.getChildCount(); i++) {
    
    XMLElement child = osm.getChild(i);
    
    if(child.getName().equals("node")) {
      //println(child.getInt("id") + ": " + child.getFloat("lat") + ", " + child.getFloat("lon"));
      PVector n = new PVector(str2Int(child.getString("lat")), str2Int(child.getString("lon")));
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
                PVector waypoint = new PVector(str2Int(n.getString("lat")), str2Int(n.getString("lon")));
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
  if(rounding > 0) {
    stroke(20);
    float r = rounding * zoom;
    for(int i = 0; i <= width/r; i++) {
      line(i*r + offsetx % r + r/2, 0, i*r + offsetx % r +r/2, height);
    }

    for(int i = 0; i <= height/r; i++) {
      line(0, i*r + offsety % r + r/2, width, i*r + offsety % r + r/2);
    }
  }

  stroke(255);
    
  for(int i = 0; i < nodes.size(); i++) {
    PVector n = (PVector) nodes.get(i);
    float x = r(n.y-offsetlon)*coordscale*zoom+offsetx;
    float y = -1 * r(n.x-offsetlat)*coordscale*zoom+offsety;
    point(x, y);
  }
  
  stroke(255,0,0);
 
  for(int i = 0; i < ways.size(); i++) {
    ArrayList waypoints = (ArrayList) ways.get(i);
    for (int j = 1; j < waypoints.size(); j++) {
      PVector start = (PVector) waypoints.get(j-1);
      PVector end = (PVector) waypoints.get(j);
      float x1 = r(start.y-offsetlon)*coordscale*zoom+offsetx;
      float y1 = -1 * r(start.x-offsetlat)*coordscale*zoom+offsety;
      float x2 = r(end.y-offsetlon)*coordscale*zoom+offsetx;
      float y2 = -1 * r(end.x-offsetlat)*coordscale*zoom+offsety;
      //line(r(x1),r(y1),r(x2),r(y2));
      line(x1,y1,x2,y2);
    }
  }
}

float r(float n) {
  if(rounding > 0) {
    return round(n / (rounding/coordscale)) * (rounding/coordscale);
  } else {
    return n;
  }
}
