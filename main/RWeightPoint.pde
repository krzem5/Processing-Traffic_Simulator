class RWeightPoint {
  Engine ENGINE;
  PVector pos;
  Road r;
  RLine l;
  boolean clicked=false;
  int DEFAULT_WEIGHT=50;



  RWeightPoint(Engine ENGINE, PVector pos, RLine l, Road r) {
    this.ENGINE=ENGINE;
    this.pos=pos;
    this.l=l;
    this.r=r;
  }



  int default_weight() {
    if (this.ENGINE.road_weights.get(this.r.ID).size()<=this.l.lane-1+this.ENGINE.MAX_LANES||this.ENGINE.road_weights.get(this.r.ID).get(this.l.lane-1+this.ENGINE.MAX_LANES)==-1) {
      this.set_weight(this.DEFAULT_WEIGHT);
    }
    return this.DEFAULT_WEIGHT;
  }



  void update() {
    if (mousePressed==true&&this.clicked==false) {
      this.clicked=true;
      if (dst(this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y, this.pos.x, this.pos.y)<=this.ENGINE.POS_DRAG_RADIUS) {
        this.ENGINE.updating_rpoint=this;
        this.ENGINE.TEXTBOX.show("Input Road \nWeight", this.get_weight());
      }
    }
    if (mousePressed==false) {
      this.clicked=false;
    }
  }



  void set_weight(int w) {
    while (this.ENGINE.road_weights.get(this.r.ID).size()<=this.l.lane-1+this.ENGINE.MAX_LANES) {
      this.ENGINE.road_weights.get(this.r.ID).append(-1);
    }
    this.ENGINE.road_weights.get(this.r.ID).set(this.l.lane-1+this.ENGINE.MAX_LANES, w);
  }
  int get_weight() {
    return this.ENGINE.road_weights.get(this.r.ID).get(this.l.lane-1+this.ENGINE.MAX_LANES);
  }



  void draw() {
    noStroke();
    fill(128, 255, 255);
    circle(this.pos.x, this.pos.y, this.ENGINE.POS_DRAG_RADIUS*2);
  }
}
