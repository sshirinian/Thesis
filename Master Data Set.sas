/* Creating dataset for KHANDLE analysis */
libname mylib "/home/u63767048/Thesis Data/Final Thesis Scripts";

/* Load Raw Data */
data master_raw;
    set mylib.khandle_all_waves_20250110;
run;

/* Clean Data and Drop Specific Values for Gender */
data master_clean;
    set master_raw;

    /* Drop observations with missing gender, 77, or 88 */
    if W1_D_GENDER in (., 77, 88) then delete;

    /* Drop observations in Cohort 1 with missing age data */
    if cohort = 1 and (missing(W1_INTERVIEW_AGE) or missing(W2_INTERVIEW_AGE) or 
                       missing(W3_INTERVIEW_AGE) or missing(W4_INTERVIEW_AGE)) then delete;
                       
    /* Clean numeric variables */
    array num_vars[*] 
        W1_SQX_LOC_HLPLSS W1_SQX_LOC_DTR W1_SQX_LOC_LFE W1_SQX_LOC_CNTRL W1_SQX_LOC_SLV
        W4_SQX_LOC_HLPLSS W4_SQX_LOC_DTR W4_SQX_LOC_LFE W4_SQX_LOC_CNTRL W4_SQX_LOC_SLV
        W1_D_SENAS_EXEC_Z W2_D_SENAS_EXEC_Z W3_D_SENAS_EXEC_Z W4_D_SENAS_EXEC_Z
        W1_D_SENAS_VRMEM_Z W2_D_SENAS_VRMEM_Z W3_D_SENAS_VRMEM_Z W4_D_SENAS_VRMEM_Z
        W1_INTERVIEW_AGE W2_INTERVIEW_AGE W3_INTERVIEW_AGE W4_INTERVIEW_AGE
        W1_HEALTH W4_HEALTH 
        W1_NIHTLBX_DEPR_THETA W4_NIHTLBX_DEPR_THETA
        W1_D_GENDER;

    do i = 1 to dim(num_vars);
        if num_vars[i] in (7, 77, 88, 99) then num_vars[i] = .;
    end;

    /* Clean character variables */
    array char_vars[*] $ W1_D_RACE_SUMMARY StudyID;

    do j = 1 to dim(char_vars);
        if char_vars[j] in ("7", "77", "88", "99") then char_vars[j] = "";
    end;

    /* Recode gender variable */
    if W1_D_GENDER = "I" then W1_D_GENDER = .;
    else if W1_D_GENDER = 1 then W1_D_GENDER = 0;  /* Recode 1 to 0 for Male */
    else if W1_D_GENDER = 2 then W1_D_GENDER = 1;  /* Recode 2 to 1 for Female */

	/* Recode Education as Numeric */
	length education 8;

	if 0 <= W1_EDU_EDUCATION_TEXT <= 12 then education = W1_EDU_EDUCATION_TEXT; 
	else if W1_EDU_EDUCATION = 1 then education = 13; 
	else if W1_EDU_EDUCATION = 2 then education = 14; 
	else if W1_EDU_EDUCATION = 3 then education = 16; 
	else if W1_EDU_EDUCATION = 4 then education = 18; 
	else if W1_EDU_EDUCATION = 5 then education = 20;  

	/* Catching missings from self-report by filling in with new education variable */
	if (W1_EDU_EDUCATION = 99 or W1_EDU_EDUCATION = 88) and W1_EDU_GED = 2 then education = 12; 
	if W1_EDU_EDUCATION = 0 and W1_EDU_TRNCERT = 2 and W1_EDU_LONGCERT = 4 then education = education + 1;  

    drop i j;
run;
	
/* Verify the gender variable recoding and cohort-based deletion */
proc freq data=master_clean;
    tables cohort * W1_D_GENDER / missing;
    title "Frequency of Recoded Gender Variable (After Cohort 1 Age Deletion)";
run;

proc freq data=master_clean;
    tables education/ missing;
    title "Frequency of Education Years";
run;


/* Create Time Variables */
data master_with_times;
    set master_clean;
    Time_W1W4 = W4_INTERVIEW_AGE - W1_INTERVIEW_AGE;
    Time_W2W4 = W4_INTERVIEW_AGE - W2_INTERVIEW_AGE;
    Time_W3W4 = W4_INTERVIEW_AGE - W3_INTERVIEW_AGE;

    Time_W1W2 = W2_INTERVIEW_AGE - W1_INTERVIEW_AGE;
    Time_W2W3 = W3_INTERVIEW_AGE - W2_INTERVIEW_AGE;
    Time_W1W3 = W3_INTERVIEW_AGE - W1_INTERVIEW_AGE;
run;

proc means data=master_with_times noprint;
    var Time_W1W4 Time_W2W4 Time_W3W4 Time_W1W2 Time_W2W3 Time_W1W3;
    output out=median_times 
        median=med_t1t4 med_t2t4 med_t3t4 med_t1t2 med_t2t3 med_t1t3;
