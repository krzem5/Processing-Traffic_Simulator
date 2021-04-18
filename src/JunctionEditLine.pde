class JunctionEditLine{
	Engine engine;
	Junction junction;
	PVector s;
	PVector e;
	JunctionEditPoint sp;
	JunctionEditPoint ep;
	int conn_index;
	ArrayList<RoadLine> ls;
	int w;



	JunctionEditLine(Engine engine,Junction j,PVector s,PVector e,JunctionEditPoint sp,JunctionEditPoint ep,int i,int w){
		this.engine=engine;
		this.junction=j;
		this.s=s;
		this.e=e;
		this.sp=sp;
		this.ep=ep;
		this.conn_index=i;
		this.sp.conns.add(this.ep);
		this.ep.conns.add(this.sp);
		this.ls=new ArrayList<RoadLine>();
		this.w=w;
	}



	void draw(){
		strokeWeight(5);
		stroke(20,80,200);
		line(this.s.x,this.s.y,this.e.x,this.e.y);
	}



	void create_lines(){
		this.rm_line();
		PVector a=new PVector(this.s.x+cos(this.sp.sa)*10,this.s.y+sin(this.sp.sa)*10),b=new PVector(this.e.x+cos(this.ep.sa)*10,this.e.y+sin(this.ep.sa)*10);
		PVector m=intersectionRoundLineLine(this.s.x,this.s.y,a.x,a.y,b.x,b.y,this.e.x,this.e.y);
		this.ls=new ArrayList<RoadLine>();
		RoadLine l1=new RoadLine(this.engine,-1,this.engine.RMAP.nID);
		this.engine.RMAP.nID++;
		l1.junction=true;
		l1.j=this.junction;
		l1.set_pos(this.s,m);
		this.engine.RMAP.get_lines(this.junction.ID).add(l1);
		this.ls.add(l1);
		RoadLine l2=new RoadLine(this.engine,-1,this.engine.RMAP.nID);
		this.engine.RMAP.nID++;
		l2.junction=true;
		l2.j=this.junction;
		l2.set_pos(m,this.e);
		this.engine.RMAP.get_lines(this.junction.ID).add(l2);
		this.ls.add(l2);
		l1.sl=l2;
		l2.el=l1;
		l1.update_j_sides();
		l2.update_j_sides();
		if (this.sp.lp==0){
			for (RoadLine l:this.sp.l.lst){
				l.Asl.add(l1);
				l.AslW.append(this.w);
			}
			l1.el=this.sp.l;
		}
		else{
			for (RoadLine l:this.sp.l.lst){
				l.Ael.add(l1);
				l.AelW.append(this.w);
			}
			l1.el=this.sp.l;
		}
		if (this.ep.lp==0){
			for (RoadLine l:this.ep.l.lst){
				l.Asl.add(l2);
				l.AslW.append(this.w);
			}
			l2.sl=this.ep.l;
		}
		else{
			for (RoadLine l:this.ep.l.lst){
				l.Ael.add(l2);
				l.AelW.append(this.w);
			}
			l2.sl=this.ep.l;
		}
	}



	void remove(){
		this.rm_line();
		this.junction.edit_lines.remove(this);
		this.junction.connections.set(this.conn_index,null);
		this.sp.conns.remove(this.ep);
		this.ep.conns.remove(this.sp);
	}



	void rm_line(){
		if (this.ls.size()>0){
			for (RoadLine l:this.sp.l.lst){
				l.Asl.remove(this.ls.get(0));
				l.Ael.remove(this.ls.get(0));
				l.AslW.removeValue(this.w);
				l.AelW.removeValue(this.w);
			}
			for (RoadLine l:this.ep.l.lst){
				l.Asl.remove(this.ls.get(1));
				l.Ael.remove(this.ls.get(1));
				l.AslW.removeValue(this.w);
				l.AelW.removeValue(this.w);
			}
		}
		for (RoadLine l:this.ls){
			this.engine.RMAP.get_lines(this.junction.ID).remove(l);
		}
	}
}
