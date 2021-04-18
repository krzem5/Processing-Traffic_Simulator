class Junction{
	Engine engine;
	PVector pos;
	int sides=3;
	int radius;
	float offset_angle;
	ArrayList<PVector> side_points;
	ArrayList<JunctionPoint> side_c_points;
	ArrayList<JunctionEditPoint> l_edit_points;
	ArrayList<int[]> connections;
	ArrayList<JunctionEditLine> edit_lines;
	ArrayList<JunctionWeightLine> weight_lines;
	boolean highlight=false;
	int ID=-1;
	int DRAGGING=0;
	boolean CLICK=false;
	boolean KEYDOWN=false;
	JSONArray conns;
	boolean editing_points=false;
	boolean weighting_points=false;
	boolean editing_lights=false;
	JunctionEditPoint selected_start_point=null;
	LightObject LIGHTS;
	JSONObject lgt_json;



	Junction(Engine engine){
		this.engine=engine;
		this.pos=new PVector(this.engine.MOUSE.x,this.engine.MOUSE.y);
		this.radius=this.engine.MIN_JUNCTION_RADIUS;
		this.offset_angle=0;
		this.side_points=new ArrayList<PVector>();
		this.side_c_points=new ArrayList<JunctionPoint>();
		this.l_edit_points=new ArrayList<JunctionEditPoint>();
		this.connections=new ArrayList<int[]>();
		this.edit_lines=new ArrayList<JunctionEditLine>();
		this.ID=this.engine.gen_id();
		this.update_side_points(0);
		this.LIGHTS=new LightObject(this.engine,this);
	}



	Junction(Engine engine,JSONObject json){
		this.engine=engine;
		this.from_json(json);
	}



	void update(boolean ex){
		if (this.engine.ROADMAP_VIEW==true||this.engine.RUNNING==true||this.engine.updating_junction!=null||this.engine.EDITING_ROAD_INPUT==true){
			if (this.engine.ROADMAP_VIEW==true||this.engine.RUNNING==true){
				this.editing_points=false;
				this.weighting_points=false;
			}
			this.highlight=false;
			this.DRAGGING=0;
			return;
		}
		if (mousePressed==true&&this.CLICK==false){
			this.CLICK=true;
			PVector[] verts=new PVector[this.side_points.size()];
			for (int i=0;i<this.side_points.size();i++){
				verts[i]=this.side_points.get(i);
			}
			boolean c=collisionPointPoly(this.engine.MOUSE.x,this.engine.MOUSE.y,verts);
			if (this.editing_points==true&&c==false){
				c=true;
			}
			if (c==false&&this.DRAGGING>0){
				this.DRAGGING=0;
				this.engine.DRAGGING_OBJECT=0;
				this.highlight=true;
			}
			if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&this.editing_points==false&&this.weighting_points==false&&dst(this.pos.x,this.pos.y,this.engine.MOUSE.x,this.engine.MOUSE.y)<=this.engine.POS_DRAG_RADIUS&&this.engine.DRAGGING_OBJECT==0){
				this.DRAGGING=1;
				this.engine.DRAGGING_OBJECT=2;
				c=false;
			}
			if (CTRL_DOWN==false&&this.editing_points==true){
				for (JunctionEditPoint p:this.l_edit_points){
					if ((p.type==1&&this.selected_start_point==null)||(p.type==0&&this.selected_start_point!=null&&this.selected_start_point!=p)){
						continue;
					}
					if (dst(p.pos.x,p.pos.y,this.engine.MOUSE.x,this.engine.MOUSE.y)<=this.engine.POS_DRAG_RADIUS){
						if (SHIFT_DOWN==true){
							p.disconnect();
						}
						else{
							p.select();
						}
						break;
					}
				}
			}
			if (ALT_DOWN==false&&this.weighting_points==true){
				for (JunctionWeightLine l:this.weight_lines){
					if (l.click((int)this.engine.MOUSE.x,(int)this.engine.MOUSE.y)==true){
						break;
					}
				}
			}
			if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&ex==false&&CTRL_DOWN==true&&SHIFT_DOWN==false&&ALT_DOWN==false&&c==true&&this.highlight==true&&this.editing_points==false){
				this.editing_points=true;
				this.engine.EDITING_JUNCTION=true;
				this.engine.DRAGGING_OBJECT=0;
				this.DRAGGING=0;
				this.highlight=false;
				c=false;
				if (this.create_edit_points()==false){
					this.highlight=true;
					this.editing_points=false;
					this.engine.EDITING_JUNCTION=false;
					c=true;
				}
				this.engine.INFOTEXT.ep=1;
				this.engine.INFOTEXT.update_keys();
			}
			else if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&CTRL_DOWN==true&&SHIFT_DOWN==false&&ALT_DOWN==false&&c==true&&this.editing_points==true){
				this.editing_points=false;
				this.engine.EDITING_JUNCTION=false;
				this.highlight=true;
				this.engine.INFOTEXT.ep=0;
				this.engine.INFOTEXT.update_keys();
			}
			if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&c==true&&this.highlight==true&&this.weighting_points==false){
				this.weighting_points=true;
				this.highlight=false;
				this.engine.WEIGHTING_JUNCTION=true;
				this.engine.DRAGGING_OBJECT=0;
				this.DRAGGING=0;
				c=false;
				if (this.connections.size()==0){
					c=true;
					this.weighting_points=false;
					this.engine.WEIGHTING_JUNCTION=false;
					this.highlight=true;
				}
				else{
					this.create_weight_lines();
				}
				this.engine.INFOTEXT.ep=2;
				this.engine.INFOTEXT.update_keys();
			}
			else if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==false&&c==true&&this.weighting_points==true){
				this.weighting_points=false;
				this.engine.WEIGHTING_JUNCTION=false;
				this.highlight=true;
				this.engine.INFOTEXT.ep=0;
				this.engine.INFOTEXT.update_keys();
			}
			if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&c==true&&this.highlight==true&&this.editing_lights==false){
				this.editing_lights=true;
				this.highlight=false;
				this.engine.EDITING_LIGHTS=true;
				this.engine.DRAGGING_OBJECT=0;
				this.DRAGGING=0;
				c=false;
				if (this.LIGHTS.lights==null||this.LIGHTS.lights.size()==0){
					c=true;
					this.editing_lights=false;
					this.engine.EDITING_LIGHTS=false;
					this.highlight=true;
				}
				else{
					this.LIGHTS.edit_lights();
				}
				this.engine.INFOTEXT.ep=3;
				this.engine.INFOTEXT.update_keys();
			}
			else if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&ALT_DOWN==true&&SHIFT_DOWN==false&&CTRL_DOWN==true&&c==true&&this.editing_lights==true){
				this.editing_lights=false;
				this.engine.EDITING_LIGHTS=false;
				this.highlight=true;
				this.LIGHTS.stop_edit_lights();
				this.engine.INFOTEXT.ep=0;
				this.engine.INFOTEXT.update_keys();
			}
			if (this.editing_points==false&&this.weighting_points==false&&this.editing_lights==false){
				if (c==true&&this.highlight==false){
					this.editing_points=false;
					this.engine.EDITING_JUNCTION=false;
					this.highlight=true;
				}
				if (c==false&&this.highlight==true){
					this.editing_points=false;
					this.engine.EDITING_JUNCTION=false;
					this.highlight=false;
				}
				if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&SHIFT_DOWN==true&&c==true){
					for (JunctionPoint p:this.side_c_points){
						p.disconnect();
					}
				}
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
				float xm=this.engine.MOUSE.x-(pmouseX+this.engine.OFF_X)*this.engine.ZOOM_OUT;
				float ym=this.engine.MOUSE.y-(pmouseY+this.engine.OFF_X)*this.engine.ZOOM_OUT;
				this.pos.x+=xm;
				this.pos.y+=ym;
				for (PVector p:this.side_points){
					p.x+=xm;
					p.y+=ym;
				}
				for (JunctionPoint p:this.side_c_points){
					p.add_pos(xm,ym);
				}
			}
		}
		if (keyPressed==true&&this.highlight==true&&this.KEYDOWN==false){
			this.KEYDOWN=true;
			switch(keyCode){
			case UP:
				this.sides=min(this.sides+1,this.engine.MAX_JUNCTION_SIDES);
				this.update_side_points(1);
				this.update_lines();
				break;
			case DOWN:
				this.sides=max(this.sides-1,this.engine.MIN_JUNCTION_SIDES);
				this.update_side_points(1);
				this.update_lines();
				break;
			}
			if (key==DELETE){
				this.delete();
			}
		}
		if (keyPressed==true&&this.highlight==true){
			if (CTRL_DOWN==true){
				switch(keyCode){
				case RIGHT:
					this.offset_angle=(this.offset_angle+this.engine.JUNCTION_ANGLE_INCREMENT+PI*2)%(PI*2);
					this.update_side_points(1);
					this.update_lines();
					break;
				case LEFT:
					this.offset_angle=(this.offset_angle-this.engine.JUNCTION_ANGLE_INCREMENT+PI*2)%(PI*2);
					this.update_side_points(1);
					this.update_lines();
					break;
				}
			}
			else{
				switch(keyCode){
				case RIGHT:
					this.radius=min(this.radius+this.engine.JUNCTION_RADIUS_INCREMENT,this.engine.MAX_JUNCTION_RADIUS);
					this.update_side_points(1);
					this.update_lines();
					break;
				case LEFT:
					this.radius=max(this.radius-this.engine.JUNCTION_RADIUS_INCREMENT,this.engine.MIN_JUNCTION_RADIUS);
					this.update_side_points(1);
					this.update_lines();
					break;
				}
			}
		}
		if (keyPressed==false&&this.KEYDOWN==true){
			this.KEYDOWN=false;
		}
		if (this.highlight==true||this.DRAGGING>0||this.editing_points==true||this.weighting_points==true||this.editing_lights==true){
			this.update_text();
		}
	}



	void update_side_points(int s){
		if (s==0){
			this.side_points=new ArrayList<PVector>();
			this.side_c_points=new ArrayList<JunctionPoint>();
			for (int i=0;i<this.sides;i++){
				this.side_points.add(new PVector(this.pos.x+cos((float)i/this.sides*2*PI+this.offset_angle)*this.radius,this.pos.y+sin((float)i/this.sides*2*PI+this.offset_angle)*this.radius));
			}
			for (int i=1;i<=this.sides;i++){
				this.side_c_points.add(new JunctionPoint(this.engine,this,lerp(this.side_points.get(i-1),this.side_points.get(i%this.sides),0.5)));
			}
		}
		if (s==1){
			ArrayList<JunctionPoint> o_scp=new ArrayList<JunctionPoint>();
			for (JunctionPoint p:this.side_c_points){
				o_scp.add(p.clone());
			}
			this.side_points=new ArrayList<PVector>();
			this.side_c_points=new ArrayList<JunctionPoint>();
			for (int i=0;i<this.sides;i++){
				this.side_points.add(new PVector(this.pos.x+cos((float)i/this.sides*2*PI+this.offset_angle)*this.radius,this.pos.y+sin((float)i/this.sides*2*PI+this.offset_angle)*this.radius));
			}
			for (int i=1;i<=this.sides;i++){
				this.side_c_points.add(new JunctionPoint(this.engine,this,lerp(this.side_points.get(i-1),this.side_points.get(i%this.sides),0.5)));
			}
			int i=0;
			for (JunctionPoint p:this.side_c_points){
				if (i==o_scp.size()){
					break;
				}
				p.r_in=o_scp.get(i).r_in;
				p.add_pos(0,0);
				i++;
			}
			if (i<o_scp.size()){
				while (i<o_scp.size()){
					o_scp.get(i).disconnect();
					i++;
				}
			}
		}
	}



	void update_lines(){
		this.create_edit_points();
		for (JunctionEditLine l:this.edit_lines){
			l.create_lines();
		}
	}



	void update_weight(int nw){
		for (JunctionWeightLine l:this.weight_lines){
			if (l.active==true){
				l.u_conn(nw);
				break;
			}
		}
		this.update_text();
	}



	void update_text(){
		String s="";
		s+="  Type: Junction";
		s+="\n  ID: "+str(this.ID);
		s+="\n  Pos:";
		s+="\n    Screen: x: "+str(int(this.pos.x-this.engine.OFF_X))+" y: "+str(int(this.pos.y-this.engine.OFF_Y));
		s+="\n    Editor: x: "+str(int(this.pos.x))+" y: "+str(int(this.pos.y));
		s+="\n  Sides: "+str(this.sides);
		s+="\n  Radius: "+str(round(this.radius));
		s+="\n  Offset Angle: "+str(round(this.offset_angle*(180/PI)))+"°";
		s+="\n  Road Connections:";
		int i=1;
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in==null){
				s+="\n    "+str(i)+":";
			}
			else{
				s+="\n    "+str(i)+": ID "+p.r_in.ID;
			}
			i++;
		}
		s+="\n  Connections:";
		for (int[] c:this.connections){
			if (c==null||c.length<2){
				continue;
			}
			s+="\n    "+str(c[0])+" (Side "+str(c[0]/(this.engine.MAX_LANES*2)+1)+") — "+str(c[1])+" (Side "+str(c[1]/(this.engine.MAX_LANES*2)+1)+") —> "+str(c[2])+"%";
		}
		if (this.connections.size()==0){
			s+="\n    None";
		}
		s+="\n  Lights:";
		if (this.LIGHTS.lights!=null){
			for (Light l:this.LIGHTS.lights){
				s+="\n    Light (ID "+l.n+"):";
				s+="\n      Lengths: red: "+l.RED_TIME+"s green: "+l.GREEN_TIME+"s orange: "+l.ORANGE_TIME+"s";
				s+="\n      Offset length: "+l.OFFSET_TIME+"s";
			}
		}
		if (this.LIGHTS.lights==null||this.LIGHTS.lights.size()==0){
			s+="\n    None";
		}
		this.engine.INFOTEXT.set_sel(s,1);
	}



	void draw(){
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		strokeWeight(2);
		stroke(255);
		for (int i=1;i<=this.sides;i++){
			line(this.side_points.get(i-1).x,this.side_points.get(i-1).y,this.side_points.get(i%this.sides).x,this.side_points.get(i%this.sides).y);
		}
		if (this.editing_points==true){
			for (JunctionEditLine l:this.edit_lines){
				l.draw();
			}
			for (JunctionEditPoint p:this.l_edit_points){
				p.draw();
			}
		}
		if (this.weighting_points==true){
			for (JunctionWeightLine l:this.weight_lines){
				l.draw();
			}
		}
		if (this.highlight==true){
			fill(230,30,40);
			noStroke();
			circle(this.pos.x,this.pos.y,this.engine.POS_DRAG_RADIUS*2);
		}
		if (this.highlight==false&&this.engine.DRAGGING_OBJECT==1){
			for (JunctionPoint p:this.side_c_points){
				p.draw();
			}
		}
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void draw_roadmap(){
		if (this.editing_points==true||this.weighting_points==true){
			this.editing_points=false;
			this.engine.EDITING_JUNCTION=false;
			this.highlight=true;
		}
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		beginShape();
		fill(30);
		noStroke();
		for (PVector p:this.side_points){
			vertex(p.x,p.y);
		}
		endShape(CLOSE);
		strokeWeight(2);
		stroke(255);
		for (int i=1;i<=this.sides;i++){
			if (this.side_c_points.get(i-1).r_in==null){
				line(this.side_points.get(i-1).x,this.side_points.get(i-1).y,this.side_points.get(i%this.sides).x,this.side_points.get(i%this.sides).y);
			}
			else{
				ArrayList<PVector> l=this.side_c_points.get(i-1).r_in.get_bound_pos(this);
				PVector A=l.get(0),B=l.get(1),C=l.get(2);
				line(this.side_points.get(i-1).x,this.side_points.get(i-1).y,A.x,A.y);
				line(C.x,C.y,this.side_points.get(i%this.sides).x,this.side_points.get(i%this.sides).y);
				noStroke();
				fill(255);
				this.draw_triangle_strip(A,B);
				noFill();
				stroke(255);
			}
		}
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void draw_triangle_strip(PVector s,PVector e){
		float cx=s.x/2+e.x/2;
		float cy=s.y/2+e.y/2;
		int d=int(dst(s.x,s.y,e.x,e.y));
		float off=(d-max(int(d/this.engine.JUNCTION_TRIANGLE_SIZE),1)*this.engine.JUNCTION_TRIANGLE_SIZE)/2/max(int(d/this.engine.JUNCTION_TRIANGLE_SIZE),1);
		float ang=ang(s.x,s.y,e.x,e.y);
		for (int i=0;i<max(d/this.engine.JUNCTION_TRIANGLE_SIZE,1);i++){
			float yoff=map(i,0,max(d/this.engine.JUNCTION_TRIANGLE_SIZE,1),-d/2,d/2)+this.engine.JUNCTION_TRIANGLE_SIZE/2+off;
			PVector a=rot_point(cx,cy+yoff+(float)this.engine.JUNCTION_TRIANGLE_SIZE/4,cx,cy,ang);
			PVector b=rot_point(cx,cy+yoff-(float)this.engine.JUNCTION_TRIANGLE_SIZE/4,cx,cy,ang);
			PVector c=rot_point(cx+(float)this.engine.JUNCTION_TRIANGLE_SIZE/3,cy+yoff,cx,cy,ang);
			beginShape();
			vertex(a.x,a.y);
			vertex(b.x,b.y);
			vertex(c.x,c.y);
			endShape(CLOSE);
		}
	}



	void delete(){
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in==null){
				continue;
			}
			p.r_in.rm_j(this);
		}
		this.engine.JUNCTIONS.remove(this);
		for (JunctionEditLine l:this.edit_lines){
			l.remove();
		}
		this.engine.INFOTEXT.reset_sel();
	}



	boolean create_edit_points(){
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in!=null){
				p.r_in.update_lines();
			}
		}
		this.engine.RMAP.create_lines(this.ID,new ArrayList<RoadLine>());
		this.l_edit_points=new ArrayList<JunctionEditPoint>();
		this.edit_lines=new ArrayList<JunctionEditLine>();
		this.selected_start_point=null;
		for (Road r:this.engine.ROADS){
			r.update_lines();
		}
		for (Road r:this.engine.ROADS){
			r.update_lines();
		}
		int c=0;
		Road r;
		List<RoadLine> LINES;
		RoadLine L;
		int[] nums=new int[this.sides*this.engine.MAX_LANES*2];
		for (int i=0;i<this.sides*this.engine.MAX_LANES*2;i++){
			nums[i]=-1;
		}
		int j=0;
		ArrayList<JunctionEditPoint> pts;
		JunctionEditPoint pt;
		float sa;
		int k=0;
		PVector aa,ab;
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in!=null){
				aa=this.side_points.get(k);
				ab=this.side_points.get((k+1)%this.sides);
				sa=ang(aa.x,aa.y,ab.x,ab.y);
				c++;
				r=p.r_in;
				LINES=this.engine.RMAP.get_lines(r.ID);
				pts=new ArrayList<JunctionEditPoint>();
				if (r.j_st==this){
					for (int i=0;i<r.lanesB;i++){
						nums[j+this.engine.MAX_LANES+i]=j+this.engine.MAX_LANES+i;
						L=LINES.get(this.engine.MAX_LANES+i);
						pt=new JunctionEditPoint(this.engine,this,L,0,0,j+this.engine.MAX_LANES+i,null,sa);
						pts.add(pt);
						this.l_edit_points.add(pt);
					}
					for (int i=0;i<r.lanesA;i++){
						nums[j+this.engine.MAX_LANES-1-i]=j+this.engine.MAX_LANES-1-i;
						L=LINES.get(this.engine.MAX_LANES-1-i);
						this.l_edit_points.add(new JunctionEditPoint(this.engine,this,L,0,1,j+this.engine.MAX_LANES-1-i,pts,sa));
					}
				}
				else{
					for (int i=0;i<r.lanesA;i++){
						nums[j+this.engine.MAX_LANES-1-i]=j+this.engine.MAX_LANES-1-i;
						L=LINES.get(this.engine.MAX_LANES-1-i);
						pt=new JunctionEditPoint(this.engine,this,L,1,0,j+this.engine.MAX_LANES-1-i,null,sa);
						pts.add(pt);
						this.l_edit_points.add(pt);
					}
					for (int i=0;i<r.lanesB;i++){
						nums[j+this.engine.MAX_LANES+i]=j+this.engine.MAX_LANES+i;
						L=LINES.get(this.engine.MAX_LANES+i);
						this.l_edit_points.add(new JunctionEditPoint(this.engine,this,L,1,1,j+this.engine.MAX_LANES+i,pts,sa));
					}
				}
			}
			j+=this.engine.MAX_LANES*2;
			k++;
		}
		JunctionEditLine l;
		JunctionEditPoint a,b;
		int[] cn;
		boolean fA,fB;
		for (int i=this.connections.size()-1;i>=0;i--){
			cn=this.connections.get(i);
			if (cn==null){
				continue;
			}
			fA=false;
			fB=false;
			for (int n:nums){
				if (n==-1){
					continue;
				}
				if (n==cn[0]){
					fA=true;
				}
				if (n==cn[1]){
					fB=true;
				}
				if (fA==true&&fB==true){
					break;
				}
			}
			if (fA==false||fB==false){
				this.connections.remove(i);
				continue;
			}
			a=null;
			b=null;
			for (JunctionEditPoint p:this.l_edit_points){
				if (p.conn_idx==cn[0]){
					a=p;
					break;
				}
			}
			for (JunctionEditPoint p:this.l_edit_points){
				if (p.conn_idx==cn[1]){
					b=p;
					break;
				}
			}
			if (a==null||b==null){
				throw new NullPointerException();
			}
			l=new JunctionEditLine(this.engine,this,new PVector(a.pos.x,a.pos.y),new PVector(b.pos.x,b.pos.y),a,b,i,cn[2]);
			this.edit_lines.add(l);
		}
		this.LIGHTS.from_junction();
		return (c>1);
	}



	void connect_edit(JunctionEditPoint a,JunctionEditPoint b){
		this.selected_start_point=null;
		int i=0;
		while (true){
			if (this.connections.size()<=i){
				this.connections.add(null);
			}
			if (this.connections.get(i)==null){
				break;
			}
			i++;
		}
		int[] A={a.conn_idx,b.conn_idx,50};
		this.connections.set(i,A);
		JunctionEditLine l=new JunctionEditLine(this.engine,this,new PVector(a.pos.x,a.pos.y),new PVector(b.pos.x,b.pos.y),a,b,i,A[2]);
		this.edit_lines.add(l);
	}



	void disconnect_edit_point(JunctionEditPoint p){
		for (int i=this.edit_lines.size()-1;i>=0;i--){
			JunctionEditLine l=this.edit_lines.get(i);
			if (l.sp==p||l.ep==p){
				l.remove();
			}
		}
	}



	Light get_lgt(RoadLine ln){
		for (Light l:this.LIGHTS.lights){
			if (dst(l.pos.x,l.pos.y,ln.s.x,ln.s.y)<=this.engine.POS_DRAG_RADIUS||dst(l.pos.x,l.pos.y,ln.e.x,ln.e.y)<=this.engine.POS_DRAG_RADIUS){
				return l;
			}
		}
		return null;
	}



	void create_weight_lines(){
		this.weight_lines=new ArrayList<JunctionWeightLine>();
		for (JunctionEditLine l:this.edit_lines){
			this.weight_lines.add(new JunctionWeightLine(this.engine,this,l.s.copy(),l.e.copy(),l.conn_index));
		}
	}



	void rm_r(Road r){
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in==r){
				p.disconnect();
				this.create_edit_points();
				return;
			}
		}
	}



	PVector get_r_pos(Road r){
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in==r){
				return p.pos;
			}
		}
		return new PVector(0,0);
	}



	void set_connections(){
		int ID;
		for (int i=0;i<this.sides;i++){
			if (i==this.conns.size()){
				return;
			}
			ID=this.conns.getInt(i);
			if (ID==-1){
				continue;
			}
			for (Road r:this.engine.ROADS){
				if (r.ID!=ID){
					continue;
				}
				this.side_c_points.get(i).r_in=r;
				this.side_c_points.get(i).add_pos(0,0);
				break;
			}
		}
		this.create_edit_points();
		this.LIGHTS.from_json(this.lgt_json);
	}



	ArrayList<PVector> get_side(Road r){
		for (int i=1;i<=this.sides;i++){
			if (this.side_c_points.get(i-1).r_in==r){
				ArrayList<PVector> l=new ArrayList<PVector>();
				l.add(this.side_points.get(i-1));
				l.add(this.side_points.get(i%this.sides));
				return l;
			}
		}
		return null;
	}



	void try_connect(Road r,int d){
		for (JunctionPoint p:this.side_c_points){
			if (p.r_in!=null&&p.r_in==r){
				return;
			}
		}
		for (JunctionPoint p:this.side_c_points){
			if (p.try_connect(r,d)==true){
				r.LIGHTS.enabled=false;
				return;
			}
		}
	}



	void from_json(JSONObject json){
		this.side_points=new ArrayList<PVector>();
		this.side_c_points=new ArrayList<JunctionPoint>();
		this.l_edit_points=new ArrayList<JunctionEditPoint>();
		this.connections=new ArrayList<int[]>();
		this.edit_lines=new ArrayList<JunctionEditLine>();
		this.LIGHTS=new LightObject(this.engine,this);
		this.pos=new PVector(json.getJSONObject("pos").getInt("x"),json.getJSONObject("pos").getInt("y"));
		this.radius=json.getInt("radius");
		this.offset_angle=(float)json.getInt("angle")/(180/PI);
		this.sides=json.getInt("sides");
		this.conns=json.getJSONArray("connections");
		JSONArray a=json.getJSONArray("j-connections");
		for (int i=0;i<a.size();i++){
			if (a.get(i).getClass().getCanonicalName().indexOf("Null")>-1){
				continue;
			}
			JSONObject o=a.getJSONObject(i);
			int[] nc={o.getInt("a"),o.getInt("b"),o.getInt("w")};
			this.connections.add(nc);
		}
		this.ID=json.getInt("id");
		this.update_side_points(0);
		this.lgt_json=json.getJSONObject("lights");
	}



	JSONObject to_json(){
		JSONObject o=new JSONObject();
		JSONArray conns=new JSONArray();
		JSONObject pos=new JSONObject();
		JSONArray j_conns=new JSONArray();
		int i=0;
		for (JunctionPoint p:this.side_c_points){
			conns.setInt(i,(p.r_in!=null?p.r_in.ID:-1));
			i++;
		}
		int[] nc;
		JSONObject c;
		for (i=0;i<this.connections.size();i++){
			nc=this.connections.get(i);
			if (nc==null||nc.length<3){
				continue;
			}
			c=new JSONObject();
			c.setInt("a",nc[0]);
			c.setInt("b",nc[1]);
			c.setInt("w",nc[2]);
			j_conns.setJSONObject(i,c);
		}
		pos.setInt("x",int(this.pos.x));
		pos.setInt("y",int(this.pos.y));
		o.setJSONObject("pos",pos);
		o.setInt("radius",this.radius);
		o.setInt("angle",int(this.offset_angle*(180/PI)));
		o.setInt("sides",this.sides);
		o.setJSONArray("connections",conns);
		o.setJSONArray("j-connections",j_conns);
		o.setJSONObject("lights",this.LIGHTS.to_json());
		o.setInt("id",this.ID);
		o.setString("type","junction");
		return o;
	}
}
