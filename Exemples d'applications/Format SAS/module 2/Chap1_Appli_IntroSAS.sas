*****************************;
**** Travailler avec SAS ****;
*****************************;


/*
Vous devrez modifier le chemin de la librairie et placer 
le dataset 'birthwt.sas7bdat' dans le r�pertoire Windows 
auquel la librairie fait r�f�rence pour que ces lignes fonctionnent
*/


*Cr�er une nouvelle librairie;
libname introsas "\\vmware-host\Shared Folders\Bureau\introsas" ;

*Faire afficher les 10 premi�res observations;
proc print data=introsas.birthwt (obs=10);
run;

*Cr�er un dataset contenant uniquement les variables "birthwt" et "age";
data introsas.birthwt_clean;
set introsas.birthwt;
keep birthwt age;
run;


*Faire afficher la distribution des donn�es;
proc univariate data=introsas.birthwt_clean noprint;
var birthwt age;
histogram birthwt age;
run; 



*Faire afficher des statistiques descriptives;
proc means data=introsas.birthwt_clean n min max mean std;
var birthwt age;
run; 



*Ex�cuter une r�gression simple;
ods graphics on;
proc reg data=introsas.birthwt_clean;
model birthwt=age;
run;


