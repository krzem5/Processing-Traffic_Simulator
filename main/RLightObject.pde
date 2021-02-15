class RLightObject {
  Engine ENGINE;
  Road r;
  boolean enabled=false;
  int state=0;
  float t=0;
  float d_time=0;
  boolean editing=false;
  int u_type=0;
  boolean clicked=false;
  int MIN_DELAY=30;
  int MAX_DELAY=60;
  int CROSSING_TIME=25;
  int LIGHT_ALPHA=150;



  RLightObject(Engine ENGINE, Road r) {
    this.ENGINE=ENGINE;
    this.r=r;
  }



  void reset() {
    this.t=0;
  }



  void set_weight(int w) {
    switch(this.u_type) {
    case 0:
      this.MIN_DELAY=w;
      break;
    case 1:
      this.MAX_DELAY=w;
      break;
    case 2:
      this.CROSSING_TIME=w;
      break;
    }
    this.r.update_text();
    this.ENGINE.save_JSON();
  }



  void update() {
    if (this.enabled==false) {
      return;
    }
    if (this.editing==false) {
      if (this.t==0) {
        this.d_time=random(1)*(this.MAX_DELAY-this.MIN_DELAY)+this.MIN_DELAY;
      }
      this.t+=1/frameRate;
      if (this.t>=this.d_time+this.CROSSING_TIME) {
        this.t=0;
      }
      if (this.t<this.d_time) {
        this.state=0;
      } else {
        this.state=1;
      }
    } else {
      if (this.clicked==false&&mousePressed==true) {
        this.clicked=true;
        PVector p=avg2(this.r.start, this.r.end);
        if (dst(this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y, p.x, p.y)<=this.ENGINE.POS_DRAG_RADIUS) {
          if (CTRL_DOWN==false&&SHIFT_DOWN==false&&ALT_DOWN==false) {
            this.ENGINE.updating_r_light=this;
            this.ENGINE.TEXTBOX.show("Min Delay\nLength", this.MIN_DELAY);
            this.u_type=0;
          }
          if (CTRL_DOWN==false&&SHIFT_DOWN==true&&ALT_DOWN==false) {
            this.ENGINE.updating_r_light=this;
            this.ENGINE.TEXTBOX.show("Max Delay\nLength", this.MAX_DELAY);
            this.u_type=1;
          }
          if (CTRL_DOWN==false&&SHIFT_DOWN==false&&ALT_DOWN==true) {
            this.ENGINE.updating_r_light=this;
            this.ENGINE.TEXTBOX.show("Crossing Time\nLength", this.CROSSING_TIME);
            this.u_type=2;
          }
        }
      }
      if (this.clicked==true&&mousePressed==false) {
        this.clicked=false;
      }
    }
  }



  RLight get_light(RLine l) {
    List<RLine> LINES=this.ENGINE.RMAP.get_lines(this.r.ID);
    for (int i=0; i<this.r.lanesA; i++) {
      RLine L=LINES.get(this.ENGINE.MAX_LANES-1-i);
      if (L.ID==l.ID) {
        float oa=map(i, 0, this.r.lanesA, -this.ENGINE.LANE_WIDTH, -this.r.lanesA*this.ENGINE.LANE_WIDTH-this.ENGINE.LANE_WIDTH);
        float ob=map(i, 0, this.r.lanesA, -this.ENGINE.LANE_WIDTH, -this.r.lanesA*this.ENGINE.LANE_WIDTH-this.ENGINE.LANE_WIDTH)+this.ENGINE.LANE_WIDTH;
        PVector aa=rot_point(this.r.start.x+oa, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector ab=rot_point(this.r.start.x+ob, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector ba=rot_point(this.r.end.x+oa, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector bb=rot_point(this.r.end.x+ob, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector c=avg4(aa, ab, ba, bb);
        PVector off=rot_point(0, this.ENGINE.CROSSING_LIGHT_OFFSET, 0, 0, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        return new RLight(this.ENGINE, this, new PVector(c.x-off.x, c.y-off.y));
      }
    }
    for (int i=0; i<this.r.lanesB; i++) {
      RLine L=LINES.get(this.ENGINE.MAX_LANES+i);
      if (L.ID==l.ID) {
        float oa=map(i, 0, this.r.lanesB, this.ENGINE.LANE_WIDTH, this.r.lanesB*this.ENGINE.LANE_WIDTH+this.ENGINE.LANE_WIDTH);
        float ob=map(i, 0, this.r.lanesB, this.ENGINE.LANE_WIDTH, this.r.lanesB*this.ENGINE.LANE_WIDTH+this.ENGINE.LANE_WIDTH)-this.ENGINE.LANE_WIDTH;
        PVector aa=rot_point(this.r.start.x+oa, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector ab=rot_point(this.r.start.x+ob, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector ba=rot_point(this.r.end.x+oa, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector bb=rot_point(this.r.end.x+ob, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        PVector c=avg4(aa, ab, ba, bb);
        PVector off=rot_point(0, -this.ENGINE.CROSSING_LIGHT_OFFSET, 0, 0, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
        return new RLight(this.ENGINE, this, new PVector(c.x-off.x, c.y-off.y));
      }
    }
    return null;
  }



  void draw() {
    if (this.enabled==false) {
      return;
    }
    this.draw_crossing();
    if (this.editing==true) {
      PVector p=avg2(this.r.start, this.r.end);
      fill(30, 100, 210);
      noStroke();
      ellipseMode(RADIUS);
      circle(p.x, p.y, this.ENGINE.POS_DRAG_RADIUS);
      ellipseMode(DIAMETER);
    }
  }
  void draw_roadmap() {
    if (this.enabled==false) {
      return;
    }
    this.draw_crossing();
    if (this.state==0) {
      fill(220, 100, 100, this.LIGHT_ALPHA);
    }
    if (this.state==1) {
      fill(100, 220, 100, this.LIGHT_ALPHA);
    }
    noStroke();
    ellipseMode(RADIUS);
    float oa, ob;
    for (int i=0; i<this.r.lanesA; i++) {
      oa=map(i, 0, this.r.lanesA, -this.ENGINE.LANE_WIDTH, -this.r.lanesA*this.ENGINE.LANE_WIDTH-this.ENGINE.LANE_WIDTH);
      ob=map(i, 0, this.r.lanesA, -this.ENGINE.LANE_WIDTH, -this.r.lanesA*this.ENGINE.LANE_WIDTH-this.ENGINE.LANE_WIDTH)+this.ENGINE.LANE_WIDTH;
      PVector aa=rot_point(this.r.start.x+oa, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector ab=rot_point(this.r.start.x+ob, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector ba=rot_point(this.r.end.x+oa, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector bb=rot_point(this.r.end.x+ob, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector c=avg4(aa, ab, ba, bb);
      PVector off=rot_point(0, this.ENGINE.CROSSING_LIGHT_OFFSET, 0, 0, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      circle(c.x-off.x, c.y-off.y, this.ENGINE.POS_DRAG_RADIUS);
    }
    for (int i=0; i<this.r.lanesB; i++) {
      oa=map(i, 0, this.r.lanesB, this.ENGINE.LANE_WIDTH, this.r.lanesB*this.ENGINE.LANE_WIDTH+this.ENGINE.LANE_WIDTH);
      ob=map(i, 0, this.r.lanesB, this.ENGINE.LANE_WIDTH, this.r.lanesB*this.ENGINE.LANE_WIDTH+this.ENGINE.LANE_WIDTH)-this.ENGINE.LANE_WIDTH;
      PVector aa=rot_point(this.r.start.x+oa, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector ab=rot_point(this.r.start.x+ob, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector ba=rot_point(this.r.end.x+oa, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector bb=rot_point(this.r.end.x+ob, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      PVector c=avg4(aa, ab, ba, bb);
      PVector off=rot_point(0, -this.ENGINE.CROSSING_LIGHT_OFFSET, 0, 0, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
      circle(c.x-off.x, c.y-off.y, this.ENGINE.POS_DRAG_RADIUS);
    }
    ellipseMode(DIAMETER);
  }
  void draw_crossing() {
    fill(255);
    noStroke();
    float a=ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y)+PI/2;
    PVector aa=rot_point(this.r.start.x-this.r.lanesA*this.ENGINE.LANE_WIDTH, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
    PVector ab=rot_point(this.r.start.x+this.r.lanesB*this.ENGINE.LANE_WIDTH, this.r.start.y, this.r.start.x, this.r.start.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
    PVector ba=rot_point(this.r.end.x-this.r.lanesA*this.ENGINE.LANE_WIDTH, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
    PVector bb=rot_point(this.r.end.x+this.r.lanesB*this.ENGINE.LANE_WIDTH, this.r.end.y, this.r.end.x, this.r.end.y, ang(this.r.start.x, this.r.start.y, this.r.end.x, this.r.end.y));
    PVector ca=avg2(aa, ba);
    PVector cb=avg2(ab, bb);
    float cx=aa.x/2+bb.x/2;
    float cy=aa.y/2+bb.y/2;
    int d=int(dst(ca.x, ca.y, cb.x, cb.y));
    int w=this.ENGINE.CROSSING_GAP+this.ENGINE.CROSSING_HEIGHT;
    float off=(d-max(int(d/w), 1)*w)/2/max(int(d/w), 1);
    for (int i=0; i<max(d/w, 1); i++) {
      float yoff=map(i, 0, max(d/w, 1), -d/2, d/2)+w/2+off;
      PVector tl=rot_point(cx+this.ENGINE.CROSSING_WIDTH, cy+yoff+this.ENGINE.CROSSING_HEIGHT/2, cx, cy, a);
      PVector tr=rot_point(cx-this.ENGINE.CROSSING_WIDTH, cy+yoff+this.ENGINE.CROSSING_HEIGHT/2, cx, cy, a);
      PVector bl=rot_point(cx+this.ENGINE.CROSSING_WIDTH, cy+yoff-this.ENGINE.CROSSING_HEIGHT/2, cx, cy, a);
      PVector br=rot_point(cx-this.ENGINE.CROSSING_WIDTH, cy+yoff-this.ENGINE.CROSSING_HEIGHT/2, cx, cy, a);
      beginShape();
      vertex(tl.x, tl.y);
      vertex(tr.x, tr.y);
      vertex(br.x, br.y);
      vertex(bl.x, bl.y);
      endShape(CLOSE);
    }
  }



  void fromJSON(JSONObject json) {
    this.enabled=json.getBoolean("exist");
    if (this.enabled==true) {
      this.MIN_DELAY=json.getInt("min");
      this.MAX_DELAY=json.getInt("max");
      this.CROSSING_TIME=json.getInt("cross");
    }
  }
  JSONObject toJSON() {
    JSONObject json=new JSONObject();
    json.setBoolean("exist", this.enabled);
    if (this.enabled==true) {
      json.setInt("min", this.MIN_DELAY);
      json.setInt("max", this.MAX_DELAY);
      json.setInt("cross", this.CROSSING_TIME);
    }
    return json;
  }
}
