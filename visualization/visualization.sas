proc import DATAFILE = 'C:\Users\xwj\Desktop\zhujiao\wine_data.csv' out = mydata;
run;

/* show the data */
proc print data = mydata(obs = 5);
run;

/* 1.1 column chart */
proc gchart data=mydata;
vbar quality;
run;


/* 1.2 Histogram */
proc univariate data=mydata;
histogram fixed_acidity;
run;


/* Histogram add kernel curve */
proc univariate data=mydata;
 histogram fixed_acidity
 /
 normal (
 mu = est
 sigma = est
 color = blue
 w = 2.5
 )
;
run;


/* 1.3 pie */
/* type = cpct means display ratio instead of frequency */
proc gchart data = mydata;
pie type / type=cpct;
run;


/* ------------------------------------------------*/

/* 2.1 scatter plot */
ODS LISTING GPATH = "'C:\Users\xwj\Desktop";
ODS GRAPHICS on / ANTIALIASMAX=6500;
proc sgscatter data = mydata  ;
plot fixed_acidity * volatile_acidity ;
run;
ODS GRAPHICS off;


/* 2.2  Grouped histogram  */
proc gchart data=mydata;
vbar quality/DISCRETE TYPE=PERCENT OUTSIDE=PERCENT AUTOREF WIDTH=6 GROUP=type PATTERNID=GROUP;
run;

proc gchart data=mydata;
hbar quality/DISCRETE TYPE=PERCENT OUTSIDE=PERCENT AUTOREF WIDTH=6 SUBGROUP=type PATTERNID=SUBGROUP;
run;


PROC gchart data=mydata;
vbar quality / DISCRETE TYPE=PERCENT OUTSIDE=PERCENT AUTOREF WIDTH=6 group = type subgroup = type;
RUN;

/* 2.4    */
proc sgplot data = mydata;
VBOX fixed_acidity   / category =quality;
run;


/* 2.5 */
proc sgscatter data = mydata;
compare y = volatile_acidity x = fixed_acidity /group = type;
run;


/* 2.6 */
proc sgpanel data = mydata;
panelby type;
vbox fixed_acidity /category = quality;
run;


/* 2.7 */
