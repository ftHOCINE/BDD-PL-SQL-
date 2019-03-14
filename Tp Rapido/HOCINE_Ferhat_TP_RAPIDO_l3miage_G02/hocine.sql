DROP TABLE STOCK;
/


CREATE TABLE  STOCK(
            S_REF number(4), 
            M_REF number(4),
            S_nb number(6),
            CONSTRAINT st_primary PRIMARY KEY(S_REF,M_REF),
            CONSTRAINT st_con FOREIGN KEY (S_REF) REFERENCES FF_SIMPLE (S_REF),
            CONSTRAINT st_cons FOREIGN KEY (M_REF) REFERENCES FF_MAGASIN (M_REF)
            );
            
/

create or replace PACKAGE BODY PAQ_PRODUITS AS

  procedure vérif_param( parametre VARCHAR2) AS
  BEGIN
    IF (parametre is null) then
      raise parametre_indefini;
      end if;
    END vérif_param;
    
  procedure traiter_erreur(msg VARCHAR2) As
  BEGIN 
   IF (msg like '%PRIX_POSITIF%')
    then raise PRIX_NON_POSITIF;
  elsIF (msg like '%ENUM_TAILLE%')
    then raise PB_VALEUR_TAILLE;
  elsIF (msg like '%ENUM_CATEG%')
    then raise PB_VALEUR_CATEGORIE;
  END IF;
  END traiter_erreur;
  
  
  procedure ajouter_simple(le_nom ff_produit.nom%type, 
                           le_prix ff_produit.prix%type, 
                           la_taille ff_produit.taille%type, 
                           la_categ ff_simple.categ%type)  AS
  EXP_VAL exception;
  pragma exception_init(EXP_VAL,-2290);
  num_val NUMBER := gen_clef.nextval;
  
  BEGIN
    vérif_param(le_nom);
    vérif_param(le_prix);
    vérif_param(la_categ);
    vérif_param(la_taille);
    
  INSERT INTO FF_PRODUIT VALUES
    (num_val,le_nom,le_prix,la_taille);
  
  INSERT INTO FF_SIMPLE VALUES
    (num_val,la_categ);
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX
    THEN RAISE DOUBLON_NOM_PRODUIT;
  WHEN EXP_VAL
    THEN traiter_erreur(SQLERRM);
    

  END ajouter_simple;

  procedure supprimer_simple(la_ref ff_simple.s_ref%type)  AS
  re ff_simple.s_ref%type; 
  EXPP_VAL exception;
  pragma exception_init(EXPP_VAL,-2292);
  
  BEGIN
    vérif_param(la_ref);
      BEGIN
      SELECT S_REF INTO re
      FROM FF_SIMPLE
      WHERE S_REF= la_ref;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  END; 
    begin 
        DELETE FROM STOCK
        where S_REF=la_ref ;

    DELETE FROM FF_PRODUIT
    WHERE P_REF=la_ref AND la_ref NOT in (select M_REF from FF_MENU);
  IF SQL%ROWCOUNT = 0 THEN
    RAISE PRODUIT_INCONNU;
  END IF;
  end;

  EXCEPTION 
  WHEN EXPP_VAL
    THEN RAISE PRODUIT_UTILISE;
  END supprimer_simple;

  procedure ajouter_menu(le_nom ff_produit.nom%type, 
                         le_prix ff_produit.prix%type, 
                         la_taille ff_produit.taille%type, 
                         la_promo ff_menu.promo%type)  AS
  num_vall NUMBER := gen_clef.nextval;
  EXPPP_VAL exception;
  pragma exception_init(EXPPP_VAL,-2290);
  BEGIN
    vérif_param(le_nom);
    vérif_param(le_prix);
    vérif_param(la_taille);
    vérif_param(la_promo);
    
    INSERT INTO FF_produit values(num_vall,le_nom,le_prix,la_taille);
    INSERT INTO FF_MENU VALUES(num_vall,la_promo);
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX
    THEN RAISE DOUBLON_NOM_PRODUIT;
  WHEN EXPPP_VAL
    THEN traiter_erreur(SQLERRM);
    
    
  END ajouter_menu;

  procedure supprimer_menu(la_ref ff_menu.m_ref%type)  AS
  
  EX exception;
  pragma exception_init(EX,-2292);
  BEGIN
    vérif_param(la_ref);
    DELETE FROM FF_PRODUIT
    WHERE P_REF=la_ref AND la_ref in (select m_ref from FF_MENU);
  IF SQL%ROWCOUNT = 0 THEN
    RAISE PRODUIT_INCONNU;
  END IF;
  EXCEPTION 
  WHEN EX
    THEN RAISE PRODUIT_UTILISE;
  END supprimer_menu;

  procedure enrichir_menu(la_ref_menu ff_menu.m_ref%type, la_ref_simple ff_simple.s_ref%type)  AS
  TAILLE_S ff_PRODUIT.TAILLE%type;
  TAILLE_M ff_PRODUIT.TAILLE%type;
  re ff_simple.s_ref%type;
  ree ff_simple.s_ref%type;
  BEGIN
  BEGIN
      vérif_param(la_ref_menu);
      vérif_param(la_ref_simple);
      SELECT TAILLE INTO TAILLE_S
      FROM FF_PRODUIT
      WHERE P_REF= la_ref_simple;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  END;
  BEGIN
      SELECT TAILLE INTO TAILLE_M
      FROM FF_PRODUIT
      WHERE P_REF= la_ref_menu;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  END;
    BEGIN
      SELECT S_REF INTO re
      FROM FF_SIMPLE
      WHERE S_REF= la_ref_simple;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  END;
  BEGIN
      SELECT M_REF INTO ree
      FROM FF_MENU
      WHERE M_REF= la_ref_menu;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  END;    
      IF (TAILLE_S <> TAILLE_M) THEN
        RAISE INCOHERENCE_TAILLES;
        END IF;

  INSERT INTO FF_CONSTITUE VALUES
  (la_ref_menu, la_ref_simple);
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX THEN
  NULL;    
  END enrichir_menu;

  procedure appauvrir_menu(la_ref_menu ff_menu.m_ref%type, la_ref_simple ff_simple.s_ref%type)  AS
  BEGIN
      vérif_param(la_ref_menu);
      vérif_param(la_ref_simple);
      DELETE FROM FF_CONSTITUE
      WHERE REF_MENU=la_ref_menu AND REF_SIMPLE= la_ref_simple;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE PB_COMPOSITION;
    END IF;
  NULL; 
  END appauvrir_menu;

