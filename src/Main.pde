import java.util.List;
import java.util.ArrayList;



Engine ENGINE;
boolean SHIFT_DOWN=false;
boolean CTRL_DOWN=false;
boolean ALT_DOWN=false;
boolean KEY_DOWN=false;



void setup() {
  ENGINE=new Engine();
  ENGINE.BOARD_NAME="junction.json";
  ENGINE.from_JSON(loadJSONObject(ENGINE.BOARD_NAME));
  fullScreen();
  frameRate(60);
}



void keyPressed() {
  ENGINE.keyPressed(keyCode);
}
void keyReleased() {
  ENGINE.keyReleased(keyCode);
}
void mouseReleased() {
  ENGINE.mouseReleased();
}




void draw() {
  if ((SHIFT_DOWN==true&&ALT_DOWN==true&&frameCount%2==0)||!(SHIFT_DOWN==true&&ALT_DOWN==true)) {
    ENGINE.update();
  }
  if (SHIFT_DOWN==false&&ALT_DOWN==true) {
    ENGINE.update();
  }
  ENGINE.draw();
}
