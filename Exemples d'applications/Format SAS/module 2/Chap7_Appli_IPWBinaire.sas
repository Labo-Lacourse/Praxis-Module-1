****************************************************;
*** 			Simulation des données			 ***;
****************************************************;

* Taille de l'échantillon;
%let ssize = 500;

* Statistiques de Y, X et Z: moyenne 'mu' et variance 'sigma';
%let muY = 3;
%let sigmaY = 1.5;
%let muX = 2;
%let sigmaX = 1;
%let muZ = 0;
%let sigmaZ = 1;

* Corrélations entre Y, X et Z;
%let corrYX = .40;
%let corrYZ = .25;


* Simulation des relations entre les variables;
* 'rannor(0)' is a random normal variable using the system clock as a seed;
data sim;
		do id = 1 to &ssize;
			y = sqrt(&sigmaY)*rannor(0) + &muY;
			x = &corrYX*y + sqrt(&sigmaX)*sqrt(1-(&corrYX)**2)*rannor(0) + (1-&corrYX)*&muX;
			z = &corrYZ*y + sqrt(&sigmaZ)*sqrt(1-(&corrYZ)**2)*rannor(0) + (1-&corrYZ)*&muZ;
	  	output;
	  	end;
run;



****************************************************;
*** Création de mécanismes de données manquantes ***;
****************************************************;

* Simulation des mécanismes;
* y = vraies données;
* ymcar = MCAR;
* ymarx = MAR|x;
* ymnar = MNAR;
data sim;
  set sim;
  ymcar = y;
  ymarx = y;
  ymnar = y;
  if uniform(0) > 0.4 then ymcar =.;
  if x <= &muX and RAND('BERNOULLI',0.85)=1 then ymarx =.;
  if y <= &muY and RAND('BERNOULLI',0.85)=1 then ymnar =.;
run;


* Statistiques: N, MOY et Corrélations;
proc corr data=sim;
variable y ymcar ymarx ymnar x z;
run;


******************************************************;
**** Exploration visuelle des données manquantes  ****;
******************************************************;

symbol1 color=black
		value=dot
		height=1.2
		interpol=r
		line=1;
symbol2 color=black
		value=X
		height=1
		interpol=r
		line=2;
legend1 label=none
		value=('Estimation from Partial data' 'Estimation from Full data')
        position=(top center inside)
        mode=share;
proc gplot data=sim;
plot
ymcar*x
y*x /overlay legend=legend1;
plot
ymarx*x
y*x /overlay legend=legend1;
plot
ymnar*x 
y*x /overlay legend=legend1;;
run;
quit;




******************************************************;
*** Création des indicateurs de données manquantes ***;

data miss_pattern (drop=i);
  set sim;
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


* Fusionner les variables indicatrices de données manquantes avec les données;
* D'abord la macro pour ajouter le préfixe 'r' devant les variables indicatrices de valeurs manquantes; 
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
data sim; 
merge sim miss_pattern;
run;




***************;
***************;
***   IPW   ***;
***************;
***************;


proc sort data=sim; by rymarx; run;

proc means data=sim n min max mean;
by rymarx;
var x;
run;


*****************************************************************;
*** Régression logistique et output des probabilités prédites ***;
*****************************************************************;
proc sort data=sim; by rymarx; run;

proc logistic data=sim;
class rymnar(ref=first);
model rymnar= y x z / link=probit;
output out=logregmulti predprobs=i;
run;


********************************;
* Calculer la variable (w) contenant l'inverse de la probabilité d'être observé;
* 'IP_0' contient les probabilités qu'une donnée soit observée;
data simweight;
set logregmulti;
w=1/IP_0;
run;


proc sort data=simweight;
by rymarx;
run;
proc means data=simweight mean;
by rymarx;
var w;
output out=mean_weight mean=mw;
run;
* Merge the mean weights with the original dataset *;
data simweight;
	merge simweight mean_weight;
	by rymarx;
run;


/*
********************************;
* Dans le cas où certaines des covariables entrées dans la 
* régression logistique contenaient des valeurs manquantes.
* Donner le poids moyen aux individus qui avaient des valeurs manquantes sur
* les covariables inclues dans la rég. logistique ;
data simweight;
	set simweight;
	if w=. and (rymarx=0) then w=mw;
run;
*/

********************************;
* Calculer le poid standardisé dans une variable que l'on nomme 'wstd';
* Permet de corriger pour la possibilité de gros poids;
data simweight;
	set simweight;
	wstd = w/mw;
run;

********************************;
* Vérifier que la somme des poids est égale au N de chaque groupe,
* ET que la moyenne des poids par groupe soit égale à 1 ;
proc means data=simweight mean sum n;
	var wstd;
	by rymarx;
run;

proc univariate data=simweight;
histogram wstd;
var wstd;
run;

proc gplot data=simweight;
plot wstd*y;
run;
quit;


********************************;
* PROC MIXED sans données manquantes;
proc mixed data=simweight method=ml covtest;
model y= x /solution notest outpm=param outp=est;
title "Y: Analyse sans données manquantes";
run;


*** YMARX ***;
********************************;
* PROC MIXED SANS pondération;
proc mixed data=simweight method=ml covtest;
model ymarx= x /solution notest outpm=paramnowgt outp=est;
title "YMARX: Analyse non-pondérée";
run;

********************************;
* PROC MIXED AVEC pondération;
proc mixed data=simweight method=ml covtest;
model ymarx= x /solution notest outpm=paramwgt outp=est;
weight wstd;
title "YMARX: Analyse pondérée (IPW)";
run;


*** YMNAR ***;
********************************;
* PROC MIXED SANS pondération;
proc mixed data=simweight method=ml covtest;
model ymnar= x /solution notest outpm=paramnowgt outp=est;
title "YMNAR: Analyse non-pondérée";
run;

********************************;
* PROC MIXED AVEC pondération;
proc mixed data=simweight method=ml covtest;
model ymnar= x /solution notest outpm=paramwgt outp=est;
weight wstd;
title "YMNAR: Analyse pondérée (IPW)";
run;
