/*
References

Introduction to SAS. UCLA: Academic Technology Services, Statistical Consulting Group. 
from http://www.ats.ucla.edu/stat/sas/modules/missing.htm (accessed March 15, 2011).

Introduction to SAS. UCLA: Academic Technology Services, Statistical Consulting Group.
from http://www.ats.ucla.edu/stat/sas/faq/nummiss_sas.htm (accessed March 15, 2011).

Introduction to SAS. UCLA: Academic Technology Services, Statistical Consulting Group. 
from http://www.ats.ucla.edu/stat/sas/faq/how_to_code_missing_differently.htm (accessed March 15, 2011).

*/

/*
Dans SAS, le point "." indique une valeur manquante dans toutes les procédures.
Par défaut, toutes les procédures de SAS omettent les observations avec valeurs manquantes
et calculent les statistiques uniquement à partir des cas valides. 
Selon le type d'analyse, SAS utilisera généralement l'ensemble des cas complets (listwise deletion) 
lors d'analyses univariées ou toutes les paires d'observations disponibles dans le cas des
analyses multivariées. Référez-vous au manuel de SAS pour les détails de chaque procédure.
*/

/*
Il est possible de distinguer différents types de données manquantes. Les lettres A-Z et
le trait de soulignement "_" peuvent être utilisés à cette fin.
Dans l'exemple qui suit, la valeur -999 représente que le participant a refusé de répondre
et -99 indique une erreur de saisie
*/

data test1;
  input score female ses ;
datalines;
56    1    1 
62    1    2 
73    0    3
67 -999    1
57    0    1
56  -99    2
57    1 -999
;
run;

* On peut recoder directement chacune des variables;
data test1a;
  set test1;
  if female = -999 then female=.a;
  if female = -99 then female = .b;
  if ses = -999 then ses = .a;
run;
proc print data = test1a;
run;


* Si on a plusieurs variables à recoder, il est plus rapide d'utiliser un ARRAY;
data test1b;
 set test1;
  array miss(2) female ses;
   do i = 1 to 2;
   if miss(i) = -999 then miss(i) =.a;
   if miss(i) = -99 then miss(i) =.b;  
  end;
drop i;
run;
proc print data = test1b;
run; 


/*
Les données manquantes lors de la manipulation de variables.
*/

* Lors de la création d'une variable représentant la moyenne de plusieurs variables;

DATA times2 ;
  SET times ;
  avg = (trial1 + trial2 + trial3) / 3 ;
RUN ;
 


/*
Dans l'exemple précédent, la variable 'avg' est calculée à partir de 'trial1', 'trial2' et 'trial3'.
Si une de ces variables est manquante, le résultat sotcké dans 'avg' sera manquant.
Regardez le résultat du PROC PRINT suivant
*/

PROC PRINT DATA=times2 ;
RUN ;  

/*
Une règle générale est que tous les calculs exécutés sur une valeur manquante vont produire une valeur manquante.
Par exemple:

2 + 2 donnera 4
2 + . donnera .
2 / 2 donnera 1
. / 2 donnera .
2 * 3 donnera 6
2 * . donnera .

*/

/*
Une autre manière de procéder est d'utiliser la fonction MEAN;
Cette fonction produit la moyenne de toutes les observations valides,
peu importe le nombre d'observations. Dans le cas où une seule variable aurait une
valeur valide, la moyenne serait égale à la valeur de cette variable.
*/

DATA times3 ;
  SET times ;
  avg = MEAN(trial1, trial2, trial3) ;
RUN ;
 
PROC PRINT DATA=times3 ;
RUN ;  

/*
S'il y a beaucoup de variables à intégrer dans le calcul de la moyenne, au lieu d'écrire:
avg = mean(trial1, trial2, trial3 .... trial50)
La fonction MEAN peut être écrite sous la forme:
avg = mean(of trial1-trial50)

Il y a d'autres fonction arythmétiques du genre, comme SUM, MIN et MAX par exemple. 

Une autre astuce pratique est d'utiliser les fonctions N ou NMISS.
Elles calculent respectivement le nombre de valeurs valides ou manquantes
dans une liste de variables.

Ces fonctions peuvent être combinées pour qu'une moyenne soit effectuées
uniquement pour les cas qui ont un certain nombre de valeurs valides.
L'exemple suivnt illustre cette situation.
*/

DATA times4 ;
  SET times ;
  n = N(trial1, trial2, trial3) ;
RUN ;
 
PROC PRINT DATA=times4 ;
RUN ;  

* Le PROC PRINT montre que l'observation 4 n'a qu'ue seule valeur valide;
* La combinaison des fonctions N et MEAN permettre de calculer la moyenne;
* uniquement pour las observations qui contiennent au moins 2 valeurs valides;

DATA times5 ;
  SET times ;
  n = N(trial1, trial2, trial3) ;
  IF n >= 2 THEN avg = MEAN(trial1, trial2, trial3) ;
  IF n <= 1 THEN avg=. ; 
RUN ; 

PROC PRINT DATA=times5 ; 
RUN ;

* Toutes les observations, sauf la 4, ont maintenant une moyenne de calculée;


 /*
Les données manquantes lors de l'utilisation d'opérateurs logiques.
 */

/*
SAS considère qu'une valeur manquante est la plus petite valeur possible (l'infini négatif).
Ceci a des conséquences lors de l'utilisation des opérateurs logiques.

Dans l'exemple suivant, nous désirons créer une variable dichotomique [0/1] selon
que la variable 'trial1' soit inférieure ou supérieure à 1,5.
*/

* La manière intuitive (et incorrecte s'il y a des valeurs manquantes) serait la suivante;

DATA times2 ;
  SET times ;
  if (trial1 <= 1.5) then trial1a = 0; else trial1a = 1 ;
RUN ;

proc print data=times2;
  var id trial1 trial1a;
run;

/*
Comme le PROC PRINT le montre, les observations 3 et 4 qui avaient des valeurs manquantes
se sont vues atribuées la valeurs de 0. 
Il faut explicitement exclure les valeurs manquantes de la manière suivante.
*/

DATA times2 ;
  SET times ;
  trial1a = .;
  if (trial1 <= 1.5) and (trial1 > .) then trial1a = 0;
  if (trial1 > 1.5) then trial1a = 1 ;
RUN ;

proc print data=times2;
  var id trial1 trial1a;
run;

* Maintenant les résultats sont cohérents!!;

