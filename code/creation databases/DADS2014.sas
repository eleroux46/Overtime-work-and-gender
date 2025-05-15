/* CREATION DATABASE 2014 */



/* Import database "Entreprise" 2014 */

data ent14 (keep = A6 APEN EFF_MOY EFF_MOY_1 SIREN TR_CA TR_CA_1 REG_SIEGE DAT_CREA CATJUR
NB_SAL NB_TYP_EMPLOI_A NB_TYP_EMPLOI_E NB_TYP_EMPLOI_O NB_TYP_EMPLOI_S
); 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Entreprises_2014\ent.sas7bdat"; 
if cmiss(of SIREN) then delete;
run;

data ent14;
set ent14;
if A6 = "OQ" then delete;
run;


/* Select variables */
%let keepvars = IDENT_S A6 AGE SEXE SIREN PCS S_BRUT S_BRUT_1 CPFD CPFD_1 NBHEUR NBHEUR_1
 CONTRAT_TRAVAIL CONV_COLL CRIS DEPT DOMEMPL DOMEMPL_EMPL DUREE EFF_0101_ET 
EFF_3112_ET EFF_MOY_ET ETP FILT FRONTALIER 
 IND_3112 IND_3112_1 S_NET TREFFECT TREFFECT_1 TREFFEN TREFFEN_1 TYP_EMPLOI
TYP_EMPLOI_1 UUT APEN
COMR COMT DATDEB DATFIN;


/* Import database "Postes" 2014 */

data post24 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post24.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post27 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post27.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post28 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post28.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post32 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post32.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post44 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post44.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post52 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post52.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post53 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post53.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post75 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post75.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post76 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post76.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post84 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post84.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post93 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post93.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post94 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post94.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post97 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post97.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post99 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2014\Régions\post99.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;


/* Append all databases in post14 */

data post14;
set post24 post27 post28 post32 post44 post52 post53 post75 post76 post84 post93 post94 post97 post99;
run;


/* recoding the variables */


data post14cleaned;
set post14;
if CPFD = "C" then COMPLET = 1;
else COMPLET = 0;
run;


data post14cleaned;
set post14cleaned;
if SEXE = 1 then HOMME = 1;
else HOMME = 0;
if SEXE = 2 then FEMME = 1;
else FEMME = 0;
run;


/* Selecting the observations that are interesting for the analysis */


/* droping people who are not working full time */

DATA post14_c;
 set post14cleaned;
 where COMPLET = 1;
run;

/* creating indicators for people working overtime */

data post14_c;
set post14_c;
if NBHEUR/DUREE*360 > 1607 then HSUP_1607 = 1; 
else HSUP = 0;
if NBHEUR/DUREE*360 > 1642 then HSUP_1SEM_1607 = 1;
else HSUP_1SEM = 0;
if NBHEUR/DUREE*360 > 1677 then HSUP_2SEM_1607 = 1;
else HSUP_2SEM = 0;
if NBHEUR/DUREE*360 > 1712 then HSUP_3SEM_1607 = 1;
else HSUP_3SEM = 0;
if NBHEUR/DUREE*360 > 1747 then HSUP_4SEM_1607 = 1;
else HSUP_4SEM = 0;
if NBHEUR/DUREE*360 > 1782 then HSUP_5SEM_1607 = 1;
else HSUP_5SEM = 0;
if NBHEUR/DUREE*360 > 1817 then HSUP_6SEM_1607 = 1;
else HSUP_6SEM = 0;
if NBHEUR/DUREE*360 > 1820 then HSUP = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 1855 then HSUP_1SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 1890 then HSUP_2SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 1925 then HSUP_3SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 1960 then HSUP_4SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 1995 then HSUP_5SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 2030 then HSUP_6SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 2065 then HSUP_7SEM = 1;
else HSUP_MAX = 0;
if NBHEUR/DUREE*360 > 2100 then HSUP_8SEM = 1;
else HSUP_MAX = 0;
run;

/* Global mean statistics */
proc sql;
create table post14_c_ent as
select SIREN, mean(S_BRUT) as S_BRUT_MOY, mean(NBHEUR) as NBHEUR_MOY, mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY, 
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360 ,mean(AGE) as AGE_MOY, 
 sum(COMPLET) as NBR_COMPLET, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR, 
 mean(EFF_0101_ET) as EFF_0101_ET, mean(EFF_3112_ET) as EFF_3112_ET, mean(EFF_MOY_ET) as EFF_MOY_ET, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR,
