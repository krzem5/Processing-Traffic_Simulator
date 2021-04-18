class CarPathPoint{
	Engine engine;
	PVector pos;
	boolean change;
	PVector start_lane;
	boolean slow=false;
	RoadLine lane;
	int ch_dir=1;
	Light lgt;



	CarPathPoint(Engine engine,PVector pos){
		this.engine=engine;
		this.pos=pos;
		this.change=false;
		this.start_lane=null;
	}



	CarPathPoint(Engine engine,PVector pos,RoadLine l,boolean slow){
		this.engine=engine;
		this.pos=pos;
		this.change=false;
		this.start_lane=null;
		this.set_lane(l);
		this.slow=slow;
	}



	CarPathPoint(Engine engine,PVector pos,PVector start){
		this.engine=engine;
		this.pos=pos;
		this.change=true;
		this.start_lane=start;
	}



	void set_lane(RoadLine l){
		this.lane=l;
	}



	void set_ch_dir(RoadLine l){
		if (this.lane.lane<l.lane){
			this.ch_dir=1;
		}
		else{
			this.ch_dir=-1;
		}
	}



	PVector get_pos(){
		if (this.change==false){
			return this.pos;
		}
		return this.start_lane;
	}
}
