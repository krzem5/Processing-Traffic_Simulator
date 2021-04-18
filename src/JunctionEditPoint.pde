class JunctionEditPoint{
	Engine engine;
	Junction junction;
	PVector pos;
	int type;
	int conn_idx;
	ArrayList<JunctionEditPoint> ig;
	ArrayList<JunctionEditPoint> conns;
	float sa;
	RoadLine l;
	int lp;



	JunctionEditPoint(Engine engine,Junction j,RoadLine l,int lp,int t,int i,ArrayList<JunctionEditPoint> ig,float sa){
		this.engine=engine;
		this.junction=j;
		this.l=l;
		this.lp=lp;
		this.pos=(this.lp==0?this.l.s:this.l.e);
		this.type=t;
		this.conn_idx=i;
		this.ig=ig;
		this.conns=new ArrayList<JunctionEditPoint>();
		this.sa=sa;
	}



	void draw(){
		noStroke();
		fill(30,100,210);
		if (this.check()==false){
			fill(75);
		}
		if (this.type==0){
			if (this.junction.selected_start_point==this){
				fill(60,180,255);
			}
			circle(this.pos.x,this.pos.y,this.engine.POS_DRAG_RADIUS*2);
		}
		else{
			circle(this.pos.x,this.pos.y,this.engine.POS_DRAG_RADIUS*2);
		}
	}



	boolean check(){
		if (this.type==0){
			return (this.junction.selected_start_point==null||this.junction.selected_start_point==this);
		}
		if (this.junction.selected_start_point==null){
			return false;
		}
		if (this.ig==null){
			return true;
		}
		for (JunctionEditPoint p : this.ig){
			if (p==this.junction.selected_start_point){
				return false;
			}
		}
		for (JunctionEditPoint p : this.conns){
			if (p==this.junction.selected_start_point){
				return false;
			}
		}
		return true;
	}



	void disconnect(){
		this.junction.disconnect_edit_point(this);
	}



	void select(){
		if (this.check()==false){
			return;
		}
		if (this.type==0){
			this.junction.selected_start_point=this;
		}
		else{
			this.junction.connect_edit(this.junction.selected_start_point,this);
		}
	}
}
