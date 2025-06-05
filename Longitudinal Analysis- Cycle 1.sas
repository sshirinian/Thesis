/**************************************************************
Name: Longitudinal Analysis (Linear Mixed Effects Models) 
Created by: Seda Shirinian
Purpose: Compute and analyze locus of control at Cycle 1
**************************************************************/
data analysis_ready_c1;
set analysis_ready;
where cohort =1;
run;

/* Step 1: Keep Only StudyID, centered_loc_avgscore, and Covariates */
data loc_avg_data;
    set analysis_ready_c1(keep=StudyID centered_loc_avgscore Centered_Age_at_LOC depression education gender visit_type health race);
    by StudyID;
    if first.StudyID;
run;

/* Step 2: Convert Data to Long Format */
data filtered_data_with_time;
    set analysis_ready_c1;
    if W1_Visit_Type = . then W1_Visit_Type = 0;
    if W2_Visit_Type = . then W2_Visit_Type = 0;
    if W3_Visit_Type = . then W3_Visit_Type = 0;
    if W4_Visit_Type = . then W4_Visit_Type = 0;

    keep StudyID Baseline_Age Time_W1 Time_W2 Time_W3 Time_W4 
         W1_Visit_Type W2_Visit_Type W3_Visit_Type W4_Visit_Type 
         W1_INTERVIEW_AGE W2_INTERVIEW_AGE W3_INTERVIEW_AGE W4_INTERVIEW_AGE
         W1_D_SENAS_EXEC_Z W2_D_SENAS_EXEC_Z W3_D_SENAS_EXEC_Z W4_D_SENAS_EXEC_Z
         W1_D_SENAS_VRMEM_Z W2_D_SENAS_VRMEM_Z W3_D_SENAS_VRMEM_Z W4_D_SENAS_VRMEM_Z;
run;

proc transpose data=filtered_data_with_time 
    out=long_data_time(drop=_LABEL_ rename=(COL1=Study_Time _NAME_=WAVEID_N));
    var Time_W1 Time_W2 Time_W3 Time_W4;
    by StudyID;
run;

data long_data_time;
    set long_data_time;
    wave = substr(WAVEID_N, 6);
run;

proc transpose data=filtered_data_with_time out=long_data(drop=_LABEL_ rename=(COL1=Interview_age _NAME_=WAVEID_N));
    var W1_INTERVIEW_AGE W2_INTERVIEW_AGE W3_INTERVIEW_AGE W4_INTERVIEW_AGE;
    by StudyID;
run;

data long_data;
    set long_data;
    wave = substr(WAVEID_N, 1, 2);
run;

proc transpose data=filtered_data_with_time out=long_data_1(drop=_LABEL_ rename=(COL1=SENAS_EXEC_z _NAME_=WAVEID_N));
    var W1_D_SENAS_EXEC_Z W2_D_SENAS_EXEC_Z W3_D_SENAS_EXEC_Z W4_D_SENAS_EXEC_Z;
    by StudyID;
run;

data long_data_1;
    set long_data_1;
    wave = substr(WAVEID_N, 1, 2);
run;

proc transpose data=filtered_data_with_time out=long_data_2(drop=_LABEL_ rename=(COL1=SENAS_VREM_z _NAME_=WAVEID_N));
    var W1_D_SENAS_VRMEM_Z W2_D_SENAS_VRMEM_Z W3_D_SENAS_VRMEM_Z W4_D_SENAS_VRMEM_Z;
    by StudyID;
run;

data long_data_2;
    set long_data_2;
    wave = substr(WAVEID_N, 1, 2);
run;

proc transpose data=filtered_data_with_time out=long_data_visit(drop=_LABEL_ rename=(COL1=Visit_Type _NAME_=WAVEID_N));
    var W1_Visit_Type W2_Visit_Type W3_Visit_Type W4_Visit_Type;
    by StudyID;
run;

data long_data_visit;
    set long_data_visit;
    wave = substr(WAVEID_N, 1, 2);
run;

/* Include Baseline Age */
data baseline_age_data;
    set analysis_ready_c1(keep=StudyID Baseline_Age);
run;

/* Include Covariates */
data covariates_data;
    set analysis_ready_c1(keep=StudyID Centered_Age_at_LOC depression education gender visit_type  health race);
run;

/* Step 4: Merge All Data */
data merged_long_data;
    merge 
        long_data 
        long_data_1 
        long_data_2 
        long_data_time 
        long_data_visit 
        loc_avg_data 
        baseline_age_data 
        covariates_data;
    by StudyID;

    /* First Visit Indicator */
    if first.StudyID then First_Visit = 1;
    else First_Visit = 0;
run;

/* Verify Inclusion of All Covariates */
proc contents data=merged_long_data;
    title "Variable List in merged_long_data";
