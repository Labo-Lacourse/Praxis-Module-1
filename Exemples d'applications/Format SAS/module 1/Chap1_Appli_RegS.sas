**** ENTR�E DES DONN�ES POUR L'EXEMPLE ****;
data regsimple;
	input st	state & $20.	region4	scs134	scs155	crc402	jbs170	pvs501	dms451	scs142	hts384	dms439;
	cards;
1	ALABAMA	 3	12.6	1.9	5662.3	5	20.1	25.56	4295	9.4	60.4
2	ALASKA	 4	9.6	3.1	6921.2	15.2	7.1	4.3	8353	3.3	67.5
3	ARIZONA	 4	14.3	2	8703.6	5.2	16.1	3.46	4012	10.6	87.5
4	ARKANSAS	 3	10.9	2.1	6178.1	5.2	14.9	15.86	4086	6.2	53.5
5	CALIFORNIA	 4	14.3	1.9	5877.7	6.9	16.7	7.64	4878	21.5	92.6
6	COLORADO	 4	9.6	2.6	5677.9	3.7	8.8	4.38	5086	10.5	82.4
7	CONNECTICUT	 1	9.2	4.2	4662.8	5.1	9.7	9.16	8270	17.2	79.1
8	DELAWARE	 3	11.2	1.8	5379.1	5.4	10.3	18.27	6944	19.4	73
9	DISTRICT OF COLUMBIA 	3	19.1	3.1	12173.5	7.3	22.2	63.54	6767	116.8	100
10	FLORIDA	 3	14.2	1.6	7920.5	4.9	16.2	14.67	5355	29.8	84.8
11	GEORGIA	 3	14.1	1.9	6819.3	4.5	12.1	28.04	5069	20.4	63.2
12	HAWAII	 4	7	2.3	7576	6	10.3	2.44	5831	11	89
13	IDAHO	 4	9.6	3.3	5496.3	5	14.5	0.52	4237	2.7	57.4
14	ILLINOIS	 2	10.4	3.4		. 5	12.4	15.33	4991	12	84.6
15	INDIANA	 2	11.4	3.7	5241.4	3.6	9.6	8.12	5719	5.5	64.9
16	IOWA	 2	6.5	3.9	5354.4	3.4	12.2	1.97	5407	2.9	60.6
17	KANSAS	 2	8.4	4.3		. 4	10.8	6.16	5296	4.2	69.1
18	KENTUCKY	 3	13	1.9	4485.7	5	14.7	7.1	5414	4.9	51.8
19	LOUISIANA	 3	11.9	2.2	7471.6	6.1	19.7	31.83	4537	14.9	68.1
20	MAINE	 1	8.4	4.9	3888.1	4.2	11.2	0.4	6116	5.9	44.6
21	MARYLAND	 3	11	2.7	6500.7	4.4	10.1	26.72	6407	24.2	81.3
22	MASSACHUSETTS	 1	9.5	4.7	4348.8	3.9	11	6.14	6832	15.6	84.3
23	MICHIGAN	 2	9.9	2.5	5516.5	4.7	12.2	14.44	6565	8	70.5
24	MINNESOTA	 2	6.1	2.8	5031.7	3.7	9.2	2.75	5689	5.6	69.9
25	MISSISSIPPI	 3	11.7	2	6629.3	5.5	23.5	35.89	3912	10.1	47.1
26	MISSOURI	 2	11.2	3.9	6249.2	4.5	9.4	11.06	4629	8.6	68.7
27	MONTANA	 4	7.1	3	.	4.6	15.3	0.34	5300	3	52.5
28	NEBRASKA 	2	6.6	3.8	5601.4	2.7	9.6	3.91	5190	5.1	66.1
29	NEVADA	 4	14.9	2	6993.9	5	11.1	7.12	4709	15.3	88.3
30	NEW HAMPSHIRE 	1	9.9	4.6	2955.1	3.9	5.3	0.7	5999	3.8	51
31	NEW JERSEY	 1	9.3	3.8	4703.7	6.2	7.8	14.49	9318	29.5	89.4
32	NEW MEXICO	 4	10.8	3.1	7144.3	7.1	25.3	2.43	5089	8.3	73
33	NEW YORK	 1	10.1	3.8	4674.6	6	16.5	17.6	8700	44.5	84.3
34	NORTH CAROLINA 	3	13.2	2	6513.4	4	12.6	22.21	4809	13.8	50.4
35	NORTH DAKOTA	 2	4.3	3.5	3879	2.7	12	0.47	4534	.	53.3
36	OHIO	 2	8.8	3.6	4795.1	5	11.5	11.21	5295	7.1	74.1
37	OKLAHOMA 	3	9.9	2.2	6514.9	4.3	17.1	7.84	4175	7.9	67.7
38	OREGON	 4	11	2.4	7230.2	5.5	11.2	1.78	5844	9.8	70.5
39	PENNSYLVANIA 	1	9.4	2.1	3533.4	4.7	12.2	9.68	6744	10.7	68.9
40	RHODE ISLAND 	1	12.9	4	4241.3	4.9	10.6	4.85	7091	11.5	86
41	SOUTH CAROLINA 	3	11.9	1.7	6605.1	6.1	19.9	30.03	4697	14.3	54.6
42	SOUTH DAKOTA 	2	7.1	4.2	4556.7	2.9	14.5	0.41	4773	.	50
43	TENNESSEE	 3	13.6	1.6	6293.5	5.1	15.5	16.23	4386	8.8	60.9
44	TEXAS	 3	12.5	2	6034.9	5.5	17.4	12.24	5168	14.9	80.3
45	UTAH	 4	7.9	2.5	6505.7	3	8.4	0.92	3670	4.2	87
46	VERMONT	 1	8.7	4.8	4666.9	4.5	10.3	0.34	6505	6.2	32.2
47	VIRGINIA 	3	10.4	2.5	4458.8	4	10.2	19.61	5490	11.1	69.4
48	WASHINGTON	 4	10.2	2.7	6573.6	5.8	12.5	3.31	5708	11.3	76.4
49	WEST VIRGINIA	 3	10.6	2.4	3332.5	7.2	16.7	3.12	6391	3.3	36.1
50	WISCONSIN	 2	6.9	3.2	4399.8	3.1	8.5	5.52	6457	4	65.7
51	WYOMING	 4	6.3	4.9	5062.6	4.6	12.2	0.63	5720	.	65
	;
