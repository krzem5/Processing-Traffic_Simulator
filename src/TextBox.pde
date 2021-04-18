class TextBox{
	Engine engine;
	boolean visible=false;
	String text;
	String title;



	TextBox(Engine engine){
		this.engine=engine;
		this.text="50";
		this.title="Connection";
	}



	void show(String title,int v){
		this.text=str(v);
		this.title=title;
		this.visible=true;
	}



	void keypress(char key,int keyCode){
		if (this.visible==false){
			return;
		}
		if (keyCode==BACKSPACE){
			if (this.text.length()==1){
				this.text="0";
			} else{
				this.text=this.text.substring(0,this.text.length()-1);
			}
		}
		if (keyCode==10){
			this.visible=false;
			this.engine.update_weight();
		}
		if (keyCode<48||keyCode>57){
			return;
		}
		this.text=str(min(100,int(this.text+str(key))));
	}



	void draw(){
		if (this.visible==false){
			return;
		}
		noStroke();
		rectMode(CORNER);
		fill(0,128);
		rect(0,0,width,height);
		fill(45);
		rectMode(CENTER);
		rect(width/2,height/2-100,800,400,30);
		textAlign(CENTER);
		textFont(createFont("consolas",80));
		fill(230);
		text("Edit "+this.title,width/2,height/2-300+textAscent());
		textFont(createFont("consolas",40));
		fill(230);
		text(this.text,width/2,height/2);
		stroke(255);
		line(width/2-50,height/2+textDescent(),width/2+50,height/2+textDescent());
	}
}
