
data base13 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base13_2.sas7bdat"; 
ANNEE=2013;
format ANNEE BEST12.;
run;

data base14 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base14_2.sas7bdat"; 
ANNEE=2014;
format ANNEE BEST12.;
run;

data base15 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base15_2.sas7bdat"; 
ANNEE=2015;
format ANNEE BEST12.;
run;

data base16 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base16_2.sas7bdat"; 
ANNEE=2016;
format ANNEE BEST12.;
run;

data base17 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base17_2.sas7bdat"; 
ANNEE=2017;
format ANNEE BEST12.;
run;

data base18 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base18_2.sas7bdat"; 
ANNEE=2018;
format ANNEE BEST12.;
run;

data base19 ; 
set "C:\Users\Public\Documents\Leroux_Mayans\Data\base19_2.sas7bdat"; 
ANNEE=2019;
format ANNEE BEST12.;
run;


proc contents data=base13;
run;
proc contents data=base14;
run;
proc contents data=base15;
run;
proc contents data=base16;
run;
proc contents data=base17;
run;
proc contents data=base18;
run;
proc contents data=base19;
run;


data base16_char;
set base16;
length SIREN_char $9;
SIREN_char = put(SIREN, z9.);
run;

data base16_char(rename=(SIREN_char=SIREN));
set base16_char;
drop SIREN;
run;


data base16;
set base16_char;
run;

data base19;
length APEN $5;
format APEN $5.;
informat APEN $5.;
set base19;
run;


proc sql;
	create table siren_communs as
	select SIREN from base13
	intersect 
	select SIREN from base14
	intersect 
	select SIREN from base15
	intersect 
	select SIREN from base16
	intersect 
	select SIREN from base17
	intersect 
	select SIREN from base18
	intersect 
	select SIREN from base19;
quit;


%macro filter_bases;
	%do i=13 %to 19;
		proc sql;
			create table base&i._filtree as
			select a.*
			from base&i a
			inner join siren_communs b on a.SIREN = b.SIREN;
		quit;
	%end;
%mend;
%filter_bases;





data base16_filtree;
	set base16_filtree;
	length treffect_char $2 treffen_char $2;
	treffect_char = put(treffect, z2.);
	treffen_char = put(treffen, z2.);
run;

data base16_filtree(rename=(
	treffect_char=treffect
	treffen_char=treffen
));
	set base16_filtree;
	drop treffect treffen;
run;

data base_finale;
	set
		base13_filtree
		base14_filtree
		base15_filtree
		base16_filtree
		base17_filtree
		base18_filtree
		base19_filtree;
run;



libname sauv "C:\Users\Public\Documents\Leroux_Mayans\Data";
data sauv.base_finale2_2;
set base_finale;
run;


PROC EXPORT data=base_finale
outfile= "C:\Users\Public\Documents\Leroux_Mayans\Data\base_finale2_2.csv"
dbms=csv
replace;
run;





























proc contents data=base13_filtree;
run;
proc contents data=base14_filtree;
run;
proc contents data=base15_filtree;
run;
proc contents data=base16_filtree;
run;
proc contents data=base17_filtree;
run;
proc contents data=base18_filtree;
run;
proc contents data=base19_filtree;
run;



















proc sql;
create table base_commune as
select base13.*
from base13
inner join base14 on base13.SIREN = base14.SIREN
inner join base15 on base13.SIREN = base15.SIREN
inner join base16 on base13.SIREN = base16.SIREN
inner join base17 on base13.SIREN = base17.SIREN
inner join base18 on base13.SIREN = base18.SIREN
inner join base19 on base13.SIREN = base19.SIREN;
quit; 


libname sauv "C:\Users\Public\Documents\Leroux_Mayans\Data";
data sauv.base_commune;
set base_commune;
run;


PROC EXPORT data=base_commune
outfile= "C:\Users\Public\Documents\Leroux_Mayans\Data\base_commune.csv"
dbms=csv
replace;
run;