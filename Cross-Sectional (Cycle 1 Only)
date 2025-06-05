/**************************************************************
Name: Cross-Sectional Analysis of CYCLE 1 
Created by: Seda Shirinian
Purpose: To examine the cross-sectional relationship between Locus of Control (LOC) 
         and cognitive function (Executive Function & Verbal Memory)
**************************************************************/

/**************************************************************
 Primary Associations
***************************************************************/
Title1 "KHANDLE Data - Cross-Sectional Analysis (February 2025)";
libname mylib "/home/u63767048/Thesis Data/Final Thesis Scripts"; 

data analysis_ready_c1;
set analysis_ready;
where cohort =1;
run;

proc tabulate data=analysis_ready_c1 missing format=8.2;
    class health  gender visit_type;
    var Centered_Age_at_LOC centered_loc_avgscore  depression 
        cognitive_exec cognitive_vrmem education;
    table 
        (Centered_Age_at_LOC centered_loc_avgscore  depression 
         cognitive_exec cognitive_vrmem education),
            (n mean std)*f=8.2;
    table 
        (health gender visit_type),
            (n colpctn);
    title "Table 1 - Sample Characteristics (Complete Cases Only, N=861)";
run;

/*Descriptive Statistics */
proc means data=analysis_ready_c1 mean std min max n nmiss;
    var     centered_loc_avgscore  cognitive_exec cognitive_vrmem;
    title "Descriptive Statistics: Locus of Control & Cognitive Function (Cross-Sectional, Complete Cases Only)";
run;

/*Correlation Analysis */
proc corr data=analysis_ready_c1 pearson spearman;
    var  centered_loc_avgscore  cognitive_exec cognitive_vrmem;
    title "Correlation Between Locus of Control and Cognitive Function";
run;

/*Scatter Plots with Regression Lines: Executive Functioning */
proc sgplot data=analysis_ready_c1;
    scatter x=centered_loc_avgscore  y=cognitive_exec / markerattrs=(symbol=circlefilled color=blue);
    reg x=centered_loc_avgscore  y=cognitive_exec / lineattrs=(color=red thickness=2);
    title "Scatter Plot: Locus of Control vs. Executive Function";
    xaxis label="Locus of Control";
    yaxis label="Executive Function";
run;

/* Scatter Plots with Regression Lines: Verbal Memory */
proc sgplot data=analysis_ready_c1;
    scatter x= centered_loc_avgscore  y= cognitive_vrmem / markerattrs=(symbol=circlefilled color=green);
    reg x= centered_loc_avgscore  y= cognitive_vrmem / lineattrs=(color=red thickness=2);
    title "Scatter Plot: Locus of Control vs. Verbal Memory";
    xaxis label="Locus of Control";
    yaxis label="Verbal Memory";
run;


/* LOC predicting Executive Function (Unadjusted) */
proc glm data=analysis_ready_c1;
    model cognitive_exec = centered_loc_avgscore  / solution clparm;
    title "LOC Predicting Executive Function (Unajusted)";
run;

proc reg data=analysis_ready_c1;
    model cognitive_exec = centered_loc_avgscore ;
    title "LOC Predicting Executive Function (Unajusted)";
run;



/* LOC predicting Executive Function (Adjusted) */
proc glm data=analysis_ready_c1;
    class health (ref='Excellent') race (ref= 'White') visit_type (ref='In-Person') gender (ref='Male');
    model cognitive_exec = centered_loc_avgscore  education Centered_Age_at_LOC depression    
    					   health race visit_type gender/ solution clparm;
    title "LOC Predicting Executive Function (Adjusted)";
run;


/* LOC predicting Verbal Memory (Unadjusted)*/
proc glm data=analysis_ready_c1;
    model cognitive_vrmem = centered_loc_avgscore  /solution clparm;
    title "Simple Linear Regression: LOC Predicting Verbal Memory (Unadjusted)";
run;

proc reg data=analysis_ready_c1;
    model cognitive_vrmem  = centered_loc_avgscore ;
    title "LOC Predicting Executive Function (Unajusted)";
run;

/* LOC predicting Verbal Memory (Adjusted) */
proc glm data=analysis_ready_c1;
    class health (ref='Excellent') race (ref='White') visit_type (ref='In-Person') gender (ref='Male');
    model cognitive_vrmem =  centered_loc_avgscore  Centered_Age_at_LOC depression education   
    					     health race visit_type gender/ solution clparm;
    title "LOC Predicting Verbal Memory (Adjusted)";
run;


/*Curves and Distributions*/
/* Loess Curves- Executive Function */
proc sgplot data=analysis_ready_c1;
    loess x=centered_loc_avgscore  y=cognitive_exec / smooth=0.5 clm;
    title "Loess Curve: Locus of Control Predicting Executive Function";
    xaxis label="Locus of Control Score";
    yaxis label="Executive Function Z-Scores";
run;

/* Loess Curves- Verbal Memory */
proc sgplot data=analysis_ready_c1;
    loess x=centered_loc_avgscore  y=cognitive_vrmem / smooth=0.5 clm;
    title "Loess Curve: Locus of Control Predicting Verbal Memory";
    xaxis label="Locus of Control Score";
    yaxis label="Verbal Memory Z-Scores";
run;

/*Distribution of LoC- Cycle 1*/
proc sgplot data=analysis_ready_c1;
    histogram loc_avgscore  / binwidth=0.5 scale=count;
    density loc_avgscore  / type=normal;
    xaxis label="Locus of Control Score" values=(0.5 to 6 by 0.5);
    yaxis label="Frequency";
    title "Distribution of Locus of Control for Cycle 1 (n=846)";
run;


/**************************************************************
***************************************************************
* Sensitivity Analysis: LOC quintiles - CYCLE 1*
***************************************************************
**************************************************************/
               
