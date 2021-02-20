****************************************************;
*** 			Simulation des données			 ***;
****************************************************;

* Taille de l'échantillon;
%let ssize = 500;

* Statistiques de Y, X: moyenne 'mu' et variance 'sigma';
%let mu = 5;
%let sigma = 1.5;

* Corrélation entre Y et X;
%let corr = .45;


* Simulation des relations entre les variables;
data sim;
		do id = 1 to &ssize;
			y = sqrt(&sigma)*rannor(id) + &mu;
			c = RAND('BERNOULLI',0.7);
			x = &corr*c + sqrt(&sigma)*sqrt(1-(&corr)**2)*rannor(id)*c + (1-&corr)*&mu/2;
			
	  	output;
	  	end;
run;

proc freq data=sim;
table c;
run;


****************************************************;
*** Création de mécanismes de données manquantes ***;
****************************************************;

* Proportion de données manquantes;
%let py = .4; 

* Simulation des mécanismes;
* y = vraies données;
* ymarx = MAR|x,z;
data sim;
  set sim;
  ymarx = y;
  cmarx = c;
   if uniform(2013) <= &py then ymarx =.;
   if x <= &mu*uniform(2013) then cmarx =.;
run;

* Observation des N, MOY et corrélations;
proc corr data=sim;
variable y x c ymarx cmarx;
run;


* Relation réelle;
proc logistic data=sim;
class c(ref='0');
model c=y x  / link=logit;
run;


* Relation observée;
proc logistic data=sim;
class cmarx(ref='0');
model cmarx=y x   / link=logit;
run;


*****************************************************************************************************************;
*** Imputation multiple  --  MAR;
*****************************************************************************************************************;

******;
*** MI multivariate normal;
proc mi data=sim out=midefault nimpute=100 seed=210311;
   mcmc chain=multiple initial=em;
   var y x cmarx ;
run;

* Proc logistic ne pourra pas exécuter le modèle logit
  puisque les valeurs imputées ne sont pas uniquement des
  0 et des 1;


******;
*** MI par FCS;
proc mi data=sim out=midefault nimpute=100 seed=210311;
   class cmarx;
   fcs logistic(cmarx= y );
   var y x cmarx ;
run;

proc logistic data=midefault;
class cmarx(ref='0');
model cmarx=y x / link=logit covb;
by _imputation_;
ods output ParameterEstimates=lgsparms CovB=lgscovb;
run;

proc mianalyze parms=lgsparms covb(effectvar=stacking)=lgscovb;
MODELEFFECTS intercept y x;
run;



******;
*** MI AVEC covariables associée à la missingness;
proc mi data=sim out=midefault nimpute=100 seed=210311;
   class cmarx;
   fcs logistic(cmarx);
   var y x cmarx ;
run;


proc logistic data=midefault;
class cmarx(ref='0');
model cmarx=y x  / link=logit covb;
by _imputation_;
ods output ParameterEstimates=lgsparms CovB=lgscovb;
run;


proc mianalyze parms=lgsparms covb(effectvar=stacking)=lgscovb;
MODELEFFECTS intercept y x;
run;
