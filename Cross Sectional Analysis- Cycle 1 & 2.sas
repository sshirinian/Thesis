/**************************************************************
Name: Cross-Sectional Analysis - Locus of Control (Cycle 1 & 2) 
Created by: Seda Shirinian
Purpose: Compute and analyze locus of control at two cycles
**************************************************************/


/**************************************************************
***************************************************************
 					Primary Associations
 *************************************************************
***************************************************************/

Title1 "KHANDLE Data - Cross-Sectional Analysis (January 2025)";
libname mylib "/home/u63767048/Thesis Data/Final Thesis Scripts"; 

data analysis_ready_c1c2;
set analysis_ready;
run;

proc tabulate data=analysis_ready_c1c2 missing format=8.2;
    class health gender visit_type;
    var  Centered_Age_at_LOC centered_loc_avgscore cognitive_exec cognitive_vrmem depression education;
    table 
        (Centered_Age_at_LOC centered_loc_avgscore cognitive_exec cognitive_vrmem depression education ),
            (n mean std)*f=8.2;
    table 
        (health education gender visit_type),
            (n colpctn);
    title "Table 1 - Sample Characteristics (Cycle 1 & 2 Combined)";
run;

/*Scatter Plots with Regression Lines: Executive Functioning */
proc sgplot data=analysis_ready_c1c2;
    scatter x= centered_loc_avgscore  y=cognitive_exec / markerattrs=(symbol=circlefilled color=blue);
    reg x= centered_loc_avgscore  y=cognitive_exec / lineattrs=(color=red thickness=2);
    title "Scatter Plot: Locus of Control vs. Executive Function";
    xaxis label="Locus of Control (centered_loc_avgscore )";
    yaxis label="Executive Function (cognitive_exec)";
run;

/* Scatter Plots with Regression Lines: Verbal Memory */
proc sgplot data=analysis_ready_c1c2;
    scatter x= centered_loc_avgscore  y= cognitive_vrmem / markerattrs=(symbol=circlefilled color=green);
    reg x= centered_loc_avgscore  y= cognitive_vrmem / lineattrs=(color=red thickness=2);
    title "Scatter Plot: Locus of Control vs. Verbal Memory";
    xaxis label="Locus of Control (centered_loc_avgscore )";
    yaxis label="Verbal Memory (cognitive_vrmem)";
run;

/* LOC predicting Executive Function (Unadjusted) */
proc glm data=analysis_ready_c1c2;
    model cognitive_exec = centered_loc_avgscore   / solution clparm;
    title "Simple Linear Regression: LOC Predicting Executive Function (Unadjusted)";
run;

proc reg data=analysis_ready_c1c2;
    model cognitive_exec = centered_loc_avgscore ;
    title "Simple Linear Regression: LOC Predicting Executive Function (Unadjusted)";
run;

/* LOC predicting Verbal Memory (Unadjusted)*/
proc glm data=analysis_ready_c1c2;
    model cognitive_vrmem = centered_loc_avgscore  /solution clparm;
    title "Simple Linear Regression: LOC Predicting Verbal Memory (Unadjusted)";
run;

proc reg data=analysis_ready_c1c2;
    model cognitive_vrmem = centered_loc_avgscore  ;
    title "Simple Linear Regression: LOC Predicting Verbal Memory (Unadjusted)";
run;

/* LOC predicting Executive Function (Adjusted) */
proc glm data=analysis_ready_c1c2;
    class health (ref= 'Excellent') race (ref= 'White') visit_type (ref='In-Person') gender (ref='Male');
    model cognitive_exec = centered_loc_avgscore Centered_Age_at_LOC depression education  
    					   health race visit_type gender / solution clparm;
    title "LOC Predicting Executive Function (Adjusted)";
run;

