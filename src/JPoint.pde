class JPoint {
  Engine ENGINE;
  Junction junction;
  PVector pos;
  Road r_in;


  JPoint(Engine ENGINE, Junction j, PVector pos) {
    this.ENGINE=ENGINE;
    this.junction=j;
    this.pos=pos;
    this.r_in=null;
  }



  JPoint clone() {
    JPoint n=new JPoint(this.ENGINE, this.junction, this.pos);
    n.r_in=this.r_in;
    return n;
  }



  void add_pos(float x, float y) {
    this.pos.x+=x;
    this.pos.y+=y;
    if (this.r_in!=null) {
      this.r_in.get_j_pos(this.junction).x=this.pos.x;
      this.r_in.get_j_pos(this.junction).y=this.pos.y;
    }
  }



  boolean try_connect(Road r, int d) {
    if (this.r_in!=null) {
      return false;
    }
    if (d==0&&r.r_st==null&&r.j_st==null&&dst(this.pos.x, this.pos.y, r.start.x, r.start.y)<=this.ENGINE.MAX_CONNECT_DIST) {
      if (r.r_st!=null) {
        r.r_st.rm_r(r);
      }
      if (r.j_st!=null) {
        r.j_st.rm_r(r);
      }
      this.r_in=r;
      r.j_st=this.junction;
      r.DRAGGING=0;
      r.highlight=true;
      this.ENGINE.DRAGGING_OBJECT=0;
      this.add_pos(0, 0);
      return true;
    }
    if (d==1&&r.r_ed==null&&r.j_ed==null&&dst(this.pos.x, this.pos.y, r.end.x, r.end.y)<=this.ENGINE.MAX_CONNECT_DIST) {
      if (r.r_ed!=null) {
        r.r_ed.rm_r(r);
      }
      if (r.j_ed!=null) {
        r.j_ed.rm_r(r);
      }
      this.r_in=r;
      r.j_ed=this.junction;
      r.DRAGGING=0;
      r.highlight=true;
      this.ENGINE.DRAGGING_OBJECT=0;
      this.add_pos(0, 0);
      return true;
    }
    return false;
  }
  void disconnect() {
    if (this.r_in==null) {
      return;
    }
    PVector p=this.r_in.get_j_pos(this.junction);
    float a=ang(this.pos.x, this.pos.y, this.junction.pos.x, this.junction.pos.y)-PI/2;
    p.x=this.junction.pos.x+cos(a)*(dst(this.pos.x, this.pos.y, this.junction.pos.x, this.junction.pos.y)+this.ENGINE.MAX_CONNECT_DIST*2);
    p.y=this.junction.pos.y+sin(a)*(dst(this.pos.x, this.pos.y, this.junction.pos.x, this.junction.pos.y)+this.ENGINE.MAX_CONNECT_DIST*2);
    this.r_in.rm_j(this.junction);
    this.r_in=null;
  }



  void draw() {
    if (this.r_in!=null) {
      return;
    }
    noStroke();
    fill(150, 30, 210);
    circle(this.pos.x, this.pos.y, this.ENGINE.POS_DRAG_RADIUS*2);
  }
}
