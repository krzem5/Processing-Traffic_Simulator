class RLight {
  Engine ENGINE;
  RLightObject l;
  PVector pos;



  RLight(Engine ENGINE, RLightObject l, PVector pos) {
    this.ENGINE=ENGINE;
    this.l=l;
    this.pos=pos;
  }



  int get_state() {
    return this.l.state;
  }
}
