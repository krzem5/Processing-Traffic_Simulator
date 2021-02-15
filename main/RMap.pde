class RMap {
  Engine ENGINE;
  List<List<RLine>> LINES;
  List<List<PVector>> l_lst;
  int nID;



  RMap(Engine ENGINE) {
    this.ENGINE=ENGINE;
    this.LINES=new ArrayList<List<RLine>>();
  }



  void create_lines(int ID, List<RLine> LS) {
    while (this.LINES.size()<=ID) {
      this.LINES.add(this.get_empty());
    }
    this.LINES.set(ID, LS);
  }



  List<RLine> get_empty() {
    List<RLine> LS=new ArrayList<RLine>();
    int i=0;
    ArrayList<RLine> a=new ArrayList<RLine>(), b=new ArrayList<RLine>();
    while (LS.size()<=this.ENGINE.MAX_LANES*2) {
      RLine l=new RLine(this.ENGINE, i-this.ENGINE.MAX_LANES+1, this.nID);
      LS.add(l);
      if (i-this.ENGINE.MAX_LANES+1<1) {
        a.add(l);
      } else {
        b.add(l);
      }
      this.nID++;
      i++;
    }
    i=0;
    for (RLine l : LS) {
      if (i-this.ENGINE.MAX_LANES+1<1) {
        l.lst=a;
      } else {
        l.lst=b;
      }
      i++;
    }
    return LS;
  }



  List<RLine> get_lines(int ID) {
    if (0<=ID&&ID<this.LINES.size()) {
      return this.LINES.get(ID);
    }
    this.create_lines(ID, this.get_empty());
    return this.LINES.get(ID);
  }



  void remove_lines(int ID) {
    List<RLine> LS=this.get_lines(ID);
    for (int i=0; i<LS.size(); i++) {
      LS.get(i).visible=false;
    }
  }



  boolean ext_ln(PVector a, PVector b) {
    for (List<PVector> l : this.l_lst) {
      if (l.get(0).equals(a)&&l.get(1).equals(b)) {
        return true;
      }
    }
    return false;
  }
  void update_l_lst() {
    this.l_lst=new ArrayList<List<PVector>>();
    for (List<RLine> rl : this.LINES) {
      for (RLine l : rl) {
        if (l.junction==true) {
          break;
        }
        if (this.ext_ln(l.tlA, l.tlB)==false) {
          ArrayList<PVector> a=new ArrayList<PVector>();
          a.add(l.tlA);
          a.add(l.tlB);
          this.l_lst.add(a);
        }
        if (this.ext_ln(l.blA, l.blB)==false) {
          ArrayList<PVector> a=new ArrayList<PVector>();
          a.add(l.blA);
          a.add(l.blB);
          this.l_lst.add(a);
        }
      }
    }
  }
  List<List<PVector>> get_all_lines() {
    return this.l_lst;
  }



  void draw() {
    for (List<RLine> ll : this.LINES) {
      for (RLine l : ll) {
        if (l.visible==false) {
          continue;
        }
        l.draw();
      }
    }
  }
}
