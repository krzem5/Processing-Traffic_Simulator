float ang(float x1, float y1, float x2, float y2) {
  return -atan2(x2-x1, y2-y1);
}
PVector rot_point(float px, float py, float x, float y, float a) {
  return new PVector((px-x)*cos(a)-(py-y)*sin(a)+x, (px-x)*sin(a)+(py-y)*cos(a)+y);
}
PVector intersectionRoundLineLine(float l1sx, float l1sy, float l1ex, float l1ey, float l2sx, float l2sy, float l2ex, float l2ey) {
  if (abs(ang(l1sx,l1sy,l1ex,l1ey)-ang(l2sx,l2sy,l2ex,l2ey))<=1e-5){
    return avg2(new PVector(l1sx,l1sy),new PVector(l2sx,l2sy));
  }
  float t=((l1sx-l2sx)*(l2sy-l2ey)-(l1sy-l2sy)*(l2sx-l2ex))/((l1sx-l1ex)*(l2sy-l2ey)-(l1sy-l1ey)*(l2sx-l2ex));
  return new PVector(l1sx+t*(l1ex-l1sx),l1sy+t*(l1ey-l1sy));
}
PVector intersectionLineLine(float l1sx, float l1sy, float l1ex, float l1ey, float l2sx, float l2sy, float l2ex, float l2ey) {
  return new PVector(l1sx+(((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))*(l1ex-l1sx)), l1sy+(((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))*(l1ey-l1sy)));
}
boolean collisionLineLine(float l1sx, float l1sy, float l1ex, float l1ey, float l2sx, float l2sy, float l2ex, float l2ey) {
  return (((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))>=0&&((l2ex-l2sx)*(l1sy-l2sy)-(l2ey-l2sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))<=1&&((l1ex-l1sx)*(l1sy-l2sy)-(l1ey-l1sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))>=0&&((l1ex-l1sx)*(l1sy-l2sy)-(l1ey-l1sy)*(l1sx-l2sx))/((l2ey-l2sy)*(l1ex-l1sx)-(l2ex-l2sx)*(l1ey-l1sy))<=1);
}
boolean collisionLineRect(float lsx, float lsy, float lex, float ley, float rsx, float rsy, float rex, float rey) {
  return (collisionLineLine(lsx, lsy, lex, ley, rsx, rsy, rsx, rey)||collisionLineLine(lsx, lsy, lex, ley, rex, rsy, rex, rey)||collisionLineLine(lsx, lsy, lex, ley, rsx, rsy, rex, rsy)||collisionLineLine(lsx, lsy, lex, ley, rsx, rey, rex, rey));
}
boolean collisionPointPoly(float px, float py, PVector[] p) {
  boolean c=false;
  for (int i=0; i<p.length; i++) {
    if (((p[i].y>py&&p[(i+1)%p.length].y<py)||(p[i].y<py&&p[(i+1)%p.length].y>py))&&(px<(p[(i+1)%p.length].x-p[i].x)*(py-p[i].y)/(p[(i+1)%p.length].y-p[i].y)+p[i].x)) {
      c=!c;
    }
  }
  return c;
}
float distLineRect(float px, float py, float lsx, float lsy, float lex, float ley, float rsx, float rsy, float rex, float rey) {
  PVector d1=intersectionLineLine(lsx, lsy, lex, ley, rsx, rsy, rsx, rey);
  PVector d2=intersectionLineLine(lsx, lsy, lex, ley, rex, rsy, rex, rey);
  PVector d3=intersectionLineLine(lsx, lsy, lex, ley, rsx, rsy, rex, rsy);
  PVector d4=intersectionLineLine(lsx, lsy, lex, ley, rsx, rey, rex, rey);
  return min(min(min(dst(px, py, d1.x, d1.y), dst(px, py, d2.x, d2.y)), dst(px, py, d3.x, d3.y)), dst(px, py, d4.x, d4.y));
}
boolean collisionLineCircle(float lsx, float lsy, float lex, float ley, float cx, float cy, float cr) {
  if (collisionPointCircle(lsx, lsy, cx, cy, cr)||collisionPointCircle(lex, ley, cx, cy, cr)) {
    return true;
  }
  if (!collisionPointLine(lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx)), lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy)), lsx, lsy, lex, ley)) {
    return false;
  }
  return (sqrt((lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx))-cx)*(lsx+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(lex-lsx))-cx)+(lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy))-cy)*(lsy+(((((cx-lsx)*(lex-lsx))+((cy-lsy)*(ley-lsy)))/((lsx-lex)*(lsx-lex)+(lsy-ley)*(lsy-ley)))*(ley-lsy))-cy))<=cr);
}
boolean collisionPointCircle(float px, float py, float cx, float cy, float cr) {
  return (dst(px, py, cx, cy)<=cr);
}
boolean collisionPointLine(float px, float py, float lsx, float lsy, float lex, float ley) {
  float buffer=0.1;
  return (dst(px, py, lsx, lsy)+dst(px, py, lex, ley)>=dst(lsx, lsy, lex, ley)-buffer&&dst(px, py, lsx, lsy)+dst(px, py, lex, ley)<=dst(lsx, lsy, lex, ley)+buffer);
}
//float areaPolygon(PVector[] p) {
//  float a=0;
//  for (int i=0, j=p.length-1; i<p.length; j=i, i++) {
//    a+=p[i].x*p[j].y-p[i].y*p[j].x;
//  }
//  return a/2;
//}
//PVector centroidPolygon(PVector[] p) {
//  PVector c=new PVector(0, 0);
//  for (int i=0, j=p.length-1; i<p.length; j=i, i++) {
//    float f=p[i].x*p[j].y-p[i].y*p[j].x;
//    c.x+=(p[i].x+p[j].x)*f;
//    c.y+=(p[i].y+p[j].y)*f;
//  }
//  float f=areaPolygon(p)*6;
//  return new PVector(c.x/f, c.y/f);
//}
//PVector constrainPointPoly(float px, float py, PVector[] p) {
//  if (collisionPointPoly(px, py, p) == true) {
//    return new PVector(px, py);
//  }
//  PVector c=centroidPolygon(p);
//  fill(255, 0, 0, 128);
//  noStroke();
//  circle(c.x, c.y, 40);
//  strokeWeight(10);
//  stroke(0, 180);
//  line(px, py, c.x, c.y);
//  for (int i=1; i<=p.length; i++) {
//    if (collisionLineLine(px, py, c.x, c.y, p[i-1].x, p[i-1].y, p[i%p.length].x, p[i%p.length].y)==true) {
//      return intersectionLineLine(px, py, c.x, c.y, p[i-1].x, p[i-1].y, p[i%p.length].x, p[i%p.length].y);
//    }
//  }
//  return new PVector(px, py);
//}
//PVector constrainNearestPointRect(float px, float py, PVector[][] pl) {
//  float md=pow(2, 15);
//  PVector cp=new PVector(px, py);
//  for (int i=0; i<pl.length; i++) {
//    PVector c=constrainPointRect(px, py, pl[i]);
//    float d=dst(c.x, c.y, px, py);
//    if (d==0) {
//      return c;
//    }
//    if (d<md) {
//      md=d;
//      cp=c;
//    }
//  }
//  return cp;
//}
//PVector constrainPointRect(float px, float py, PVector[] v) {
//  if (collisionPointPoly(px, py, v) == true) {
//    return new PVector(px, py);
//  }
//  float a=ang(v[0].x/2+v[1].x/2, v[0].y/2+v[1].y/2, v[2].x/2+v[3].x/2, v[2].y/2+v[3].y/2);
//  PVector c=avg4(v[0], v[1], v[2], v[3]);
//  PVector[] vc=new PVector[v.length];
//  for (int i=0; i<v.length; i++) {
//    vc[i]=v[i].copy();
//  }
//  vc[0]=rot_point(vc[0].x, vc[0].y, c.x, c.y, -a);
//  vc[1]=rot_point(vc[1].x, vc[1].y, c.x, c.y, -a);
//  vc[2]=rot_point(vc[2].x, vc[2].y, c.x, c.y, -a);
//  vc[3]=rot_point(vc[3].x, vc[3].y, c.x, c.y, -a);
//  PVector min_v=new PVector(min(min(min(vc[0].x, vc[1].x), vc[2].x), vc[3].x), min(min(min(vc[0].y, vc[1].y), vc[2].y), vc[3].y));
//  PVector max_v=new PVector(max(max(max(vc[0].x, vc[1].x), vc[2].x), vc[3].x), max(max(max(vc[0].y, vc[1].y), vc[2].y), vc[3].y));
//  PVector p = rot_point(px, py, c.x, c.y, -a);
//  p.x=constrain_value(p.x, min_v.x, max_v.x);
//  p.y=constrain_value(p.y, min_v.y, max_v.y);
//  return rot_point(p.x, p.y, c.x, c.y, a);
//}
//float[] constrainPointBetweenLines(float p1x, float p1y, float p2x, float p2y, float l1sx, float l1sy, float l1ex, float l1ey, float l2sx, float l2sy, float l2ex, float l2ey, float lyBuffor) {
//  float a=ang(l1sx, l1sy, l1ex, l1ey);
//  boolean r1, r2;
//  PVector p1, p2;
//  PVector l1c=constrainPointLine(p1x, p1y, l1sx, l1sy, l1ex, l1ey), l2c=constrainPointLine(p1x, p1y, l2sx, l2sy, l2ex, l2ey);
//  if (dst(l1c.x, l1c.y, p1x, p1y)<dst(l2c.x, l2c.y, p1x, p1y)) {
//    r1=true;
//    p1=rot_point(p1x, p1y, l1sx/2+l1ex/2, l1sy/2+l1ey/2, -a);
//  } else {
//    r1=false;
//    p1=rot_point(p1x, p1y, l2sx/2+l2ex/2, l2sy/2+l2ey/2, -a);
//  }
//  l1c=constrainPointLine(p2x, p2y, l1sx, l1sy, l1ex, l1ey);
//  l2c=constrainPointLine(p2x, p2y, l2sx, l2sy, l2ex, l2ey);
//  if (dst(l1c.x, l1c.y, p2x, p2y)<dst(l2c.x, l2c.y, p2x, p2y)) {
//    r2=true;
//    p2=rot_point(p2x, p2y, l1sx/2+l1ex/2, l1sy/2+l1ey/2, -a);
//  } else {
//    r2=false;
//    p2=rot_point(p2x, p2y, l2sx/2+l2ex/2, l2sy/2+l2ey/2, -a);
//  }
//  PVector l1s=rot_point(l1sx, l1sy, l1sx/2+l1ex/2, l1sy/2+l1ey/2, -a);
//  PVector l2s=rot_point(l2sx, l2sy, l2sx/2+l2ex/2, l2sy/2+l2ey/2, -a);
//  PVector l1e=rot_point(l1ex, l1ey, l1sx/2+l1ex/2, l1sy/2+l1ey/2, -a);
//  PVector l2e=rot_point(l2ex, l2ey, l2sx/2+l2ex/2, l2sy/2+l2ey/2, -a);
//  if (l1s.y-lyBuffor<=p1.y&&l1e.y+lyBuffor>=p1.y) {
//    if (p1.x<l1s.x) {
//      p1.x=l1s.x;
//    }
//    if (p1.x>l2s.x) {
//      p1.x=l2s.x;
//    }
//  }
//  if (l2s.y-lyBuffor<=p2.y&&l2e.y+lyBuffor>=p2.y) {
//    if (p2.x<l1s.x) {
//      p2.x=l1s.x;
//    }
//    if (p2.x>l2s.x) {
//      p2.x=l2s.x;
//    }
//  }
//  if (r1==true) {
//    p1=rot_point(p1.x, p1.y, l1sx/2+l1ex/2, l1sy/2+l1ey/2, a);
//  } else {
//    p1=rot_point(p1.x, p1.y, l2sx/2+l2ex/2, l2sy/2+l2ey/2, a);
//  }
//  if (r2==true) {
//    p2=rot_point(p2.x, p2.y, l1sx/2+l1ex/2, l1sy/2+l1ey/2, a);
//  } else {
//    p2=rot_point(p2.x, p2.y, l2sx/2+l2ex/2, l2sy/2+l2ey/2, a);
//  }
//  float[] l={p1.x, p1.y, p2.x, p2.y};
//  return l;
//}
//PVector constrainPointLine(float px, float py, float lsx, float lsy, float lex, float ley) {
//  float a=ang(lsx, lsy, lex, ley);
//  PVector p=rot_point(px, py, lsx/2+lex/2, lsy/2+ley/2, -a);
//  PVector ls=rot_point(lsx, lsy, lsx/2+lex/2, lsy/2+ley/2, -a);
//  PVector le=rot_point(lex, ley, lsx/2+lex/2, lsy/2+ley/2, -a);
//  p.x=ls.x;
//  p.y=constrain_value(p.y, ls.y, le.y);
//  return rot_point(p.x, p.y, lsx/2+lex/2, lsy/2+ley/2, a);
//}
PVector lerp(PVector a, PVector b, float c) {
  return new PVector(a.x*c+b.x*(1-c), a.y*c+b.y*(1-c));
}
float dst(float a, float b, float c, float d) {
  return sqrt((a-c)*(a-c)+(b-d)*(b-d));
}
float diff(PVector a, PVector b) {
  return max(abs(a.x-b.x), abs(a.y-b.y));
}
float diff(float a, float b) {
  return abs(a-b);
}
float constrain_value(float v, float a, float b) {
  return min(max(v, a), b);
}
float map_value(float v, float aa, float ab, float ba, float bb) {
  return (v-aa)/(ab-aa)*(bb-ba)+ba;
}
PVector avg2(PVector a, PVector b) {
  return new PVector((a.x+b.x)/2, (a.y+b.y)/2);
}
PVector avg4(PVector a, PVector b, PVector c, PVector d) {
  return new PVector((a.x+b.x+c.x+d.x)/4, (a.y+b.y+c.y+d.y)/4);
}
float kmh_to_pxs(float s) {
  return m_to_px(s/3.6);
}
float pxs_to_kmh(float s) {
  return px_to_m(s)*3.6;
}
float m_to_px(float v) {
  return v*(ENGINE.CAR_WIDTH/ENGINE.REAL_CAR_WIDTH);
}
float px_to_m(float v) {
  return v/(ENGINE.CAR_WIDTH/ENGINE.REAL_CAR_WIDTH);
}
float m_to_px(float v, Engine ENGINE) {
  return v*(ENGINE.CAR_WIDTH/ENGINE.REAL_CAR_WIDTH);
}
float px_to_m(float v, Engine ENGINE) {
  return v/(ENGINE.CAR_WIDTH/ENGINE.REAL_CAR_WIDTH);
}