run;

/*format variables*/
proc format;
    value orient_fmt
        1 = "Heterosexual"
        2 = "Homosexual"
        3 = "Bisexual"
        4 = "Other";

    value health_fmt
        1 = "Excellent"
        2 = "Very Good"
        3 = "Good"
        4 = "Fair"
        5 = "Poor";

    value visit_fmt
        0 = "In-Person"
        1 = "Phone";
    
    value gender_fmt
        0 = "Male"
        1 = "Female";
        
    label 
        gender = "Gender"
        health = "Health"
        education = "Education"
        visit_type = "Visit Type";
run;

/*Merge Median Times */
data master_final;
    if _n_ = 1 then set median_times;
    set master_clean;

    format education education_fmt.
           health health_fmt.
           visit_type visit_fmt.
           gender gender_fmt.;
           
    /* Impute topcoded age values */
    if W1_INTERVIEW_AGE >= 89.99 then W1_INTERVIEW_AGE = 90;

    if W2_INTERVIEW_AGE >= 89.99 and not missing(W2_INTERVIEW_AGE) then do;
        W2_INTERVIEW_AGE = W1_INTERVIEW_AGE + med_t1t2;
    end;

    if W3_INTERVIEW_AGE >= 89.99 and not missing(W3_INTERVIEW_AGE) then do;
		if not missing(W2_INTERVIEW_AGE) then W3_INTERVIEW_AGE = W2_INTERVIEW_AGE + med_t2t3;
		else if missing(W2_INTERVIEW_AGE) and not missing(W1_INTERVIEW_AGE) then W3_INTERVIEW_AGE = W1_INTERVIEW_AGE + medt1t3;
		else if missing(W1_INTERVIEW_AGE) and missing(W2_INTERVIEW_AGE) then W3_INTERVIEW_AGE = 90;
	end;

    if W4_INTERVIEW_AGE >= 89.99 and not missing(W4_INTERVIEW_AGE) then do;
        if not missing(W3_INTERVIEW_AGE) then W4_INTERVIEW_AGE = W3_INTERVIEW_AGE + med_t3t4;
        else if missing(W2_INTERVIEW_AGE) and missing(W3_INTERVIEW_AGE) then W4_INTERVIEW_AGE = W1_INTERVIEW_AGE + medt1t4;
        else if missing(W3_INTERVIEW_AGE) and not missing(W2_INTERVIEW_AGE) then W4_INTERVIEW_AGE = W2_INTERVIEW_AGE + medt2t4;
        else if missing(W1_INTERVIEW_AGE) and missing(W2_INTERVIEW_AGE) and missing(W3_INTERVIEW_AGE) then W4_INTERVIEW_AGE = 90;
    end;

    /* Convert W1_SENAS_TELEPHONE and W4_SENAS_TELEPHONE to 1/0 */
    W1_Visit_Type = (W1_SENAS_TELEPHONE = "Y");
    W2_Visit_Type = (W2_SENAS_TELEPHONE = "Y");
    W3_Visit_Type = (W3_SENAS_TELEPHONE = "Y");
    W4_Visit_Type = (W4_SENAS_TELEPHONE = "Y");

    /* Create visit_type variable */
    if W1_Visit_Type = 1 or W4_Visit_Type = 1 then visit_type = 1;
    else visit_type = 0;

    /* Calculate LOC averages */
    loc_avgscore_w1 = mean(of W1_SQX_LOC_HLPLSS W1_SQX_LOC_DTR W1_SQX_LOC_LFE W1_SQX_LOC_CNTRL W1_SQX_LOC_SLV);
    loc_avgscore_w4 = mean(of W4_SQX_LOC_HLPLSS W4_SQX_LOC_DTR W4_SQX_LOC_LFE W4_SQX_LOC_CNTRL W4_SQX_LOC_SLV);
    
    loc_avgscore    = coalesce(loc_avgscore_w4, loc_avgscore_w1);
    cognitive_exec  = coalesce(W4_D_SENAS_EXEC_Z, W1_D_SENAS_EXEC_Z);
    cognitive_vrmem = coalesce(W4_D_SENAS_VRMEM_Z, W1_D_SENAS_VRMEM_Z);
    Age_at_LOC      = coalesce(W4_INTERVIEW_AGE, W1_INTERVIEW_AGE);
    depression      = coalesce(W4_NIHTLBX_DEPR_THETA, W1_NIHTLBX_DEPR_THETA);
    health          = coalesce(W4_HEALTH, W1_HEALTH);
    visit_type		= coalesce(W4_Visit_Type, W1_Visit_Type);
    gender 			= W1_D_GENDER;
    race            = W1_D_RACE_SUMMARY;
    
    Time_W1 = W1_INTERVIEW_AGE - W4_INTERVIEW_AGE;
    Time_W2 = W2_INTERVIEW_AGE - W4_INTERVIEW_AGE;
    Time_W3 = W3_INTERVIEW_AGE - W4_INTERVIEW_AGE;
    Time_W4 = 0;

    Baseline_Age = W4_INTERVIEW_AGE;

    if nmiss(loc_avgscore, cognitive_exec, cognitive_vrmem, Age_at_LOC, depression,
             education, gender, health) = 0 
        and race ne '' and StudyID ne '' 
        and upcase(strip(race)) ne "NATIVE AMERICAN" then complete_case = 1;
    else complete_case = 0;

