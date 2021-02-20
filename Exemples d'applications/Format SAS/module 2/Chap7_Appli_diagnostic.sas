/*
data test;
set "k:\...\xxx.sas7bdat";
run;
*/

/*
Les données suivantes serviront à illustrer quelques procédures pour décrire les données manquantes.
*/

data test;
input landval improval totval salepric saltoapr city $6. season $8.;
datalines;
   30000     64831     94831    118500   1.25  A    spring
   30000     50765     80765     93900    .         winter
   46651     18573     65224         .   1.16  B      
   45990     91402         .    184000   1.34  C    winter
   42394         .     40575    168000   1.43       
       .      3351     51102    169000   1.12  D    winter
   63596      2182     65778         .   1.26  E    spring
   56658     53806     10464    255000   1.21      
   51428     72451         .         .   1.18  F    spring
   93200         .      4321    422000   1.04      
   76125     78172     54297    290000   1.14  G    winter
       .     61934     16294    237000   1.10  H    spring
   65376     34458         .    286500   1.43       winter
   42400         .     57446         .    .    K    
   40800     92606     33406    168000   1.26  S    
;
run;



* 1. Visualiser le nombre de données valides et manquantes pour chaque variable;

* Variables numériques;
proc means data = test n nmiss ;
  var _numeric_;
run;


* Variables alphanumérique;
proc freq data = test;
  tables city season ;
run;



* 2. Créer une nouvelle variable avec le nombre de valeurs manquantes pour chaque observation;

data test;
  set test;
  miss_n = cmiss(of landval -- season);
run;

proc print data = test; 
run;



* 3. Visualiser les schémas et la distribution des valeurs manquantes;
* Cette procédure permet de regarder l'ensemble des schémas de données manquantes;
* Chaque variable est recodée en variable dichotomique [1=manquant, 0=observée];
* La procédure PROC FREQ permet de calculer la fréquence de chaque schéma de données manquantes;


data miss_pattern (drop=i);
  set test;
  array mynum(*) _numeric_;
  do i=1 to dim(mynum);
    if  mynum(i) =. then mynum{i}=1;
      else mynum(i)=0;
  end;
  array mychar(*) $ _character_;
  do i=1 to dim(mychar);
    if  mychar(i) ="" then mychar{i}=1;
      else mychar(i)=0;
  end;
run;
proc freq data=miss_pattern;
  tables landval*improval*totval*salepric*saltoapr*city*season /list;
run;


* Identifier la proportion de données manquantes pour chaque variables;
proc freq data=miss_pattern;
tables _all_;
run;


* Les schémas peuvent aussi être évalués avec la procédure MI;
* Cette procédure ne prend que des variables numériques;

proc mi data=test nimpute=0;
var _numeric_;
run;


* Si vous désirez créer une variable indicatrice d'un 
* regroupement de schémas;
* Vous pouvez utiliser différentes combinaisons de
* 'or' et 'and' pour identifier les schémas que vous
* voulez regrouper;

data test; set test;
if landval=. or improval=. or totval=. then schema=1;
else schema=0;
run;

proc sort data=test;
by schema;
run;


** MEANS **;
* Test univarié*;
proc means data=test mean;
class schema;
var salepric;
run;


******************************************************;
*** Faire le fichier pour évaluer les mécanismes   ***;
******************************************************;

* Fusionner les variables indicatrices de données manquantes avec les données;

* Macro pour ajouter le préfixe 'r' devant les variables indicatrices de valeurs manquantes; 
* C'est dans l'appel de la macro que l'on place les noms du dataset et du préfixe;
%macro vars(dsn,chr,out);                                                                                                               
 %let dsid=%sysfunc(open(&dsn));                                                                                                        
 %let num=%sysfunc(attrn(&dsid,nvars));                                                                                                 
  data &out;                                                                                                                            
   set &dsn(rename=(                                                                                                                    
    %do i = 1 %to &num;                                                                                                                 
     %let var&i=%sysfunc(varname(&dsid,&i));                                                                                            
       &&var&i=&chr&&var&i                                                                                                              
    %end;));                                                                                                                            
 %let rc=%sysfunc(close(&dsid));                                                                                                        
  run;                                                                                                                                  
%mend vars;

* Appel de la macro 'vars';
/** 1st parameter is the data set that contains all the variables.     **/
/** 2nd parameter are the characters used for the prefix.              **/
/** 3rd parameter is the new data set that contains the new variables. **/                  
                                                                            
%vars(miss_pattern,r,miss_pattern)


* L'étape de fusion;

data test; 
merge test miss_pattern;
run;



** TTESTs **;
* Tests bivariés*;
proc ttest data=test ci=equal umpu;
      class rlandval;
      var _numeric_;
run;


