/* CREATION DATABASE 2019 */

/* Select variables */
%let keepvars = IDENT_S A6 AGE SEXE SIREN PCS S_BRUT S_BRUT_1 CPFD CPFD_1 NBHEUR NBHEUR_1
 CONTRAT_TRAVAIL CONV_COLL CRIS DEPT DOMEMPL DOMEMPL_EMPL DUREE EFF_0101_ET 
EFF_3112_ET EFF_MOY_ET EQTP FILT FRONTALIER 
 IND_3112 IND_3112_1 S_NET TREFFECT TREFFECT_1 TREFFEN TREFFEN_1 TYP_EMPLOI
TYP_EMPLOI_1 UUT APEN
COMR COMT DATDEB DATFIN CATJUR;

/* Import database "Postes" 2019 */

data post1 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2019\post_1.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post2 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2019\post_2.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post3 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2019\post_3.sas7bdat"; 
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;

data post4 (keep = &keepvars) ; 
set "\\casd.fr\casdfs\Projets\ENSAE04\Data\DADS_DADS Postes_2019\post_4.sas7bdat";
if cmiss(of SEXE PCS S_BRUT SIREN) then delete;
if A6 = "OQ" then delete;
run;


/* Append all databases in post18 */

data post19;
set post1 post2 post3 post4 ;
run;


/* recoding the variables */


data post19cleaned;
set post19;
if CPFD = "C" then COMPLET = 1;
else COMPLET = 0;
run;


data post19cleaned;
set post19cleaned;
if SEXE = 1 then HOMME = 1;
else HOMME = 0;
if SEXE = 2 then FEMME = 1;
else FEMME = 0;
run;


/* Selecting the observations that are interesting for the analysis */


/* droping people who are not working full time */

DATA post19_c;
 set post19cleaned;
 where COMPLET = 1;
run;

/* creating indicators for people working overtime */

data post19_c;
set post19_c;
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
create table post19_c_ent as
select SIREN, mean(S_BRUT) as S_BRUT_MOY, mean(NBHEUR) as NBHEUR_MOY, mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY, 
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360 ,mean(AGE) as AGE_MOY, 
 sum(COMPLET) as NBR_COMPLET, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR, 
 mean(EFF_0101_ET) as EFF_0101_ET, mean(EFF_3112_ET) as EFF_3112_ET, mean(EFF_MOY_ET) as EFF_MOY_ET, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR,
sum(HSUP) as NBR_HSUP, sum(HSUP)/sum(COMPLET) as SHARE_HSUP,
sum(HSUP_1SEM) as NBR_HSUP_1SEM, sum(HSUP_2SEM) as NBR_HSUP_2SEM, sum(HSUP_3SEM) as NBR_HSUP_3SEM, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM, sum(HSUP_5SEM) as NBR_HSUP_5SEM, sum(HSUP_6SEM) as NBR_HSUP_6SEM, 
sum(HSUP_MAX) as NBR_HSUP_MAX
from post19_c
group by SIREN;
quit;

/* global statistics per gender */

/* Database men */
proc sql; 
create table ho19 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, HOMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, FRONTALIER, DUREE, HSUP, HSUP_1SEM, HSUP_2SEM, HSUP_3SEM, HSUP_4SEM, HSUP_5SEM,
HSUP_6SEM, HSUP_MAX
from post19_c
where SEXE='1';
quit;

proc sql;
create table ho19 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_H, mean(NBHEUR) as NBHEUR_MOY_H ,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_H , mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_H, mean(AGE) as AGE_MOY_H,  sum(HOMME) as NBR_H, 
 sum(COMPLET) as NBR_COMPLET_H, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_H, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_H, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_H, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_H,
sum(HSUP) as NBR_HSUP_H, sum(HSUP)/sum(COMPLET) as SHARE_HSUP_H,
sum(HSUP_1SEM) as NBR_HSUP_1SEM_H, sum(HSUP_2SEM) as NBR_HSUP_2SEM_H, sum(HSUP_3SEM) as NBR_HSUP_3SEM_H, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM_H, sum(HSUP_5SEM) as NBR_HSUP_5SEM_H, sum(HSUP_6SEM) as NBR_HSUP_6SEM_H, 
sum(HSUP_MAX) as NBR_HSUP_MAX_H
from ho19
group by SIREN;
quit;



