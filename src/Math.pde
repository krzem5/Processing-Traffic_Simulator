float ang(float x1,float y1,float x2,float y2){
	return -atan2(x2-x1,y2-y1);
}



PVector rot_point(float px,float py,float x,float y,float a){
	return new PVector((px-x)*cos(a)-(py-y)*sin(a)+x,(px-x)*sin(a)+(py-y)*cos(a)+y);
}



PVector intersectionRoundLineLine(float l1sx,float l1sy,float l1ex,float l1ey,float l2sx,float l2sy,float l2ex,float l2ey){
	if (abs(ang(l1sx,l1sy,l1ex,l1ey)-ang(l2sx,l2sy,l2ex,l2ey))<=1e-5){
		return avg2(new PVector(l1sx,l1sy),new PVector(l2sx,l2sy));
	}
	float t=((l1sx-l2sx)*(l2sy-l2ey)-(l1sy-l2sy)*(l2sx-l2ex))/((l1sx-l1ex)*(l2sy-l2ey)-(l1sy-l1ey)*(l2sx-l2ex));
	return new PVector(l1sx+t*(l1ex-l1sx),l1sy+t*(l1ey-l1sy));
}



PVector intersectionLineLine(float l1sx,float l1sy,float l1ex,float l1ey,float l2sx,float l2sy,float l2ex,float l2ey){
	return new PVector(l1sx+(((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))*(l1ex-l1sx)),l1sy+(((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))*(l1ey-l1sy)));
}



boolean collisionLineLine(float l1sx,float l1sy,float l1ex,float l1ey,float l2sx,float l2sy,float l2ex,float l2ey){
	return (((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))>=0&&((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))<=1&&((l1ex-l1sx)*(l1sy-l2sy)-(l1ey-l1sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))>=0&&((l1ex-l1sx)*(l1sy-l2sy)-(l1ey-l1sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))<=1);
}



boolean collisionLineRect(float lsx,float lsy,float lex,float ley,float rsx,float rsy,float rex,float rey){
	return (collisionLineLine(lsx,lsy,lex,ley,rsx,rsy,rsx,rey)||collisionLineLine(lsx,lsy,lex,ley,rex,rsy,rex,rey)||collisionLineLine(lsx,lsy,lex,ley,rsx,rsy,rex,rsy)||collisionLineLine(lsx,lsy,lex,ley,rsx,rey,rex,rey));
}



boolean collisionPointPoly(float px,float py,PVector[] p){
	boolean c=false;
	for (int i=0; i<p.length; i++){
		if (((p[i].y>py&&p[(i+1)%p.length].y<py)||(p[i].y<py&&p[(i+1)%p.length].y>py))&&(px<(p[(i+1)%p.length].x-p[i].x)*(py-p[i].y)/(p[(i+1)%p.length].y-p[i].y)+p[i].x)){
			c=!c;
		}
	}
	return c;
}



float distLineRect(float px,float py,float lsx,float lsy,float lex,float ley,float rsx,float rsy,float rex,float rey){
	PVector d1=intersectionLineLine(lsx,lsy,lex,ley,rsx,rsy,rsx,rey);
	PVector d2=intersectionLineLine(lsx,lsy,lex,ley,rex,rsy,rex,rey);
	PVector d3=intersectionLineLine(lsx,lsy,lex,ley,rsx,rsy,rex,rsy);
	PVector d4=intersectionLineLine(lsx,lsy,lex,ley,rsx,rey,rex,rey);
	return min(min(min(dst(px,py,d1.x,d1.y),dst(px,py,d2.x,d2.y)),dst(px,py,d3.x,d3.y)),dst(px,py,d4.x,d4.y));
}



boolean collisionLineCircle(float lsx,float lsy,float lex,float ley,float cx,float cy,float cr){
	if (collisionPointCircle(lsx,lsy,cx,cy,cr)||collisionPointCircle(lex,ley,cx,cy,cr)){
		return true;
	}
	if (!collisionPointLine(lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx)),lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy)),lsx,lsy,lex,ley)){
		return false;
	}
	return (sqrt((lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx))-cx)*(lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx))-cx)+(lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy))-cy)*(lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy))-cy))<=cr);
}



boolean collisionPointCircle(float px,float py,float cx,float cy,float cr){
	return (dst(px,py,cx,cy)<=cr);
}



boolean collisionPointLine(float px,float py,float lsx,float lsy,float lex,float ley){
	float buffer=0.1;
	return (dst(px,py,lsx,lsy)+dst(px,py,lex,ley)>=dst(lsx,lsy,lex,ley)-buffer&&dst(px,py,lsx,lsy)+dst(px,py,lex,ley)<=dst(lsx,lsy,lex,ley)+buffer);
}



PVector lerp(PVector a,PVector b,float c){
	return new PVector(a.x*c+b.x*(1-c),a.y*c+b.y*(1-c));
}



float dst(float a,float b,float c,float d){
	return sqrt((a-c)*(a-c)+(b-d)*(b-d));
}



float diff(PVector a,PVector b){
	return max(abs(a.x-b.x),abs(a.y-b.y));
}



float diff(float a,float b){
	return abs(a-b);
}



float constrain_value(float v,float a,float b){
	return min(max(v,a),b);
}



float map_value(float v,float aa,float ab,float ba,float bb){
	return (v-aa)/(ab-aa)*(bb-ba)+ba;
}



PVector avg2(PVector a,PVector b){
	return new PVector((a.x+b.x)/2,(a.y+b.y)/2);
}



PVector avg4(PVector a,PVector b,PVector c,PVector d){
	return new PVector((a.x+b.x+c.x+d.x)/4,(a.y+b.y+c.y+d.y)/4);
}



float kmh_to_pxs(float s){
	return m_to_px(s/3.6);
}



float pxs_to_kmh(float s){
	return px_to_m(s)*3.6;
}



float m_to_px(float v){
	return v*(e.CAR_WIDTH/e.REAL_CAR_WIDTH);
}



float px_to_m(float v){
	return v/(e.CAR_WIDTH/e.REAL_CAR_WIDTH);
}



float m_to_px(float v,Engine engine){
	return v*(engine.CAR_WIDTH/engine.REAL_CAR_WIDTH);
}



float px_to_m(float v,Engine engine){
	return v/(engine.CAR_WIDTH/engine.REAL_CAR_WIDTH);
}