run;


**********;
*Regression simple avec VI continue;
**********;

* Moyennes des variables � l'�tude;
proc means data=regsimple n min max mean std;
var scs134 jbs170;
run;

* Histogrammes des variables � l'�tude pour voir leur distribution;
proc univariate data=regsimple noprint;
var scs134 jbs170;
histogram scs134 jbs170;
run;

* Graphique de dispersion: proc�dure classique sans options;
proc gplot data=regsimple;
plot jbs170*scs134/ noframe;
run;

* Analyse de r�gression;
ods graphics on /imagefmt=staticmap;
proc reg data=regsimple;
model jbs170=scs134 /stb r; run;
ods graphics off;


* Cr�er un fichier de donn�es sans l'Alaska;
data regsimple_filtre;
set regsimple;
if st~="2";
run;

**********;

ods graphics on;
proc reg data=regsimple_filtre;
model jbs170=scs134 /stb r; 
run;
ods graphics off;


**********;
*Identification de valeurs aberrantes;
**********;

ods trace on;
proc reg data=regsimple;
model jbs170=scs134 / stb r;
output out=regsimpleresid student=zresid;
run;
quit;
ods trace off;

proc means data=regsimpleresid min max;
var zresid;
run;

data regsimpleresid_outliers;
set regsimpleresid;
if (zresid>3 or zresid<-3);
run;

FILENAME REFFILE '/folders/myshortcuts/SASUniversityEdition/regsimple.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT replace;
	GETNAMES=YES;
RUN;

    proc export data=regsimple
    outfile='/folders/myshortcuts/SASUniversityEdition/Exercices/Chap1_Appli_RegS.csv'  
    dbms=csv;
    run;
    
     proc export data=regsimple
    outfile='/folders/myshortcuts/SASUniversityEdition/Exercices/Chap1_Appli_RegS.sas7bdat'  
    dbms=sas7bdat;
    run;