sum(HSUP) as NBR_HSUP, sum(HSUP)/sum(COMPLET) as SHARE_HSUP,
sum(HSUP_1SEM) as NBR_HSUP_1SEM, sum(HSUP_2SEM) as NBR_HSUP_2SEM, sum(HSUP_3SEM) as NBR_HSUP_3SEM, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM, sum(HSUP_5SEM) as NBR_HSUP_5SEM, sum(HSUP_6SEM) as NBR_HSUP_6SEM, 
sum(HSUP_MAX) as NBR_HSUP_MAX
from post14_c
group by SIREN;
quit;

/* global statistics per gender */

/* Database men */
proc sql; 
create table ho14 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, HOMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, ETP, FRONTALIER, DUREE, HSUP, HSUP_1SEM, HSUP_2SEM, HSUP_3SEM, HSUP_4SEM, HSUP_5SEM,
HSUP_6SEM, HSUP_MAX
from post14_c
where SEXE='1';
quit;

proc sql;
create table ho14 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_H, mean(NBHEUR) as NBHEUR_MOY_H ,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_H , mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_H, mean(AGE) as AGE_MOY_H,  sum(HOMME) as NBR_H, 
 sum(COMPLET) as NBR_COMPLET_H, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_H, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_H, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_H, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_H,
sum(HSUP) as NBR_HSUP_H, sum(HSUP)/sum(COMPLET) as SHARE_HSUP_H,
sum(HSUP_1SEM) as NBR_HSUP_1SEM_H, sum(HSUP_2SEM) as NBR_HSUP_2SEM_H, sum(HSUP_3SEM) as NBR_HSUP_3SEM_H, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM_H, sum(HSUP_5SEM) as NBR_HSUP_5SEM_H, sum(HSUP_6SEM) as NBR_HSUP_6SEM_H, 
sum(HSUP_MAX) as NBR_HSUP_MAX_H
from ho14
group by SIREN;
quit;



/* Database women */
proc sql; 
create table fe14 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, FEMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, ETP, FRONTALIER, DUREE, HSUP, HSUP_1SEM, HSUP_2SEM, HSUP_3SEM, HSUP_4SEM, HSUP_5SEM,
HSUP_6SEM, HSUP_MAX
from post14_c
where SEXE='2';
quit;

proc sql;
create table fe14 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_F, mean(NBHEUR) as NBHEUR_MOY_F,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_F ,mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_F, mean(AGE) as AGE_MOY_F, sum(FEMME) as NBR_F, 
 sum(COMPLET) as NBR_COMPLET_F, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_F, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_F, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_F, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_F, 
sum(HSUP) as NBR_HSUP_F, sum(HSUP)/sum(COMPLET) as SHARE_HSUP_F,
sum(HSUP_1SEM) as NBR_HSUP_1SEM_F, sum(HSUP_2SEM) as NBR_HSUP_2SEM_F, sum(HSUP_3SEM) as NBR_HSUP_3SEM_F, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM_F, sum(HSUP_5SEM) as NBR_HSUP_5SEM_F, sum(HSUP_6SEM) as NBR_HSUP_6SEM_F, 
sum(HSUP_MAX) as NBR_HSUP_MAX_F
from fe14
group by SIREN;
quit;


/*global statistics for people doing overtime work */


proc sql; 
create table overt14 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, FEMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, ETP, FRONTALIER, DUREE, HSUP
from post14_c
where HSUP=1;
quit;

proc sql;
create table overt14 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_OVER, mean(NBHEUR) as NBHEUR_MOY_OVER,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_OVER ,mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_OVER, mean(AGE) as AGE_MOY_OVER, 
mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_OVER, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_OVER, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_OVER, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_OVER
from overt14
group by SIREN;
quit;


/* entreprises */


data post14_ent (keep = A6 DEPT DOMEMPL DOMEMPL_EMPL FRONTALIER SIREN TREFFECT TREFFEN UUT APEN);
set post14_c;
RUN;




/* merging databases */

proc sort data= post14_c_ent ;
by SIREN;
RUN;

proc sort data= post14_ent out=post14_ent_u nodupkey ; 
by SIREN;
RUN;

proc sort data= fe14 ;
by SIREN;
RUN;

proc sort data= ho14 ;
by SIREN;
RUN;

proc sort data= ent14 ;
by SIREN;
RUN;

proc sort data= overt14 ;
by SIREN;
RUN;



data base14;
merge post14_c_ent fe14 ho14 post14_ent_u ent14 overt14;
by SIREN;
RUN;

data base14;
set base14;
if cmiss(of NBHEUR_MOY NBR_COMPLET) then delete;
if APEN in ("7810Z", "7820Z", "7830Z") then delete;
run;


/* export database */

PROC EXPORT data=base14
outfile= "C:\Users\Public\Documents\Leroux_Mayans\Data\base14_siren2.csv"
dbms=csv
replace;
run;

libname sauv "C:\Users\Public\Documents\Leroux_Mayans\Data";
data sauv.base14_2;
set base14;
run;