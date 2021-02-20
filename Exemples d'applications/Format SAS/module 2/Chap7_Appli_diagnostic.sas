/*
data test;
set "k:\...\xxx.sas7bdat";
run;
*/

/*
Les donn�es suivantes serviront � illustrer quelques proc�dures pour d�crire les donn�es manquantes.
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



* 1. Visualiser le nombre de donn�es valides et manquantes pour chaque variable;

* Variables num�riques;
proc means data = test n nmiss ;
  var _numeric_;
run;


* Variables alphanum�rique;
proc freq data = test;
  tables city season ;
run;



* 2. Cr�er une nouvelle variable avec le nombre de valeurs manquantes pour chaque observation;

data test;
  set test;
  miss_n = cmiss(of landval -- season);
run;

proc print data = test; 
run;



* 3. Visualiser les sch�mas et la distribution des valeurs manquantes;
* Cette proc�dure permet de regarder l'ensemble des sch�mas de donn�es manquantes;
* Chaque variable est recod�e en variable dichotomique [1=manquant, 0=observ�e];
* La proc�dure PROC FREQ permet de calculer la fr�quence de chaque sch�ma de donn�es manquantes;


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


* Identifier la proportion de donn�es manquantes pour chaque variables;
proc freq data=miss_pattern;
tables _all_;
run;


* Les sch�mas peuvent aussi �tre �valu�s avec la proc�dure MI;
* Cette proc�dure ne prend que des variables num�riques;

proc mi data=test nimpute=0;
var _numeric_;
run;


* Si vous d�sirez cr�er une variable indicatrice d'un 
* regroupement de sch�mas;
* Vous pouvez utiliser diff�rentes combinaisons de
* 'or' et 'and' pour identifier les sch�mas que vous
* voulez regrouper;

data test; set test;
if landval=. or improval=. or totval=. then schema=1;
else schema=0;
run;

proc sort data=test;
by schema;
run;


** MEANS **;
* Test univari�*;
proc means data=test mean;
class schema;
var salepric;
run;


******************************************************;
*** Faire le fichier pour �valuer les m�canismes   ***;
******************************************************;

* Fusionner les variables indicatrices de donn�es manquantes avec les donn�es;

* Macro pour ajouter le pr�fixe 'r' devant les variables indicatrices de valeurs manquantes; 
* C'est dans l'appel de la macro que l'on place les noms du dataset et du pr�fixe;
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


* L'�tape de fusion;

data test; 
merge test miss_pattern;
run;



** TTESTs **;
* Tests bivari�s*;
proc ttest data=test ci=equal umpu;
      class rlandval;
      var _numeric_;
run;


** LOGISTIQUE **;
* Tests multivari�s : mieux! *;
proc logistic data=test;
class rlandval(ref=first);
model rlandval= improval salepric / link=glogit;
run;










********************************;
***  Simulation de donn�es   ***;
********************************;


* Nombre d'�chantillons et taille de chacun;
%let nsample = 100;
%let ssize = 100;

* Statistiques de Y, X et Z: moyenne 'mu' et variance 'sigma';
%let mu = 5;
%let sigma = 1.5;

* Corr�lation entre Y et X;
%let corr = .45;
* Corr�lation entre X et Z;
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
*** Cr�ation de m�canismes de donn�es manquantes ***;
****************************************************;

* Proportion de donn�es manquantes;
%let py = .6; 

* Simulation des m�canismes;
* y = vraies donn�es;
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
***      Sch�ma      ***;
************************;

* Comparer les moyennes par sch�mas;






******* Identifier des variables associ�es � la missingness *******;
*****       Se fait � partir de la variable factice R         *****;
**** Suppose qu'il n'y a pas de manquantes sur les covariables ****;


** TTESTs **;
* Tests bivari�s*;
proc ttest data=manqsim ci=equal umpu;
      class rymcar;
      var x z ;
run;


** LOGISTIQUE **;
* Tests multivari�s : mieux! *;
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
***** Ci-bas quelques blocs de programmation qui peuvent �tre utiles dans d'autres contextes;


/*

** Cr�er un dataset contenant les moyennes de chaque variables par pattern;
** Ce dataset contient uniquement les diff�rents patterns;

proc mi data=manqsim nimpute=0 out=result;
var   ymcar x z;
ods select misspattern;
ods output   MissPattern=misspattern;
run;


** On peut ensuite �valuer si certaines variables ont des moyennes diff�rentes selon le sch�ma;
** S'il y a seulement deux sch�mas, cela devient redondant avec l'�tape des r�gressions logistique;
** Mais ce n'est pas toujours le cas et cela peut permettre d'identifier des clusters qui ont potentiellement des m�canismes diff�rents;


********************************;
* Cr�er une variable distinguant les individus avec donn�es compl�tes (pr�sent)
* de ceux avec au moins 1 temps de mesure manquant (absent), et ce par groupe (controle/intervention);
* Vous pouvez utiliser une autre variable au lieu de ry2 ici selon vos choix m�thodologiques;
* Par exemple, ce pourrait �tre une variable nominale repr�sentant le croisement du sexe et du sch�ma des donn�es sont manquantes;
* Sch�ma � 3 cat�gories : (1-attrition, 2-de mani�re intermittente, 3-donn�es compl�tes);
* Sexe � 2 cat�gories : (0-Homme, 1-Femme);
* Au lieu de faire une r�gression logistique binaire, il faudrait faire une r�g. logistique multinomiale;

data manqsim1;
set manqsim1;
*Variable "nmissy" contenant le nombre de donnees manquantes pour une s�rie de variable;
nmissy= nmiss(of y1, y2, y3, y4, y5); *pour des donn�es longitudinales o� on veux voir le nombre de manquant sur plusieurs variables;
run;

data manqsim1;
set manqsim1;
grppres = 9;
if nmissy=0 then grppres=1; * pr�sent;
if nmissy>0 then grppres=0; * absent;
run;
*/


/*
**** Identifier les cas qui cr�ent un pattern monotone ****;

data atrisk;
set atrisk;
monotone=0;
if x=. and z=. and y2=. then monotone=1;
if x~=. and z=. and y2=. then monotone=1;
if x~=. and z~=. and y2=. then monotone=1;
run;
*/