run;

proc print data=merged_long_data(obs=10);
    var StudyID centered_loc_avgscore Study_Time SENAS_EXEC_z SENAS_VREM_z First_Visit Visit_Type Baseline_Age 
        Centered_Age_at_LOC depression education gender health race;
    title "First 10 Observations of merged_long_data";
run;


/* Step 6: Mixed Models */
/*model 1: executive function - unadjusted*/
proc mixed data = merged_long_data;
class StudyID Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_EXEC_z = centered_loc_avgscore  First_Visit Visit_Type Study_Time centered_loc_avgscore*Study_Time/s cl;
random int/type = un subject = StudyID;
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Executive Function";
run;

/*model 2: executive function - adjusted, stratify by race*/
%macro run_exec_by_race(race_value);
    proc mixed data=merged_long_data(where=(race="&race_value"));
        class StudyID 
              First_Visit (ref="0") 
              health (ref='Excellent') 
              visit_type (ref='In-Person') 
              gender (ref='Male');
        model SENAS_EXEC_z = centered_loc_avgscore First_Visit Visit_Type Study_Time 
                             centered_loc_avgscore*Study_Time 
                             gender health depression Centered_Age_at_LOC education  
                             gender*Study_Time health*Study_Time  
                             depression*Study_Time Centered_Age_at_LOC*Study_Time 
                             education*Study_Time / solution cl;
        random int / type=un subject=StudyID;
        title "Stratified Mixed Model: Executive Function – &race_value";
    run;
%mend;

%run_exec_by_race(Asian);
%run_exec_by_race(Black);
%run_exec_by_race(LatinX);
%run_exec_by_race(White);


/* Step 7: Mixed Models */
/*model 1: verbal memory  - unadjusted*/
proc mixed data = merged_long_data;
class StudyID Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_VREM_z = centered_loc_avgscore  First_Visit Visit_Type Study_Time centered_loc_avgscore*Study_Time/s cl;
random int/type = un subject = StudyID;
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Verbal Memory";
run;

/*model 2: verbal memory - adjusted, includes interaction terms with covariates*/
%macro run_exec_by_race(race_value);
    proc mixed data=merged_long_data(where=(race="&race_value"));
        class StudyID 
              First_Visit (ref="0") 
              health (ref='Excellent') 
              visit_type (ref='In-Person') 
              gender (ref='Male');
        model SENAS_EXEC_z  = centered_loc_avgscore First_Visit Visit_Type Study_Time 
                             centered_loc_avgscore*Study_Time 
                             gender health depression Centered_Age_at_LOC education  
                             gender*Study_Time health*Study_Time  
                             depression*Study_Time Centered_Age_at_LOC*Study_Time 
                             education*Study_Time / solution cl;
        random int / type=un subject=StudyID;
        title "Stratified Mixed Model: Executive Function – &race_value";
    run;
%mend;

%run_exec_by_race(Asian);
%run_exec_by_race(Black);
%run_exec_by_race(LatinX);
%run_exec_by_race(White);




/*Quintiles*/

data filtered_data_with_quintiles_c1;
    set analysis_ready_c1;
    if         centered_loc_avgscore  >= -0.98545 and centered_loc_avgscore  <= -0.78545 then loc_avgscore_quintile = 1;
    else if    centered_loc_avgscore  > -0.78545 and centered_loc_avgscore  <= -0.38545 then loc_avgscore_quintile = 2;
    else if    centered_loc_avgscore   > -0.38545 and centered_loc_avgscore  <= 0.21455 then loc_avgscore_quintile = 3;
    else if    centered_loc_avgscore   > 0.21455 and centered_loc_avgscore  <= 0.81455 then loc_avgscore_quintile = 4;
    else if centered_loc_avgscore > 0.81455  then loc_avgscore_quintile = 5;
    else loc_avgscore_quintile = .; 
run;

proc sort data=filtered_data_with_quintiles_c1(keep=StudyID loc_avgscore_quintile) 
          out=loc_quintiles_unique nodupkey;
    by StudyID;
run;

data merged_long_data;
    merge merged_long_data(in=a) loc_quintiles_unique(in=b);
    by StudyID;
run;

proc freq data=merged_long_data;
    tables loc_avgscore_quintile;
run;


/* Step 6: Mixed Models-quintiles */
/*model 1: executive function - unadjusted*/
proc mixed data = merged_long_data;
class StudyID loc_avgscore_quintile (ref="1") Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_EXEC_z = loc_avgscore_quintile First_Visit Visit_Type Study_Time loc_avgscore_quintile*Study_Time/s cl;
random int/type = un subject = StudyID;
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Executive Function";
run;

