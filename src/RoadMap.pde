class RoadMap{
	Engine engine;
	List<List<RoadLine>> LINES;
	List<List<PVector>> l_lst;
	int nID;



	RoadMap(Engine engine){
		this.engine=engine;
		this.LINES=new ArrayList<List<RoadLine>>();
	}



	void update_l_lst(){
		this.l_lst=new ArrayList<List<PVector>>();
		for (List<RoadLine> rl:this.LINES){
			for (RoadLine l:rl){
				if (l.junction==true){
					break;
				}
				if (this.ext_ln(l.tlA,l.tlB)==false){
					ArrayList<PVector> a=new ArrayList<PVector>();
					a.add(l.tlA);
					a.add(l.tlB);
					this.l_lst.add(a);
				}
				if (this.ext_ln(l.blA,l.blB)==false){
					ArrayList<PVector> a=new ArrayList<PVector>();
					a.add(l.blA);
					a.add(l.blB);
					this.l_lst.add(a);
				}
			}
		}
	}



	void draw(){
		for (List<RoadLine> ll:this.LINES){
			for (RoadLine l:ll){
				if (l.visible==false){
					continue;
				}
				l.draw();
			}
		}
	}



	void create_lines(int ID,List<RoadLine> LS){
		while (this.LINES.size()<=ID){
			this.LINES.add(this.get_empty());
		}
		this.LINES.set(ID,LS);
	}



	List<RoadLine> get_empty(){
		List<RoadLine> LS=new ArrayList<RoadLine>();
		int i=0;
		ArrayList<RoadLine> a=new ArrayList<RoadLine>(),b=new ArrayList<RoadLine>();
		while (LS.size()<=this.engine.MAX_LANES*2){
			RoadLine l=new RoadLine(this.engine,i-this.engine.MAX_LANES+1,this.nID);
			LS.add(l);
			if (i-this.engine.MAX_LANES+1<1){
				a.add(l);
			}
			else{
				b.add(l);
			}
			this.nID++;
			i++;
		}
		i=0;
		for (RoadLine l:LS){
			if (i-this.engine.MAX_LANES+1<1){
				l.lst=a;
			}
			else{
				l.lst=b;
			}
			i++;
		}
		return LS;
	}



	List<RoadLine> get_lines(int ID){
		if (0<=ID&&ID<this.LINES.size()){
			return this.LINES.get(ID);
		}
		this.create_lines(ID,this.get_empty());
		return this.LINES.get(ID);
	}



	void remove_lines(int ID){
		List<RoadLine> LS=this.get_lines(ID);
		for (int i=0; i<LS.size(); i++){
			LS.get(i).visible=false;
		}
	}



	boolean ext_ln(PVector a,PVector b){
		for (List<PVector> l:this.l_lst){
			if (l.get(0).equals(a)&&l.get(1).equals(b)){
				return true;
			}
		}
		return false;
	}



	List<List<PVector>> get_all_lines(){
		return this.l_lst;
	}
}
