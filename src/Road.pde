class Road{
	Engine engine;
	PVector start;
	PVector end;
	int lanesA;
	int lanesB;
	boolean highlight;
	boolean connected;
	boolean CLICK=false;
	int DRAGGING=0;
	boolean KEYDOWN=false;
	int ID;
	Road r_st;
	Road r_ed;
	Junction j_st;
	Junction j_ed;
	JSONObject conns;
	RoadLightObject LIGHTS;
	ArrayList<RoadWeightPoint> weight_points=null;



	Road(Engine engine){
		this.engine=engine;
		this.start=new PVector(this.engine.MOUSE.x-this.engine.MIN_ROAD_LEN,this.engine.MOUSE.y);
		this.end=new PVector(this.engine.MOUSE.x+this.engine.MIN_ROAD_LEN,this.engine.MOUSE.y);
		this.lanesA=this.engine.MIN_LANES;
		this.lanesB=this.engine.MIN_LANES;
		this.highlight=false;
		this.connected=false;
		this.ID=this.engine.gen_id();
		this.r_st=null;
		this.r_ed=null;
		this.j_st=null;
		this.j_ed=null;
		this.LIGHTS=new RoadLightObject(this.engine,this);
		this.update_lines();
	}



	Road(Engine engine,JSONObject road_data){
		this.engine=engine;
		this.highlight=false;
		this.connected=false;
		this.r_st=null;
		this.r_ed=null;
		this.j_st=null;
		this.j_ed=null;
		this.from_json(road_data);
		this.update_lines();
	}



	void update(boolean ex){
		if (this.engine.EDITING_ROAD_INPUT==true&&this.weight_points!=null){
			for (RoadWeightPoint p:this.weight_points){
				p.update();
			}
		}
		if (this.engine.ROADMAP_VIEW==true||this.engine.RUNNING==true||this.engine.EDITING_JUNCTION==true||this.engine.WEIGHTING_JUNCTION==true||this.engine.updating_junction!=null||this.engine.EDITING_ROAD_INPUT==true){
			this.highlight=false;
			this.DRAGGING=0;
			return;
		}
		if (mousePressed==true&&this.CLICK==false){
			this.CLICK=true;
			PVector[] verts=new PVector[4];
			verts[0]=rot_point(this.start.x-this.lanesA*this.engine.LANE_WIDTH,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			verts[1]=rot_point(this.start.x+this.lanesB*this.engine.LANE_WIDTH,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			verts[3]=rot_point(this.end.x-this.lanesA*this.engine.LANE_WIDTH,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			verts[2]=rot_point(this.end.x+this.lanesB*this.engine.LANE_WIDTH,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			boolean c=collisionPointPoly(this.engine.MOUSE.x,this.engine.MOUSE.y,verts);
			if (c==false&&this.DRAGGING>0){
				this.DRAGGING=0;
				this.engine.DRAGGING_OBJECT=0;
				this.highlight=true;
			}
			if (c==true&&SHIFT_DOWN==true&&CTRL_DOWN==true&&ALT_DOWN==false&&this.LIGHTS.enabled==false&&ex==false&&this.j_st==null&&this.j_ed==null){
				c=false;
				this.LIGHTS.enabled=true;
			}
			if (c==true&&SHIFT_DOWN==true&&CTRL_DOWN==true&&ALT_DOWN==false&&this.LIGHTS.enabled==true&&ex==false&&this.j_st==null&&this.j_ed==null){
				c=false;
				this.LIGHTS.enabled=false;
			}
			if (c==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&ALT_DOWN==false&&this.LIGHTS.enabled==true&&this.LIGHTS.editing==false&&ex==false){
				this.engine.EDITING_LIGHTS=true;
				this.highlight=false;
				c=false;
				this.LIGHTS.editing=true;
			}
			if (c==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&ALT_DOWN==false&&this.LIGHTS.enabled==true&&this.LIGHTS.editing==true&&ex==false){
				this.engine.EDITING_LIGHTS=false;
				this.highlight=true;
				c=false;
				this.LIGHTS.editing=false;
			}
			if (this.engine.EDITING_LIGHTS==false&&this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&dst(this.start.x,this.start.y,this.engine.MOUSE.x,this.engine.MOUSE.y)<=this.engine.POS_DRAG_RADIUS&&this.engine.DRAGGING_OBJECT==0&&this.j_st==null&&this.highlight==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&ALT_DOWN==false){
				c=false;
				this.DRAGGING=1;
				this.engine.DRAGGING_OBJECT=1;
			}
			if (this.engine.EDITING_LIGHTS==false&&this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&dst(this.end.x,this.end.y,this.engine.MOUSE.x,this.engine.MOUSE.y)<=this.engine.POS_DRAG_RADIUS&&this.engine.DRAGGING_OBJECT==0&&this.j_ed==null&&this.highlight==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&ALT_DOWN==false){
				c=false;
				this.DRAGGING=2;
				this.engine.DRAGGING_OBJECT=1;
			}
			if (this.engine.EDITING_LIGHTS==false&&this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&dst(this.start.x/2+this.end.x/2,this.start.y/2+this.end.y/2,this.engine.MOUSE.x,this.engine.MOUSE.y)<=this.engine.POS_DRAG_RADIUS&&this.engine.DRAGGING_OBJECT==0&&this.j_st==null&&this.j_ed==null&&this.highlight==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&ALT_DOWN==false){
				c=false;
				this.DRAGGING=3;
				this.engine.DRAGGING_OBJECT=1;
			}
			if (this.engine.EDITING_LIGHTS==false&&c==true&&this.highlight==false&&SHIFT_DOWN==false&&CTRL_DOWN==false&&ALT_DOWN==false){
				this.highlight=true;
			}
			if (this.engine.EDITING_LIGHTS==false&&c==false&&this.highlight==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&ALT_DOWN==false){
				this.highlight=false;
			}
			if (this.engine.EDITING_LIGHTS==false&&this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&SHIFT_DOWN==true&&CTRL_DOWN==false&&ALT_DOWN==false&&c==true){
				if (this.r_st!=null){
					this.r_st.get_r_pos(this).y+=this.engine.MAX_CONNECT_DIST;
					this.start.y-=this.engine.MAX_CONNECT_DIST;
					this.r_st.rm_r(this);
				}
				if (this.r_ed!=null){
					this.r_ed.get_r_pos(this).y+=this.engine.MAX_CONNECT_DIST;
					this.end.y-=this.engine.MAX_CONNECT_DIST;
					this.r_ed.rm_r(this);
				}
				if (this.j_st!=null){
					this.j_st.rm_r(this);
				}
				if (this.j_ed!=null){
					this.j_ed.rm_r(this);
				}
				this.r_st=null;
				this.r_ed=null;
				this.j_st=null;
				this.j_ed=null;
			}
		}
		if (mousePressed==false&&this.CLICK==true){
			if (this.DRAGGING>0){
				this.DRAGGING=0;
				this.engine.DRAGGING_OBJECT=0;
				this.highlight=true;
			}
			this.CLICK=false;
		}
		if (mousePressed==true){
			if (this.DRAGGING==1){
				if (dst(this.end.x,this.end.y,this.engine.MOUSE.x,this.engine.MOUSE.y)>=this.engine.MIN_ROAD_LEN){
					this.start.x=this.engine.MOUSE.x;
					this.start.y=this.engine.MOUSE.y;
				}
				else{
					float a=ang(this.engine.MOUSE.x,this.engine.MOUSE.y,this.end.x,this.end.y)-PI/2;
					this.start.x=cos(a)*this.engine.MIN_ROAD_LEN+this.end.x;
					this.start.y=sin(a)*this.engine.MIN_ROAD_LEN+this.end.y;
				}
				if (this.connected==true){
					this.get_connection_pos("start").x=this.start.x;
					this.get_connection_pos("start").y=this.start.y;
				}
				for (Road r:this.engine.ROADS){
					if (r==this){
						continue;
					}
					if (dst(this.start.x,this.start.y,r.start.x,r.start.y)<=this.engine.MAX_CONNECT_DIST){
						if (this.r_st!=null){
							this.r_st.rm_r(this);
						}
						if (r.r_st!=null){
							r.r_st.rm_r(r);
						}
						this.r_st=r;
						r.r_st=this;
						this.connected=true;
						r.connected=true;
					}
					if (dst(this.start.x,this.start.y,r.end.x,r.end.y)<=this.engine.MAX_CONNECT_DIST){
						if (this.r_st!=null){
							this.r_st.rm_r(this);
						}
						if (r.r_ed!=null){
							r.r_ed.rm_r(r);
						}
						this.r_st=r;
						r.r_ed=this;
						this.connected=true;
						r.connected=true;
					}
				}
				for (Junction j:this.engine.JUNCTIONS){
					j.try_connect(this,0);
				}
			}
			if (this.DRAGGING==2){
				if (dst(this.start.x,this.start.y,this.engine.MOUSE.x,this.engine.MOUSE.y)>=this.engine.MIN_ROAD_LEN){
					this.end.x=this.engine.MOUSE.x;
					this.end.y=this.engine.MOUSE.y;
				}
				else{
					float a=ang(this.engine.MOUSE.x,this.engine.MOUSE.y,this.start.x,this.start.y)-PI/2;
					this.end.x=cos(a)*this.engine.MIN_ROAD_LEN+this.start.x;
					this.end.y=sin(a)*this.engine.MIN_ROAD_LEN+this.start.y;
				}
				if (this.connected==true){
					this.get_connection_pos("end").x=this.end.x;
					this.get_connection_pos("end").y=this.end.y;
				}
				for (Road r:this.engine.ROADS){
					if (r==this){
						continue;
					}
					if (dst(this.end.x,this.end.y,r.start.x,r.start.y)<=this.engine.MAX_CONNECT_DIST){
						if (this.r_ed!=null){
							this.r_ed.rm_r(this);
						}
						if (r.r_st!=null){
							r.r_st.rm_r(r);
						}
						this.r_ed=r;
						r.r_st=this;
						this.connected=true;
						r.connected=true;
					}
					if (dst(this.end.x,this.end.y,r.end.x,r.end.y)<=this.engine.MAX_CONNECT_DIST){
						if (this.r_ed!=null){
							this.r_ed.rm_r(this);
						}
						if (r.r_ed!=null){
							r.r_ed.rm_r(r);
						}
						this.r_ed=r;
						r.r_ed=this;
						this.connected=true;
						r.connected=true;
					}
				}
				for (Junction j:this.engine.JUNCTIONS){
					j.try_connect(this,1);
				}
			}
			if (this.DRAGGING==3){
				float xm=this.engine.MOUSE.x-(pmouseX+this.engine.OFF_X)*this.engine.ZOOM_OUT;
				float ym=this.engine.MOUSE.y-(pmouseY+this.engine.OFF_X)*this.engine.ZOOM_OUT;
				this.start.x+=xm;
				this.start.y+=ym;
				this.end.x+=xm;
				this.end.y+=ym;
				this.get_connection_pos("start").x=this.start.x;
				this.get_connection_pos("start").y=this.start.y;
				this.get_connection_pos("end").x=this.end.x;
				this.get_connection_pos("end").y=this.end.y;
			}
		}
		if (keyPressed==true&&this.highlight==true&&this.KEYDOWN==false){
			this.KEYDOWN=true;
			switch(keyCode){
			case UP:
				this.update_lane_width(min(this.lanesA+1,this.engine.MAX_LANES),this.lanesB,new ArrayList<Road>(),null);
				this.update_I_default();
				break;
			case DOWN:
				this.update_lane_width(max(this.lanesA-1,this.engine.MIN_LANES),this.lanesB,new ArrayList<Road>(),null);
				this.update_I_default();
				break;
			case RIGHT:
				this.update_lane_width(this.lanesA,min(this.lanesB+1,this.engine.MAX_LANES),new ArrayList<Road>(),null);
				this.update_I_default();
				break;
			case LEFT:
				this.update_lane_width(this.lanesA,max(this.lanesB-1,this.engine.MIN_LANES),new ArrayList<Road>(),null);
				this.update_I_default();
				break;
			}
			if (key==DELETE){
				this.delete();
			}
		}
		if (keyPressed==false&&this.KEYDOWN==true){
			this.KEYDOWN=false;
		}
		this.start.x=min(max(this.start.x,0),this.engine.WIDTH);
		this.start.y=min(max(this.start.y,0),this.engine.HEIGHT);
		this.end.x=min(max(this.end.x,0),this.engine.WIDTH);
		this.end.y=min(max(this.end.y,0),this.engine.HEIGHT);
		if (this.highlight==true||this.DRAGGING>0){
			for (Road r:this.engine.ROADS){
				if (r==this){
					continue;
				}
				if (r.r_st==this&&r.DRAGGING==1){
					this.DRAGGING=0;
					this.highlight=false;
					continue;
				}
				if (r.r_ed==this&&r.DRAGGING==1){
					this.DRAGGING=0;
					this.highlight=false;
					continue;
				}
				r.highlight=false;
				r.DRAGGING=0;
			}
			for (Junction j:this.engine.JUNCTIONS){
				j.highlight=false;
				j.DRAGGING=0;
				j.editing_points=false;
			}
		}
		if (this.DRAGGING>0){
			this.engine.DRAGGING_OBJECT=1;
		}
		if (this.is_I()==true){
			this.setup_weights();
		}
		else{
			this.clear_weights();
		}
		if (this.highlight==true||this.DRAGGING>0||this.LIGHTS.editing==true){
			this.update_text();
		}
	}



	void update_lane_width(int a,int b,List<Road> used,Road last){
		if (used.contains(this)){
			return;
		}
		used.add(this);
		this.engine.RMAP.remove_lines(this.ID);
		if (last==null){
			this.lanesA=a;
			this.lanesB=b;
		}
		else{
			if ((this.r_st==last&&last.r_st==this)||(this.r_ed==last&&last.r_ed==this)){
				int t=a+0;
				a=b+0;
				b=t+0;
			}
			this.lanesA=a;
			this.lanesB=b;
		}
		if (this.r_st!=null){
			this.r_st.update_lane_width(a,b,used,this);
		}
		if (this.r_ed!=null){
			this.r_ed.update_lane_width(a,b,used,this);
		}
	}



	void update_lines(){
		List<RoadLine> LINES=this.engine.RMAP.get_lines(this.ID);
		if (LINES.size()==0){
			return;
		}
		PVector aa,ab,ba,bb;
		float oa,ob;
		RoadLine L;
		RoadLine sa,sb;
		for (int i=0;i<this.lanesA;i++){
			oa=map(i,0,this.lanesA,-this.engine.LANE_WIDTH,-this.lanesA*this.engine.LANE_WIDTH-this.engine.LANE_WIDTH);
			ob=map(i,0,this.lanesA,-this.engine.LANE_WIDTH,-this.lanesA*this.engine.LANE_WIDTH-this.engine.LANE_WIDTH)+this.engine.LANE_WIDTH;
			aa=rot_point(this.start.x+oa,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			ab=rot_point(this.start.x+ob,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			ba=rot_point(this.end.x+oa,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			bb=rot_point(this.end.x+ob,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			sa=(this.r_st==null?null:(this.r_st.r_st==this?this.engine.RMAP.get_lines(this.r_st.ID).get(this.engine.MAX_LANES+i):this.engine.RMAP.get_lines(this.r_st.ID).get(this.engine.MAX_LANES-1-i)));
			sb=(this.r_ed==null?null:(this.r_ed.r_st==this?this.engine.RMAP.get_lines(this.r_ed.ID).get(this.engine.MAX_LANES-1-i):this.engine.RMAP.get_lines(this.r_ed.ID).get(this.engine.MAX_LANES+i)));
			L=LINES.get(this.engine.MAX_LANES-1-i);
			L.set_pos(lerp(aa,ab,0.5),lerp(ba,bb,0.5));
			L.set_conns(sa,sb);
			L.invertA=(this.r_st!=null&&this.r_st.r_st==this);
			L.invertB=(this.r_ed!=null&&this.r_ed.r_ed==this);
			L.jA=(this.j_st!=null?this.j_st.get_side(this):null);
			L.jB=(this.j_ed!=null?this.j_ed.get_side(this):null);
			L.lA=(i+1==this.lanesA);
			L.lB=false;
			L.r=this;
			L.update();
		}
		for (int i=0;i<this.lanesB;i++){
			oa=map(i,0,this.lanesB,this.engine.LANE_WIDTH,this.lanesB*this.engine.LANE_WIDTH+this.engine.LANE_WIDTH);
			ob=map(i,0,this.lanesB,this.engine.LANE_WIDTH,this.lanesB*this.engine.LANE_WIDTH+this.engine.LANE_WIDTH)-this.engine.LANE_WIDTH;
			aa=rot_point(this.start.x+oa,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			ab=rot_point(this.start.x+ob,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			ba=rot_point(this.end.x+oa,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			bb=rot_point(this.end.x+ob,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
			sa=(this.r_st==null?null:(this.r_st.r_st==this?this.engine.RMAP.get_lines(this.r_st.ID).get(this.engine.MAX_LANES-1-i):this.engine.RMAP.get_lines(this.r_st.ID).get(this.engine.MAX_LANES+i)));
			sb=(this.r_ed==null?null:(this.r_ed.r_st==this?this.engine.RMAP.get_lines(this.r_ed.ID).get(this.engine.MAX_LANES+i):this.engine.RMAP.get_lines(this.r_ed.ID).get(this.engine.MAX_LANES-1-i)));
			L=LINES.get(this.engine.MAX_LANES+i);
			L.set_pos(lerp(aa,ab,0.5),lerp(ba,bb,0.5));
			L.set_conns(sa,sb);
			L.invertA=(this.r_st!=null&&this.r_st.r_st==this);
			L.invertB=(this.r_ed!=null&&this.r_ed.r_ed==this);
			L.jA=(this.j_st!=null?this.j_st.get_side(this):null);
			L.jB=(this.j_ed!=null?this.j_ed.get_side(this):null);
			L.lA=false;
			L.lB=(i+1==this.lanesB);
			L.r=this;
			L.update();
		}
		this.update_I();
	}



	void update_text(){
		String s="";
		s+="  Type: Road";
		s+="\n  ID: "+str(this.ID);
		s+="\n  Pos:";
		s+="\n    Screen: x: "+str(int(this.start.x/2+this.end.x/2-this.engine.OFF_X))+" y: "+str(int(this.start.y/2+this.end.y/2-this.engine.OFF_Y));
		s+="\n    Editor: x: "+str(int(this.start.x/2+this.end.x/2))+" y: "+str(int(this.start.y/2+this.end.y/2));
		s+="\n  Lanes:";
		s+="\n    Left: "+str(this.lanesA);
		s+="\n    Right: "+str(this.lanesB);
		s+="\n  Road Connections:";
		if (this.r_st==null&&this.j_st==null){
			s+="\n    Start:";
		}
		if (this.r_st!=null){
			s+="\n    Start: ID "+this.r_st.ID+" (Road)";
		}
		if (this.j_st!=null){
			s+="\n    Start: ID "+this.j_st.ID+" (Junction)";
		}
		if (this.r_ed==null&&this.j_ed==null){
			s+="\n    End:";
		}
		if (this.r_ed!=null){
			s+="\n    End: ID "+this.r_ed.ID+" (Road)";
		}
		if (this.j_ed!=null){
			s+="\n    End: ID "+this.j_ed.ID+" (Junction)";
		}
		s+="\n  Lights:";
		if (this.LIGHTS.enabled==false){
			s+="\n    Enabled: No";
		}
		else{
			s+="\n    Enabled: Yes";
			s+="\n    Delay: min: "+this.LIGHTS.MIN_DELAY+"s max: "+this.LIGHTS.MAX_DELAY+"s";
			s+="\n    Crossing time: "+this.LIGHTS.CROSSING_TIME+"s";
		}
		this.engine.INFOTEXT.set_sel(s,0);
	}



	void draw(){
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		float oa,ob;
		for (int i=0;i<this.lanesA;i++){
			oa=map(i,0,this.lanesA,-this.engine.LANE_WIDTH,-this.lanesA*this.engine.LANE_WIDTH-this.engine.LANE_WIDTH);
			ob=map(i,0,this.lanesA,-this.engine.LANE_WIDTH,-this.lanesA*this.engine.LANE_WIDTH-this.engine.LANE_WIDTH)+this.engine.LANE_WIDTH;
			this.draw_lane(oa,ob,1);
		}
		for (int i=0;i<this.lanesB;i++){
			oa=map(i,0,this.lanesB,this.engine.LANE_WIDTH,this.lanesB*this.engine.LANE_WIDTH+this.engine.LANE_WIDTH);
			ob=map(i,0,this.lanesB,this.engine.LANE_WIDTH,this.lanesB*this.engine.LANE_WIDTH+this.engine.LANE_WIDTH)-this.engine.LANE_WIDTH;
			this.draw_lane(oa,ob,0);
		}
		this.LIGHTS.draw();
		if ((this.highlight==true&&this.DRAGGING!=3)||this.engine.DRAGGING_OBJECT==1){
			noStroke();
			ellipseMode(CENTER);
			fill(230,30,40);
			if (this.DRAGGING==0&&this.engine.DRAGGING_OBJECT>0){
				fill(150,30,210);
				if (this.j_st==null&&this.r_st==null){
					circle(this.start.x,this.start.y,this.engine.POS_DRAG_RADIUS*3);
				}
				if (this.j_ed==null&&this.r_ed==null){
					circle(this.end.x,this.end.y,this.engine.POS_DRAG_RADIUS*2);
				}
			}
			else{
				if (this.j_st==null&&(this.DRAGGING==0||this.DRAGGING==1)){
					circle(this.start.x,this.start.y,this.engine.POS_DRAG_RADIUS*3);
				}
				if (this.j_ed==null&&(this.DRAGGING==0||this.DRAGGING==2)){
					circle(this.end.x,this.end.y,this.engine.POS_DRAG_RADIUS*2);
				}
			}
			if (this.highlight==true&&this.j_st==null&&this.j_ed==null&&(this.DRAGGING==0||this.DRAGGING==3)){
				circle(this.start.x/2+this.end.x/2,this.start.y/2+this.end.y/2,this.engine.POS_DRAG_RADIUS*2);
			}
		}
		if (this.engine.EDITING_ROAD_INPUT==true&&this.is_I()==true){
			for (RoadWeightPoint p:this.weight_points){
				p.draw();
			}
		}
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void draw_roadmap(){
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		beginShape();
		fill(30);
		noStroke();
		List<RoadLine> LINES=this.engine.RMAP.get_lines(this.ID);
		RoadLine l=LINES.get(this.engine.MAX_LANES-(this.lanesA-1)-1);
		vertex(l.blA.x,l.blA.y);
		vertex(l.blB.x,l.blB.y);
		l=LINES.get(this.engine.MAX_LANES+(this.lanesB-1));
		vertex(l.tlB.x,l.tlB.y);
		vertex(l.tlA.x,l.tlA.y);
		endShape(CLOSE);
		this.LIGHTS.draw_roadmap();
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void draw_lane(float oa,float ob,int dir){
		PVector aa=rot_point(this.start.x+oa,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
		PVector ab=rot_point(this.start.x+ob,this.start.y,this.start.x,this.start.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
		PVector ba=rot_point(this.end.x+oa,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
		PVector bb=rot_point(this.end.x+ob,this.end.y,this.end.x,this.end.y,ang(this.start.x,this.start.y,this.end.x,this.end.y));
		strokeWeight(2);
		stroke(255);
		line(aa.x,aa.y,ab.x,ab.y);
		line(ab.x,ab.y,bb.x,bb.y);
		line(bb.x,bb.y,ba.x,ba.y);
		line(ba.x,ba.y,aa.x,aa.y);
		if (this.engine.DRAW_ARROWS==false){
			return;
		}
		float cx=aa.x/2+bb.x/2;
		float cy=aa.y/2+bb.y/2;
		int d=int(dst(this.start.x,this.start.y,this.end.x,this.end.y));
		float off=(d-max(int(d/this.engine.ARR_DIST),1)*this.engine.ARR_DIST)/2/max(int(d/this.engine.ARR_DIST),1);
		for (int i=0;i<max(d/this.engine.ARR_DIST,1);i++){
			float yoff=map(i,0,max(d/this.engine.ARR_DIST,1),-d/2,d/2)+this.engine.ARR_DIST/2+off;
			PVector as=rot_point(cx,cy+yoff+this.engine.ARR_LEN/2,cx,cy,ang(this.start.x,this.start.y,this.end.x,this.end.y)+(1-dir)*PI);
			PVector ae=rot_point(cx,cy+yoff-this.engine.ARR_LEN/2,cx,cy,ang(this.start.x,this.start.y,this.end.x,this.end.y)+(1-dir)*PI);
			PVector lp=rot_point(cx-this.engine.ARR_LEN/5,cy+yoff+this.engine.ARR_LEN/5,cx,cy,ang(this.start.x,this.start.y,this.end.x,this.end.y)+(1-dir)*PI);
			PVector rp=rot_point(cx+this.engine.ARR_LEN/5,cy+yoff+this.engine.ARR_LEN/5,cx,cy,ang(this.start.x,this.start.y,this.end.x,this.end.y)+(1-dir)*PI);
			line(as.x,as.y,ae.x,ae.y);
			line(as.x,as.y,lp.x,lp.y);
			line(as.x,as.y,rp.x,rp.y);
		}
	}



	void delete(){
		if (this.r_st!=null){
			this.r_st.rm_r(this);
		}
		if (this.r_ed!=null){
			this.r_ed.rm_r(this);
		}
		if (this.j_st!=null){
			this.j_st.rm_r(this);
		}
		if (this.j_ed!=null){
			this.j_ed.rm_r(this);
		}
		this.engine.ROADS.remove(this);
		this.engine.RMAP.remove_lines(this.ID);
		this.engine.INFOTEXT.reset_sel();
	}



	ArrayList<PVector> get_bound_pos(Junction j){
		ArrayList<PVector> l=new ArrayList<PVector>();
		List<RoadLine> LINES=this.engine.RMAP.get_lines(this.ID);
		if (j==this.j_st){
			l.add(LINES.get(this.engine.MAX_LANES+this.lanesB-1).tlA);
			l.add(LINES.get(this.engine.MAX_LANES).blA);
			l.add(LINES.get(this.engine.MAX_LANES-this.lanesA).blA);
		}
		else{
			l.add(LINES.get(this.engine.MAX_LANES-this.lanesA).blB);
			l.add(LINES.get(this.engine.MAX_LANES).blB);
			l.add(LINES.get(this.engine.MAX_LANES+this.lanesB-1).tlB);
		}
		return l;
	}



	void rm_r(Road r){
		if (this.r_st==r){
			this.r_st=null;
			return;
		}
		if (this.r_ed==r){
			this.r_ed=null;
		}
	}



	void rm_j(Junction j){
		if (this.j_st==j){
			this.j_st=null;
			return;
		}
		if (this.j_ed==j){
			this.j_ed=null;
		}
	}



	PVector get_r_pos(Road r){
		if (this.r_st==r){
			return this.start;
		}
		return this.end;
	}



	PVector get_j_pos(Junction j){
		if (this.j_st==j){
			return this.start;
		}
		return this.end;
	}



	PVector get_connection_pos(String t){
		if (this.connected==false){
			return new PVector(0,0);
		}
		if (t.equals("start")){
			if (this.r_st!=null){
				return this.r_st.get_r_pos(this);
			}
			if (this.j_st!=null){
				return this.j_st.get_r_pos(this);
			}
			return new PVector(0,0);
		}
		if (this.r_ed!=null){
			return this.r_ed.get_r_pos(this);
		}
		if (this.j_ed!=null){
			return this.j_ed.get_r_pos(this);
		}
		return new PVector(0,0);
	}



	void set_connections(){
		if (this.conns.getInt("start")>-1){
			for (Road r:this.engine.ROADS){
				if (r.ID==this.conns.getInt("start")){
					this.r_st=r;
					break;
				}
			}
			if (this.r_st==null){
				for (Junction j:this.engine.JUNCTIONS){
					if (j.ID==this.conns.getInt("start")){
						this.j_st=j;
						break;
					}
				}
			}
		}
		if (this.conns.getInt("end")>-1){
			for (Road r:this.engine.ROADS){
				if (r.ID==this.conns.getInt("end")){
					this.r_ed=r;
					break;
				}
			}
			if (this.r_ed==null){
				for (Junction j:this.engine.JUNCTIONS){
					if (j.ID==this.conns.getInt("end")){
						this.j_ed=j;
						break;
					}
				}
			}
		}
	}



	boolean is_I(){
		return (((this.r_st!=null||this.j_st!=null)&&this.r_ed==null&&this.j_ed==null)||(this.r_st==null&&this.j_st==null&&(this.r_ed!=null||this.j_ed!=null)));
	}



	PVector get_I_point(){
		if (this.is_I()==false){
			return null;
		}
		if (this.r_st!=null||this.j_st!=null){
			return this.end;
		}
		return this.start;
	}



	void update_I_default(){
		if (this.engine.road_weights.size()>this.ID&&this.engine.road_weights.get(this.ID)!=null){
			this.engine.road_weights.set(this.ID,new IntList());
		}
		this.update_I();
		for (RoadWeightPoint p:this.weight_points){
			p.default_weight();
		}
		this.engine.save_json();
	}



	void update_I(){
		this.weight_points=new ArrayList<RoadWeightPoint>();
		if (this.is_I()==true){
			if (this.get_I_point()==this.start){
				for (int i=0;i<this.lanesA;i++){
					RoadLine l=this.engine.RMAP.get_lines(this.ID).get(this.engine.MAX_LANES-1-i);
					this.weight_points.add(new RoadWeightPoint(this.engine,l.s.copy(),l,this));
				}
			}
			else{
				for (int i=0;i<this.lanesB;i++){
					RoadLine l=this.engine.RMAP.get_lines(this.ID).get(this.engine.MAX_LANES+i);
					this.weight_points.add(new RoadWeightPoint(this.engine,l.e.copy(),l,this));
				}
			}
		}
	}



	void clear_weights(){
		while (this.engine.road_weights.size()<=this.ID){
			this.engine.road_weights.add(null);
		}
		this.engine.road_weights.set(this.ID,null);
	}



	void setup_weights(){
		if (this.engine.road_weights.get(this.ID)==null){
			this.update_lines();
			this.engine.road_weights.set(this.ID,new IntList());
			for (RoadWeightPoint p:this.weight_points){
				p.set_weight(p.default_weight());
			}
		}
	}



	void from_json(JSONObject json){
		this.start=new PVector(json.getJSONObject("from").getInt("x"),json.getJSONObject("from").getInt("y"));
		this.end=new PVector(json.getJSONObject("to").getInt("x"),json.getJSONObject("to").getInt("y"));
		this.lanesA=json.getInt("lanesA");
		this.lanesB=json.getInt("lanesB");
		this.ID=json.getInt("id");
		this.conns=json.getJSONObject("connections");
		this.LIGHTS=new RoadLightObject(this.engine,this);
		this.LIGHTS.from_json(json.getJSONObject("lights"));
	}



	JSONObject to_json(){
		JSONObject o=new JSONObject();
		JSONObject start=new JSONObject();
		JSONObject end=new JSONObject();
		JSONObject conns=new JSONObject();
		start.setInt("x",int(this.start.x));
		start.setInt("y",int(this.start.y));
		end.setInt("x",int(this.end.x));
		end.setInt("y",int(this.end.y));
		conns.setInt("start",(this.r_st!=null?this.r_st.ID:(this.j_st!=null?this.j_st.ID:-1)));
		conns.setInt("end",(this.r_ed!=null?this.r_ed.ID:(this.j_ed!=null?this.j_ed.ID:-1)));
		o.setJSONObject("from",start);
		o.setJSONObject("to",end);
		o.setInt("lanesA",this.lanesA);
		o.setInt("lanesB",this.lanesB);
		o.setInt("id",this.ID);
		o.setJSONObject("connections",conns);
		o.setJSONObject("lights",this.LIGHTS.to_json());
		o.setString("type","road");
		return o;
	}
}
