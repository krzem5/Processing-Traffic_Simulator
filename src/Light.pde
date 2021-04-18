class Light{
	Engine engine;
	LightObject l;
	JunctionEditPoint p;
	PVector pos;
	int state=1;
	int n=0;
	int ALPHA=150;
	int RED_TIME=30;
	int GREEN_TIME=10;
	int ORANGE_TIME=5;
	int OFFSET_TIME=0;
	float t=0;
	boolean edit=false;
	boolean clicked=false;
	int u_type=0;



	Light(Engine engine,PVector pos,int n,LightObject l,JunctionEditPoint p){
		this.engine=engine;
		this.pos=pos;
		this.n=n;
		this.l=l;
		this.p=p;
	}



	void update(){
		if (this.edit==false){
			this.t+=1/frameRate;
			if (this.t>=this.RED_TIME+this.GREEN_TIME+this.ORANGE_TIME){
				this.t=0;
			}
			if (this.t<this.RED_TIME){
				this.state=0;
			}
			else if (this.t<this.RED_TIME+this.GREEN_TIME){
				this.state=2;
			}
			else{
				this.state=1;
			}
		}
		else{
			if (this.clicked==false&&mousePressed==true){
				this.clicked=true;
				if (dst(this.engine.MOUSE.x,this.engine.MOUSE.y,this.pos.x,this.pos.y)<=this.engine.POS_DRAG_RADIUS){
					if (CTRL_DOWN==false&&SHIFT_DOWN==false){
						this.engine.updating_light=this;
						this.engine.TEXTBOX.show("Red Light\nLength",this.RED_TIME);
						this.u_type=0;
					}
					if (CTRL_DOWN==false&&SHIFT_DOWN==true){
						this.engine.updating_light=this;
						this.engine.TEXTBOX.show("Green Light\nLength",this.GREEN_TIME);
						this.u_type=1;
					}
					if (CTRL_DOWN==true&&SHIFT_DOWN==false){
						this.engine.updating_light=this;
						this.engine.TEXTBOX.show("Orange Light\nLength",this.ORANGE_TIME);
						this.u_type=2;
					}
					if (CTRL_DOWN==true&&SHIFT_DOWN==true){
						this.engine.updating_light=this;
						this.engine.TEXTBOX.show("Light Offset\nLength",this.OFFSET_TIME);
						this.u_type=3;
					}
				}
			}
			if (this.clicked==true&&mousePressed==false){
				this.clicked=false;
			}
		}
	}



	void draw(){
		if (this.edit==false&&this.engine.EDITING_LIGHTS==true){
			return;
		}
		translate(-this.engine.OFF_X,-this.engine.OFF_Y);
		scale(1/this.engine.ZOOM_OUT);
		if (this.edit==false){
			if (this.state==0){
				fill(220,100,100,this.ALPHA);
			}
			if (this.state==1){
				fill(220,150,100,this.ALPHA);
			}
			if (this.state==2){
				fill(100,220,100,this.ALPHA);
			}
		}
		else{
			fill(30,100,210);
		}
		noStroke();
		ellipseMode(RADIUS);
		circle(this.pos.x,this.pos.y,this.engine.POS_DRAG_RADIUS);
		ellipseMode(DIAMETER);
		scale(this.engine.ZOOM_OUT);
		translate(this.engine.OFF_X,this.engine.OFF_Y);
	}



	void reset(){
		this.t=-this.OFFSET_TIME;
	}



	void set_weight(int w){
		switch(this.u_type){
		case 0:
			this.RED_TIME=w;
			break;
		case 1:
			this.GREEN_TIME=w;
			break;
		case 2:
			this.ORANGE_TIME=w;
			break;
		case 3:
			this.OFFSET_TIME=w;
			break;
		}
		this.l.j.update_text();
	}
}
