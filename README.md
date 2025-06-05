# Thesis
Code for Master's Thesis: Perceived Control and Cognitive Decline in a Racially/Ethnically Diverse Cohort of Older Adults: Findings from the Kaiser Healthy Aging and Diverse Life Experiences (KHANDLE) Study

This repository contains the code and documentation used in the completion of my master's thesis at UCLA. The thesis investigates the relationship between locus of control (LoC)—a psychological construct reflecting perceived control over life outcomes — and cognition (executive function and verbal memory) in a racially and ethnically diverse sample of older adults enrolled in the KHANDLE study. 

# Overview
The analysis evaluates both cross-sectional and longitudinal associations, incorporating:

- Continuous and quintile-based LoC exposure variables
- Race-stratified models
- Cognitive outcomes: executive function and verbal memory
- Adjustment for covariates including age, education, gender, depression, self-rated health, and study visit type
- Diagnostic plots for model fit

All analyses were conducted using SAS (Statistical Analysis System), and the code is provided as .sas files.

# Code Structure

1.  Master Data Set: Prepares the analysis dataset by merging KHANDLE variables, harmonizing measures across cycles, cleaning invalid values, and generating final variables such as average LoC, cognitive outcomes, and covariates.

2. Cross-sectional models using Cycle 1 data. Includes: Continuous and quintile-based LoC predictors (sensitivity analysis), adjusted and unadjusted models, race-stratified models
   
3. Cross-sectional Analysis using combined Cycle 1 and 2 data. Includes: Continuous and quintile-based LoC predictors (sensitivity analysis), adjusted and unadjusted models, race-stratified models across the larger sample
   
4. Longitudinal Analysis models assessing cognitive change over time. Includes: Continuous and quintile-based LoC predictors (sensitivity analysis), Models with interactions between LoC and study time, Race-stratified models for both cognitive outcomes

# Data

The KHANDLE dataset is not publicly available due to confidentiality restrictions. This repository does not contain raw data. Scripts are written for reproducibility and assume access to cleaned and de-identified KHANDLE data.

# Acknowledgements
Special thanks to my thesis chair, Dr. Elizabeth Rose Mayeda, for her mentorship and support throughout this project. I am also grateful for my committee members, Dr. Roch Nianogo and Dr. Courtney Thomas Tobin, for their feedback and guidance. Thanks to the KHANDLE study team for providing access to the dataset and for their ongoing contributions to aging research.
