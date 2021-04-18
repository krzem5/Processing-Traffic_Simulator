class RoadLight{
	Engine engine;
	RoadLightObject l;
	PVector pos;



	RoadLight(Engine engine,RoadLightObject l,PVector pos){
		this.engine=engine;
		this.l=l;
		this.pos=pos;
	}



	int get_state(){
		return this.l.state;
	}
}
