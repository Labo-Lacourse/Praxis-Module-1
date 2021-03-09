
********************;
**** MODÉRATION ****;

**** ENTRÉE DES DONNÉES POUR L'EXEMPLE ****;

data moderation;
	input ID	CONTRACE	ATTITUDE	pression;
	cards;
1	3	1	1
2	4	1	1
3	5	1	1
4	6	1	1
5	7	1	1
6	3	1	1
7	4	1	1
8	5	1	1
9	6	1	1
10	7	1	1
26	8	2	1
27	9	2	1
28	10	2	1
29	11	2	1
30	12	2	1
31	7	2	1
32	8	2	1
33	9	2	1
34	10	2	1
35	11	2	1
51	13	3	1
52	14	3	1
53	15	3	1
54	16	3	1
55	17	3	1
56	11	3	1
57	12	3	1
58	13	3	1
59	14	3	1
60	15	3	1
76	18	4	1
77	19	4	1
78	20	4	1
79	21	4	1
80	22	4	1
81	15	4	1
82	16	4	1
83	17	4	1
84	18	4	1
85	19	4	1
101	23	5	1
102	24	5	1
103	25	5	1
104	26	5	1
105	27	5	1
106	19	5	1
107	20	5	1
108	21	5	1
109	22	5	1
110	23	5	1
11	3	1	2
12	4	1	2
13	5	1	2
14	6	1	2
15	7	1	2
36	6	2	2
37	7	2	2
38	8	2	2
39	9	2	2
40	10	2	2
61	9	3	2
62	10	3	2
63	11	3	2
64	12	3	2
65	13	3	2
86	12	4	2
87	13	4	2
88	14	4	2
89	15	4	2
90	16	4	2
111	15	5	2
112	16	5	2
113	17	5	2
114	18	5	2
115	19	5	2
16	3	1	3
17	4	1	3
18	5	1	3
19	6	1	3
20	7	1	3
21	3	1	3
22	4	1	3
23	5	1	3
24	6	1	3
25	7	1	3
41	5	2	3
42	6	2	3
43	7	2	3
44	8	2	3
45	9	2	3
46	4	2	3
47	5	2	3
48	6	2	3
49	7	2	3
50	8	2	3
66	7	3	3
67	8	3	3
68	9	3	3
69	10	3	3
70	11	3	3
71	5	3	3
72	6	3	3
73	7	3	3
74	8	3	3
75	9	3	3
91	9	4	3
92	10	4	3
93	11	4	3
94	12	4	3
95	13	4	3
96	6	4	3
97	7	4	3
98	8	4	3
99	9	4	3
100	10	4	3
116	11	5	3
117	12	5	3
118	13	5	3
119	14	5	3
120	15	5	3
121	7	5	3
122	8	5	3
123	9	5	3
124	10	5	3
125	11	5	3
;
run;


*Centrer les VI continues;
*Trouver la moyenne;
proc means data=moderation n min max mean ;
var contrace attitude pression ;
run;

*Centrer la VI;
data moderation;
set moderation;
attitudec=attitude-3;
run;
proc means data=moderation n mean;
var attitudec;
run;


*Régression multiple SANS le terme d'interaction;
proc reg data=moderation;
model contrace=attitudec pression /details ;
output out=effetsprinc student=zresid p=pred;
run;


*Création du terme d'interaction;
data moderation;
set moderation;
att_pre=attitudec*pression;
run;


*Régression multiple AVEC le terme d'interaction;
proc reg data=moderation;
model contrace=attitudec pression att_pre /details ;
run;


*Graphique représentant l’effet de l’attitude sur la contraception;
proc sort data=moderation;
by pression;
run;
proc reg data=moderation;
model contrace=attitudec;
by pression;
output out=effetmoderation p=pred;
run;
proc gplot data=effetmoderation;
symbol1 c=black i=join v=none;
symbol2 c=black i=join v=dot;
symbol3 c=black i=join v=square;
plot pred*attitudec=pression;
run;


*Créer les variables modifiant la représentation du zéro de 
la VImod et les termes d'interactions associés;
data moderation;
set moderation;
pression1=pression-1;
pression2=pression-2;
pression3=pression-3;
att_pre1=attitudec*pression1;
att_pre2=attitudec*pression2;
att_pre3=attitudec*pression3;
run;


*Régression multiple pour chaque catégorie de la VImod;
proc reg data=moderation;
model contrace=attitudec pression1 att_pre1 /details ;
output out=pression1 student=zresid p=pred;
run;
proc reg data=moderation;
model contrace=attitudec pression2 att_pre2 /details ;
output out=pression2 student=zresid p=pred;
run;
proc reg data=moderation;
model contrace=attitudec pression3 att_pre3 /details ;
output out=pression3 student=zresid p=pred;
run;