run;

/* Calculate Mean of Age_at_LOC */
proc means data=master_final noprint;
    var Age_at_LOC;
    output out=age_mean mean=mean_Age_at_LOC;
run;

/* Center Age_at_LOC */
data master_final;
    if _n_ = 1 then set age_mean;
    set master_final;

    centered_Age_at_LOC = Age_at_LOC - mean_Age_at_LOC;
    drop mean_Age_at_LOC;
run;

/* Calculate Mean of loc_avgscore */
proc means data=master_final noprint;
    var loc_avgscore;
    output out=loc_mean mean=mean_loc_avgscore;
run;

/* Center loc_avgscore */
data master_final;
    if _n_ = 1 then set loc_mean;
    set master_final;

    centered_loc_avgscore = loc_avgscore - mean_loc_avgscore;

    drop mean_loc_avgscore;
run;

/* Create Collapsed Health Variable */
data master_final;
    set master_final;

    if health in (1, 2) then health = 3;  /* Very Good/Excellent → 3 */
    else if health = 3 then health = 2;  /* Good → 2 */
    else if health in (4, 5) then health = 1;  /* Fair/Poor → 1 */
run;

proc format;
    value health3fmt
        1 = "Poor/Fair"
        2 = "Good"
        3 = "Very Good/Excellent";
run;

proc datasets library=work nolist;
    modify master_final;
    format health health3fmt.;
quit;


/*Final Dataset */
data analysis_ready;
    set master_final;
    if complete_case = 1;
    keep StudyID cohort loc_avgscore cognitive_exec cognitive_vrmem
         Age_at_LOC Rounded_Age_at_LOC depression educ_yrs gender visit_type
         health race complete_case
         Time_W1 Time_W2 Time_W3 Time_W4 
         W1_Visit_Type W2_Visit_Type W3_Visit_Type W4_Visit_Type
         Baseline_Age W1_INTERVIEW_AGE W2_INTERVIEW_AGE W3_INTERVIEW_AGE W4_INTERVIEW_AGE
         W1_D_SENAS_EXEC_Z W2_D_SENAS_EXEC_Z W3_D_SENAS_EXEC_Z W4_D_SENAS_EXEC_Z
         W1_D_SENAS_VRMEM_Z W2_D_SENAS_VRMEM_Z W3_D_SENAS_VRMEM_Z W4_D_SENAS_VRMEM_Z education centered_Age_at_LOC centered_loc_avgscore loc_avgscore;
run;


/*table 1 code*/
/* Create Cycle 1 Only Dataset */
/* Continuous Variables Summary */
proc means data=analysis_ready n mean std;
where cohort=1;
    var Age_at_LOC depression loc_avgscore cognitive_exec cognitive_vrmem education;
    title "Cycle 1 Only - Continuous Variables";
run;

proc means data=analysis_ready n mean std;
    var Age_at_LOC depression centered_loc_avgscore cognitive_exec cognitive_vrmem education;
    title "Cycle 1+2 - Continuous Variables";
run;

proc means data=analysis_ready n mean std;
    var Age_at_LOC depression loc_avgscore centered_loc_avgscore cognitive_exec cognitive_vrmem education;
    title "Cycle 1+2 Combined - categorical Variables";
run;

/*Categorical Variables Summary - Cycle 1 Only */
proc freq data=analysis_ready;
where cohort=1;
    tables  gender race health visit_type/ missing;
    title "Cycle 1 Only - Categorical Variables";
run;

/*Categorical Variables Summary - Combined */
proc freq data=analysis_ready;
    tables  gender race health visit_type/ missing;
    title "Cycle 1+2 Combined - Categorical Variables";
run;

/*Other*/
proc univariate data=analysis_ready;
    var Age_at_LOC depression centered_Age_at_LOC centered_loc_avgscore education health;
    output out=quintile_cutoffs
        min = min_loc_age min_loc_depression min_loc_centered_age min_centered_loc_avgscore education
        max = max_loc_age max_loc_depression max_loc_centered_age max_centered_loc_avgscore education
        pctlpts = 20 40 60 80 100
        pctlpre = p_age_ p_depr_ p_c_age_;
run;

proc means data=analysis_ready mean std min max;
    var centered_Age_at_LOC;
    title "Verification of Centered Age_at_LOC";
run;

/*Count how many obs dropped*/
proc sql;
    select count(*) as N_total
    from mylib.khandle_all_waves_20250110;
quit;

proc sql;
    select count(*) as N_complete_cases
    from analysis_ready;
quit;
