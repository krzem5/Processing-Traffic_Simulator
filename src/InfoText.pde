class InfoText{
	Engine engine;
	String txt;
	String ts;
	String rt;
	int st;
	int ep;
	int rep;
	int FONT_SIZE=20;



	InfoText(Engine engine){
		this.engine=engine;
		this.update_m(0,0);
		this.reset_sel();
		this.update_keys();
	}



	void update_m(int ep,int rep){
		this.ep=ep;
		this.rep=rep;
		String s="";
		s+="Mouse Pos:";
		s+="\n  Screen: x: "+str(mouseX)+" y: "+str(mouseY);
		s+="\n  Editor: x: "+str((int)this.engine.MOUSE.x)+" y: "+str((int)this.engine.MOUSE.y);
		s+="\nScroll: xd: "+str(this.engine.OFF_X)+" y: "+this.engine.OFF_Y;
		s+="\nZoom: "+int(this.engine.MAX_ZOOM_OUT-this.engine.ZOOM_OUT+1);
		s+="\nMode: "+(this.engine.EDITING_LIGHTS==true?"Editing Lights":(this.engine.EDITING_ROAD_INPUT==true?"Editing Input/Output Weights":(ep==1?"Editing Junction Connections":(ep==2?"Editing Junction Connection Weights":(this.engine.RUNNING==true?"Simulation":(this.engine.ROADMAP_VIEW==true?"View":"Edit"))))));
		if (this.engine.ROADMAP_VIEW==true||this.engine.RUNNING==true){
			s+="\nTrack Visible: "+(this.engine.LANE_LINES==true?"Yes":"No");
			if (this.engine.RUNNING==true){
				if (this.engine.SIMULATION_PAUSED==true){
					s+="\nSimulation: Paused";
				}
				else{
					s+="\nSimulation: Running";
				}
				s+="\nSimulation Ratio: "+str((float)round((float)this.engine.c_out/(float)(this.engine.c_in+this.engine.CARS.size())*10000)/100).replaceAll("\\.0$","")+"% ("+str(this.engine.c_out)+" / "+str(this.engine.c_in+this.engine.CARS.size())+")";
			}
		}
		else{
			s+="\nArrows Visible: "+(this.engine.DRAW_ARROWS==true?"Yes":"No");
		}
		if (this.engine.RUNNING==true){
			s+="\n\nStatistics:";
			s+="\n  Cars: "+str(this.engine.CARS.size());
		}
		if (this.engine.RUNNING==false&&this.engine.ROADMAP_VIEW==false&&this.engine.EDITING_ROAD_INPUT==false){
			s+="\n\nCurrect Selection:\n";
			if (this.ts!=null){
				s+=this.ts;
			}
			else{
				s+="  None";
			}
		}
		if (this.engine.EDITING_ROAD_INPUT==true){
			s+="\n\nInput Weights:";
			for (Road r : this.engine.ROADS){
				if (r.is_I()==false){
					continue;
				}
				s+="\n  ID "+r.ID+":";
				IntList l=this.engine.road_weights.get(r.ID);
				for (int i=0; i<l.size(); i++){
					if (l.get(i)==-1){
						continue;
					}
					s+="\n    Weight: "+l.get(i);
				}
			}
		}
		this.txt=s;
	}



	void update_keys(){
		String s="";
		s+="ESC — Close the programm";
		s+="\nQ — Toggle Text visibility";
		s+="\n\nE — Toggle between Editor and View mode";
		if (this.ep==0){
			s+="\nS — Toggle Simulation mode";
			if (this.engine.RUNNING==true){
				s+="\nP — Pause / Unpause the simulation";
				s+="\nALT — x2 Speed";
				s+="\nSHIFT + ALT — x0.5 speed";
				s+="\nCTRL + S — Reset simulation";
			}
		}
		if (this.engine.ROADMAP_VIEW==true||this.engine.RUNNING==true){
			s+="\n\nT — Toggle track visibility";
		}
		else{
			s+="\n\nA — Toggle arrows";
		}
		if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT&&this.engine.RUNNING==false&&this.engine.ROADMAP_VIEW==false&&this.engine.EDITING_ROAD_INPUT==false&&this.engine.highlight==false&&this.ep==0&&this.rep==0){
			s+="\n\nCTRL + CLICK — Toggle Road I/O weight edit mode";
			s+="\n\nCTRL + SHIFT + DELETE(2x) — Delete everything";
			s+="\n\nN — Create a new road";
			s+="\nM — Create a new junction";
		}
		if (this.engine.highlight==false&&this.ep==0&&this.rep==0){
			s+="\n\nUP — Scroll up";
			s+="\nDOWN — Scroll down";
			s+="\nLEFT — Scroll left";
			s+="\nRIGHT — Scroll right";
			s+="\n\nCTRL + UP — Scroll to 0";
			s+="\nCTRL + DOWN — Scroll to height";
			s+="\nCTRL + LEFT — Scroll to 0";
			s+="\nCTRL + RIGHT — Scroll to width";
			s+="\n\nSHIFT + UP — Zoom in";
			s+="\nSHIFT + DOWN — Zoom out";
		}
		if (this.engine.RUNNING==false&&this.engine.ROADMAP_VIEW==false&&this.engine.EDITING_ROAD_INPUT==false&&this.ts!=null){
			if (this.st==0){
				if (this.rep==0){
					s+="\n\nUP — Adds 1 lane to the left";
					s+="\nDOWN — Removes 1 lane from the left";
					s+="\nRIGHT — Adds 1 lane to the right";
					s+="\nLEFT — REMOVES 1 lane from the right";
					if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT){
						s+="\n\nCLICK — Move the anchor point to the mouse poition";
						s+="\nSHIFT + CLICK — Disconnect from all Roads / Junctions";
					}
					if (this.ts.indexOf("Enabled: Yes")!=-1){
						s+="\nCTRL + CLICK — Toggle light edit mode";
					}
					if (this.ts.indexOf(" (Junction)")==-1){
						s+="\nCTRL + SHIFT + CLICK — Toggle lights";
					}
					s+="\n\nDELETE — Removes the Road";
				}
				else{
					s+="\n\nCLICK — Edit min light delay";
					s+="\nSHIFT + CLICK — Edit max light delay";
					s+="\nALT + CLICK — Edit crossing time";
					s+="\nCTRL + CLICK — Toggle light edit mode";
				}
			}
			if (this.st==1){
				if (this.ep==0){
					s+="\n\nUP — Adds 1 side";
					s+="\nDOWN — Removes 1 side";
					s+="\nRIGHT — Increments radius";
					s+="\nLEFT — Decrements radius";
					s+="\nCTRL + RIGHT — Rotates right";
					s+="\nCTRL + LEFT — Rotates left";
					if (this.engine.ZOOM_OUT<=this.engine.MAX_EDIT_ZOOM_OUT){
						s+="\n\nCLICK — Move the anchor point to the mouse poition";
						s+="\nSHIFT + CLICK — Disconnect from all Roads";
						s+="\nCTRL + CLICK — Toggle Connecion mode";
						s+="\nALT + CLICK — Edit connection weights";
						s+="\nCTRL + ALT + CLICK — Toggle Edit Lights mode";
					}
					s+="\n\nDELETE — Removes the junction";
				}
				if (this.ep==1){
					s+="\n\nCLICK — Select a point";
					s+="\nSHIFT + CLICK — Disconnect all lines from a point";
					s+="\nCTRL + CLICK — Toggle Connecion mode";
				}
				if (this.ep==2){
					s+="\n\nCLICK — Edit the weight of the connection";
					s+="\nALT + CLICK — Toggle Edit Weights mode";
				}
				if (this.ep==3){
					s+="\n\nCTRL + ALT + CLICK — Toggle Edit Lights mode";
					s+="\n\nCLICK — Edit red light length";
					s+="\nSHIFT + CLICK — Edit green light length";
					s+="\nCTRL + CLICK — Edit orange light length";
					s+="\nCTRL + SHIFT + CLICK — Edit light offset";
				}
			}
		}
		if (this.engine.EDITING_ROAD_INPUT==true){
			s+="\n\nCLICK — Edit the weight";
		}
		this.rt=s;
	}



	void draw(){
		textFont(createFont("consolas",this.FONT_SIZE));
		noStroke();
		fill(255,180);
		textAlign(LEFT);
		text(this.txt,10,10+textAscent());
		textAlign(RIGHT);
		text(this.rt,width-10,10+textAscent());
	}



	void set_sel(String t,int v){
		this.ts=t;
		this.st=v;
		this.update_keys();
	}



	void reset_sel(){
		this.ts=null;
		this.st=-1;
		this.update_keys();
	}
}