END PAQ_PRODUITS;

/

create or replace PROCEDURE CONSO(DAT IN TIMESTAMP,PRODUIT FF_PRODUIT.P_REF%TYPE ,MAG FF_Magasin.m_ref%type ) AS 
 pf FF_PRODUIT.P_REF%TYPE;
 pm FF_Magasin.m_ref%type;
 dd TIMESTAMP;
 PARAMETRE_INDEFINI EXCEPTION ;
 PRODUIT_INCONNU EXCEPTION ;

 PRAGMA exception_init(PARAMETRE_INDEFINI,-20102) ;
 PRAGMA exception_init(PRODUIT_INCONNU,-20103);
  
BEGIN
  if(DAT is Null)then
    select sysdate into dd from dual;
  else 
  dd:=DAT;
  end if;
  if(PRODUIT is Null or MAG is Null)then
    raise parametre_indefini;
  End if;

  begin
 SELECT P_REF INTO pf
      FROM FF_PRODUIT
      WHERE P_REF= PRODUIT;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
       end;
       begin
SELECT MAG INTO pm
      FROM FF_MAGASIN
      WHERE M_REF= MAG;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
       RAISE PRODUIT_INCONNU;
  end;
  insert into FF_CONSOMMATION VALUES (dd,PRODUIT,MAG);
  
    
END CONSO;

/

create or replace TRIGGER TRIGGER1_QUESTION6_1 
AFTER INSERT ON FF_SIMPLE
for each row
DECLARE
CURSOR MAG IS 
SELECT M_REF FROM ff_magasin;
MG FF_Magasin.m_ref%type;
BEGIN

  
  for MG IN MAG loop
  EXIT WHEN  MAG%NOTFOUND;
  insert into stock values (:NEW.S_REF,MG.M_REF,0);
  END LOOP;
  
  END;
  
/

create or replace TRIGGER TRIGGER1_QUESTION6_2 
AFTER INSERT ON FF_MAGASIN
for each row
DECLARE
CURSOR MAG IS 
SELECT S_REF FROM FF_SIMPLE;
PF FF_SIMPLE.S_ref%type;
BEGIN

  
  for pf IN MAG loop
  EXIT WHEN  MAG%NOTFOUND;
  insert into stock values (pf.S_ref,:NEW.M_REF,0);
  END LOOP;
  
  END;
  
/

create or replace PACKAGE PACKAGE_STOCK AS 

  PARAMETRE_INDEFINI EXCEPTION ;
  PRODUIT_INCONNU EXCEPTION ;
  INCOHERENCE_TAILLES EXCEPTION ; 
  PB_COMPOSITION EXCEPTION ;
  PRIX_NON_POSITIF EXCEPTION ;
  PB_VALEUR_TAILLE EXCEPTION ;
  PB_VALEUR_CATEGORIE EXCEPTION ;
  DOUBLON_NOM_PRODUIT EXCEPTION ;
  PRODUIT_UTILISE EXCEPTION ;
  MAGASIN_INCONNU EXCEPTION ;

  PRAGMA exception_init(PARAMETRE_INDEFINI,-20102) ;
  PRAGMA exception_init(PRODUIT_INCONNU,-20103);
  PRAGMA exception_init(INCOHERENCE_TAILLES,-20104);
  PRAGMA exception_init(PB_COMPOSITION,-20105);
  PRAGMA exception_init(PRIX_NON_POSITIF,-20106) ;
  PRAGMA exception_init(PB_VALEUR_TAILLE,-20107) ;
  PRAGMA exception_init(PB_VALEUR_CATEGORIE,-20108) ;
  PRAGMA exception_init(DOUBLON_NOM_PRODUIT,-20109) ;
  PRAGMA exception_init(PRODUIT_UTILISE,-20110) ;
  PRAGMA exception_init(MAGASIN_INCONNU,-20111) ;
  
    procedure ajouter_PR_Simple(PRODUIT FF_SIMPLE.S_REF%TYPE ,MAG FF_Magasin.m_ref%type);
    procedure ajouter_PR_Menu(PRODUIT FF_MENU.M_REF%TYPE ,MAG FF_Magasin.m_ref%type);
    procedure changer_Quantite_STOCK(PRODUIT FF_SIMPLE.S_REF%TYPE ,MAG FF_Magasin.m_ref%type , nb number);

