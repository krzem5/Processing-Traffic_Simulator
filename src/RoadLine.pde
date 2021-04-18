class RoadLine{
	Engine engine;
	PVector o_s;
	PVector o_e;
	PVector s;
	PVector e;
	PVector tlA;
	PVector tlB;
	PVector blA;
	PVector blB;
	boolean visible=true;
	RoadLine sl;
	RoadLine el;
	ArrayList<RoadLine> Asl;
	ArrayList<RoadLine> Ael;
	int lane;
	boolean invertA;
	boolean invertB;
	ArrayList<PVector> jA;
	ArrayList<PVector> jB;
	boolean lA;
	boolean lB;
	boolean junction=false;
	Junction j;
	int ID;
	IntList AslW,AelW;
	List<RoadLine> lst=null;
	Road r=null;
	PVector crossing_lights=null;



	RoadLine(Engine engine,int l,int ID){
		this.engine=engine;
		this.visible=false;
		this.o_s=new PVector(0,0);
		this.o_e=new PVector(0,0);
		this.s=new PVector(0,0);
		this.e=new PVector(0,0);
		this.tlA=new PVector(0,0);
		this.tlB=new PVector(0,0);
		this.blA=new PVector(0,0);
		this.blB=new PVector(0,0);
		this.lane=l;
		this.invertA=false;
		this.invertB=false;
		this.jA=null;
		this.jB=null;
		this.lA=false;
		this.lB=false;
		this.ID=ID;
		this.sl=null;
		this.el=null;
		this.Asl=new ArrayList<RoadLine>();
		this.Ael=new ArrayList<RoadLine>();
		this.AslW=new IntList();
		this.AelW=new IntList();
	}



	void update(){
		if (this.visible==false){
			return;
		}
		this.s=this.o_s.copy();
		this.e=this.o_e.copy();
		this.update_sides();
		if (this.jA!=null){
			PVector A=this.jA.get(0),B=this.jA.get(1);
			this.s=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,A.x,A.y,B.x,B.y);
			this.tlA=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,A.x,A.y,B.x,B.y);
			this.blA=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,A.x,A.y,B.x,B.y);
		}
		if (this.jB!=null){
			PVector A=this.jB.get(0),B=this.jB.get(1);
			this.e=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,A.x,A.y,B.x,B.y);
			this.tlB=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,A.x,A.y,B.x,B.y);
			this.blB=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,A.x,A.y,B.x,B.y);
		}
	}



	void update_sides(){
		float a=ang(this.s.x,this.s.y,this.e.x,this.e.y);
		this.tlA=rot_point(this.s.x+this.engine.LANE_WIDTH/2,this.s.y,this.s.x,this.s.y,a);
		this.tlB=rot_point(this.e.x+this.engine.LANE_WIDTH/2,this.e.y,this.e.x,this.e.y,a);
		this.blA=rot_point(this.s.x-this.engine.LANE_WIDTH/2,this.s.y,this.s.x,this.s.y,a);
		this.blB=rot_point(this.e.x-this.engine.LANE_WIDTH/2,this.e.y,this.e.x,this.e.y,a);
		if (this.sl!=null&&this.jA==null){
			this.s=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,this.sl.s.x,this.sl.s.y,this.sl.e.x,this.sl.e.y);
			if (this.invertA==false){
				this.tlA=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.sl.tlA.x,this.sl.tlA.y,this.sl.tlB.x,this.sl.tlB.y);
				this.blA=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.sl.blA.x,this.sl.blA.y,this.sl.blB.x,this.sl.blB.y);
			} else{
				this.tlA=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.sl.blA.x,this.sl.blA.y,this.sl.blB.x,this.sl.blB.y);
				this.blA=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.sl.tlA.x,this.sl.tlA.y,this.sl.tlB.x,this.sl.tlB.y);
			}
		}
		if (this.el!=null&&this.jB==null){
			this.e=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,this.el.s.x,this.el.s.y,this.el.e.x,this.el.e.y);
			if (this.invertB==false){
				this.tlB=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.el.tlA.x,this.el.tlA.y,this.el.tlB.x,this.el.tlB.y);
				this.blB=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.el.blA.x,this.el.blA.y,this.el.blB.x,this.el.blB.y);
			} else{
				this.tlB=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.el.blA.x,this.el.blA.y,this.el.blB.x,this.el.blB.y);
				this.blB=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.el.tlA.x,this.el.tlA.y,this.el.tlB.x,this.el.tlB.y);
			}
		}
	}



	void update_j_sides(){
		float a=ang(this.s.x,this.s.y,this.e.x,this.e.y);
		this.tlA=rot_point(this.s.x+this.engine.LANE_WIDTH/2,this.s.y,this.s.x,this.s.y,a);
		this.tlB=rot_point(this.e.x+this.engine.LANE_WIDTH/2,this.e.y,this.e.x,this.e.y,a);
		this.blA=rot_point(this.s.x-this.engine.LANE_WIDTH/2,this.s.y,this.s.x,this.s.y,a);
		this.blB=rot_point(this.e.x-this.engine.LANE_WIDTH/2,this.e.y,this.e.x,this.e.y,a);
		if (this.sl!=null&&this.sl.junction==true){
			this.e=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,this.sl.s.x,this.sl.s.y,this.sl.e.x,this.sl.e.y);
			this.tlB=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.sl.tlA.x,this.sl.tlA.y,this.sl.tlB.x,this.sl.tlB.y);
			this.blB=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.sl.blA.x,this.sl.blA.y,this.sl.blB.x,this.sl.blB.y);
		}
		if (this.el!=null&&this.el.junction==true){
			this.s=intersectionLineLine(this.s.x,this.s.y,this.e.x,this.e.y,this.el.s.x,this.el.s.y,this.el.e.x,this.el.e.y);
			this.tlA=intersectionLineLine(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y,this.el.tlA.x,this.el.tlA.y,this.el.tlB.x,this.el.tlB.y);
			this.blA=intersectionLineLine(this.blA.x,this.blA.y,this.blB.x,this.blB.y,this.el.blA.x,this.el.blA.y,this.el.blB.x,this.el.blB.y);
		}
	}



	void draw(){
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		if (this.engine.LANE_LINES==true){
			strokeWeight(3);
			stroke(20,230,20);
			line(this.s.x,this.s.y,this.e.x,this.e.y);
		}
		if (this.junction==true){
			scale(this.engine.ZOOM_OUT);
			translate(this.engine.OFF_X,this.engine.OFF_Y);
			return;
		}
		stroke(255);
		strokeWeight(2);
		if (this.lane==0||this.lane==this.engine.MAX_LANES||this.lB==true){
			line(this.tlA.x,this.tlA.y,this.tlB.x,this.tlB.y);
		} else{
			this.draw_dashed_lanes(this.tlA,this.tlB);
		}
		if (this.lane==1||this.lane==-this.engine.MAX_LANES+1||this.lA==true){
			line(this.blA.x,this.blA.y,this.blB.x,this.blB.y);
		}
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void draw_dashed_lanes(PVector s,PVector e){
		float cx=s.x/2+e.x/2;
		float cy=s.y/2+e.y/2;
		int d=int(dst(s.x,s.y,e.x,e.y));
		float off=(d-max(int(d/this.engine.LANE_DASH_DIST),1)*this.engine.LANE_DASH_DIST)/2/max(int(d/this.engine.LANE_DASH_DIST),1);
		float a=ang(s.x,s.y,e.x,e.y);
		for (int i=0;i<max(d/this.engine.LANE_DASH_DIST,1);i++){
			float yoff=map(i,0,max(d/this.engine.LANE_DASH_DIST,1),-d/2,d/2)+this.engine.LANE_DASH_DIST/2+off;
			PVector as=rot_point(cx,cy+yoff+(float)this.engine.LANE_DASH_DIST/4,cx,cy,a);
			PVector ae=rot_point(cx,cy+yoff-(float)this.engine.LANE_DASH_DIST/4,cx,cy,a);
			line(as.x,as.y,ae.x,ae.y);
		}
	}



	void set_pos(PVector a,PVector b){
		this.visible=true;
		this.o_s=a;
		this.o_e=b;
		this.update();
	}



	void set_conns(RoadLine a,RoadLine b){
		if (a!=null&&a.visible==false){
			a=null;
		}
		if (b!=null&&b.visible==false){
			b=null;
		}
		this.sl=a;
		this.el=b;
	}



	RoadLight get_road_crossing(){
		if (this.r!=null&&this.r.LIGHTS.enabled==true){
			 return this.r.LIGHTS.get_light(this);
		}
		return null;
	}



	RoadLine get_rand(String tp){
		if (tp.equals("s")){
			int t=0;
			for (int i=0;i<this.Asl.size();i++){
				t+=this.AslW.get(i);
			}
			int[] A=new int[t];
			int idx=0;
			for (int i=0;i<this.Asl.size();i++){
				int v=this.AslW.get(i);
				for (int j=0;j<v;j++){
					A[idx]=i;
					idx++;
				}
			}
			return this.Asl.get(A[int(random(1)*t)]);
		}
		int t=0;
		for (int i=0;i<this.Ael.size();i++){
			t+=this.AelW.get(i);
		}
		int[] A=new int[t];
		int idx=0;
		for (int i=0;i<this.Ael.size();i++){
			int v=this.AelW.get(i);
			for (int j=0;j<v;j++){
				A[idx]=i;
				idx++;
			}
		}
		return this.Ael.get(A[int(random(1)*t)]);
	}



	boolean change_lane(RoadLine l){
		return (l.sl!=this&&l.el!=this);
	}
}