/* Database women */
proc sql; 
create table fe19 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, FEMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, FRONTALIER, DUREE, HSUP, HSUP_1SEM, HSUP_2SEM, HSUP_3SEM, HSUP_4SEM, HSUP_5SEM,
HSUP_6SEM, HSUP_MAX
from post19_c
where SEXE='2';
quit;

proc sql;
create table fe19 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_F, mean(NBHEUR) as NBHEUR_MOY_F,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_F ,mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_F, mean(AGE) as AGE_MOY_F, sum(FEMME) as NBR_F, 
 sum(COMPLET) as NBR_COMPLET_F, mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_F, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_F, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_F, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_F, 
sum(HSUP) as NBR_HSUP_F, sum(HSUP)/sum(COMPLET) as SHARE_HSUP_F,
sum(HSUP_1SEM) as NBR_HSUP_1SEM_F, sum(HSUP_2SEM) as NBR_HSUP_2SEM_F, sum(HSUP_3SEM) as NBR_HSUP_3SEM_F, 
sum(HSUP_4SEM) as NBR_HSUP_4SEM_F, sum(HSUP_5SEM) as NBR_HSUP_5SEM_F, sum(HSUP_6SEM) as NBR_HSUP_6SEM_F, 
sum(HSUP_MAX) as NBR_HSUP_MAX_F
from fe19
group by SIREN;
quit;


/*global statistics for people doing overtime work */


proc sql; 
create table overt19 as
select IDENT_S, AGE, SEXE, SIREN, PCS, S_BRUT, S_BRUT_1, 
CPFD, CPFD_1, NBHEUR, NBHEUR_1, FEMME, COMPLET, DEPT, DOMEMPL, EFF_0101_ET, EFF_3112_ET,
EFF_MOY_ET, FRONTALIER, DUREE, HSUP
from post19_c
where HSUP=1;
quit;

proc sql;
create table overt19 as
select SIREN, mean(S_BRUT) as S_BRUT_MOY_OVER, mean(NBHEUR) as NBHEUR_MOY_OVER,
mean(NBHEUR/DUREE*360) as NBHEUR_DAY_MOY360_OVER ,mean(NBHEUR/DUREE) as NBHEUR_DAY_MOY_OVER, mean(AGE) as AGE_MOY_OVER, 
mean(S_BRUT- S_BRUT_1) as CROISS_S_BRUT_OVER, mean(NBHEUR- NBHEUR_1) as CROISS_NBHEUR_OVER, 
mean(S_BRUT/NBHEUR) as S_BRUT_HOR_OVER, mean(S_BRUT/NBHEUR - S_BRUT_1/NBHEUR_1) as CROISS_S_BRUT_HOR_OVER
from overt19
group by SIREN;
quit;


/* entreprises */


data post19_ent (keep = A6 DEPT DOMEMPL DOMEMPL_EMPL FRONTALIER SIREN TREFFECT TREFFEN UUT APEN);
set post19_c;
RUN;




/* merging databases */

proc sort data= post19_c_ent ;
by SIREN;
RUN;

proc sort data= post19_ent out=post19_ent_u nodupkey ; 
by SIREN;
RUN;

proc sort data= fe19 ;
by SIREN;
RUN;

proc sort data= ho19 ;
by SIREN;
RUN;


proc sort data= overt19 ;
by SIREN;
RUN;



data base19;
merge post19_c_ent fe19 ho19 post19_ent_u overt19;
by SIREN;
if APEN in ("7810Z", "7820Z", "7830Z") then delete;
RUN;


/* export database */

PROC EXPORT data=base19
outfile= "C:\Users\Public\Documents\Leroux_Mayans\Data\base19_siren2.csv"
dbms=csv
replace;
run;

libname sauv "C:\Users\Public\Documents\Leroux_Mayans\Data";
data sauv.base19_2;
set base19;
run;