/* LOC predicting Verbal Memory (Adjusted) */
proc glm data=analysis_ready_c1c2;
    class health (ref= 'Excellent') 
    	 race (ref= 'White') visit_type (ref='In-Person') gender (ref='Male');
    model cognitive_vrmem = centered_loc_avgscore  Centered_Age_at_LOC depression education  
    					    health race visit_type gender/ solution clparm;
    title "LOC Predicting Verbal Memory (Adjusted)";
run;

/*Curves and Distributions*/
/* Loess Curves - Executive Functioning*/
proc sgplot data=analysis_ready_c1c2;
    loess x=centered_loc_avgscore  y=cognitive_exec / smooth=0.5 clm;
    title "Loess Curve: Locus of Control Predicting Executive Function";
    xaxis label="Locus of Control Score";
    yaxis label="Executive Function (Z-Score)";
run;


/* Loess Curves - Verbal Memory*/
proc sgplot data=analysis_ready_c1c2;
    loess x=centered_loc_avgscore  y=cognitive_vrmem / smooth=0.5 clm;
    title "Loess Curve: Locus of Control Predicting Verbal Memory";
    xaxis label="Locus of Control Score";
    yaxis label="Verbal Memory (Z-Score)";
run;

/*Distribution of LoC - Cycle 1+2*/
proc sgplot data=analysis_ready_c1c2;
    histogram loc_avgscore  / binwidth=0.5 scale=count;
    density loc_avgscore  / type=normal;
    xaxis label="Locus of Control Score" values=(0.5 to 6 by 0.5);
    yaxis label="Frequency";
    title "Distribution of Locus of Control for Cycle 1 + 2 (N= 1305)";
run;

/*Distribution of LoC centered - Cycle 1+2*/
proc sgplot data=analysis_ready_c1c2;
    histogram centered_loc_avgscore  / binwidth=0.5 scale=count;
    density centered_loc_avgscore  / type=normal;
    xaxis label="Locus of Control Score" values=(-3 to 3 by 0.5);
    yaxis label="Frequency";
    title "Distribution of Locus of Control for Cycle 1 + 2 (N= 1305)";
run;

proc univariate data=analysis_ready_c1c2 noprint;
    var centered_loc_avgscore;
    output out=loc_percentiles
        pctlpts = 0 5 10 20  25 50 75 90 95 100
        pctlpre = P;
run;

proc print data=loc_percentiles;
    title "Percentiles of Centered Locus of Control Score (Cycle 1 + 2)";
run;


/*****************************************************************
******************************************************************
Race Interaction Analyses: Analysis of Race x LoC for CYCLE 1 + 2
******************************************************************
*****************************************************************/

Title1 "KHANDLE Data - Cross-Sectional Analysis (January 2025)";
libname mylib "/home/u63767048/Thesis Data/Final Thesis Scripts"; 

/*Load combined clean dataset */
data race_analysis_bothcycles;
    set analysis_ready;
    where complete_case = 1;
run;

/* Sort by race */
proc sort data=race_analysis_bothcycles; 
    by race; 
run;

/*Adjusted Interaction Models with Race: Executive Function */
proc glm data=race_analysis_bothcycles;
    class health (ref= 'Excellent') visit_type (ref='In-Person') gender (ref='Male') race (ref='White');
    model cognitive_exec = centered_loc_avgscore   Centered_Age_at_LOC 
                           education gender depression health visit_type race*centered_loc_avgscore / solution clparm;
    title "Stratified GLM: LOC Predicting Executive Function (By Race)- Cycle 1 & 2";
run;

/*Adjusted Interaction Models with Race: Verbal Memory */
proc glm data=race_analysis_bothcycles;
    class health (ref= 'Excellent') visit_type (ref='In-Person') gender (ref='Male') race (ref='White');
    model cognitive_vrmem = centered_loc_avgscore   Centered_Age_at_LOC 
                            education gender depression health visit_type  race*centered_loc_avgscore / solution clparm;
    title "Stratified GLM: LOC Predicting Verbal Memory (By Race)- Cycle 1 & 2";
run;

