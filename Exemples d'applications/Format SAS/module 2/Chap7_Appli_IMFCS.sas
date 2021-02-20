****************************************************;
*** 			Simulation des donn�es			 ***;
****************************************************;

* Taille de l'�chantillon;
%let ssize = 500;

* Statistiques de Y, X: moyenne 'mu' et variance 'sigma';
%let mu = 5;
%let sigma = 1.5;

* Corr�lation entre Y et X;
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
*** Cr�ation de m�canismes de donn�es manquantes ***;
****************************************************;

* Proportion de donn�es manquantes;
%let py = .4; 

* Simulation des m�canismes;
* y = vraies donn�es;
* ymarx = MAR|x,z;
data sim;
  set sim;
  ymarx = y;
  cmarx = c;
   if uniform(2013) <= &py then ymarx =.;
   if x <= &mu*uniform(2013) then cmarx =.;
run;

* Observation des N, MOY et corr�lations;
proc corr data=sim;
variable y x c ymarx cmarx;
run;


* Relation r�elle;
proc logistic data=sim;
class c(ref='0');
model c=y x  / link=logit;
run;


* Relation observ�e;
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

* Proc logistic ne pourra pas ex�cuter le mod�le logit
  puisque les valeurs imput�es ne sont pas uniquement des
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
*** MI AVEC covariables associ�e � la missingness;
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
