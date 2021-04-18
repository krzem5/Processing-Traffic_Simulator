class LightObject{
	Engine engine;
	Junction j=null;
	ArrayList<Light> lights;
	JSONObject json;
	boolean setup=false;



	LightObject(Engine engine,Junction j){
		this.engine=engine;
		this.j=j;
	}



	void update(){
		if (this.lights==null){
			return;
		}
		for (Light l:this.lights){
			l.update();
		}
	}



	void draw(){
		if (this.lights==null){
			return;
		}
		for (Light l:this.lights){
			l.draw();
		}
	}



	void reset(){
		if (this.lights==null){
			return;
		}
		for (Light l:this.lights){
			l.reset();
		}
	}



	void edit_lights(){
		if (this.lights==null){
			return;
		}
		for (Light l:this.lights){
			l.edit=true;
		}
	}



	void stop_edit_lights(){
		if (this.lights==null){
			return;
		}
		for (Light l:this.lights){
			l.edit=false;
		}
	}



	void from_junction(){
		if (this.lights==null){
			this.lights=new ArrayList<Light>();
			for (JunctionEditPoint p:this.j.l_edit_points){
				if (p.type!=0){
					continue;
				}
				this.lights.add(new Light(this.engine,p.pos.copy(),p.conn_idx,this,p));
			}
		}
		else{
			ArrayList<JunctionEditPoint> done=new ArrayList<JunctionEditPoint>();
			for (int i=this.lights.size()-1;i>=0;i--){
				Light l=this.lights.get(i);
				boolean r=false;
				for (JunctionEditPoint p:this.j.l_edit_points){
					if (p.type!=0){
						continue;
					}
					if (p.conn_idx==l.p.conn_idx){
						r=true;
						l.pos=p.pos.copy();
						break;
					}
				}
				if (r==true){
					done.add(l.p);
				}
				else{
					this.lights.remove(i);
				}
			}
			for (JunctionEditPoint p:this.j.l_edit_points){
				if (p.type!=0){
					continue;
				}
				boolean s=true;
				for (JunctionEditPoint p2:done){
					if (p.conn_idx==p2.conn_idx){
						s=false;
						break;
					}
				}
				if (s==true){
					this.lights.add(new Light(this.engine,p.pos.copy(),p.conn_idx,this,p));
				}
			}
		}
	}



	void from_json(JSONObject json){
		if (this.setup==true){
			return;
		}
		this.setup=true;
		for (Object k:json.keys()){
			for (Light l:this.lights){
				if (l.n==int(k.toString())){
					JSONObject dt=json.getJSONObject(k.toString());
					l.RED_TIME=dt.getInt("red");
					l.GREEN_TIME=dt.getInt("green");
					l.ORANGE_TIME=dt.getInt("orange");
					l.OFFSET_TIME=dt.getInt("offset");
					break;
				}
			}
		}
	}



	JSONObject to_json(){
		JSONObject o=new JSONObject();
		if (this.lights==null){
			return o;
		}
		for (Light l:this.lights){
			JSONObject dt=new JSONObject();
			dt.setInt("red",l.RED_TIME);
			dt.setInt("green",l.GREEN_TIME);
			dt.setInt("orange",l.ORANGE_TIME);
			dt.setInt("offset",l.OFFSET_TIME);
			o.setJSONObject(str(l.n),dt);
		}
		return o;
	}
}