END PACKAGE_STOCK;

/

create or replace PACKAGE BODY PACKAGE_STOCK AS

  procedure vérif_param( parametre VARCHAR2) AS
  BEGIN
    IF (parametre is null) then
      raise parametre_indefini;
      end if;
    END vérif_param;
    
  procedure traiter_erreur(msg VARCHAR2) As
  BEGIN 
   IF (msg like '%PRIX_POSITIF%')
    then raise PRIX_NON_POSITIF;
  elsIF (msg like '%ENUM_TAILLE%')
    then raise PB_VALEUR_TAILLE;
  elsIF (msg like '%ENUM_CATEG%')
    then raise PB_VALEUR_CATEGORIE;
  END IF;
  END traiter_erreur;
  
  procedure ajouter_PR_Simple(PRODUIT FF_SIMPLE.S_REF%TYPE ,MAG FF_Magasin.m_ref%type) AS
  re ff_simple.s_ref%type; 
  me FF_Magasin.m_ref%type;
   EXP_VAL exception;
  BEGIN
    vérif_param(PRODUIT);
    vérif_param(MAG);
    begin
    select S_REF into re from FF_SIMPLE where S_REF=PRODUIT;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE PRODUIT_INCONNU;
      end;
          begin
    select M_REF into me from FF_MAGASIN where M_REF=MAG;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE MAGASIN_INCONNU;
      end;
      insert into STOCK VALUES (PRODUIT,MAG,0);
        EXCEPTION
      WHEN DUP_VAL_ON_INDEX
     THEN Null;
     WHEN EXP_VAL
     THEN traiter_erreur(SQLERRM);
  END ajouter_PR_Simple;


  procedure ajouter_PR_Menu(PRODUIT FF_MENU.M_REF%TYPE ,MAG FF_Magasin.m_ref%type) AS
  re FF_MENU.M_ref%type; 
  me FF_Magasin.m_ref%type;
  BEGIN

    
    vérif_param(PRODUIT);
    vérif_param(MAG);
    begin
    select M_REF into re from FF_MENU where M_REF=PRODUIT;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE PRODUIT_INCONNU;
      end;
     begin
    select M_REF into me from FF_MAGASIN where M_REF=MAG;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE MAGASIN_INCONNU;
      end;
      begin
      declare
        CURSOR prod IS 
        SELECT * FROM FF_CONSTITUE where REF_MENU=PRODUIT;
      begin
        for pr_s IN prod loop
        EXIT WHEN  prod%NOTFOUND;
        insert into stock values (pr_s.REF_SIMPLE,MAG,0);
        END LOOP;
        end;
  
         END;
  
  END ajouter_PR_Menu;
  
  procedure changer_Quantite_STOCK(PRODUIT FF_SIMPLE.S_REF%TYPE ,MAG FF_Magasin.m_ref%type , nb number) AS
  re ff_simple.s_ref%type; 
  me FF_Magasin.m_ref%type;
  nba number;
  begin
    vérif_param(PRODUIT);
    vérif_param(MAG);
        begin
    select S_REF into re from STOCK where S_REF=PRODUIT;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE PRODUIT_INCONNU;
      end;
          begin
    select M_REF into me from STOCK where M_REF=MAG;
      EXCEPTION 
      WHEN NO_DATA_FOUND THEN
      RAISE MAGASIN_INCONNU;
      end;
      
      if nb>0 then
      nba:=nb;
      else
      nba:=0;
      end if;
      
      UPDATE STOCK SET  S_NB=nba where S_REF =re and M_REF=me;
      
    END changer_Quantite_STOCK;
  
END PACKAGE_STOCK;

/

create or replace TRIGGER TRIGGER_QUESTION8 
AFTER INSERT ON FF_CONSOMMATION
for each row
BEGIN
  UPDATE STOCK SET  S_NB=S_NB-1 where S_REF =:new.REF_PRODUIT and M_REF=:new.REF_MAGASIN;
  END;
  
/

create or replace TRIGGER TRIGGER1_QUESTION8_2 
BEFORE INSERT on FF_CONSOMMATION
for each row
declare
 QUANTITE_NULL EXCEPTION ;
  PRAGMA exception_init(QUANTITE_NULL,-20112) ;
 NB STOCK.s_nb%type;
BEGIN
  select S_NB INTO nb from  STOCK where S_REF =:new.REF_PRODUIT and M_REF=:new.REF_MAGASIN and S_NB>0 ;
  EXCEPTION 
  WHEN NO_DATA_FOUND THEN
  raise QUANTITE_NULL;
  END;