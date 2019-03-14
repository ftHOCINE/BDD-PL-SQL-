--TD2_CINEMA(ci_ref,ci_nom, ci_ville)

--TD2_FILM (fi_ref,fi_titre,fi_annee)

--TD2_SEANCE (se_ref,fi_ref, ci_ref,se_horaire)

--TD2_SPECTATEUR(sp_ref,sp_nom,sp_prenom,sp_mail)

--TD2_ASSISTE(sp_ref,se_ref,as_avis)

create table TD2_CINEMA (
  ci_ref varchar2(5) constraint PK_TD2_CINEMA primary key,
  ci_nom varchar2(20) not null,
  ci_ville varchar2(20) not null
);

insert into TD2_CINEMA values ('ci1', 'METROPOLE', 'LILLE');
insert into TD2_CINEMA values ('ci2', 'GAUMONT', 'LILLE');
insert into TD2_CINEMA values ('ci3', 'BASTILLE', 'PARIS');
insert into TD2_CINEMA values ('ci4', 'ODEON', 'PARIS');

create table TD2_FILM (
  fi_ref  varchar2(5) constraint PK_TD2_FILM primary key,
  fi_titre varchar2(30) not null,
  fi_annee number(4) not null
); 

insert into TD2_FILM values ('fi1', 'Gravity', 2013);
insert into TD2_FILM values ('fi2', 'gone girl', 2014);
insert into TD2_FILM values ('fi3', 'mommy', 2014);

create table TD2_SEANCE (
  se_ref varchar2(5) constraint PK_TD2_SEANCE primary key,
  fi_ref varchar2(5) not null constraint FK_SEANCE_REF_FILM references TD2_FILM,
  ci_ref varchar2(5) not null constraint FK_SEANCE_REF_CINEMA references TD2_CINEMA,
  se_horaire DATE not null
);

