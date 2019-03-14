/**HOCINE FERHAT L3MIAGE G02**/

/**Creation des tables**/

CREATE TABLE livre (
ref number(10),
titre varchar(50) not null,
editeur varchar(50),
CONSTRAINT livre_PK PRIMARY KEY(ref) );


CREATE TABLE auteur (
id number(10),
nom varchar(50) NOT NULL,
prenom varchar(50),
CONSTRAINT auteur_PK PRIMARY KEY(id) );


CREATE TABLE diplome (
code number(6),
libelle varchar(50) not null,
CONSTRAINT diplome_PK PRIMARY KEY(code) ,
CONSTRAINT code_CN CHECK (regexp_like(code,'^[0-9][0-9][0-9][0-9][0-9][0-9]$'))) ;


CREATE TABLE matiere (
numero number(10),
code number(6),
libelle varchar(50) not null,
CONSTRAINT matiere_PK PRIMARY KEY(numero,code),
CONSTRAINT numero_CN CHECK (numero>0),
CONSTRAINT code_dip FOREIGN KEY (code) REFERENCES diplome (code)
);



CREATE TABLE enseignant (
id number(10),
nom varchar(50) not null,
prenom varchar(50) not null,
tel number(10),
mail varchar(100),
CONSTRAINT enseignant_PK PRIMARY KEY(id),
CONSTRAINT tel_CN CHECK (tel like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT mail_CN CHECK (regexp_like(mail, '^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')),
CONSTRAINT mail_tel CHECK (tel is not null or mail is not null));



CREATE TABLE recommandation (
ref number(10),
rnumero number(10),
rcode number(6),
ide number(10),
CONSTRAINT recom_PK PRIMARY KEY(ref,rnumero,rcode),
CONSTRAINT ref_ref FOREIGN KEY (ref) REFERENCES livre (ref),
CONSTRAINT ref_numero FOREIGN KEY (rnumero,rcode) REFERENCES matiere (numero,code),
CONSTRAINT ref_ide FOREIGN KEY (ide) REFERENCES enseignant (id));



/**Question1.3**/
INSERT INTO livre VALUES (1,'sql pour oracle','Eyrolles');
INSERT INTO livre VALUES (2,'Design Patterns,Tete la Première','O Reilly');
INSERT INTO livre VALUES (3,'Les reseaux','Eyrolles');
INSERT INTO livre VALUES (4,'Réseaux et Télécoms','Dunod');
INSERT INTO livre VALUES (5,'Les Bases de données pour les nuls','Générales First');



INSERT INTO auteur VALUES (1,'Soutou','Christian');
INSERT INTO auteur VALUES (2,'Teste','Olivier');
INSERT INTO auteur (id,nom) VALUES (3,'Eric');
INSERT INTO auteur VALUES (4,'Freeman','Elisabeth');
INSERT INTO auteur VALUES (5,'Pujolle','Guy');
INSERT INTO auteur VALUES (6,'Servin','Claude');
INSERT INTO auteur VALUES (7,'Fabien','Fabre.');

INSERT INTO diplome VALUES (123789,'Licence 3 informatique');
INSERT INTO diplome VALUES (123456,'licence 3 MIAGE');
INSERT INTO diplome VALUES (123232,'licence 2 informatique');

INSERT INTO matiere VALUES (1,123456,'Bases de Données');
INSERT INTO matiere VALUES (2,123232,'technologie du web');
INSERT INTO matiere VALUES (3,123456,'Conception Orientée Objet');
INSERT INTO matiere VALUES (4,123456,'Réseaux');
INSERT INTO matiere VALUES (4,123789,'Réseaux');



INSERT INTO enseignant(id,nom,prenom,mail) VALUES (100,'Caron','Anne-Cécile','AnneCecile@lille.fr');
INSERT INTO enseignant(id,nom,prenom,mail) VALUES (101,'Bogaert','Bruno','BogaertBruno@lille.fr');
INSERT INTO enseignant(id,nom,prenom,mail) VALUES (102,'Roos','Yves','RoosYves@lille.fr');
INSERT INTO enseignant(id,nom,prenom,mail) VALUES (103,'Noe','Laurent','LaurentNoe@lille.fr'); 



INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(1,1,123456,100);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(5,1,123456,100);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(5,2,123232,101);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(2,3,123456,102);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(3,4,123456,103);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(4,4,123456,103);
INSERT INTO recommandation(ref,rnumero,rcode,ide) VALUES(4,4,123789,103);





/**Question2.3**/

/**Q1**/
SELECT FI_REF,FI_TITRE,FI_ANNEE 
FROM td2_film
where fi_annee='2014';
/**Q2**/
select ci_nom, se_horaire 
from TD2_SEANCE 
join TD2_CINEMA using(CI_REF) 
join td2_film using(fi_ref) 
where fi_titre='Gravity';
/**Q3**/
select count(*) AS nb_spectateurs_se10
from TD2_ASSISTE
where SE_REF='se10';
/**Q4**/
SELECT avg(count(*)) as nb_moyen
FROM td2_assiste 
GROUP BY se_ref;

/**Q5**/
WITH nbr as (Select count(*) as nb,sp_ref
from TD2_ASSISTE
group by sp_ref)
select sp_ref,sp_nom,sp_prenom,nb as nb_seances
from nbr
join td2_spectateur using(sp_ref);

/**Q6**/
with nbm as(select sp_ref,count(*) as nb_mauv
from td2_assiste
where se_avis='mauvais'
group by sp_ref),
nbf as(select sp_ref,count(*) as nb_fil
from td2_assiste
group by sp_ref)
select sp_nom,sp_prenom,sp_ref
from nbm 
join nbf using(sp_ref)
join td2_spectateur using(sp_ref)
where nb_mauv=nb_fil ;

/**Q7**/
WITH avistb as (Select fi_ref, count(*) as nbavistb
from TD2_ASSISTE
join TD2_SEANCE using (SE_REF)
where TD2_ASSISTE.SE_AVIS = 'tres bon'
group by FI_REF)
select FI_TITRE
from avistb
join TD2_FILM USING(FI_REF)
WHERE nbavistb = (select max(nbavistb) from avistb);


/**Q8**/
WITH avistb as (Select fi_ref,CI_REF, count(*) as nbavistb
from TD2_ASSISTE
join TD2_SEANCE using (SE_REF)
where TD2_ASSISTE.SE_AVIS = 'tres bon'
group by FI_REF,CI_REF)
SELECT CI_NOM,CI_VILLE,FI_TITRE,nbavistb
from avistb EXTERNE
join TD2_CINEMA ON EXTERNE.CI_REF=TD2_CINEMA.CI_REF
join TD2_FILM USING(FI_REF)
WHERE nbavistb = (select max(nbavistb) from avistb WHERE CI_REF=EXTERNE.CI_REF);

/**Q9**/
WITH SPEC as (Select SP_REF,FI_ref, count(distinct SE_AVIS) as nbavis
from TD2_ASSISTE
join TD2_SEANCE using (SE_REF)
join TD2_FILM using (FI_REF)
having count(*)>1
group by SP_REF,FI_ref)
select sp_ref,sp_nom,sp_prenom,fi_titre
from SPEC
join TD2_FILM using (fi_ref)
join TD2_SPECTATEUR using(sp_ref)
where nbavis>1;


/**10**/
with dayy as(Select CI_NOM,CI_VILLE,to_char(SE_HORAIRE,'D') AS NBR
FROM TD2_CINEMA
JOIN TD2_SEANCE using (CI_REF)),
WEEK AS(select CI_NOM,COUNT(case when nbr>5 then 1 else null end) AS nb_we,COUNT(case when nbr<6 then 1 else null end) AS nb_hors_we
from dayy
GROUP BY CI_NOM)
select distinct Ci_nom,CI_VILLE,nb_we,nb_hors_we
FROM DAYY
JOIN WEEK using(ci_nom);


/**11**/
with avis as(select se_ref,count(case when se_avis = 'mauvais' then 1 else null end) as nb_mauvais,count(case when se_avis = 'moyen' then 1 else null end) as nb_moyen,count(case when se_avis = 'pas mal' then 1 else null end) as nb_pas_mal,count(case when se_avis = 'tres bon' then 1 else null end) as nb_tres_bon
from td2_assiste
group by se_ref)
select fi_titre,nb_mauvais, nb_moyen, nb_pas_mal, nb_tres_bon
from avis 
join td2_seance using(se_ref)
join td2_film using(fi_ref);

/**12**/
with dayy as(Select se_avis,to_char(SE_HORAIRE,'D') AS NBR
FROM TD2_ASSISTE
JOIN TD2_SEANCE using (se_ref))
select max(count(*)) as jour
from dayy
where se_avis='tres bon'
GROUP BY NBR;



/**13**/
with dayy as(Select CI_NOM,CI_VILLE,se_avis,to_char(SE_HORAIRE,'D') AS NBR
FROM TD2_ASSISTE
JOIN TD2_SEANCE using (se_ref)
JOIN TD2_CINEMA USING (CI_REF))
select DISTINCT CI_NOM,CI_VILLE,max(NBR)
from dayy
where se_avis='tres bon'
group by ci_nom,CI_VILLE;


/**14**/
with avis_b as (select fi_titre,count(se_avis) as ab
from td2_assiste 
join td2_seance using(se_ref)
join td2_film using(fi_ref)
where se_avis='tres bon' or se_avis='pas mal'
group by fi_titre),
avis_t as(select fi_titre,count(se_avis)as at
from td2_assiste 
join td2_seance using(se_ref)
join td2_film using(fi_ref)
group by fi_titre)
select fi_titre 
from avis_b 
join avis_t using (fi_titre)
where (ab/at>=0.8);

/**15**/
with avis_b as (select FI_TITRE,CI_VILLE,count(se_avis) as ab
from td2_assiste 
join td2_seance using(se_ref)
join td2_film using(fi_ref)
join td2_CINEMA using(CI_REF)
where se_avis='tres bon' 
group by CI_VILLE,FI_TITRE),
avis_T as (select FI_TITRE,CI_VILLE,count(se_avis) as ab
from td2_assiste 
join td2_seance using(se_ref)
join td2_film using(fi_ref)
join td2_CINEMA using(CI_REF)
group by CI_VILLE,FI_TITRE),
LILLE AS(select FI_TITRE,avis_b.ab/avis_T.ab AS ratio_lille from avis_T
LEFT JOIN avis_b using (CI_VILLE,FI_TITRE)
where ci_ville='LILLE'),
PARIS AS(select FI_TITRE,avis_b.ab/avis_T.ab AS ratio_paris from avis_T
JOIN avis_b using (CI_VILLE,FI_TITRE)
where ci_ville='PARIS')
SELECT FI_TITRE ,count(ratio_lille), ratio_paris
FROM PARIS join LILLE using(FI_TITRE)
group by FI_TITRE,ratio_paris;


/**Question 2**/
/**2.4.1**/
INSERT INTO td2_spectateur VALUES ('sp34','HOCINE1','Ferhat1','hocineferhat1@gmail.com');

/**2.4.2**/
delete 
from td2_seance where se_ref in (select se_ref from td2_seance where to_char(SE_HORAIRE,'yyyy-mm')<'2013-07');
delete 
from td2_seance 
where to_char(SE_HORAIRE,'yyyy-mm')<'2013-07'

/**2.4.3**/
UPDATE td2_spectateur
SET sp_nom = 'Normand'
WHERE sp_nom='Breton';

/**2.4.4**/
UPDATE td2_assiste
SET se_avis = 'pas mal'
WHERE sp_ref in( select sp_ref from td2_spectateur where sp_nom='Roux') and se_ref='se4';


/**2.5**/
ALTER TABLE td2_film
ADD derniereProjection date ;

/**2.6**/
select ci_ref ,SE_HORAIRE
from td2_seance join td2_film using(fi_ref)
where fi_ref='fi1' and se_horaire in(select MAX(SE_HORAIRE)
from td2_seance join td2_film using(fi_ref)
where fi_ref='fi1' );

/**2.7**/
UPDATE TD2_FILM 
SET TD2_FILM.derniereProjection = (SELECT MAX(se_horaire) 
FROM TD2_SEANCE 
WHERE TD2_FILM.fi_ref = TD2_SEANCE.fi_ref);


