//<>// //<>// //<>// //<>// //<>// //<>// //<>//
//              DEMINEUR               //
//<>// //<>// //<>// //<>// //<>// //<>// //<>//

//DECLARATION DES VARIABLES GLOBALES
//hauteur de la grille
int nbcolonnes = 9; 
//largeur de la grille
int nblignes = 8; 
//dimension d'une case
int taillecase;
//emplacement infos du jeu
int marge_du_haut;
//nombre de bombes (10% du nb cases)
int nbbombes = round(nbcolonnes*nblignes*10/100); 
//image de la bombe
PImage bombe; 
//image de drapeau
PImage drapeau; 
//image de partie perdue
PImage perdu;
//image de partie gagnée
PImage gagne;
//image d'horloge
PImage horloge;
//image de titre
PImage titre;
//booléen de partie perdue
boolean jeuPerdu = false;
//booléen d'arrêt du temps
boolean arret_du_temps = false;
//tableau contenant les objets "case"
Case[][] grille = new Case[nbcolonnes][nblignes];
//tableau des couleurs pour les bombes voisines
final color[] couleur_nb_voisins = {color(0, 0, 0), color(0, 128, 0), color(0, 0, 128), 
  color(128, 0, 0), color(128, 128, 0), color(128, 0, 128), 
  color(0, 255, 0), color(0, 0, 255), color(255, 0, 0)};
//compteur cases découvertes
int nb_cases_decouvertes = 0;
//compteur de drapeaux
int nb_drapeaux = 0;
//temps ecoulé jusqu'à la fin de la partie
int tempsEcoule;

//Initialisation
void setup() {
  size(450, 500);  //dimensions de la fenêtre
  frameRate(1000);
  bombe = loadImage("Images/bombe.png");  //chargement du fichier contenant l'image pour la bombe
  perdu = loadImage("Images/perdu.png");  //chargement du fichier contenant l'image pour le jeu perdu
  drapeau = loadImage("Images/drapeau.png");  //chargement du fichier contenant l'image pour le drapeau
  gagne = loadImage("Images/gagne.png");  //chargement du fichier contenant l'image pour le jeu gagné
  horloge = loadImage("Images/horloge.png");  //chargement du fichier contenant l'image pour l'horloge
  titre = loadImage("Images/demineur.png");  //chargement du fichier contenant l'image pour l'horloge
  taillecase=width/nbcolonnes;  //déclaration des dimensions d'une case
  marge_du_haut = height/5; //déclaration de la dimension de la marge du haut

  //Appel de fonctions
  creer_grille_vide();
  placer_bombes();
  calculer_nb_voisins();
}


//Affichage récursif
void draw() {
  background(200);
  affichage_infos();
  dessiner_grille();
}


//FONCTIONS

//créer la grille
void creer_grille_vide() {  
  for (int i=0; i<nbcolonnes; i++) {
    for (int j=0; j<nblignes; j++) {  
      grille[i][j]=new Case(false, false, 0, false, false);  //création des cases dans le tableau
    }
  }
}

//placer les bombes
void placer_bombes() {
  for (int b = 0; b<nbbombes; b++) {
    //on affecte au hasard une valeur à i et j
    int i = (int)(Math.random()*nbcolonnes);
    int j = (int)(Math.random()*nblignes);
    if (!grille[i][j].bombe) {         //si la case ne contient pas de bombe
      grille[i][j].bombe = true;       //on place une bombe
    } else b--;                        //sinon, on choisit une autre case
  }
}


//calcul des nombres de bombes autour des cases
void calculer_nb_voisins() {
  for (int i=0; i<nbcolonnes; i++) {
    for (int j=0; j<nblignes; j++) {
      int voisins = 0;
      for (int i1=-1; i1<2; i1++) {
        for (int j1=-1; j1<2; j1++) {
          if (autour_case_et_dans_grille(i, j, i1, j1)) {
            if (grille[i+i1][j+j1].bombe) {            
              {
                voisins++;
              }
            }
          }
        }
      }
      grille[i][j].nbvoisins=voisins;
    }
  }
}

//affichage infos de jeu
void affichage_infos() {
  affichage_info_titre(); 
  affichage_info_bombes_restantes();
  affichage_info_temps_ecoule();
}

//affichage du titre
void affichage_info_titre() {
  imageMode(CENTER);
  titre.resize(150, 50);
  image(titre, width/2, height/10);
}

//affichage des bombes restantes
void affichage_info_bombes_restantes() {
  imageMode(CENTER);
  bombe.resize(2*taillecase/3, 2*taillecase/3);
  image(bombe, width/9, height/10);
  fill(0);
  textAlign(CENTER);
  textSize(30);
  text(nbbombes - nb_drapeaux, 2*width/10, 13*height/100);
}


//affichage du temps écoulé
void affichage_info_temps_ecoule() {
  imageMode(CENTER);
  horloge.resize(2*taillecase/3, 2*taillecase/3);
  image(horloge, 7*width/9, height/10);
  fill(0);
  textAlign(CENTER);
  textSize(30);
  if (!(jeuPerdu || jeu_gagne())) {
    tempsEcoule = millis()/1000;
  } else {
    tempsEcoule += 0;
  }
  text(tempsEcoule, 9*width/10, 13*height/100);
}