proc univariate data= analysis_ready_c1;
    var centered_loc_avgscore ;
    output out=quintile_cutoffs
        min = min_loc
        max = max_loc
        pctlpts = 20 40 60 80 100
        pctlpre = p;
run;

proc print data= quintile_cutoffs;
    title "Min, Max, and Quintile Cutoffs for centered_loc_avgscore ";
run;
proc means data=analysis_ready_c1 min max;
    var centered_loc_avgscore;
    title "Minimum and Maximum Values of centered_loc_avgscore";
run;

data filtered_data_with_quintiles_c1;
    set analysis_ready_c1;
    if         centered_loc_avgscore  >= -0.98545 and centered_loc_avgscore <= -0.78545 then loc_avgscore_quintile = 1;
    else if    centered_loc_avgscore  > -0.78545 and centered_loc_avgscore  <= -0.38545 then loc_avgscore_quintile = 2;
    else if    centered_loc_avgscore  > -0.38545 and centered_loc_avgscore <= 0.21455 then loc_avgscore_quintile = 3;
    else if    centered_loc_avgscore  > 0.21455 and centered_loc_avgscore <= 0.81455 then loc_avgscore_quintile = 4;
    else if    centered_loc_avgscore  > 0.81455 then loc_avgscore_quintile = 5;
    else       centered_loc_avgscore  = .;
run;

/* Visualizing Distribution of LOC Quintiles */
proc sgplot data=filtered_data_with_quintiles_c1;
    vbar loc_avgscore_quintile / datalabel;
    xaxis label="LOC Quintiles" values=(1 to 5 by 1);
    yaxis label="Frequency";
    title "Distribution of LOC Quintiles (Cycle 1)";
run;

proc univariate data=filtered_data_with_quintiles_c1;
    var  loc_avgscore_quintile;
    histogram  loc_avgscore_quintile / normal;
    inset mean std skewness kurtosis;
    title "Distribution and Skewness of centered_loc_avgscore ";
run;

/* Unadjusted Model – Executive Function */
proc glm data=filtered_data_with_quintiles_c1;
    class  loc_avgscore_quintile(ref='1');
    model cognitive_exec =  loc_avgscore_quintile / solution clparm;
    title "Executive Function by LoC Quintile (Cycle 1- Unadjusted Model)";
run;

/* Adjusted Model – Executive Function */
proc glm data=filtered_data_with_quintiles_c1;
    class loc_avgscore_quintile (ref='1') health (ref='Excellent') race (ref= 'White') visit_type (ref='In-Person') gender (ref='Male');
    model cognitive_exec = loc_avgscore_quintile education gender   
                           Centered_Age_at_LOC depression health visit_type/ solution clparm;
    title "Executive Function by LoC Quintile (Cycle 1 - Adjusted)";
run;

/* Unadjusted Model – Verbal Memory */
proc glm data=filtered_data_with_quintiles_c1;
    class loc_avgscore_quintile (ref='1');
    model cognitive_vrmem = loc_avgscore_quintile / solution clparm;
    title "Verbal Memory by LoC Quintile (Cycle 1- Unadjusted)";
run;

/* Adjusted Model – Verbal Memory */
proc glm data=filtered_data_with_quintiles_c1;
    class loc_avgscore_quintile (ref='1') health (ref='Excellent') race (ref= 'White') visit_type (ref='In-Person') gender(ref='Male');
    model cognitive_vrmem = loc_avgscore_quintile education gender   
                            Centered_Age_at_LOC depression health visit_type/ solution clparm;
    title "Verbal Memory by LoC Quintile (Cycle 1 - Adjusted)";
run;




/**************************************************************
***************************************************************
Race Interaction Analyses: Analysis of Race x LoC for CYCLE 1 Only
****************************************************************
*************************************************************/


Title1 "KHANDLE Data - Cross-Sectional Analysis: Cycle 1 Only (Wave 4)";
libname mylib "/home/u63767048/Thesis Data/Final Thesis Scripts"; 

/* Load Cycle 1 cleaned data */
data race_analysis_c1;
    set analysis_ready_c1;
run;

/* Confirm complete cases */
proc freq data=race_analysis_c1;
    tables complete_case;
    title "Complete Cases with LOC + Executive + Verbal Memory (Cycle 1)";
run;

/*Sort by race */
proc sort data=race_analysis_c1; 
    by race; 
run;


/*Adjusted Stratified Models with Race: Executive Memory */
%macro run_stratified_glm(racegroup);
    proc glm data=race_analysis_c1(where=(race="&racegroup"));
        class health (ref='Excellent') visit_type (ref='In-Person') gender (ref='Male');
        model cognitive_exec = centered_loc_avgscore Centered_Age_at_LOC 
                               education gender depression health visit_type / solution clparm;
        title "Stratified GLM: LOC Predicting Executive Function for &racegroup";
    run;
%mend;

%run_stratified_glm(White);
%run_stratified_glm(Asian);
%run_stratified_glm(Black);
%run_stratified_glm(LatinX);

/*Adjusted Stratified Models with Race: Verbal Memory */
%macro run_stratified_glm(racegroup);
    proc glm data=race_analysis_c1(where=(race="&racegroup"));
        class health (ref='Excellent') visit_type (ref='In-Person') gender (ref='Male');
        model cognitive_vrmem = centered_loc_avgscore Centered_Age_at_LOC 
                               education gender depression health visit_type / solution clparm;
        title "Stratified GLM: LOC Predicting Verbal Memory for &racegroup";
    run;
%mend;

%run_stratified_glm(White);
%run_stratified_glm(Asian);
%run_stratified_glm(Black);
%run_stratified_glm(LatinX);



