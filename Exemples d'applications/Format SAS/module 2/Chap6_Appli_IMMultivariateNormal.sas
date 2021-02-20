****************************************************;
*** 			Simulation des donn�es			 ***;
****************************************************;

* Taille de l'�chantillon;
%let ssize = 500;

* Statistiques de Y, X et Z: moyenne 'mu' et variance 'sigma';
%let mu = 5;
%let sigma = 1.5;

* Corr�lation entre Y et X;
%let corr = .45;
* Corr�lation entre X et Z;
%let corr2 = .30;


* Simulation des relations entre les variables;
data sim;
		do id = 1 to &ssize;
			y = sqrt(&sigma)*rannor(id) + &mu;
			x = &corr*y + sqrt(&sigma)*sqrt(1-(&corr)**2)*rannor(id) + (1-&corr)*&mu/2;
			z = &corr2*x + sqrt(&sigma)*sqrt(1-(&corr2)**2)*rannor(id) + (1-&corr2)*&mu;
	  	output;
	  	end;
run;




****************************************************;
*** Cr�ation de m�canismes de donn�es manquantes ***;
****************************************************;

* Simulation des m�canismes;
* y = vraies donn�es;
* ymarx = MAR|x;
data sim;
  set sim;
  ymarx = y;
   if x <= &mu*0.6 then ymarx =.;
run;


* Observation de la relation r�elle et celle MARx;
proc gplot data=sim;
plot y * z;
*plot ymarx * x;
plot ymarx * z;
run; 

* Observation des N, MOY et corr�lations;
proc corr data=sim;
*variable y ymarx x ;
variable y ymarx z ;
run;


*****************************************************************************************************************;
*** Imputation multiple  --  MAR;
*****************************************************************************************************************;

* Vraie relation;
proc mixed data=sim method=ml covtest;
model y= z  /solution notest covb;
run;

* Relation observ�e;
proc mixed data=sim method=ml covtest;
model ymarx= z  /solution notest covb;
run;



******;
*** MI SANS covariables associ�e � la missingness;
proc mi data=sim out=midefault nimpute=100 seed=210311;
mcmc chain=multiple initial=em;
var ymarx z ;
run;

* La commande "ods output" permet de sauvegarder les param�tres fixes (solutionf) avec sa matrice covariance (CovB)
* ainsi que les param�tres al�atoires (covparms);
proc mixed data=midefault method=ml covtest ;
model ymarx= z  /solution notest covb;
by _imputation_;
ods output solutionf=mioutparms CovB=mioutcovb covparms=mioutcovparms;
run;

* Commande MIANALYZE servant � combiner les effets fixes;
proc mianalyze parms=mioutparms covb(effectvar=rowcol)=mioutcovb;
MODELEFFECTS intercept z;
stderr intercept z;
run;


******;
*** MI AVEC covariables associ�e � la missingness;
proc mi data=sim out=midefault nimpute=100 seed=210311;
mcmc chain=multiple initial=em;
var ymarx x z;
run;

proc mixed data=midefault method=ml covtest;
model ymarx= z  /solution notest covb;
by _imputation_;
ods output solutionf=mioutparms CovB=mioutcovb covparms=mioutcovparms;
run;

proc mianalyze parms=mioutparms covb(effectvar=rowcol)=mioutcovb;
MODELEFFECTS intercept z;
stderr intercept z;
run;







******;
*** MI AVEC examen des cha�nes de Markov;
proc mi data=sim out=midefault nimpute=100 seed=210311;
mcmc chain=multiple initial=em plots=(trace acf);
var ymarx x z;
run;
