class RoadWeightPoint{
	Engine engine;
	PVector pos;
	Road r;
	RoadLine l;
	boolean clicked=false;
	int DEFAULT_WEIGHT=50;



	RoadWeightPoint(Engine engine,PVector pos,RoadLine l,Road r){
		this.engine=engine;
		this.pos=pos;
		this.l=l;
		this.r=r;
	}



	void update(){
		if (mousePressed==true&&this.clicked==false){
			this.clicked=true;
			if (dst(this.engine.MOUSE.x,this.engine.MOUSE.y,this.pos.x,this.pos.y)<=this.engine.POS_DRAG_RADIUS){
				this.engine.updating_rpoint=this;
				this.engine.TEXTBOX.show("Input Road \nWeight",this.get_weight());
			}
		}
		if (mousePressed==false){
			this.clicked=false;
		}
	}



	void draw(){
		noStroke();
		fill(128,255,255);
		circle(this.pos.x,this.pos.y,this.engine.POS_DRAG_RADIUS*2);
	}



	int default_weight(){
		if (this.engine.road_weights.get(this.r.ID).size()<=this.l.lane-1+this.engine.MAX_LANES||this.engine.road_weights.get(this.r.ID).get(this.l.lane-1+this.engine.MAX_LANES)==-1){
			this.set_weight(this.DEFAULT_WEIGHT);
		}
		return this.DEFAULT_WEIGHT;
	}



	void set_weight(int w){
		while (this.engine.road_weights.get(this.r.ID).size()<=this.l.lane-1+this.engine.MAX_LANES){
			this.engine.road_weights.get(this.r.ID).append(-1);
		}
		this.engine.road_weights.get(this.r.ID).set(this.l.lane-1+this.engine.MAX_LANES,w);
	}



	int get_weight(){
		return this.engine.road_weights.get(this.r.ID).get(this.l.lane-1+this.engine.MAX_LANES);
	}
}