/*model 2: executive function - adjusted, includes interaction terms with covariates*/
proc mixed data = merged_long_data;
	class StudyID 
	      loc_avgscore_quintile (ref="1")
		  First_Visit (ref="0")
	      health (ref='Excellent') 
	      race (ref= 'White') 
	      visit_type (ref='In-Person') 
	      gender (ref='Male');
	      
	model SENAS_EXEC_z = loc_avgscore_quintile First_Visit Visit_Type Study_Time loc_avgscore_quintile*Study_Time 
						 gender race health depression Centered_Age_at_LOC education  
						 gender*Study_Time  race*Study_Time  health*Study_Time  
						 depression*Study_Time  Centered_Age_at_LOC*Study_Time education*Study_Time /s cl;
	random int/type = un subject = StudyID;
	title "Linear Mixed-Effects Model: Adjusted Analysis of LOC Predicting Executive Function";
run;



/*model 1: verbal memory  - unadjusted*/
proc mixed data = merged_long_data;
class loc_avgscore_quintile (ref="1") StudyID Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_VREM_z = loc_avgscore_quintile  First_Visit Visit_Type Study_Time loc_avgscore_quintile*Study_Time/s cl;
random int/type = un subject = StudyID;
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Verbal Memory";
run;

/*model 2: verbal memory - adjusted, includes interaction terms with covariates*/
proc mixed data = merged_long_data;
	class  loc_avgscore_quintile (ref="1")
			StudyID 
		    First_Visit (ref="0")
	        health (ref='Excellent') 
	        race (ref= 'White') 
	        visit_type (ref='In-Person') 
	        gender (ref='Male');
		  
   model SENAS_VREM_z =  loc_avgscore_quintile  First_Visit Visit_Type Study_Time loc_avgscore_quintile*Study_Time 
		  				 gender race health depression Centered_Age_at_LOC education  
		  				 gender*Study_Time  race*Study_Time  health*Study_Time  
		  				 depression*Study_Time  Centered_Age_at_LOC*Study_Time education*Study_Time 
		  				 /s cl;
   random int/type = un subject = StudyID;
   title "Linear Mixed-Effects Model: Adjusted LOC Predicting Verbal Memory";
run;




/* Step 6: Mixed Models- continuous LOC */
/*model 1: executive function - unadjusted*/
proc mixed data = merged_long_data;
class StudyID  Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_EXEC_z = centered_loc_avgscore First_Visit Visit_Type Study_Time  centered_loc_avgscore*Study_Time/s cl;
random int/type = un subject = StudyID; 
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Executive Function";
run;

/*model 2: executive function - adjusted, includes interaction terms with covariates*/
proc mixed data = merged_long_data;
	class StudyID 
		  First_Visit (ref="0")
	      health (ref='Excellent') 
	      race (ref= 'White') 
	      visit_type (ref='In-Person') 
	      gender (ref='Male');
	      
	model SENAS_EXEC_z = centered_loc_avgscore First_Visit Visit_Type Study_Time 
						 gender race health depression Centered_Age_at_LOC education  
						 gender*Study_Time  race*Study_Time  health*Study_Time  
						 depression*Study_Time  Centered_Age_at_LOC*Study_Time education*Study_Time centered_loc_avgscore*Study_Time/s cl;
	random int/type = un subject = StudyID;
	title "Linear Mixed-Effects Model: Adjusted Analysis of LOC Predicting Executive Function";
run;



/*model 1: verbal memory  - unadjusted*/
proc mixed data = merged_long_data;
class StudyID Visit_Type (ref="In-Person") First_Visit (ref="0");
model SENAS_VREM_z = centered_loc_avgscore  First_Visit Visit_Type Study_Time centered_loc_avgscore*Study_Time /s cl;
random int/type = un subject = StudyID;
title "Linear Mixed-Effects Model: Unadjusted Analysis of LOC Predicting Verbal Memory";
run;

/*model 2: verbal memory - adjusted, includes interaction terms with covariates*/
proc mixed data = merged_long_data;
	class  
			StudyID 
		    First_Visit (ref="0")
	        health (ref='Excellent') 
	        race (ref= 'White') 
	        visit_type (ref='In-Person') 
	        gender (ref='Male');
		  
   model SENAS_VREM_z =  centered_loc_avgscore  First_Visit Visit_Type Study_Time 
		  				 gender race health depression Centered_Age_at_LOC education  
		  				 gender*Study_Time  race*Study_Time  health*Study_Time  
		  				 depression*Study_Time  Centered_Age_at_LOC*Study_Time education*Study_Time centered_loc_avgscore*Study_Time
		  				 /s cl;
   random int/type = un subject = StudyID;
   title "Linear Mixed-Effects Model: Adjusted LOC Predicting Verbal Memory";
run;


