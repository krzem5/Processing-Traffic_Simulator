class Car{
	Engine engine;
	PVector pos;
	PVector vel;
	PVector acc;
	ArrayList<CarPathPoint> path;
	ArrayList<CarPathPoint> l_path;
	CarPathPoint target;
	CarPathPoint l_target;
	int target_i;
	int l_target_i;
	boolean changing_lane=false;
	boolean right_lane=false;
	PVector lane_change=null;
	color c;
	int sp_lim=-1;
	Light curr_j_lgt;
	RoadLight curr_r_lgt;
	float f_dir=-1;
	PVector[][] side_path_polygones;
	float MAX_SPEED=kmh_to_pxs(50);
	float SLOW_MAX_SPEED_START=kmh_to_pxs(30);
	float SLOW_MAX_SPEED_END=kmh_to_pxs(25);
	int MIN_NEXT_DIST=80;
	int MAX_CAR_COLLISION_DIST=150;
	int MIN_CAR_COLLISION_DIST=60;
	int LANE_CHANGE_BUFFOR=6;
	int MIN_CHANGE_LANE_DIST=100;
	int MAX_CHANGE_LANE_DIST=550;
	int MIN_LIGHTS_STOP_DIST=100;
	int MAX_LIGHTS_STOP_DIST=350;
	float SEEK_WEIGHT=1;
	float LANE_CHANGE_WEIGHT=1;
	float AVOID_COLLISION_WEIGHT=2;
	float LIGHTS_WEIGHT=1.5;
	float LANE_CHANGE_SPEED=kmh_to_pxs(10);
	int LANE_PATH_DIFF_POINT_BUFFOR=10;
	int COLLISION_LINE_CONSTRAIN_BUFFOR=1;
	color[] colors={#101010,#a1a1a1,#ffffff,#0074fd,#e2e2e2,#eb0032,#59ae00,#f97b1f,#c9ae5d,#ffeb00};
	int[] color_weights={21,20,19,17,10,10,3,3,2,1};
	boolean DETAIL_CAR_MODEL=false;



	Car(Engine engine){
		this.engine=engine;
		this.pos=new PVector(-1,-1);
		this.vel=new PVector(0,0);
		this.acc=new PVector(0,0);
		this.create_path(this.engine.get_car_road());
		this.c=this.gen_c();
	}



	void update(){
		if (this.path==null){
			this.end();
			return;
		}
		this.acc.mult(0);
		this.acc.add(this.seek(this.target.get_pos()).mult(this.SEEK_WEIGHT));
		this.acc.add(this.change_lane().mult(this.LANE_CHANGE_WEIGHT));
		this.acc.add(this.avoid_collision().mult(this.AVOID_COLLISION_WEIGHT));
		this.acc.add(this.lights().mult(this.LIGHTS_WEIGHT));
		PVector dvel=this.vel.copy();
		dvel.add(this.acc);
		if (this.sp_lim!=-1){
			dvel.limit(this.sp_lim);
		}
		else if (this.target.slow==true){
			dvel.limit(this.SLOW_MAX_SPEED_START);
		}
		else if (this.path.get(this.target_i-1).slow==true){
			dvel.limit(this.SLOW_MAX_SPEED_END);
		}
		else{
			dvel.limit(this.MAX_SPEED);
		}
		this.pos.add(this.vel.copy().div(max(frameRate,1)));
		this.vel=lerp(this.vel,dvel,1-0.15);
		this.vel.limit(this.MAX_SPEED);
		if (!this.vel.equals(new PVector(0,0))){
			this.f_dir=ang(0,0,this.vel.x,this.vel.y);
		}
		if (dst(this.pos.x,this.pos.y,this.target.pos.x,this.target.pos.y)<=this.MIN_NEXT_DIST){
			this.target_i++;
			if (this.target_i==this.path.size()){
				this.engine.c_out++;
				this.engine.c_in++;
				this.end();
				return;
			}
			if (this.target_i+1==this.path.size()){
				this.MIN_NEXT_DIST=10;
			}
			this.target=this.path.get(this.target_i);
			this.lane_change=null;
			this.right_lane=false;
			if (diff(this.path.get(this.target_i-1).pos,this.l_target.pos)<this.LANE_PATH_DIFF_POINT_BUFFOR){
				this.l_target_i++;
				this.l_target=this.l_path.get(this.l_target_i);
				this.curr_r_lgt=null;
				if (this.l_target.lane!=null){
					this.curr_r_lgt=this.l_target.lane.get_road_crossing();
				}
			}
			if (this.target_i+1<this.path.size()&&this.path.get(this.target_i+1).lane!=null&&this.path.get(this.target_i+1).lane.junction==true){
				this.curr_j_lgt=this.path.get(this.target_i+1).lane.j.get_lgt(this.l_target.lane);
			}
			else{
				this.curr_j_lgt=null;
			}
			this.changing_lane=false;
			if (this.target.change==false){
				this.right_lane=true;
			}
		}
	}



	void draw(){
		if (this.pos.x==-1&&this.pos.y==-1){
			return;
		}
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		noStroke();
		fill(this.c);
		translate(this.pos.x,this.pos.y);
		rotate(this.f_dir+PI/2);
		rectMode(CENTER);
		if (this.DETAIL_CAR_MODEL==true){
			rect(0,0,this.engine.CAR_WIDTH,this.engine.CAR_HEIGHT,3,60,60,3);
			rectMode(CORNER);
			fill(#ffff50);
			rect(this.engine.CAR_WIDTH/2*0.7,-this.engine.CAR_HEIGHT/2,this.engine.CAR_WIDTH/2*0.3,this.engine.CAR_HEIGHT/2*0.6,0,60,0,0);
			rect(this.engine.CAR_WIDTH/2*0.7,this.engine.CAR_HEIGHT/2-this.engine.CAR_HEIGHT/2*0.6,this.engine.CAR_WIDTH/2*0.3,this.engine.CAR_HEIGHT/2*0.6,0,0,60,0);
		}
		else{
			rect(0,0,this.engine.CAR_WIDTH,this.engine.CAR_HEIGHT);
		}
		rotate(-this.f_dir-PI/2);
		translate(-this.pos.x,-this.pos.y);
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
		resetMatrix();
	}



	void create_path(RoadLine s){
		if (s==null){
			this.end();
			return;
		}
		this.l_path=this.engine.MAP.get_path(s);
		if (this.l_path==null){
			this.end();
			return;
		}
		this.path=this.engine.MAP.split(this.l_path);
		this.side_path_polygones=this.get_side_path_polygones();
		this.pos=this.path.get(0).pos.copy();
		this.target=this.path.get(1);
		this.l_target=this.l_path.get(1);
		this.target_i=1;
		this.l_target_i=1;
		if (diff(this.path.get(this.target_i-1).pos,this.l_target.pos)<this.LANE_PATH_DIFF_POINT_BUFFOR){
			this.l_target_i++;
			this.l_target=this.l_path.get(this.l_target_i);
			this.curr_r_lgt=null;
			if (this.target.lane!=null){
				this.curr_r_lgt=this.l_target.lane.get_road_crossing();
			}
		}
		if (this.target_i+1<this.path.size()&&this.path.get(this.target_i+1).lane!=null&&this.path.get(this.target_i+1).lane.junction==true){
			this.curr_j_lgt=this.path.get(this.target_i+1).lane.j.get_lgt(this.l_target.lane);
		}
		else{
			this.curr_j_lgt=null;
		}
		this.right_lane=false;
		if (this.target.change==false){
			this.right_lane=true;
		}
	}



	color gen_c(){
		int s=0;
		for (int w:this.color_weights){
			s+=w;
		}
		color[] l=new color[s];
		int i=0;
		int j=0;
		for (color c:this.colors){
			for (int k=0;k<this.color_weights[i];k++){
				l[j]=c;
				j++;
			}
			i++;
		}
		return l[int(random(1)*s)];
	}



	void end(){
		this.engine.CARS.remove(this);
	}



	PVector[][] get_side_path_polygones(){
		if (this.path==null){
			return null;
		}
		IntList ids=new IntList();
		int t=0;
		for (CarPathPoint p:this.path){
			if (p.lane==null||ids.hasValue(p.lane.ID)==true){
				continue;
			}
			ids.push(p.lane.ID);
			t++;
		}
		ids=new IntList();
		PVector[][] pl=new PVector[t*2][2];
		int i=0;
		for (CarPathPoint p:this.path){
			if (p.lane==null||ids.hasValue(p.lane.ID)==true){
				continue;
			}
			ids.push(p.lane.ID);
			pl[i][0]=p.lane.tlA;
			pl[i][1]=p.lane.tlB;
			pl[i+1][0]=p.lane.blB;
			pl[i+1][1]=p.lane.blA;
			i+=2;
		}
		return pl;
	}



	float[] get_rect(){
		float ang=ang(0,0,this.vel.x,this.vel.y)+PI/2;
		PVector a=rot_point(this.pos.x-this.engine.CAR_WIDTH/2,this.pos.y-this.engine.CAR_HEIGHT/2,this.pos.x,this.pos.y,ang);
		PVector b=rot_point(this.pos.x+this.engine.CAR_WIDTH/2,this.pos.y+this.engine.CAR_HEIGHT/2,this.pos.x,this.pos.y,ang);
		float[] r={a.x,a.y,b.x,b.y};
		return r;
	}



	float get_min_dist(){
		float dst=-1;
		float ang=this.f_dir+PI/2;
		PVector la=rot_point(this.pos.x,this.pos.y,this.pos.x,this.pos.y,ang);
		PVector lb=rot_point(this.pos.x+this.engine.CAR_WIDTH/2+this.MAX_CAR_COLLISION_DIST+1,this.pos.y,this.pos.x,this.pos.y,ang);
		float[] l={la.x,la.y,lb.x,lb.y};
		if (this.side_path_polygones!=null){
			for (PVector[] p:this.side_path_polygones){
				PVector a=p[0],b=p[1];
				if (collisionLineLine(l[0],l[1],l[2],l[3],a.x,a.y,b.x,b.y)==true){
					PVector pt=intersectionLineLine(l[0],l[1],l[2],l[3],a.x,a.y,b.x,b.y);
					l[2]=pt.x;
					l[3]=pt.y;
				}
			}
		}
		for (Car c:this.engine.CARS){
			if (c==this){
				continue;
			}
			float[] r=c.get_rect();
			if (collisionLineRect(l[0],l[1],l[2],l[3],r[0],r[1],r[2],r[3])==false){
				continue;
			}
			float v=distLineRect(l[0],l[1],l[0],l[1],l[2],l[3],r[0],r[1],r[2],r[3]);
			if (dst!=-1){
				dst=min(dst,v);
			}
			else{
				dst=v;
			}
		}
		if (dst==-1){
			return this.MAX_CAR_COLLISION_DIST+1;
		}
		return dst;
	}



	PVector seek(PVector t){
		return t.copy().sub(this.pos).normalize().mult(this.MAX_SPEED).sub(this.vel);
	}



	PVector change_lane(){
		if (this.right_lane==true){
			return new PVector(0,0);
		}
		float d=dst(this.pos.x,this.pos.y,this.target.get_pos().x,this.target.get_pos().y);
		if (d>this.MAX_CHANGE_LANE_DIST){
			return new PVector(0,0);
		}
		if (this.changing_lane==false){
			float ch=map_value(d,this.MAX_CHANGE_LANE_DIST,this.MIN_CHANGE_LANE_DIST,1,100);
			if (int(random(1)*100)<ch){
				this.changing_lane=true;
				RoadLine l=this.target.lane;
				this.lane_change=rot_point(-this.target.ch_dir,0,0,0,ang(l.s.x,l.s.y,l.e.x,l.e.y)).normalize().mult(this.LANE_CHANGE_SPEED);
			}
		}
		this.check_lane();
		if (this.right_lane==true){
			this.target.change=false;
			this.changing_lane=false;
			this.lane_change=new PVector(0,0);
			return new PVector(0,0);
		}
		if (this.changing_lane==true){
			return this.lane_change.copy();
		}
		else{
			return new PVector(0,0);
		}
	}



	PVector avoid_collision(){
		float car_dist=this.get_min_dist();
		if (car_dist<=this.MAX_CAR_COLLISION_DIST){
			this.sp_lim=(int)max(0,map_value(car_dist,this.MAX_CAR_COLLISION_DIST,this.MIN_CAR_COLLISION_DIST,this.MAX_SPEED,-0.2*this.MAX_SPEED));
			//return this.acc.copy().mult(map_value(car_dist,this.MAX_CAR_COLLISION_DIST,this.MIN_CAR_COLLISION_DIST,-1/100,-1));
		}
		else{
			this.sp_lim=-1;
		}
		return new PVector(0,0);
	}



	PVector lights(){
		if (this.curr_j_lgt!=null&&this.right_lane==true&&this.curr_j_lgt.state!=2){
			float d=dst(this.pos.x,this.pos.y,this.curr_j_lgt.pos.x,this.curr_j_lgt.pos.y);
			if (d>this.MAX_LIGHTS_STOP_DIST){
				return new PVector(0,0);
			}
			d=max(d,this.MIN_LIGHTS_STOP_DIST);
			this.sp_lim=(int)min((this.sp_lim==-1?this.MAX_SPEED:this.sp_lim),map_value(d,this.MAX_LIGHTS_STOP_DIST,this.MIN_LIGHTS_STOP_DIST,this.MAX_SPEED,0));
			return new PVector(0,0);
			//return this.acc.copy().mult(map_value(d,this.MAX_LIGHTS_STOP_DIST,this.MIN_LIGHTS_STOP_DIST,-1/100,-1));
		}
		if (this.curr_r_lgt!=null&&this.right_lane==true&&this.curr_r_lgt.get_state()!=1){
			float d=dst(this.pos.x,this.pos.y,this.curr_r_lgt.pos.x,this.curr_r_lgt.pos.y);
			if (d>this.MAX_LIGHTS_STOP_DIST){
				return new PVector(0,0);
			}
			d=max(d,this.MIN_LIGHTS_STOP_DIST);
			this.sp_lim=(int)min((this.sp_lim==-1?this.MAX_SPEED:this.sp_lim),map_value(d,this.MAX_LIGHTS_STOP_DIST,this.MIN_LIGHTS_STOP_DIST,this.MAX_SPEED,0));
			return new PVector(0,0);
			//return this.acc.copy().mult(map_value(d,this.MAX_LIGHTS_STOP_DIST,this.MIN_LIGHTS_STOP_DIST,-1/100,-1));
		}
		return new PVector(0,0);
	}



	void check_lane(){
		RoadLine l=this.target.lane;
		if (collisionLineCircle(l.s.x,l.s.y,l.e.x,l.e.y,this.pos.x,this.pos.y,this.LANE_CHANGE_BUFFOR)){
			this.right_lane=true;
		}
	}
}
