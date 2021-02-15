class CPathPoint {
  Engine ENGINE;
  PVector pos;
  boolean change;
  PVector start_lane;
  boolean slow=false;
  RLine lane;
  int ch_dir=1;
  Light lgt;



  CPathPoint(Engine ENGINE, PVector pos) {
    this.ENGINE=ENGINE;
    this.pos=pos;
    this.change=false;
    this.start_lane=null;
  }
  CPathPoint(Engine ENGINE, PVector pos, RLine l, boolean slow) {
    this.ENGINE=ENGINE;
    this.pos=pos;
    this.change=false;
    this.start_lane=null;
    this.set_lane(l);
    this.slow=slow;
  }
  CPathPoint(Engine ENGINE, PVector pos, PVector start) {
    this.ENGINE=ENGINE;
    this.pos=pos;
    this.change=true;
    this.start_lane=start;
  }



  void set_lane(RLine l) {
    this.lane=l;
  }



  void set_ch_dir(RLine l) {
    if (this.lane.lane<l.lane) {
      this.ch_dir=1;
    } else {
      this.ch_dir=-1;
    }
  }



  PVector get_pos() {
    if (this.change==false) {
      return this.pos;
    }
    return this.start_lane;
  }
}
