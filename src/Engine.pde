class Engine {
  Map MAP;
  RMap RMAP;
  InfoText INFOTEXT;
  TextBox TEXTBOX;
  int WINDOW_SCALE_SIZE=8;
  int SCROLL_STEP=10;
  int WIDTH=width*WINDOW_SCALE_SIZE;
  int HEIGHT=height*WINDOW_SCALE_SIZE;
  int OFF_X=0;
  int OFF_Y=0;
  float ZOOM_OUT=1;
  float MIN_ZOOM_OUT=0.5;
  int MAX_ZOOM_OUT=WINDOW_SCALE_SIZE;
  float MAX_EDIT_ZOOM_OUT=1.5;
  String BOARD_NAME="test.json";
  float REAL_LANE_WIDTH=3.5;
  int MIN_ROAD_LEN=100;
  int POS_DRAG_RADIUS=10;
  int MAX_LANES=300;
  int MIN_LANES=1;
  float SECONDS_UNTIL_SAVE=0.5;
  int ARR_DIST=100;
  int ARR_LEN=40;
  int CROSSING_WIDTH=20;
  int CROSSING_HEIGHT=8;
  int CROSSING_GAP=5;
  int CROSSING_LIGHT_OFFSET=40;
  int MIN_JUNCTION_WIDTH=150;
  int MAX_CONNECT_DIST=20;
  int MIN_JUNCTION_RADIUS=150;
  int MAX_JUNCTION_RADIUS=600;
  int MIN_JUNCTION_SIDES=3;
  int MAX_JUNCTION_SIDES=8;
  int JUNCTION_RADIUS_INCREMENT=10;
  float JUNCTION_ANGLE_INCREMENT=PI/50;
  int LANE_DASH_DIST=40;
  int JUNCTION_TRIANGLE_SIZE=20;
  float REAL_CAR_WIDTH=4.7;
  int CAR_WIDTH=50;
  float CAR_SIZE_RATIO=1.9/4.7;
  int DRAGGING_OBJECT=0;
  ArrayList<Road> ROADS;
  ArrayList<Junction> JUNCTIONS;
  ArrayList<Car> CARS;
  boolean ROADMAP_VIEW=!true;
  boolean DRAW_ARROWS=true;
  boolean LANE_LINES=!true;
  boolean EDITING_JUNCTION=false;
  boolean RUNNING=false;
  boolean INFOTEXT_VISIBLE=true;
  boolean WEIGHTING_JUNCTION=false;
  boolean EDITING_ROAD_INPUT=false;
  boolean EDITING_LIGHTS=false;
  boolean SIMULATION_PAUSED=false;
  int MAX_CARS=1000;
  int MAX_CARS_PER_TICK=1;
  int MAX_CAR_ADD_TRY_PER_TICK=1;
  float SIMULATION_RESET_TIME=10;
  Junction updating_junction=null;
  RWeightPoint updating_rpoint=null;
  Light updating_light=null;
  RLightObject updating_r_light;
  int LANE_WIDTH;
  int CAR_HEIGHT;
  boolean clicked=false;
  boolean key_pressed=false;
  boolean highlight=false;
  int sim_s_time=0;
  int c_in=0;
  int c_out=0;
  PVector MOUSE;
  List<IntList> road_weights;



  Engine() {
    this.MOUSE=new PVector((mouseX+this.OFF_X)*this.ZOOM_OUT, (mouseY+this.OFF_Y)*this.ZOOM_OUT);
    this.LANE_WIDTH=int(m_to_px(REAL_LANE_WIDTH, this));
    this.CAR_HEIGHT=int(CAR_WIDTH*CAR_SIZE_RATIO);
    this.ROADS=new ArrayList<Road>();
    this.JUNCTIONS=new ArrayList<Junction>();
    this.CARS=new ArrayList<Car>();
    this.MAP=new Map(this);
    this.RMAP=new RMap(this);
    this.INFOTEXT=new InfoText(this);
    this.TEXTBOX=new TextBox(this);
    this.road_weights=new ArrayList<IntList>();
  }



  void new_road() {
    if (this.ROADMAP_VIEW==true||this.RUNNING==true) {
      return;
    }
    this.ROADS.add(new Road(this));
  }
  void new_junction() {
    if (this.ROADMAP_VIEW==true||this.RUNNING==true) {
      return;
    }
    this.JUNCTIONS.add(new Junction(this));
  }



  void delete_all() {
    while (this.ROADS.size()>0) {
      this.ROADS.get(0).delete();
    }
    while (this.JUNCTIONS.size()>0) {
      this.JUNCTIONS.get(0).delete();
    }
  }



  void update_weight() {
    if (this.WEIGHTING_JUNCTION==true) {
      if (this.updating_junction==null) {
        return;
      }
      this.updating_junction.update_weight(int(this.TEXTBOX.text));
      this.updating_junction=null;
    }
    if (this.EDITING_ROAD_INPUT==true) {
      if (this.updating_rpoint==null) {
        return;
      }
      this.updating_rpoint.set_weight(int(this.TEXTBOX.text));
      this.updating_rpoint=null;
    }
    if (this.EDITING_LIGHTS==true&&this.updating_light!=null) {
      this.updating_light.set_weight(int(this.TEXTBOX.text));
      this.updating_light=null;
    }
    if (this.EDITING_LIGHTS==true&&this.updating_r_light!=null) {
      this.updating_r_light.set_weight(int(this.TEXTBOX.text));
      this.updating_r_light=null;
    }
  }




  void start_running() {
    if (this.RUNNING==true||this.EDITING_JUNCTION==true||this.WEIGHTING_JUNCTION==true) {
      return;
    }
    this.sim_s_time=millis();
    this.RUNNING=true;
    this.ROADMAP_VIEW=!true;
    this.updating_junction=null;
    this.WEIGHTING_JUNCTION=false;
    this.EDITING_JUNCTION=false;
    this.EDITING_ROAD_INPUT=false;
    this.SIMULATION_PAUSED=false;
    this.toggle_roadmap_view();
    this.c_in=0;
    this.c_out=0;
    this.INFOTEXT.update_keys();
    this.save_JSON();
    this.RMAP.update_l_lst();
    this.CARS=new ArrayList<Car>();
  }
  void stop_running() {
    if (this.RUNNING==false) {
      return;
    }
    this.RUNNING=false;
    this.ROADMAP_VIEW=false;
    this.SIMULATION_PAUSED=false;
    this.c_in=0;
    this.c_out=0;
    this.INFOTEXT.update_keys();
    this.CARS=new ArrayList<Car>();
  }
  void reset_running() {
    this.stop_running();
    this.start_running();
  }



  void toggle_roadmap_view() {
    this.ROADMAP_VIEW=!this.ROADMAP_VIEW;
    for (Junction j : this.JUNCTIONS) {
      j.LIGHTS.reset();
    }
    for (Road r : this.ROADS) {
      r.LIGHTS.reset();
    }
    for (Road r : this.ROADS) {
      r.update_lines();
    }
    for (Road r : this.ROADS) {
      r.update_lines();
    }
    for (Junction j : this.JUNCTIONS) {
      j.update_lines();
    }
  }



  void keyPressed(int keyCode) {
    if (keyCode==78&&this.ZOOM_OUT<=this.MAX_EDIT_ZOOM_OUT&&this.highlight==false&&this.RUNNING==false&&this.ROADMAP_VIEW==false&&this.EDITING_LIGHTS==false) {
      this.new_road();
    }
    if (keyCode==77&&this.ZOOM_OUT<=this.MAX_EDIT_ZOOM_OUT&&this.highlight==false&&this.RUNNING==false&&this.ROADMAP_VIEW==false&&this.EDITING_LIGHTS==false) {
      this.new_junction();
    }
    if (keyCode==SHIFT) {
      SHIFT_DOWN=true;
    }
    if (keyCode==CONTROL) {
      CTRL_DOWN=true;
    }
    if (keyCode==ALT) {
      ALT_DOWN=true;
    }
    if (KEY_DOWN==false) {
      KEY_DOWN=true;
      if (keyCode==69) {
        this.toggle_roadmap_view();
      }
      if (keyCode==65) {
        this.DRAW_ARROWS=!this.DRAW_ARROWS;
      }
      if (keyCode==84) {
        this.LANE_LINES=!this.LANE_LINES;
      }
      if (keyCode==83&&CTRL_DOWN==false) {
        if (this.RUNNING==false) {
          this.start_running();
        } else {
          this.stop_running();
        }
      }
      if (keyCode==83) {
        if (this.RUNNING==true&&CTRL_DOWN==true) {
          this.reset_running();
        }
      }
      if (keyCode==80) {
        if (this.RUNNING==true) {
          this.SIMULATION_PAUSED=!this.SIMULATION_PAUSED;
        }
      }
      if (keyCode==81) {
        this.INFOTEXT_VISIBLE=!this.INFOTEXT_VISIBLE;
      }
      if (this.ZOOM_OUT<=this.MAX_EDIT_ZOOM_OUT&&CTRL_DOWN==true&&SHIFT_DOWN==true&&keyCode==DELETE&&this.highlight==false&&this.RUNNING==false&&this.ROADMAP_VIEW==false&&this.EDITING_LIGHTS==false) {
        this.delete_all();
      }
    }
    this.TEXTBOX.keypress(key, keyCode);
    if (this.RUNNING==true||this.highlight==false) {
      if (CTRL_DOWN==false&&SHIFT_DOWN==false) {
        switch(keyCode) {
        case 37:
          this.OFF_X-=this.SCROLL_STEP;
          break;
        case 39:
          this.OFF_X+=this.SCROLL_STEP;
          break;
        case 40:
          this.OFF_Y+=this.SCROLL_STEP;
          break;
        case 38:
          this.OFF_Y-=this.SCROLL_STEP;
          break;
        }
        this.OFF_X=(int)min(max(this.OFF_X, 0), this.WIDTH-width*this.ZOOM_OUT);
        this.OFF_Y=(int)min(max(this.OFF_Y, 0), this.HEIGHT-height*this.ZOOM_OUT);
      }
      if (CTRL_DOWN==true&&SHIFT_DOWN==false) {
        switch(keyCode) {
        case 37:
          this.OFF_X=0;
          break;
        case 39:
          this.OFF_X=int(this.WIDTH-width*this.ZOOM_OUT);
          break;
        case 40:
          this.OFF_Y=int(this.HEIGHT-height*this.ZOOM_OUT);
          break;
        case 38:
          this.OFF_Y=0;
          break;
        }
      }
      if (CTRL_DOWN==false&&SHIFT_DOWN==true) {
        switch(keyCode) {
        case 40:
          this.ZOOM_OUT+=0.5;
          break;
        case 38:
          this.ZOOM_OUT-=0.5;
          break;
        }
        this.ZOOM_OUT=min(max(this.ZOOM_OUT, this.MIN_ZOOM_OUT), this.MAX_ZOOM_OUT);
        this.OFF_X=(int)min(max(this.OFF_X, 0), this.WIDTH-width*this.ZOOM_OUT);
        this.OFF_Y=(int)min(max(this.OFF_Y, 0), this.HEIGHT-height*this.ZOOM_OUT);
        if (this.OFF_X<0) {
          this.OFF_X=0;
        }
        if (this.OFF_Y<0) {
          this.OFF_Y=0;
        }
      }
    }
  }
  void keyReleased(int keyCode) {
    KEY_DOWN=false;
    if (keyCode==SHIFT) {
      SHIFT_DOWN=false;
    }
    if (keyCode==CONTROL) {
      CTRL_DOWN=false;
    }
    if (keyCode==ALT) {
      ALT_DOWN=false;
    }
  }
  void mouseReleased() {
    this.clicked=false;
    if (this.DRAGGING_OBJECT>0) {
      for (Road r : this.ROADS) {
        if (r.DRAGGING>0) {
          return;
        }
      }
      this.DRAGGING_OBJECT=0;
      for (Road r : this.ROADS) {
        r.highlight=false;
        r.DRAGGING=0;
      }
    }
  }



  void update() {
    this.MOUSE=new PVector((mouseX+this.OFF_X)*this.ZOOM_OUT, (mouseY+this.OFF_Y)*this.ZOOM_OUT);
    if (this.RUNNING==false) {
      this.highlight=false;
      for (Road r : this.ROADS) {
        if (r.highlight==true||r.DRAGGING>0||r.LIGHTS.editing==true) {
          this.highlight=true;
        }
      }
      for (Junction j : this.JUNCTIONS) {
        if (j.highlight==true||j.DRAGGING>0||j.editing_points==true||j.weighting_points==true||j.editing_lights==true) {
          this.highlight=true;
        }
      }
      boolean ex=false;
      if (mousePressed==true&&this.ROADMAP_VIEW==false&&this.EDITING_JUNCTION==false&&this.WEIGHTING_JUNCTION==false&&this.updating_junction==null&&this.highlight==false) {
        if (CTRL_DOWN==true&&this.clicked==false&&this.EDITING_ROAD_INPUT==false&&this.EDITING_LIGHTS==false) {
          this.clicked=true;
          this.EDITING_ROAD_INPUT=true;
        }
        if (CTRL_DOWN==true&&this.clicked==false&&this.EDITING_ROAD_INPUT==true&&this.EDITING_LIGHTS==false) {
          this.clicked=true;
          this.EDITING_ROAD_INPUT=false;
          ex=true;
        }
      }
      int ep=0, rep=0;
      for (int i=0; i<this.ROADS.size(); i++) {
        this.ROADS.get(i).update(ex);
        if (this.ROADS.size()>i&&this.ROADS.get(i).LIGHTS.editing==true) {
          rep=1;
        }
      }
      for (int i=0; i<this.JUNCTIONS.size(); i++) {
        this.JUNCTIONS.get(i).update(ex);
        if (this.JUNCTIONS.size()>i&&this.JUNCTIONS.get(i).editing_points==true) {
          ep=1;
        }
        if (this.JUNCTIONS.size()>i&&this.JUNCTIONS.get(i).weighting_points==true) {
          ep=2;
        }
        if (this.JUNCTIONS.size()>i&&this.JUNCTIONS.get(i).editing_lights==true) {
          ep=3;
        }
      }
      if (this.highlight==false&&ep==0&&rep==0) {
        this.INFOTEXT.reset_sel();
      }
      this.INFOTEXT.update_m(ep, rep);
      this.INFOTEXT.update_keys();
      if (frameCount%(this.SECONDS_UNTIL_SAVE*30)==0) {
        this.save_JSON();
      }
    } else {
      if (this.SIMULATION_PAUSED==false) {
        for (int i=this.CARS.size()-1; i>=0; i--) {
          this.CARS.get(i).update();
        }
        if (this.CARS.size()<this.MAX_CARS&&this.get_car_road()!=null) {
          int start=this.CARS.size()+0;
          int i=0;
          while (true) {
            if (this.CARS.size()>=this.MAX_CARS||(this.CARS.size()-start)>=this.MAX_CARS_PER_TICK||i>=this.MAX_CAR_ADD_TRY_PER_TICK) {
              break;
            }
            Car c=new Car(this);
            c.update();
            if (c.get_min_dist()>=c.MIN_CAR_COLLISION_DIST) {
              this.CARS.add(c);
            }
            i++;
          }
        }
      } else {
        this.sim_s_time=millis();
      }
      if (millis()-this.SIMULATION_RESET_TIME*60*1000>=this.sim_s_time) {
        this.stop_running();
        this.start_running();
      }
      this.INFOTEXT.update_m(0, 0);
    }
    if (this.ROADMAP_VIEW==true||this.EDITING_LIGHTS==true) {
      for (Junction j : this.JUNCTIONS) {
        j.LIGHTS.update();
      }
      for (Road r : this.ROADS) {
        r.LIGHTS.update();
      }
    }
    this.u_cursor();
  }
  void u_cursor() {
    if (this.RUNNING==true||this.ROADMAP_VIEW==true) {
      cursor(CROSS);
    } else {
      if (this.DRAGGING_OBJECT>0) {
        cursor(MOVE);
      } else {
        if (this.TEXTBOX.visible==true) {
          cursor(TEXT);
        } else {
          cursor(ARROW);
        }
      }
    }
  }



  RLine get_car_road() {
    ArrayList<RLine> d=new ArrayList<RLine>();
    for (int i=0; i<this.road_weights.size(); i++) {
      IntList l=this.road_weights.get(i);
      if (l==null) {
        continue;
      }
      for (int j=0; j<l.size(); j++) {
        if (l.get(j)==-1) {
          continue;
        }
        RLine ln=this.RMAP.LINES.get(i).get(j);
        for (int k=0; k<l.get(j); k++) {
          d.add(ln);
        }
      }
    }
    if (d.size()==0) {
      return null;
    }
    return d.get(int(random(1)*d.size()));
  }



  void draw() {
    background(0);
    if (this.RUNNING==false) {
      if (this.ROADMAP_VIEW==false) {
        this.draw_map();
      } else {
        this.draw_roadmap();
      }
    } else {
      this.draw_roadmap();
      for (Car c : this.CARS) {
        c.draw();
      }
    }
    if (this.EDITING_LIGHTS==true) {
      for (Junction j : this.JUNCTIONS) {
        j.LIGHTS.draw();
      }
    }
    if (this.INFOTEXT_VISIBLE==true) {
      this.INFOTEXT.draw();
    }
    this.TEXTBOX.draw();
  }
  void draw_map() {
    for (int i=0; i<this.ROADS.size(); i++) {
      if (this.ROADS.get(i).highlight==true||this.ROADS.get(i).DRAGGING>0) {
        continue;
      }
      this.ROADS.get(i).draw();
    }
    for (int i=0; i<JUNCTIONS.size(); i++) {
      if (this.JUNCTIONS.get(i).highlight==true||this.JUNCTIONS.get(i).DRAGGING>0) {
        continue;
      }
      this.JUNCTIONS.get(i).draw();
    }
    for (int i=0; i<ROADS.size(); i++) {
      if (this.ROADS.get(i).highlight==false&&this.ROADS.get(i).DRAGGING==0) {
        continue;
      }
      this.ROADS.get(i).draw();
      break;
    }
    for (int i=0; i<this.JUNCTIONS.size(); i++) {
      if (JUNCTIONS.get(i).highlight==false&&this.JUNCTIONS.get(i).DRAGGING==0) {
        continue;
      }
      this.JUNCTIONS.get(i).draw();
      break;
    }
  }
  void draw_roadmap() {
    for (Road r : this.ROADS) {
      r.draw_roadmap();
    }
    for (Junction j : this.JUNCTIONS) {
      j.draw_roadmap();
    }
    for (Junction j : this.JUNCTIONS) {
      j.LIGHTS.draw();
    }
    this.RMAP.draw();
  }



  void from_JSON(JSONObject json) {
    JSONArray b=json.getJSONArray("board");
    JSONObject conns=json.getJSONObject("conns");
    this.ROADS=new ArrayList<Road>();
    this.JUNCTIONS=new ArrayList<Junction>();
    this.CARS=new ArrayList<Car>();
    this.road_weights=new ArrayList<IntList>();
    for (int i=0; i<b.size(); i++) {
      JSONObject j=b.getJSONObject(i);
      if (j.getString("type").equals("road")) {
        Road rd=new Road(this, j);
        this.ROADS.add(rd);
      }
      if (j.getString("type").equals("junction")) {
        Junction jt=new Junction(this, j);
        this.JUNCTIONS.add(jt);
      }
    }
    for (Road r : ROADS) {
      JSONObject o=conns.getJSONObject(str(r.ID));
      while (this.road_weights.size()<=r.ID) {
        this.road_weights.add(null);
      }
      if (o==null) {
        this.road_weights.set(r.ID, null);
      } else {
        IntList l=new IntList();
        for (Object k : o.keys().toArray()) {
          while (l.size()<int(k.toString())) {
            l.append(-1);
          }
          l.set(int(k.toString()), o.getInt(k.toString()));
        }
        this.road_weights.set(r.ID, l);
      }
    }
    for (Road r : this.ROADS) {
      r.set_connections();
    }
    for (Junction j : this.JUNCTIONS) {
      j.set_connections();
    }
    this.toggle_roadmap_view();
  }
  void save_JSON() {
    JSONObject json=new JSONObject();
    JSONObject conns=new JSONObject();
    JSONArray data=new JSONArray();
    int i=0;
    for (IntList cl : this.road_weights) {
      if (cl!=null) {
        JSONObject l=new JSONObject();
        for (int j=0; j<cl.size(); j++) {
          int v=cl.get(j);
          if (v==-1) {
            continue;
          }
          l.setInt(str(j), v);
        }
        conns.setJSONObject(str(i), l);
      }
      i++;
    }
    for (i=0; i<this.ROADS.size(); i++) {
      data.setJSONObject(i, this.ROADS.get(i).toJSON());
    }
    for (i=0; i<this.JUNCTIONS.size(); i++) {
      data.setJSONObject(this.ROADS.size()+i, this.JUNCTIONS.get(i).toJSON());
    }
    json.setJSONArray("board", data);
    json.setJSONObject("conns", conns);
    saveJSONObject(json, "./data/"+this.BOARD_NAME);
  }



  int gen_ID() {
    IntList used=new IntList();
    for (Road r : this.ROADS) {
      used.append(r.ID);
    }
    for (Junction j : this.JUNCTIONS) {
      used.append(j.ID);
    }
    int id=0;
    while (true) {
      if (!used.hasValue(id)) {
        return id;
      }
      id++;
    }
  }
}