--gravity
insert into TD2_SEANCE values ('se1', 'fi1', 'ci2', to_date('21/04/2013:17:00', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se2', 'fi1', 'ci2', to_date('24/04/2013:21:00', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se3', 'fi1', 'ci3', to_date('22/04/2013:20:30', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se4', 'fi1', 'ci4', to_date('26/04/2013:18:30', 'dd/mm/yyyy/hh24:mi'));
--gone girl
insert into TD2_SEANCE values ('se10', 'fi2', 'ci2', to_date('12/06/2014:17:00', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se11', 'fi2', 'ci3', to_date('17/07/2014:21:00', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se12', 'fi2', 'ci3', to_date('22/08/2014:20:30', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se13', 'fi2', 'ci4', to_date('26/08/2014:18:30', 'dd/mm/yyyy/hh24:mi'));
--mommy
insert into TD2_SEANCE values ('se20', 'fi3', 'ci4', to_date('12/09/2014:20:15', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se21', 'fi3', 'ci4', to_date('17/09/2014:21:00', 'dd/mm/yyyy/hh24:mi'));
insert into TD2_SEANCE values ('se22', 'fi3', 'ci1', to_date('21/09/2014:21:00', 'dd/mm/yyyy/hh24:mi'));

create table TD2_SPECTATEUR (
  sp_ref varchar2(5) constraint PK_TD2_SPECTATEUR primary key,
  sp_nom varchar2(20) not null,
  sp_prenom varchar2(20) not null,
  sp_mail varchar2(30) not null,
  constraint TD2_SPECTATEUR_MAIL check (REGEXP_LIKE (sp_mail, '^[a-z0-9._-]+@[a-z0-9._-]{2,}\.[a-z]{2,4}$'))
 );


--le spectateur sp20 n'a rien vu
insert into TD2_SPECTATEUR values ('sp1', 'Breton', 'Michel', 'breton@gmail.com');
insert into TD2_SPECTATEUR values ('sp2', 'Cambier', 'Aline', 'cambier@yahoo.fr');
insert into TD2_SPECTATEUR values ('sp3', 'Kante', 'Karamoko', 'kante@free.fr');
insert into TD2_SPECTATEUR values ('sp4', 'Chberreq', 'Ahmed', 'achberreq@gmail.com');
insert into TD2_SPECTATEUR values ('sp5', 'Roux', 'Julien', 'julien@hotmail.com');
insert into TD2_SPECTATEUR values ('sp6', 'Pele', 'Marie', 'marie.pele@laposte.net');
insert into TD2_SPECTATEUR values ('sp7', 'Zeng', 'Yifan', 'yifanzeng@gmail.com');
insert into TD2_SPECTATEUR values ('sp8', 'Schmid', 'Damien', 'dscmid-56@free.fr');
insert into TD2_SPECTATEUR values ('sp9', 'Cervantes', 'Pablo', 'pablo59@hotmail.fr');
insert into TD2_SPECTATEUR values ('sp10', 'Ramos', 'Irene', 'irene.ramos@gmail.com');
insert into TD2_SPECTATEUR values ('sp11', 'Vallet', 'Valerie', 'vava@gmail.com');
insert into TD2_SPECTATEUR values ('sp20', 'Victor', 'Bravo', 'bravo@gmail.com');


create table TD2_ASSISTE (
  sp_ref varchar2(5) constraint ASSISTE_REF_SPECTATEUR references TD2_SPECTATEUR,
  se_ref varchar2(5) constraint ASSISTE_REF_SEANCE references TD2_SEANCE,
  se_avis varchar2(10) not null constraint LISTE_AVIS check (se_avis in ('tres bon','pas mal','moyen','mauvais','sans avis'))
);

alter table TD2_ASSISTE add constraint ASSITE_PK PRIMARY KEY(sp_ref, se_ref);

-- sp8 a trouve tous les films qu'il a vu mauvais, idem pour sp1
-- la seance se20 et se21 a fait l'unanimite : que des avis tres bon
-- sp3 a vu 2 fois gone girl et a donne 2 avis differents
-- pour gone girl, 90% des avis sont tres bon ou pas mal (et pour mommy aussi)

insert into TD2_ASSISTE values ('sp8', 'se2', 'mauvais');
insert into TD2_ASSISTE values ('sp8', 'se11', 'mauvais');
insert into TD2_ASSISTE values ('sp1', 'se1', 'mauvais');

insert into TD2_ASSISTE values ('sp3', 'se20', 'tres bon');
insert into TD2_ASSISTE values ('sp4', 'se20', 'tres bon');
insert into TD2_ASSISTE values ('sp9', 'se20', 'tres bon');
insert into TD2_ASSISTE values ('sp2', 'se21', 'tres bon');
insert into TD2_ASSISTE values ('sp6', 'se21', 'tres bon');
insert into TD2_ASSISTE values ('sp10', 'se21', 'tres bon');

insert into TD2_ASSISTE values ('sp3', 'se10', 'moyen');
insert into TD2_ASSISTE values ('sp3', 'se11', 'pas mal');


--gone girl a deja 1 mauvais, 1 moyen, 1 pas mal - pour avoir + de 80% d'avis pas mal ou tres bon il en faut au moins 7 de plus, sans le 1,8,3
insert into TD2_ASSISTE values ('sp2', 'se10', 'pas mal');
insert into TD2_ASSISTE values ('sp4', 'se10', 'tres bon');
insert into TD2_ASSISTE values ('sp5', 'se11', 'pas mal');
insert into TD2_ASSISTE values ('sp6', 'se12', 'pas mal');
insert into TD2_ASSISTE values ('sp6', 'se11', 'pas mal');
insert into TD2_ASSISTE values ('sp7', 'se13', 'tres bon');
insert into TD2_ASSISTE values ('sp9', 'se13', 'pas mal');
insert into TD2_ASSISTE values ('sp10', 'se12', 'tres bon');
insert into TD2_ASSISTE values ('sp11', 'se11', 'tres bon');

--des spectateurs pour gravity sauf sp1 et sp8

insert into TD2_ASSISTE values ('sp2', 'se1', 'pas mal');
insert into TD2_ASSISTE values ('sp3', 'se1', 'moyen');
insert into TD2_ASSISTE values ('sp4', 'se2', 'mauvais');
insert into TD2_ASSISTE values ('sp6', 'se2', 'pas mal');
insert into TD2_ASSISTE values ('sp9', 'se3', 'sans avis');
insert into TD2_ASSISTE values ('sp10', 'se3', 'tres bon');
insert into TD2_ASSISTE values ('sp11', 'se4', 'pas mal');
insert into TD2_ASSISTE values ('sp5', 'se4', 'tres bon');

--des spectateurs pour la seance 22 (pas sp1 et sp8)
insert into TD2_ASSISTE values ('sp5', 'se22', 'tres bon');
insert into TD2_ASSISTE values ('sp6', 'se22', 'moyen');
insert into TD2_ASSISTE values ('sp10', 'se22', 'pas mal');
insert into TD2_ASSISTE values ('sp11', 'se22', 'moyen');