//dessin
void dessiner_grille() {
  for (int i=0; i<nbcolonnes; i++) {
    for (int j=0; j<nblignes; j++) {
      if (!grille[i][j].decouvert) {
        dessiner_case_vide(i, j);
        dessiner_drapeau(i, j);
        afficher_point_interrogation(i, j);
      }
      if (grille[i][j].decouvert) {
        dessiner_case_decouverte(i, j);
        dessiner_bombe(i, j);
        afficher_nb_bombes_voisines(i, j);
      }
      affichage_fin_jeu(i, j);
    }
  }
}


void dessiner_drapeau(int i, int j) {
  if (grille[i][j].drapeau) {
    imageMode(CENTER);
    drapeau.resize(2*taillecase/3, 2*taillecase/3);
    image(drapeau, taillecase*i+taillecase/2, marge_du_haut + taillecase*j+taillecase/2);
  }
}

void dessiner_case_vide(int i, int j) {
  fill(150);
  strokeWeight(1);
  rect(taillecase*i, marge_du_haut + taillecase*j, taillecase, taillecase);
}

void dessiner_case_decouverte(int i, int j) {
  fill(200);
  strokeWeight(1);
  rect(taillecase*i, marge_du_haut + taillecase*j, taillecase, taillecase);
}

void dessiner_bombe(int i, int j) {
  if (grille[i][j].bombe) {
    imageMode(CENTER);
    bombe.resize(2*taillecase/3, 2*taillecase/3);
    image(bombe, taillecase*i+taillecase/2, marge_du_haut + taillecase*j+taillecase/2);
  }
}

void afficher_point_interrogation(int i, int j) {
  if (grille[i][j].interrogation) {
    fill(0);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("?", i*taillecase+taillecase/2, marge_du_haut + j*taillecase+taillecase/2);
  }
}

void afficher_nb_bombes_voisines(int i, int j) {
  if (!grille[i][j].bombe && grille[i][j].nbvoisins!=0) {
    fill(couleur_nb_voisins[grille[i][j].nbvoisins]);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(grille[i][j].nbvoisins, i*taillecase+taillecase/2, marge_du_haut + j*taillecase+taillecase/2);
  }
}

//une case est-elle dans la grille ?
boolean dans_grille(int i, int j) {
  return i>=0 && i<nbcolonnes && j>=0 && j<nblignes;
}

//une case est-elle autour d'une autre ?
boolean autour_case_et_dans_grille(int i, int j, int i1, int j1) {
  return !(i1==0 && j1==0) && i+i1>=0 && i+i1<nbcolonnes && j+j1>=0 && j+j1<nblignes;
}

//la partie est-elle gagnée ?
boolean jeu_gagne() {
  return nb_cases_decouvertes > nbcolonnes*nblignes*90/100;
}

//affichage fin du jeu
void affichage_fin_jeu(int i, int j) {
  if (jeuPerdu) { 
    grille[i][j].decouvert=true;
    imageMode(CENTER);
    perdu.resize(2*width/3, height/2);
    image(perdu, width/2, height/2);
  } else if (jeu_gagne()) {
    imageMode(CENTER);
    gagne.resize(2*width/3, height/2);
    image(gagne, width/2, height/2);
  }
}

//interactions souris
void mousePressed() {
  if (mouseButton==LEFT && !jeuPerdu) {
    int i = floor(map(mouseX, 0, width, 0, nbcolonnes));
    int j = floor(map(mouseY, marge_du_haut, height, 0, nblignes));
    interaction_clic_gauche(i, j);
  }
  if (mouseButton==RIGHT && !jeuPerdu) {
    int i = floor(map(mouseX, 0, width, 0, nbcolonnes));
    int j = floor(map(mouseY, marge_du_haut, height, 0, nblignes));
    interaction_clic_droit(i, j);
  }
}

void interaction_clic_gauche(int i, int j) {
  println("Clic gauche : ", i, j);
  if (dans_grille(i, j) && grille[i][j].bombe) {
    jeuPerdu = true;
  }
  if (dans_grille(i, j) && !grille[i][j].drapeau && !grille[i][j].interrogation) {
    creuser(i, j);
    println("Nombre de cases découvertes : ", nb_cases_decouvertes);
  }
}

void interaction_clic_droit(int i, int j) {
  println("Clic droit : ", i, j);
  if (dans_grille(i, j) && !grille[i][j].decouvert) {
    if (!grille[i][j].drapeau && !grille[i][j].interrogation) {
      grille[i][j].drapeau = true;
      nb_drapeaux++;
      grille[i][j].interrogation = false;
    } else if (grille[i][j].drapeau && !grille[i][j].interrogation) {
      grille[i][j].drapeau = false;
      nb_drapeaux--;
      grille[i][j].interrogation=true;
    } else if (!grille[i][j].drapeau && grille[i][j].interrogation) {
      grille[i][j].drapeau = false;
      grille[i][j].interrogation = false;
    }
  }
}

//découvrir une ou plusieurs cases
void creuser(int i, int j) {
  if (!grille[i][j].bombe && !grille[i][j].decouvert && !grille[i][j].drapeau && !grille[i][j].interrogation) {
    grille[i][j].decouvert=true;
    nb_cases_decouvertes++;
    //println("Nombre de cases découvertes : ",nb_cases_decouvertes);
    for (int i1=-1; i1<2; i1++) {
      for (int j1=-1; j1<2; j1++) {
        if (grille[i][j].nbvoisins==0 && dans_grille(i+i1, j+j1)) {
          if (!grille[i+i1][j+j1].decouvert) {
            creuser(i+i1, j+j1);
          }
        }
      }
    }
  }
}