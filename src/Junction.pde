class Junction {
  Engine ENGINE;
  PVector pos;
  int sides=3;
  int radius;
  float offset_angle;
  ArrayList<PVector> side_points;
  ArrayList<JPoint> side_c_points;
  ArrayList<JEditPoint> l_edit_points;
  ArrayList<int[]> connections;
  ArrayList<JEditLine> edit_lines;
  ArrayList<JWeightLine> weight_lines;
  boolean highlight=false;
  int ID=-1;
  int DRAGGING=0;
  boolean CLICK=false;
  boolean KEYDOWN=false;
  JSONArray conns;
  boolean editing_points=false;
  boolean weighting_points=false;
  boolean editing_lights=false;
  JEditPoint selected_start_point=null;
  LightObject LIGHTS;
  JSONObject lgt_json;



  Junction(Engine ENGINE) {
    this.ENGINE=ENGINE;
    this.pos=new PVector(this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y);
    this.radius=this.ENGINE.MIN_JUNCTION_RADIUS;
    this.offset_angle=0;
    this.side_points=new ArrayList<PVector>();
    this.side_c_points=new ArrayList<JPoint>();
    this.l_edit_points=new ArrayList<JEditPoint>();
    this.connections=new ArrayList<int[]>();
    this.edit_lines=new ArrayList<JEditLine>();
    this.ID=this.ENGINE.gen_ID();
    this.update_side_points(0);
    this.LIGHTS=new LightObject(this.ENGINE, this);
  }
  Junction(Engine ENGINE, JSONObject junction_data) {
    this.ENGINE=ENGINE;
    this.fromJSON(junction_data);
  }



  void update(boolean ex) {
    if (this.ENGINE.ROADMAP_VIEW==true||this.ENGINE.RUNNING==true||this.ENGINE.updating_junction!=null||this.ENGINE.EDITING_ROAD_INPUT==true) {
      if (this.ENGINE.ROADMAP_VIEW==true||this.ENGINE.RUNNING==true) {
        this.editing_points=false;
        this.weighting_points=false;
      }
      this.highlight=false;
      this.DRAGGING=0;
      return;
    }
    if (mousePressed==true&&this.CLICK==false) {
      this.CLICK=true;
      PVector[] verts=new PVector[this.side_points.size()];
      for (int i=0; i<this.side_points.size(); i++) {
        verts[i]=this.side_points.get(i);
      }
      boolean c=collisionPointPoly(this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y, verts);
      if (this.editing_points==true&&c==false) {
        c=true;
      }
      if (c==false&&this.DRAGGING>0) {
        this.DRAGGING=0;
        this.ENGINE.DRAGGING_OBJECT=0;
        this.highlight=true;
      }
      if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&this.editing_points==false&&this.weighting_points==false&&dst(this.pos.x, this.pos.y, this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y)<=this.ENGINE.POS_DRAG_RADIUS&&this.ENGINE.DRAGGING_OBJECT==0) {
        this.DRAGGING=1;
        this.ENGINE.DRAGGING_OBJECT=2;
        c=false;
      }
      if (CTRL_DOWN==false&&this.editing_points==true) {
        for (JEditPoint p : this.l_edit_points) {
          if ((p.type==1&&this.selected_start_point==null)||(p.type==0&&this.selected_start_point!=null&&this.selected_start_point!=p)) {
            continue;
          }
          if (dst(p.pos.x, p.pos.y, this.ENGINE.MOUSE.x, this.ENGINE.MOUSE.y)<=this.ENGINE.POS_DRAG_RADIUS) {
            if (SHIFT_DOWN==true) {
              p.disconnect();
            } else {
              p.select();
            }
            break;
          }
        }
      }
      if (ALT_DOWN==false&&this.weighting_points==true) {
        for (JWeightLine l : this.weight_lines) {
          if (l.click((int)this.ENGINE.MOUSE.x, (int)this.ENGINE.MOUSE.y)==true) {
            break;
          }
        }
      }
      if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&ex==false&&CTRL_DOWN==true&&SHIFT_DOWN==false&&ALT_DOWN==false&&c==true&&this.highlight==true&&this.editing_points==false) {
        this.editing_points=true;
        this.ENGINE.EDITING_JUNCTION=true;
        this.ENGINE.DRAGGING_OBJECT=0;
        this.DRAGGING=0;
        this.highlight=false;
        c=false;
        if (this.create_edit_points()==false) {
          this.highlight=true;
          this.editing_points=false;
          this.ENGINE.EDITING_JUNCTION=false;
          c=true;
        }
        this.ENGINE.INFOTEXT.ep=1;
        this.ENGINE.INFOTEXT.update_keys();
      } else if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&CTRL_DOWN==true&&SHIFT_DOWN==false&&ALT_DOWN==false&&c==true&&this.editing_points==true) {
        this.editing_points=false;
        this.ENGINE.EDITING_JUNCTION=false;
        this.highlight=true;
        this.ENGINE.INFOTEXT.ep=0;
        this.ENGINE.INFOTEXT.update_keys();
      }
      if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&c==true&&this.highlight==true&&this.weighting_points==false) {
        this.weighting_points=true;
        this.highlight=false;
        this.ENGINE.WEIGHTING_JUNCTION=true;
        this.ENGINE.DRAGGING_OBJECT=0;
        this.DRAGGING=0;
        c=false;
        if (this.connections.size()==0) {
          c=true;
          this.weighting_points=false;
          this.ENGINE.WEIGHTING_JUNCTION=false;
          this.highlight=true;
        } else {
          this.create_weight_lines();
        }
        this.ENGINE.INFOTEXT.ep=2;
        this.ENGINE.INFOTEXT.update_keys();
      } else if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&c==true&&this.weighting_points==true) {
        this.weighting_points=false;
        this.ENGINE.WEIGHTING_JUNCTION=false;
        this.highlight=true;
        this.ENGINE.INFOTEXT.ep=0;
        this.ENGINE.INFOTEXT.update_keys();
      }
      if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&c==true&&this.highlight==true&&this.editing_lights==false) {
        this.editing_lights=true;
        this.highlight=false;
        this.ENGINE.EDITING_LIGHTS=true;
        this.ENGINE.DRAGGING_OBJECT=0;
        this.DRAGGING=0;
        c=false;
        if (this.LIGHTS.lights==null||this.LIGHTS.lights.size()==0) {
          c=true;
          this.editing_lights=false;
          this.ENGINE.EDITING_LIGHTS=false;
          this.highlight=true;
        } else {
          this.LIGHTS.edit_lights();
        }
        this.ENGINE.INFOTEXT.ep=3;
        this.ENGINE.INFOTEXT.update_keys();
      } else if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&c==true&&this.editing_lights==true) {
        this.editing_lights=false;
        this.ENGINE.EDITING_LIGHTS=false;
        this.highlight=true;
        this.LIGHTS.stop_edit_lights();
        this.ENGINE.INFOTEXT.ep=0;
        this.ENGINE.INFOTEXT.update_keys();
      }
      if (this.editing_points==false&&this.weighting_points==false&&this.editing_lights==false) {
        if (c==true&&this.highlight==false) {
          this.editing_points=false;
          this.ENGINE.EDITING_JUNCTION=false;
          this.highlight=true;
        }
        if (c==false&&this.highlight==true) {
          this.editing_points=false;
          this.ENGINE.EDITING_JUNCTION=false;
          this.highlight=false;
        }
        if (this.ENGINE.ZOOM_OUT<=this.ENGINE.MAX_EDIT_ZOOM_OUT&&SHIFT_DOWN==true&&c==true) {
          for (JPoint p : this.side_c_points) {
            p.disconnect();
          }
        }
      }
    }
    if (mousePressed==false&&this.CLICK==true) {
      if (this.DRAGGING>0) {
        this.DRAGGING=0;
        this.ENGINE.DRAGGING_OBJECT=0;
        this.highlight=true;
      }
      this.CLICK=false;
    }
    if (mousePressed==true) {
      if (this.DRAGGING==1) {
        float xm=this.ENGINE.MOUSE.x-(pmouseX+this.ENGINE.OFF_X)*this.ENGINE.ZOOM_OUT;
        float ym=this.ENGINE.MOUSE.y-(pmouseY+this.ENGINE.OFF_X)*this.ENGINE.ZOOM_OUT;
        this.pos.x+=xm;
        this.pos.y+=ym;
        for (PVector p : this.side_points) {
          p.x+=xm;
          p.y+=ym;
        }
        for (JPoint p : this.side_c_points) {
          p.add_pos(xm, ym);
        }
      }
    }
    if (keyPressed==true&&this.highlight==true&&this.KEYDOWN==false) {
      this.KEYDOWN=true;
      switch(keyCode) {
      case UP:
        this.sides=min(this.sides+1, this.ENGINE.MAX_JUNCTION_SIDES);
        this.update_side_points(1);
        this.update_lines();
        break;
      case DOWN:
        this.sides=max(this.sides-1, this.ENGINE.MIN_JUNCTION_SIDES);
        this.update_side_points(1);
        this.update_lines();
        break;
      }
      if (key==DELETE) {
        this.delete();
      }
    }
    if (keyPressed==true&&this.highlight==true) {
      if (CTRL_DOWN==true) {
        switch(keyCode) {
        case RIGHT:
          this.offset_angle=(this.offset_angle+this.ENGINE.JUNCTION_ANGLE_INCREMENT+PI*2)%(PI*2);
          this.update_side_points(1);
          this.update_lines();
          break;
        case LEFT:
          this.offset_angle=(this.offset_angle-this.ENGINE.JUNCTION_ANGLE_INCREMENT+PI*2)%(PI*2);
          this.update_side_points(1);
          this.update_lines();
          break;
        }
      } else {
        switch(keyCode) {
        case RIGHT:
          this.radius=min(this.radius+this.ENGINE.JUNCTION_RADIUS_INCREMENT, this.ENGINE.MAX_JUNCTION_RADIUS);
          this.update_side_points(1);
          this.update_lines();
          break;
        case LEFT:
          this.radius=max(this.radius-this.ENGINE.JUNCTION_RADIUS_INCREMENT, this.ENGINE.MIN_JUNCTION_RADIUS);
          this.update_side_points(1);
          this.update_lines();
          break;
        }
      }
    }
    if (keyPressed==false&&this.KEYDOWN==true) {
      this.KEYDOWN=false;
    }
    if (this.highlight==true||this.DRAGGING>0||this.editing_points==true||this.weighting_points==true||this.editing_lights==true) {
      this.update_text();
    }
  }
  void update_side_points(int s) {
    if (s==0) {
      this.side_points=new ArrayList<PVector>();
      this.side_c_points=new ArrayList<JPoint>();
      for (int i=0; i<this.sides; i++) {
        this.side_points.add(new PVector(this.pos.x+cos((float)i/this.sides*2*PI+this.offset_angle)*this.radius, this.pos.y+sin((float)i/this.sides*2*PI+this.offset_angle)*this.radius));
      }
      for (int i=1; i<=this.sides; i++) {
        this.side_c_points.add(new JPoint(this.ENGINE, this, lerp(this.side_points.get(i-1), this.side_points.get(i%this.sides), 0.5)));
      }
    }
    if (s==1) {
      ArrayList<JPoint> o_scp=new ArrayList<JPoint>();
      for (JPoint p : this.side_c_points) {
        o_scp.add(p.clone());
      }
      this.side_points=new ArrayList<PVector>();
      this.side_c_points=new ArrayList<JPoint>();
      for (int i=0; i<this.sides; i++) {
        this.side_points.add(new PVector(this.pos.x+cos((float)i/this.sides*2*PI+this.offset_angle)*this.radius, this.pos.y+sin((float)i/this.sides*2*PI+this.offset_angle)*this.radius));
      }
      for (int i=1; i<=this.sides; i++) {
        this.side_c_points.add(new JPoint(this.ENGINE, this, lerp(this.side_points.get(i-1), this.side_points.get(i%this.sides), 0.5)));
      }
      int i=0;
      for (JPoint p : this.side_c_points) {
        if (i==o_scp.size()) {
          break;
        }
        p.r_in=o_scp.get(i).r_in;
        p.add_pos(0, 0);
        i++;
      }
      if (i<o_scp.size()) {
        while (i<o_scp.size()) {
          o_scp.get(i).disconnect();
          i++;
        }
      }
    }
  }



  void delete() {
    for (JPoint p : this.side_c_points) {
      if (p.r_in==null) {
        continue;
      }
      p.r_in.rm_j(this);
    }
    this.ENGINE.JUNCTIONS.remove(this);
    for (JEditLine l : this.edit_lines) {
      l.remove();
    }
    this.ENGINE.INFOTEXT.reset_sel();
  }



  boolean create_edit_points() {
    for (JPoint p : this.side_c_points) {
      if (p.r_in!=null) {
        p.r_in.update_lines();
      }
    }
    this.ENGINE.RMAP.create_lines(this.ID, new ArrayList<RLine>());
    this.l_edit_points=new ArrayList<JEditPoint>();
    this.edit_lines=new ArrayList<JEditLine>();
    this.selected_start_point=null;
    for (Road r : this.ENGINE.ROADS) {
      r.update_lines();
    }
    for (Road r : this.ENGINE.ROADS) {
      r.update_lines();
    }
    int c=0;
    Road r;
    List<RLine> LINES;
    RLine L;
    int[] nums=new int[this.sides*this.ENGINE.MAX_LANES*2];
    for (int i=0; i<this.sides*this.ENGINE.MAX_LANES*2; i++) {
      nums[i]=-1;
    }
    int j=0;
    ArrayList<JEditPoint> pts;
    JEditPoint pt;
    float sa;
    int k=0;
    PVector aa, ab;
    for (JPoint p : this.side_c_points) {
      if (p.r_in!=null) {
        aa=this.side_points.get(k);
        ab=this.side_points.get((k+1)%this.sides);
        sa=ang(aa.x, aa.y, ab.x, ab.y);
        c++;
        r=p.r_in;
        LINES=this.ENGINE.RMAP.get_lines(r.ID);
        pts=new ArrayList<JEditPoint>();
        if (r.j_st==this) {
          for (int i=0; i<r.lanesB; i++) {
            nums[j+this.ENGINE.MAX_LANES+i]=j+this.ENGINE.MAX_LANES+i;
            L=LINES.get(this.ENGINE.MAX_LANES+i);
            pt=new JEditPoint(this.ENGINE, this, L, 0, 0, j+this.ENGINE.MAX_LANES+i, null, sa);
            pts.add(pt);
            this.l_edit_points.add(pt);
          }
          for (int i=0; i<r.lanesA; i++) {
            nums[j+this.ENGINE.MAX_LANES-1-i]=j+this.ENGINE.MAX_LANES-1-i;
            L=LINES.get(this.ENGINE.MAX_LANES-1-i);
            this.l_edit_points.add(new JEditPoint(this.ENGINE, this, L, 0, 1, j+this.ENGINE.MAX_LANES-1-i, pts, sa));
          }
        } else {
          for (int i=0; i<r.lanesA; i++) {
            nums[j+this.ENGINE.MAX_LANES-1-i]=j+this.ENGINE.MAX_LANES-1-i;
            L=LINES.get(this.ENGINE.MAX_LANES-1-i);
            pt=new JEditPoint(this.ENGINE, this, L, 1, 0, j+this.ENGINE.MAX_LANES-1-i, null, sa);
            pts.add(pt);
            this.l_edit_points.add(pt);
          }
          for (int i=0; i<r.lanesB; i++) {
            nums[j+this.ENGINE.MAX_LANES+i]=j+this.ENGINE.MAX_LANES+i;
            L=LINES.get(this.ENGINE.MAX_LANES+i);
            this.l_edit_points.add(new JEditPoint(this.ENGINE, this, L, 1, 1, j+this.ENGINE.MAX_LANES+i, pts, sa));
          }
        }
      }
      j+=this.ENGINE.MAX_LANES*2;
      k++;
    }
    JEditLine l;
    JEditPoint a, b;
    int[] cn;
    boolean fA, fB;
    for (int i=this.connections.size()-1; i>=0; i--) {
      cn=this.connections.get(i);
      if (cn==null) {
        continue;
      }
      fA=false;
      fB=false;
      for (int n : nums) {
        if (n==-1) {
          continue;
        }
        if (n==cn[0]) {
          fA=true;
        }
        if (n==cn[1]) {
          fB=true;
        }
        if (fA==true&&fB==true) {
          break;
        }
      }
      if (fA==false||fB==false) {
        this.connections.remove(i);
        continue;
      }
      a=null;
      b=null;
      for (JEditPoint p : this.l_edit_points) {
        if (p.conn_idx==cn[0]) {
          a=p;
          break;
        }
      }
      for (JEditPoint p : this.l_edit_points) {
        if (p.conn_idx==cn[1]) {
          b=p;
          break;
        }
      }
      l=new JEditLine(this.ENGINE, this, new PVector(a.pos.x, a.pos.y), new PVector(b.pos.x, b.pos.y), a, b, i, cn[2]);
      this.edit_lines.add(l);
    }
    this.LIGHTS.from_junction();
    return (c>1);
  }
  void connect_edit(JEditPoint a, JEditPoint b) {
    this.selected_start_point=null;
    int i=0;
    while (true) {
      if (this.connections.size()<=i) {
        this.connections.add(null);
      }
      if (this.connections.get(i)==null) {
        break;
      }
      i++;
    }
    int[] A={a.conn_idx, b.conn_idx, 50};
    this.connections.set(i, A);
    JEditLine l=new JEditLine(this.ENGINE, this, new PVector(a.pos.x, a.pos.y), new PVector(b.pos.x, b.pos.y), a, b, i, A[2]);
    this.edit_lines.add(l);
  }
  void disconnect_edit_point(JEditPoint p) {
    for (int i=this.edit_lines.size()-1; i>=0; i--) {
      JEditLine l=this.edit_lines.get(i);
      if (l.sp==p||l.ep==p) {
        l.remove();
      }
    }
  }



  Light get_lgt(RLine ln) {
    for (Light l : this.LIGHTS.lights) {
      if (dst(l.pos.x, l.pos.y, ln.s.x, ln.s.y)<=this.ENGINE.POS_DRAG_RADIUS||dst(l.pos.x, l.pos.y, ln.e.x, ln.e.y)<=this.ENGINE.POS_DRAG_RADIUS) {
        return l;
      }
    }
    return null;
  }



  void update_lines() {
    this.create_edit_points();
    for (JEditLine l : this.edit_lines) {
      l.create_lines();
    }
  }



  void create_weight_lines() {
    this.weight_lines=new ArrayList<JWeightLine>();
    for (JEditLine l : this.edit_lines) {
      this.weight_lines.add(new JWeightLine(this.ENGINE, this, l.s.copy(), l.e.copy(), l.conn_index));
    }
  }
  void update_weight(int nw) {
    for (JWeightLine l : this.weight_lines) {
      if (l.active==true) {
        l.u_conn(nw);
        break;
      }
    }
    this.update_text();
  }



  void rm_r(Road r) {
    for (JPoint p : this.side_c_points) {
      if (p.r_in==r) {
        p.disconnect();
        this.create_edit_points();
        return;
      }
    }
  }



  PVector get_r_pos(Road r) {
    for (JPoint p : this.side_c_points) {
      if (p.r_in==r) {
        return p.pos;
      }
    }
    return new PVector(0, 0);
  }



  void set_connections() {
    int ID;
    for (int i=0; i<this.sides; i++) {
      if (i==this.conns.size()) {
        return;
      }
      ID=this.conns.getInt(i);
      if (ID==-1) {
        continue;
      }
      for (Road r : this.ENGINE.ROADS) {
        if (r.ID!=ID) {
          continue;
        }
        this.side_c_points.get(i).r_in=r;
        this.side_c_points.get(i).add_pos(0, 0);
        break;
      }
    }
    this.create_edit_points();
    this.LIGHTS.from_json(this.lgt_json);
  }



  ArrayList<PVector> get_side(Road r) {
    for (int i=1; i<=this.sides; i++) {
      if (this.side_c_points.get(i-1).r_in==r) {
        ArrayList<PVector> l=new ArrayList<PVector>();
        l.add(this.side_points.get(i-1));
        l.add(this.side_points.get(i%this.sides));
        return l;
      }
    }
    return null;
  }



  void try_connect(Road r, int d) {
    for (JPoint p : this.side_c_points) {
      if (p.r_in!=null&&p.r_in==r) {
        return;
      }
    }
    for (JPoint p : this.side_c_points) {
      if (p.try_connect(r, d)==true) {
        r.LIGHTS.enabled=false;
        return;
      }
    }
  }



  void update_text() {
    String s="";
    s+="  Type: Junction";
    s+="\n  ID: "+str(this.ID);
    s+="\n  Pos:";
    s+="\n    Screen: x: "+str(int(this.pos.x-this.ENGINE.OFF_X))+" y: "+str(int(this.pos.y-this.ENGINE.OFF_Y));
    s+="\n    Editor: x: "+str(int(this.pos.x))+" y: "+str(int(this.pos.y));
    s+="\n  Sides: "+str(this.sides);
    s+="\n  Radius: "+str(round(this.radius));
    s+="\n  Offset Angle: "+str(round(this.offset_angle*(180/PI)))+"°";
    s+="\n  Road Connections:";
    int i=1;
    for (JPoint p : this.side_c_points) {
      if (p.r_in==null) {
        s+="\n    "+str(i)+":";
      } else {
        s+="\n    "+str(i)+": ID "+p.r_in.ID;
      }
      i++;
    }
    s+="\n  Connections:";
    for (int[] c : this.connections) {
      if (c==null||c.length<2) {
        continue;
      }
      s+="\n    "+str(c[0])+" (Side "+str(c[0]/(this.ENGINE.MAX_LANES*2)+1)+") — "+str(c[1])+" (Side "+str(c[1]/(this.ENGINE.MAX_LANES*2)+1)+") —> "+str(c[2])+"%";
    }
    if (this.connections.size()==0) {
      s+="\n    None";
    }
    s+="\n  Lights:";
    if (this.LIGHTS.lights!=null) {
      for (Light l : this.LIGHTS.lights) {
        s+="\n    Light (ID "+l.n+"):";
        s+="\n      Lengths: red: "+l.RED_TIME+"s green: "+l.GREEN_TIME+"s orange: "+l.ORANGE_TIME+"s";
        s+="\n      Offset length: "+l.OFFSET_TIME+"s";
      }
    }
    if (this.LIGHTS.lights==null||this.LIGHTS.lights.size()==0) {
      s+="\n    None";
    }
    this.ENGINE.INFOTEXT.set_sel(s, 1);
  }



  void draw() {
    translate(-this.ENGINE.OFF_X, -this.ENGINE.OFF_Y);
    scale(1/this.ENGINE.ZOOM_OUT);
    strokeWeight(2);
    stroke(255);
    for (int i=1; i<=this.sides; i++) {
      line(this.side_points.get(i-1).x, this.side_points.get(i-1).y, this.side_points.get(i%this.sides).x, this.side_points.get(i%this.sides).y);
    }
    if (this.editing_points==true) {
      for (JEditLine l : this.edit_lines) {
        l.draw();
      }
      for (JEditPoint p : this.l_edit_points) {
        p.draw();
      }
    }
    if (this.weighting_points==true) {
      for (JWeightLine l : this.weight_lines) {
        l.draw();
      }
    }
    if (this.highlight==true) {
      fill(230, 30, 40);
      noStroke();
      circle(this.pos.x, this.pos.y, this.ENGINE.POS_DRAG_RADIUS*2);
    }
    if (this.highlight==false&&this.ENGINE.DRAGGING_OBJECT==1) {
      for (JPoint p : this.side_c_points) {
        p.draw();
      }
    }
    scale(this.ENGINE.ZOOM_OUT);
    translate(this.ENGINE.OFF_X, this.ENGINE.OFF_Y);
  }
  void draw_roadmap() {
    if (this.editing_points==true||this.weighting_points==true) {
      this.editing_points=false;
      this.ENGINE.EDITING_JUNCTION=false;
      this.highlight=true;
    }
    translate(-this.ENGINE.OFF_X, -this.ENGINE.OFF_Y);
    scale(1/this.ENGINE.ZOOM_OUT);
    beginShape();
    fill(30);
    noStroke();
    for (PVector p : this.side_points) {
      vertex(p.x, p.y);
    }
    endShape(CLOSE);
    strokeWeight(2);
    stroke(255);
    for (int i=1; i<=this.sides; i++) {
      if (this.side_c_points.get(i-1).r_in==null) {
        line(this.side_points.get(i-1).x, this.side_points.get(i-1).y, this.side_points.get(i%this.sides).x, this.side_points.get(i%this.sides).y);
      } else {
        ArrayList<PVector> l=this.side_c_points.get(i-1).r_in.get_bound_pos(this);
        PVector A=l.get(0), B=l.get(1), C=l.get(2);
        line(this.side_points.get(i-1).x, this.side_points.get(i-1).y, A.x, A.y);
        line(C.x, C.y, this.side_points.get(i%this.sides).x, this.side_points.get(i%this.sides).y);
        noStroke();
        fill(255);
        this.draw_triangle_strip(A, B);
        noFill();
        stroke(255);
      }
    }
    scale(this.ENGINE.ZOOM_OUT);
    translate(this.ENGINE.OFF_X, this.ENGINE.OFF_Y);
  }
  void draw_triangle_strip(PVector s, PVector e) {
    float cx=s.x/2+e.x/2;
    float cy=s.y/2+e.y/2;
    int d=int(dst(s.x, s.y, e.x, e.y));
    float off=(d-max(int(d/this.ENGINE.JUNCTION_TRIANGLE_SIZE), 1)*this.ENGINE.JUNCTION_TRIANGLE_SIZE)/2/max(int(d/this.ENGINE.JUNCTION_TRIANGLE_SIZE), 1);
    float ang=ang(s.x, s.y, e.x, e.y);
    for (int i=0; i<max(d/this.ENGINE.JUNCTION_TRIANGLE_SIZE, 1); i++) {
      float yoff=map(i, 0, max(d/this.ENGINE.JUNCTION_TRIANGLE_SIZE, 1), -d/2, d/2)+this.ENGINE.JUNCTION_TRIANGLE_SIZE/2+off;
      PVector a=rot_point(cx, cy+yoff+(float)this.ENGINE.JUNCTION_TRIANGLE_SIZE/4, cx, cy, ang);
      PVector b=rot_point(cx, cy+yoff-(float)this.ENGINE.JUNCTION_TRIANGLE_SIZE/4, cx, cy, ang);
      PVector c=rot_point(cx+(float)this.ENGINE.JUNCTION_TRIANGLE_SIZE/3, cy+yoff, cx, cy, ang);
      beginShape();
      vertex(a.x, a.y);
      vertex(b.x, b.y);
      vertex(c.x, c.y);
      endShape(CLOSE);
    }
  }



  void fromJSON(JSONObject json) {
    this.side_points=new ArrayList<PVector>();
    this.side_c_points=new ArrayList<JPoint>();
    this.l_edit_points=new ArrayList<JEditPoint>();
    this.connections=new ArrayList<int[]>();
    this.edit_lines=new ArrayList<JEditLine>();
    this.LIGHTS=new LightObject(this.ENGINE, this);
    this.pos=new PVector(json.getJSONObject("pos").getInt("x"), json.getJSONObject("pos").getInt("y"));
    this.radius=json.getInt("radius");
    this.offset_angle=(float)json.getInt("angle")/(180/PI);
    this.sides=json.getInt("sides");
    this.conns=json.getJSONArray("connections");
    JSONArray a=json.getJSONArray("j-connections");
    for (int i=0; i<a.size(); i++) {
      if (a.get(i).getClass().getCanonicalName().indexOf("Null")>-1) {
        continue;
      }
      JSONObject o=a.getJSONObject(i);
      int[] nc={o.getInt("a"), o.getInt("b"), o.getInt("w")};
      this.connections.add(nc);
    }
    this.ID=json.getInt("id");
    this.update_side_points(0);
    this.lgt_json=json.getJSONObject("lights");
  }
  JSONObject toJSON() {
    JSONObject json=new JSONObject();
    JSONArray conns=new JSONArray();
    JSONObject pos=new JSONObject();
    JSONArray j_conns=new JSONArray();
    int i=0;
    for (JPoint p : this.side_c_points) {
      conns.setInt(i, (p.r_in!=null?p.r_in.ID:-1));
      i++;
    }
    int[] nc;
    JSONObject c;
    for (i=0; i<this.connections.size(); i++) {
      nc=this.connections.get(i);
      if (nc==null||nc.length<3) {
        continue;
      }
      c=new JSONObject();
      c.setInt("a", nc[0]);
      c.setInt("b", nc[1]);
      c.setInt("w", nc[2]);
      j_conns.setJSONObject(i, c);
    }
    pos.setInt("x", int(this.pos.x));
    pos.setInt("y", int(this.pos.y));
    json.setJSONObject("pos", pos);
    json.setInt("radius", this.radius);
    json.setInt("angle", int(this.offset_angle*(180/PI)));
    json.setInt("sides", this.sides);
    json.setJSONArray("connections", conns);
    json.setJSONArray("j-connections", j_conns);
    json.setJSONObject("lights", this.LIGHTS.to_json());
    json.setInt("id", this.ID);
    json.setString("type", "junction");
    return json;
  }
}
