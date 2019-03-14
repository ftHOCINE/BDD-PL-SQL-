---------------------------------
-- creation du schema 'Rapido' --
---------------------------------

/*
drop sequence gen_clef ;
drop table ff_consommation ;
drop table ff_magasin ;
drop table ff_constitue ;
drop table ff_menu ;
drop table ff_simple ;
drop table ff_produit ;
drop package paq_produits ;
*/

---------------------------------
-- creation du schema 'Rapido' --
---------------------------------
create table FF_PRODUIT(
  p_ref number(4) constraint ff_produit_pkey PRIMARY KEY,
  nom varchar2(30) not null,
  prix number(5,2),
  taille varchar2(5) not null,
  constraint nom_unique unique(nom), -- pas 2 produits avec le meme nom
  constraint enum_taille check (taille in ('petit','moyen','grand')),
  constraint prix_positif check (prix > 0)
);

create table FF_SIMPLE(
  s_ref number(4) constraint ff_simple_pkey PRIMARY KEY
  constraint ff_simple_ff_produit_fkey REFERENCES FF_PRODUIT on delete cascade,
  categ varchar2(15),
  constraint enum_categ check (categ in ('boisson','dessert','salade','accompagnement','sandwich'))
);

create table FF_MENU(
  m_ref number(4) constraint ff_menu_pkey PRIMARY KEY
  constraint ff_menu_ff_produit_fkey REFERENCES FF_PRODUIT on delete cascade,
  promo varchar2(20)
);

create table FF_CONSTITUE(
  ref_menu number(4) constraint ff_constitue_ff_menu_fkey REFERENCES FF_MENU on delete cascade,
  ref_simple number(4) constraint ff_constitue_ff_simple_fkey REFERENCES FF_SIMPLE,
  constraint ff_constitue_pkey PRIMARY KEY(ref_menu, ref_simple)
);

create table FF_MAGASIN(
  m_ref number(4) constraint ff_magasin_pkey PRIMARY KEY,
  nom varchar2(10) not null,
  ville varchar2(10) not null
);

create table FF_CONSOMMATION(
  estampille TIMESTAMP not null,
  ref_produit number(4) not null constraint consom_ff_produit_fkey REFERENCES FF_PRODUIT,
  ref_magasin number(4) not null constraint consom_ff_magasin_fkey REFERENCES FF_MAGASIN
);

-- sequence pour les clefs des produits
create sequence gen_clef
increment by 1
start with 1 ;

----------------------------
-- Paquetage PAQ_PRODUITS --
----------------------------

create or replace
package PAQ_PRODUITS as
  PARAMETRE_INDEFINI EXCEPTION ;
  PRODUIT_INCONNU EXCEPTION ;
  INCOHERENCE_TAILLES EXCEPTION ; 
  PB_COMPOSITION EXCEPTION ;
  PRIX_NON_POSITIF EXCEPTION ;
  PB_VALEUR_TAILLE EXCEPTION ;
  PB_VALEUR_CATEGORIE EXCEPTION ;
  DOUBLON_NOM_PRODUIT EXCEPTION ;
  PRODUIT_UTILISE EXCEPTION ;
  
  PRAGMA exception_init(PARAMETRE_INDEFINI,-20102) ;
  PRAGMA exception_init(PRODUIT_INCONNU,-20103);
  PRAGMA exception_init(INCOHERENCE_TAILLES,-20104);
  PRAGMA exception_init(PB_COMPOSITION,-20105);
  PRAGMA exception_init(PRIX_NON_POSITIF,-20106) ;
  PRAGMA exception_init(PB_VALEUR_TAILLE,-20107) ;
  PRAGMA exception_init(PB_VALEUR_CATEGORIE,-20108) ;
  PRAGMA exception_init(DOUBLON_NOM_PRODUIT,-20109) ;
  PRAGMA exception_init(PRODUIT_UTILISE,-20110) ;
  
  /* on ajoute un produit simple dans la base 
   * Déclenche PARAMETRE_INDEFINI si l'un des paramètres vaut NULL
   * Déclenche PB_VALEUR_TAILLE, PRIX_NON_POSITIF, DOUBLON_NOM_PRODUIT ou PB_VALEUR_CATEGORIE
   * si les contraintes déclarées avec les tables ne sont pas respectées.
   */
  procedure ajouter_simple(le_nom ff_produit.nom%type, 
                           le_prix ff_produit.prix%type, 
                           la_taille ff_produit.taille%type, 
                           la_categ ff_simple.categ%type) ;
                           
  /* on supprime un produit simple de la base 
   * Déclenche PARAMETRE_INDEFINI si le paramètre vaut NULL
   * Déclenche PRODUIT_INCONNU si ce produit simple n'existe pas
   * Déclenche PRODUIT_UTILISE si ce produit entre dans la composition d'un menu
   */
  procedure supprimer_simple(la_ref ff_simple.s_ref%type) ;

  /* on ajoute un menu dans la base 
   * Déclenche PARAMETRE_INDEFINI si l'un des paramètres vaut NULL
   * Déclenche PB_VALEUR_TAILLE, PRIX_NON_POSITIF ou  DOUBLON_NOM_PRODUIT
   * si les contraintes déclarées avec les tables ne sont pas respectées.
   */
  procedure ajouter_menu(le_nom ff_produit.nom%type, 
                         le_prix ff_produit.prix%type, 
                         la_taille ff_produit.taille%type, 
                         la_promo ff_menu.promo%type) ;
  
  /* on supprime un menu de la base 
   * Déclenche PARAMETRE_INDEFINI si le paramètre vaut NULL
   * Déclenche PRODUIT_INCONNU si ce menu n'existe pas
   */
  procedure supprimer_menu(la_ref ff_menu.m_ref%type) ;

  /* Ajoute un produit simple dans la composition d'un menu
   * Déclenche PARAMETRE_INDEFINI si l'un des paramètres vaut NULL
   * Déclenche INCOHERENCE_TAILLES si le menu et le simple n'ont pas la même taille
   * par exemple, mettre une petite frite dans un "grand" menu est une erreur.
   * On déclenche PRODUIT_INCONNU si le menu ou le simple n'existe pas.
   * si on veut mettre un produit simple deja present dans ce menu, ça ne declenche pas d'erreur (ça ne fait rien)
   */
  procedure enrichir_menu(la_ref_menu ff_menu.m_ref%type, la_ref_simple ff_simple.s_ref%type) ;

  /* Enlève un produit simple de la constitution d'un menu.
   * Déclenche PARAMETRE_INDEFINI si l'un des paramètres vaut NULL
   * Déclenche PB_COMPOSITION si ce produit simple n'est pas dans ce menu.
   */
  procedure appauvrir_menu(la_ref_menu ff_menu.m_ref%type, la_ref_simple ff_simple.s_ref%type) ;
end;
/


