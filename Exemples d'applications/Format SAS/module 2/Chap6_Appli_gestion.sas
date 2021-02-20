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
Dans SAS, le point "." indique une valeur manquante dans toutes les proc�dures.
Par d�faut, toutes les proc�dures de SAS omettent les observations avec valeurs manquantes
et calculent les statistiques uniquement � partir des cas valides. 
Selon le type d'analyse, SAS utilisera g�n�ralement l'ensemble des cas complets (listwise deletion) 
lors d'analyses univari�es ou toutes les paires d'observations disponibles dans le cas des
analyses multivari�es. R�f�rez-vous au manuel de SAS pour les d�tails de chaque proc�dure.
*/

/*
Il est possible de distinguer diff�rents types de donn�es manquantes. Les lettres A-Z et
le trait de soulignement "_" peuvent �tre utilis�s � cette fin.
Dans l'exemple qui suit, la valeur -999 repr�sente que le participant a refus� de r�pondre
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


* Si on a plusieurs variables � recoder, il est plus rapide d'utiliser un ARRAY;
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
Les donn�es manquantes lors de la manipulation de variables.
*/

* Lors de la cr�ation d'une variable repr�sentant la moyenne de plusieurs variables;

DATA times2 ;
  SET times ;
  avg = (trial1 + trial2 + trial3) / 3 ;
RUN ;
 


/*
Dans l'exemple pr�c�dent, la variable 'avg' est calcul�e � partir de 'trial1', 'trial2' et 'trial3'.
Si une de ces variables est manquante, le r�sultat sotck� dans 'avg' sera manquant.
Regardez le r�sultat du PROC PRINT suivant
*/

PROC PRINT DATA=times2 ;
RUN ;  

/*
Une r�gle g�n�rale est que tous les calculs ex�cut�s sur une valeur manquante vont produire une valeur manquante.
Par exemple:

2 + 2 donnera 4
2 + . donnera .
2 / 2 donnera 1
. / 2 donnera .
2 * 3 donnera 6
2 * . donnera .

*/

/*
Une autre mani�re de proc�der est d'utiliser la fonction MEAN;
Cette fonction produit la moyenne de toutes les observations valides,
peu importe le nombre d'observations. Dans le cas o� une seule variable aurait une
valeur valide, la moyenne serait �gale � la valeur de cette variable.
*/

DATA times3 ;
  SET times ;
  avg = MEAN(trial1, trial2, trial3) ;
RUN ;
 
PROC PRINT DATA=times3 ;
RUN ;  

/*
S'il y a beaucoup de variables � int�grer dans le calcul de la moyenne, au lieu d'�crire:
avg = mean(trial1, trial2, trial3 .... trial50)
La fonction MEAN peut �tre �crite sous la forme:
avg = mean(of trial1-trial50)

Il y a d'autres fonction arythm�tiques du genre, comme SUM, MIN et MAX par exemple. 

Une autre astuce pratique est d'utiliser les fonctions N ou NMISS.
Elles calculent respectivement le nombre de valeurs valides ou manquantes
dans une liste de variables.

Ces fonctions peuvent �tre combin�es pour qu'une moyenne soit effectu�es
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

* Toutes les observations, sauf la 4, ont maintenant une moyenne de calcul�e;


 /*
Les donn�es manquantes lors de l'utilisation d'op�rateurs logiques.
 */

/*
SAS consid�re qu'une valeur manquante est la plus petite valeur possible (l'infini n�gatif).
Ceci a des cons�quences lors de l'utilisation des op�rateurs logiques.

Dans l'exemple suivant, nous d�sirons cr�er une variable dichotomique [0/1] selon
que la variable 'trial1' soit inf�rieure ou sup�rieure � 1,5.
*/

* La mani�re intuitive (et incorrecte s'il y a des valeurs manquantes) serait la suivante;

DATA times2 ;
  SET times ;
  if (trial1 <= 1.5) then trial1a = 0; else trial1a = 1 ;
RUN ;

proc print data=times2;
  var id trial1 trial1a;
run;

/*
Comme le PROC PRINT le montre, les observations 3 et 4 qui avaient des valeurs manquantes
se sont vues atribu�es la valeurs de 0. 
Il faut explicitement exclure les valeurs manquantes de la mani�re suivante.
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

* Maintenant les r�sultats sont coh�rents!!;