** LOGISTIQUE **;
* Tests multivariés : mieux! *;
proc logistic data=test;
class rlandval(ref=first);
model rlandval= improval salepric / link=glogit;
run;










********************************;
***  Simulation de données   ***;
********************************;


* Nombre d'échantillons et taille de chacun;
%let nsample = 100;
%let ssize = 100;

* Statistiques de Y, X et Z: moyenne 'mu' et variance 'sigma';
%let mu = 5;
%let sigma = 1.5;

* Corrélation entre Y et X;
%let corr = .45;
* Corrélation entre X et Z;
%let corr2 = .30;


* Simulation des relations entre les variables;
data manqsim;
	do sample = 1 to &nsample;
		do i = 1 to &ssize;
			y = sqrt(&sigma)*rannor(i) + &mu;
			x = &corr*y + sqrt(&sigma)*sqrt(1-(&corr)**2)*rannor(i) + (1-&corr)*&mu/2;
			z = &corr2*x + sqrt(&sigma)*sqrt(1-(&corr2)**2)*rannor(i) + (1-&corr2)*&mu;
	  	output;
	  	end;
	end;
run;


****************************************************;
*** Création de mécanismes de données manquantes ***;
****************************************************;

* Proportion de données manquantes;
%let py = .6; 

* Simulation des mécanismes;
* y = vraies données;
* ymcar = MCAR;
* ymarx = MAR|x;
* ymnar = MNAR;
data manqsim;
  set manqsim;
  ymcar = y;
  ymarx = y;
  ymnar = y;
  x2 = x;
  z2 = z;
  if uniform(20120531) < &py then ymcar=.;
  if x <= 4 then ymarx =.;
  if y <= &mu then ymnar =.;
  if x <= &mu then x2 = .;
  if x <= &mu+1 then z2 = .;
run;




************************;
***      Schéma      ***;
************************;

* Comparer les moyennes par schémas;






******* Identifier des variables associées à la missingness *******;
*****       Se fait à partir de la variable factice R         *****;
**** Suppose qu'il n'y a pas de manquantes sur les covariables ****;


** TTESTs **;
* Tests bivariés*;
proc ttest data=manqsim ci=equal umpu;
      class rymcar;
      var x z ;
run;


** LOGISTIQUE **;
* Tests multivariés : mieux! *;
proc logistic data=manqsim;
class rymcar(ref=first);
model rymcar= x z / link=glogit;
run;

proc logistic data=manqsim;
class rymarx(ref=first);
model rymarx= x z / link=glogit;
run;

proc logistic data=manqsim;
class rymnar(ref=first);
model rymnar= x z / link=glogit;
run;



********************************************************************************************;
***** Ci-bas quelques blocs de programmation qui peuvent être utiles dans d'autres contextes;


/*

** Créer un dataset contenant les moyennes de chaque variables par pattern;
** Ce dataset contient uniquement les différents patterns;

proc mi data=manqsim nimpute=0 out=result;
var   ymcar x z;
ods select misspattern;
ods output   MissPattern=misspattern;
run;


** On peut ensuite évaluer si certaines variables ont des moyennes différentes selon le schéma;
** S'il y a seulement deux schémas, cela devient redondant avec l'étape des régressions logistique;
** Mais ce n'est pas toujours le cas et cela peut permettre d'identifier des clusters qui ont potentiellement des mécanismes différents;


********************************;
* Créer une variable distinguant les individus avec données complètes (présent)
* de ceux avec au moins 1 temps de mesure manquant (absent), et ce par groupe (controle/intervention);
* Vous pouvez utiliser une autre variable au lieu de ry2 ici selon vos choix méthodologiques;
* Par exemple, ce pourrait être une variable nominale représentant le croisement du sexe et du schéma des données sont manquantes;
* Schéma à 3 catégories : (1-attrition, 2-de manière intermittente, 3-données complètes);
* Sexe à 2 catégories : (0-Homme, 1-Femme);
* Au lieu de faire une régression logistique binaire, il faudrait faire une rég. logistique multinomiale;

data manqsim1;
set manqsim1;
*Variable "nmissy" contenant le nombre de donnees manquantes pour une série de variable;
nmissy= nmiss(of y1, y2, y3, y4, y5); *pour des données longitudinales où on veux voir le nombre de manquant sur plusieurs variables;
run;

data manqsim1;
set manqsim1;
grppres = 9;
if nmissy=0 then grppres=1; * présent;
if nmissy>0 then grppres=0; * absent;
run;
*/


/*
**** Identifier les cas qui créent un pattern monotone ****;

data atrisk;
set atrisk;
monotone=0;
if x=. and z=. and y2=. then monotone=1;
if x~=. and z=. and y2=. then monotone=1;
if x~=. and z~=. and y2=. then monotone=1;
run;
*/

