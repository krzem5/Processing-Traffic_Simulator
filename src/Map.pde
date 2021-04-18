class Map{
	Engine engine;
	int START_END_OFFSET=50;
	int MAP_TRACK_POINTS_DIST=75;
	int MAX_POINT_DIFF=10;



	Map(Engine engine){
		this.engine=engine;
	}



	ArrayList<CarPathPoint> get_path(RoadLine cell){
		ArrayList<CarPathPoint> path=new ArrayList<CarPathPoint>();
		IntList visited=new IntList();
		RoadLine next;
		boolean change;
		while (true){
			if (cell==null){
				break;
			}
			visited.push(cell.ID);
			next=null;
			change=false;
			if (((cell.sl==null&&cell.Asl.size()>0)||cell.sl!=null)&&!this.chk_id(visited,cell.sl,cell.Asl)){
				if (cell.sl==null){
					next=cell.get_rand("s");
					if (cell.change_lane(next)==true){
						change=true;
					}
				}
				if (path.size()<2){
					float a=ang(cell.s.x,cell.s.y,cell.e.x,cell.e.y)+PI/2;
					PVector v=cell.e.copy();
					v.add(this.START_END_OFFSET*cos(a),this.START_END_OFFSET*sin(a));
					path.add(new CarPathPoint(this.engine,v));
				}
				if (change==true){
					path.add(new CarPathPoint(this.engine,cell.e.copy()));
					path.add(new CarPathPoint(this.engine,next.s.copy(),cell.s));
				}
				else{
					if (next!=null){
						path.add(new CarPathPoint(this.engine,cell.e.copy()));
						path.add(new CarPathPoint(this.engine,cell.s.copy()));
						path.add(new CarPathPoint(this.engine,next.s.copy()));
					}
					else{
						if (cell.junction==true){
							path.add(new CarPathPoint(this.engine,cell.e.copy()));
						}
						else{
							path.add(new CarPathPoint(this.engine,cell.s.copy()));
						}
					}
				}
				if (cell.sl==null){
					path.get(path.size()-1).set_lane(next.el);
					if (change==true){
						path.get(path.size()-1).set_ch_dir(cell);
					}
					cell=next;
				}
				else{
					path.get(path.size()-1).set_lane(cell);
					cell=cell.sl;
				}
			}
			else{
				if (((cell.el==null&&cell.Ael.size()>0)||cell.el!=null)&&!this.chk_id(visited,cell.el,cell.Ael)){
					if (cell.el==null){
						next=cell.get_rand("e");
						if (cell.change_lane(next)==true){
							change=true;
						}
					}
					if (path.size()<2){
						float a=ang(cell.s.x,cell.s.y,cell.e.x,cell.e.y)-PI/2;
						PVector v=cell.s.copy();
						v.add(this.START_END_OFFSET*cos(a),this.START_END_OFFSET*sin(a));
						path.add(new CarPathPoint(this.engine,v));
					}
					if (change==true){
						path.add(new CarPathPoint(this.engine,cell.s.copy()));
						path.add(new CarPathPoint(this.engine,next.s.copy(),cell.e));
					}
					else{
						if (next!=null){
							path.add(new CarPathPoint(this.engine,cell.s.copy()));
							path.add(new CarPathPoint(this.engine,cell.e.copy()));
							path.add(new CarPathPoint(this.engine,next.s.copy()));
						}
						else{
							if (cell.junction==true){
								path.add(new CarPathPoint(this.engine,cell.e.copy()));
							}
							else{
								path.add(new CarPathPoint(this.engine,cell.e.copy()));
							}
						}
					}
					if (cell.el==null){
						path.get(path.size()-1).set_lane(next.el);
						if (change==true){
							path.get(path.size()-1).set_ch_dir(cell);
						}
						cell=next;
					}
					else{
						path.get(path.size()-1).set_lane(cell);
						cell=cell.el;
					}
				}
				else{
					if (cell.el==null&&cell.Ael.size()==0){
						float a=ang(cell.s.x,cell.s.y,cell.e.x,cell.e.y)+PI/2;
						PVector v=cell.e.copy();
						v.add(this.START_END_OFFSET*cos(a),this.START_END_OFFSET*sin(a));
						path.add(new CarPathPoint(this.engine,v));
					}
					else{
						float a=ang(cell.s.x,cell.s.y,cell.e.x,cell.e.y)-PI/2;
						PVector v=cell.s.copy();
						v.add(this.START_END_OFFSET*cos(a),this.START_END_OFFSET*sin(a));
						path.add(new CarPathPoint(this.engine,v));
					}
					path.get(path.size()-1).set_lane(cell);
					break;
				}
			}
		}
		if (path.size()<2){
			return null;
		}
		return path;
	}



	ArrayList<CarPathPoint> remove_duplicate(ArrayList<CarPathPoint> path){
		ArrayList<CarPathPoint> r_path=new ArrayList<CarPathPoint>();
		CarPathPoint l=null;
		for (CarPathPoint p:path){
			if (l==null||diff(p.pos,l.pos)>this.MAX_POINT_DIFF){
				l=p;
				r_path.add(p);
			}
		}
		return r_path;
	}



	ArrayList<CarPathPoint> split(ArrayList<CarPathPoint> path){
		ArrayList<CarPathPoint> f_path=new ArrayList<CarPathPoint>();
		f_path.add(path.get(0));
		for (int i=1; i<path.size(); i++){
			if (path.get(i).change==true){
				f_path.add(path.get(i));
				continue;
			}
			PVector a=path.get(i-1).pos,b=path.get(i).pos;
			RoadLine l=path.get(i).lane;
			ArrayList<PVector> d=this.divide(a,b);
			int j=0;
			for (PVector v:d){
				f_path.add(new CarPathPoint(this.engine,v,l,(j==d.size()-1)));
				j++;
			}
		}
		return f_path;
	}



	ArrayList<PVector> divide(PVector s,PVector e){
		ArrayList<PVector> a=new ArrayList<PVector>();
		float cx=s.x/2+e.x/2;
		float cy=s.y/2+e.y/2;
		int d=int(dst(s.x,s.y,e.x,e.y));
		float off=(d-max(int(d/this.MAP_TRACK_POINTS_DIST),1)*this.MAP_TRACK_POINTS_DIST)/2/max(int(d/this.MAP_TRACK_POINTS_DIST),1);
		float ang=ang(s.x,s.y,e.x,e.y);
		for (int i=0; i<max(d/this.MAP_TRACK_POINTS_DIST,1); i++){
			float yoff=map(i,0,max(d/this.MAP_TRACK_POINTS_DIST,1),-d/2,d/2)+this.MAP_TRACK_POINTS_DIST/2+off;
			PVector v=rot_point(cx,cy+yoff,cx,cy,ang);
			a.add(v);
		}
		a.add(e);
		return a;
	}



	boolean chk_id(IntList vs,RoadLine c,ArrayList<RoadLine> cl){
		if (c!=null&&vs.hasValue(c.ID)==true){
			return true;
		}
		for (RoadLine l:cl){
			if (vs.hasValue(l.ID)){
				return true;
			}
		}
		return false;
	}
}
