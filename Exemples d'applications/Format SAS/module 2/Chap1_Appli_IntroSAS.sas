*****************************;
**** Travailler avec SAS ****;
*****************************;


/*
Vous devrez modifier le chemin de la librairie et placer 
le dataset 'birthwt.sas7bdat' dans le répertoire Windows 
auquel la librairie fait référence pour que ces lignes fonctionnent
*/


*Créer une nouvelle librairie;
libname introsas "\\vmware-host\Shared Folders\Bureau\introsas" ;

*Faire afficher les 10 premières observations;
proc print data=introsas.birthwt (obs=10);
run;

*Créer un dataset contenant uniquement les variables "birthwt" et "age";
data introsas.birthwt_clean;
set introsas.birthwt;
keep birthwt age;
run;


*Faire afficher la distribution des données;
proc univariate data=introsas.birthwt_clean noprint;
var birthwt age;
histogram birthwt age;
run; 



*Faire afficher des statistiques descriptives;
proc means data=introsas.birthwt_clean n min max mean std;
var birthwt age;
run; 



*Exécuter une régression simple;
ods graphics on;
proc reg data=introsas.birthwt_clean;
model birthwt=age;
run;


