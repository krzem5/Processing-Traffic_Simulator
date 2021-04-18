import java.util.List;



Engine e;
boolean SHIFT_DOWN=false;
boolean CTRL_DOWN=false;
boolean ALT_DOWN=false;
boolean KEY_DOWN=false;



void setup(){
	fullScreen();
	frameRate(60);
	e=new Engine();
	e.BOARD_NAME="junction.json";
	e.from_json(loadJSONObject(e.BOARD_NAME));
}



void keyPressed(){
	e.keyPressed(keyCode);
}
void keyReleased(){
	e.keyReleased(keyCode);
}
void mouseReleased(){
	e.mouseReleased();
}




void draw(){
	if ((SHIFT_DOWN==true&&ALT_DOWN==true&&frameCount%2==0)||!(SHIFT_DOWN==true&&ALT_DOWN==true)){
		e.update();
	}
	if (SHIFT_DOWN==false&&ALT_DOWN==true){
		e.update();
	}
	e.draw();
}
