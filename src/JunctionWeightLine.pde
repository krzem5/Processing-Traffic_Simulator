class JunctionWeightLine{
	Engine engine;
	Junction j;
	PVector s;
	PVector e;
	int c_idx;
	boolean active=false;



	JunctionWeightLine(Engine engine,Junction j,PVector s,PVector e,int c_idx){
		this.engine=engine;
		this.j=j;
		this.s=s;
		this.e=e;
		this.c_idx=c_idx;
	}



	void draw(){
		strokeWeight(5);
		stroke(20,80,200);
		line(this.s.x,this.s.y,this.e.x,this.e.y);
		noStroke();
		fill(75);
		circle(this.s.x,this.s.y,this.engine.POS_DRAG_RADIUS*2);
		circle(this.e.x,this.e.y,this.engine.POS_DRAG_RADIUS*2);
	}



	boolean click(int x,int y){
		if (collisionLineCircle(this.s.x,this.s.y,this.e.x,this.e.y,x,y,this.engine.POS_DRAG_RADIUS)==true){
			this.active=true;
			this.engine.updating_junction=this.j;
			this.engine.TEXTBOX.show("Connection\nWeight",this.j.connections.get(this.c_idx)[2]);
			return true;
		}
		return false;
	}



	void u_conn(int nw){
		this.j.connections.get(this.c_idx)[2]=nw;
	}
}
