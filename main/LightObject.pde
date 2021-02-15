class LightObject {
  Engine ENGINE;
  Junction j=null;
  ArrayList<Light> lights;
  JSONObject json;
  boolean setup=false;



  LightObject(Engine ENGINE, Junction j) {
    this.ENGINE=ENGINE;
    this.j=j;
  }



  void reset() {
    if (this.lights==null){
      return;
    }
    for (Light l : this.lights) {
      l.reset();
    }
  }



  void edit_lights() {
    if (this.lights==null){
      return;
    }
    for (Light l : this.lights) {
      l.edit=true;
    }
  }
  void stop_edit_lights() {
    if (this.lights==null){
      return;
    }
    for (Light l : this.lights) {
      l.edit=false;
    }
  }



  void update() {
    if (this.lights==null){
      return;
    }
    for (Light l : this.lights) {
      l.update();
    }
  }



  void draw() {
    if (this.lights==null){
      return;
    }
    for (Light l : this.lights) {
      l.draw();
    }
  }




  void from_junction() {
    if (this.lights==null) {
      this.lights=new ArrayList<Light>();
      for (JEditPoint p : this.j.l_edit_points) {
        if (p.type!=0) {
          continue;
        }
        this.lights.add(new Light(this.ENGINE, p.pos.copy(), p.conn_idx, this, p));
      }
    } else {
      ArrayList<JEditPoint> done=new ArrayList<JEditPoint>();
      for (int i=this.lights.size()-1; i>=0; i--) {
        Light l=this.lights.get(i);
        boolean r=false;
        for (JEditPoint p : this.j.l_edit_points) {
          if (p.type!=0) {
            continue;
          }
          if (p.conn_idx==l.p.conn_idx) {
            r=true;
            l.pos=p.pos.copy();
            break;
          }
        }
        if (r==true) {
          done.add(l.p);
        } else {
          this.lights.remove(i);
        }
      }  
      for (JEditPoint p : this.j.l_edit_points) {
        if (p.type!=0) {
          continue;
        }
        boolean s=true;
        for (JEditPoint p2 : done) {
          if (p.conn_idx==p2.conn_idx) {
            s=false;
            break;
          }
        }
        if (s==true) {
          this.lights.add(new Light(this.ENGINE, p.pos.copy(), p.conn_idx, this, p));
        }
      }
    }
  }
  void from_json(JSONObject json) {
    if (this.setup==true) {
      return;
    }
    this.setup=true;
    for (Object k : json.keys()) {
      for (Light l : this.lights) {
        if (l.n==int(k.toString())) {
          JSONObject o=json.getJSONObject(k.toString());
          l.RED_TIME=o.getInt("red");
          l.GREEN_TIME=o.getInt("green");
          l.ORANGE_TIME=o.getInt("orange");
          l.OFFSET_TIME=o.getInt("offset");
          break;
        }
      }
    }
  }
  JSONObject to_json() {
    JSONObject json=new JSONObject();
    if (this.lights==null) {
      return json;
    }
    for (Light l : this.lights) {
      JSONObject o=new JSONObject();
      o.setInt("red", l.RED_TIME);
      o.setInt("green", l.GREEN_TIME);
      o.setInt("orange", l.ORANGE_TIME);
      o.setInt("offset", l.OFFSET_TIME);
      json.setJSONObject(str(l.n), o);
    }
    return json;
  }
}
