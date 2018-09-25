class Case{
  //attributs
  int nbvoisins=0;
  boolean bombe=false;
  boolean decouvert=false;
  boolean drapeau=false;
  boolean interrogation = false;

  //constructeurs
  Case (boolean bombe,boolean decouvert,int nbvoisins, boolean drapeau, boolean interrogation){
    this.bombe=bombe;
    this.decouvert=decouvert;
    this.nbvoisins=nbvoisins;
    this.drapeau= drapeau;
    this.interrogation = interrogation;
  }

  
  
}