**** ENTR�E DES DONN�ES POUR L'EXEMPLE ****;

data regsimplecat;
	input pays & $12.	region	calories;
	cards;
Afghanistan	 3	.
Argentine	 6	3113
Arm�nie	 5	.
Australie 	1	3216
Autriche 	1	3495
Azerba�djan 	5	.
Barhe�n	 5	.
Bangladesh 	3	2021
Barbados	 6	.
B�larussie	 2	.
Belgique	 1	.
Bolivie	 6	1916
Bosnie	 2	.
Botswana 	4	2375
Br�sil	 6	2751
Bulgarie 	2	.
Burkina Faso 	4	2288
Burundi	 4	1932
Cambodge 	3	2166
Cameroun	 4	2217
Canada 	1	3482
Afri. Cent. 	4	2036
Chili	 6	2581
Chine	 3	2639
Colombie 	6	2598
Costa Rica	 6	2808
Croatie	 2	.
Cuba	 6	.
R�p. Tch�que 	2	3632
Danemark	 1	3628
R�p. Dominic 	6	2359
Equateur	 6	2531
Egypte 	5	3336
Salvador 	6	2317
Estonie	 2	.
Ethiopie 	4	1667
Finlande 	1	3253
France	 1	3465
Gabon	 4	2383
Gambie	 4	.
G�orgie	 2	.
Allemagne 	1	3443
Gr�ce	 1	3825
Guatemala 	6	2235
Ha�ti	 6	2013
Honduras 	6	2247
Hong Kong 	3	.
Hongrie	 2	3644
Islande	 1	.
Inde	 3	2229
Indon�sie 	3	2750
Iran	 5	3181
Iraq	 5	2887
Irlande	 1	3778
Isra�l	 5	.
Italie	 1	3504
Japon	 3	2956
Jordanie 	5	2634
Kenya	 4	2163
Kowe�t	 5	3195
Lettonie 	2	.
Liban	 5	.
Lib�ria	 4	2382
Libya	 5	3324
Lithuanie 	2	.
Malaisie 	3	2774
Mexique	 6	3052
Maroc	 4	.
Cor�e du N. 	3	.
Pays-Bas	 1	3151
Nlle Z�lande 	1	3362
Nicaragua	 6	2265
Nig�ria	 4	2312
Norv�ge	 1	3326
Oman	 5	.
Pakistan 	3	.
Panama	 6	2539
Paraguay 	6	2757
P�rou	 6	2186
Philippines 	3	2375
Pologne	 2	.
Portugal 	1	.
Roumanie 	2	3155
Russie	 2	.
Rwanda	 4	1971
Cor�e du S. 	3	.
Arab. Saoud. 	5	2874
S�n�gal	 4	2369
Singapour 	3	3198
Somalie	 4	1906
Afr. du Sud 	4	.
Espagne	 1	3572
Su�de	 1	2960
Suisse	 1	3562
Syrie	 5	.
Taiwan	 3	.
Tanzanie 	4	2206
Tha�lande 	3	2316
Turquie	 5	3236
Em. Arab.U 	5	.
GB	 1	3149
EU	 1	3671
Uganda 	4	2153
Ukraine 	2	.
Uruguay	 6	2653
Uzbekistan 	5	.
V�n�zu�la	 6	2582
Vietnam	 3	2233
Zambie	 4	2077
;
run;




**********;
*Regression simple avec VI cat�goriell;
**********;

* Moyennes des variables continues � l'�tude;
proc means data=regsimplecat n min max mean std;
var calories;
run;

* Histogramme de la VD pour voir sa distribution;
proc univariate data=regsimplecat noprint;
var calories ;
histogram calories ;
run;

* Tableau de fr�quence des variables cat�gorielles;
* D�finition du nom des r�gions;
proc format;
value regionnames
1= "OCDE"
2= "Europe de l'est"
3= "Pacifique/Asie"
4= "Afrique"
5= "Moyen-Orient"
6= "Am�rique Latine"
;
run;
proc freq data=regsimplecat;
tables region;
format region regionnames.;
run;

* Cr�er les variables factices;
data regsimplecat; set regsimplecat;
	ocde=0;
	if region=1 then ocde=1;

	euroest=0;
	if region=2 then euroest=1;

	pacifasie=0;
	if region=3 then pacifasie=1;

	afrique=0;
	if region=4 then afrique=1;

	moyori=0;
	if region=5 then moyori=1;

	amlat=0;
	if region=6 then amlat=1;
run;

* Pour valider le recodage;
proc freq data=regsimplecat ;
tables region*ocde region*euroest region*pacifasie region*afrique region*moyori region*amlat /nocum nopercent norow nocol;
run;


* Analyse de r�gression;
proc reg data=regsimplecat;
model calories=euroest pacifasie afrique moyori amlat;
run;

