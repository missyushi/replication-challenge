/*
*
* COMPARING LFS WITH CPSS USING SUMMARY STATISTICS 
*
* Version 1 (March 3, 2021)
*	- First Pass 
*
* VERSION 2 (March 3, 2021)
*	- NOTE: summarize ... [aweight] is the same as using svy set, estimating 
*		the mean, the variance. It is much faster to just summarize than declare
*		the dataset.
*	- See: https://www.stata.com/support/faqs/statistics/weights-and-summary-statistics/
*	- This greatly simplifies the problem of exporting as we can use esttab 
*		directly. 
*
*	- NEW MARRIAGE VARIABLE 
*		- The old on didn't consider those who were common-law as married. 
*		- Have to redefine one of the outcomes. 
*
*	- Exporting table to
*
* Version 3 (March 5, 2021)
	- Updating the data file to 5March2021
	
	- Deleting all the new variable definitions for codes since they are updated 
		in the new .dta file which is called. 
*
*/

clear 
	
/* timer on */	
	timer on 14 
	
/*
* 
* Generate LFS Summary Statistics 
*
* Include Demographics: Female, Married, Age group dummies, education dummies, 
*	 immigrants 	
*
* Just using March 2020 
*
*/

/* Use the most up-to-date data file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"
			
		
/* Generate Age Group dummies */ 
	tab ageCats_alt 
	tab ageCats_alt, generate(dummy_ageCats_alt_)
	
/* Relabel the new dummy variables */
	label variable dummy_ageCats_alt_1 "15 - 34"
	label variable dummy_ageCats_alt_2 "35 - 54"
	label variable dummy_ageCats_alt_3 "55 - 64"
	
	
/* Generate education dummies */
	tab Educ, generate(dummy_Educ_)
	
	
/* Label the education dummies */
	label variable dummy_Educ_1 "Less than highschool"
	label variable dummy_Educ_2 "Highschool or some college"
	label variable dummy_Educ_3 "Postsecondary accreditation"
	
	
/* RAW SUMMARIZE FOR ALL VARIABLES */
	summ female marStat_2 dummy_ageCats* dummy_Educ* if K_age_12 <= 10 
	
	
/* AWEIGHT SUMMARIZE FOR ALL VARIABLES */
	eststo lfs_all: estpost summarize ///
		female marStat_2 dummy_ageCats* dummy_Educ* ///
		[aweight = K_finalwt] if K_age_12 <= 10 

/* Keep if in March 2020 */		
	keep if ( K_year == 2020 & K_month == 3)	
	
/* AWEIGHT SUMMARIZE FOR ALL VARIABLES */
	eststo lfs_march: estpost summarize ///
		female marStat_2 dummy_ageCats* dummy_Educ* ///
		[aweight = K_finalwt] if K_age_12 <= 10 
		
/* 
*
* Generate CPSS Summary Statistics 
*
* Include Demographics: Female, Married, Age Group Dummies, Education Dummies,
*	immigrants 
*
*/

clear 

/* Grab CPSS */
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset_CPSS.dta"

/* Set the survey data */
/* Corrections that statistics Canada wants us to apply 
	gen basicVarianceCorrection = 3.0 
	gen groupVarianceCorrection = 2.5
*/


/* Variable: Female - looks good */
	tab female 
	tab female, nolab 

	
/* Marital Status - looks good */
	tab marStat
	label variable marStat "Married or common-law"
	tab marStat, nolab 
	
	clonevar marStat_2 = marStat
	
/* Variable: Age Groups. Check, create, generate dummies */ 
	tab agegrp 
	tab agegrp, nolab
	
	recode agegrp (1/2 = 0 "15 - 34") (3/4 = 1 "25 - 54") (5 = 2 "55 - 64") ///
		(6/7 = .), gen(ageCats_alt)
		
	tab ageCats_alt 

/* Generate age group dummies */
	tab ageCats_alt, gen(dummy_ageCats_alt_)
	
/* Relabel the new dummy variables */
	label variable dummy_ageCats_alt_1 "15 - 34"
	label variable dummy_ageCats_alt_2 "35 - 54"
	label variable dummy_ageCats_alt_3 "55 - 64"
	
	
/* Variable: education. looks good; create dummies */	
	tab educ, gen(dummy_Educ_)

/* Label the education dummies */
	label variable dummy_Educ_1 "Less than highschool"
	label variable dummy_Educ_2 "Highschool or some college"
	label variable dummy_Educ_3 "Postsecondary accreditation"

	
/* RAW SUMMARIZE FOR ALL VARIABLES */		
summ female marStat_2 dummy_ageCats* dummy_Educ* if agegrp <= 5

/* AWEIGHT SUMMARIZE FOR ALL VARIABLES */		
eststo cpss: estpost summarize ///
	female marStat_2 dummy_ageCats* dummy_Educ* ///
	[aweight = covid_wt] if agegrp <= 5
		

/* What does this look like? */
esttab lfs_all lfs_march cpss ///
	, 	///
	cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) min max") ///
	label
	
	
/* Export to Tables */
	esttab lfs_all lfs_march cpss ///
		using "ReplicationFolder_CJE_Covid/Tables/lfs_cpss_comparison_summaryStatistics_v1.tex" ///
		, 	replace noisily /// 
		se(%9.4f)  compress eqlabels(none) label /// 
		varwidth(50) modelwidth(4) wrap nobase nodepvars nonumbers ///
		cells("mean( fmt(%9.3f) label(Mean) ) sd( fmt(%9.3f) label(Std. Dev.) ) min( fmt(%9.1f) label(Min) ) max( fmt(%9.1f) label(Max) )") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{8}{c}{Labour Force Survey} &\multicolumn{4}{c}{Canadian Perspectives Survey Series} \\"' `"\cline{2-9} \cline{10-13}\\"' `"&\multicolumn{4}{c}{All Months 2016 -- 2020}   &\multicolumn{4}{c}{March 2020} &\multicolumn{4}{c}{March/April 2020} \\ "' `"\cline{2-5} \cline{6-9} \\"' `"\textit{Summary Statistics} "') ///
		posthead(`"\hline"' `"\\"') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
		mlabels(, none) ///
		varlabels(_cons Constant, begin(\hspace{0.5cm})  end([0.25em]) nolast) 
		
		
/* Export to LaTeX/Tables - NOW REDUNDANT CODE
	esttab lfs_all lfs_march cpss ///
		using "ReplicationFolder_CJE_Covid/Tables/lfs_cpss_comparison_summaryStatistics_v1.tex" ///
		, 	replace noisily /// 
		se(%9.4f) compress eqlabels(none) label /// 
		varwidth(50) modelwidth(4) wrap nobase nodepvars nonumbers ///
		cells("mean( fmt(%9.3f) label(Mean) ) sd( fmt(%9.3f) label(Std. Dev.) ) min( fmt(%9.1f) label(Min) ) max( fmt(%9.1f) label(Max) )") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{8}{c}{Labour Force Survey} &\multicolumn{4}{c}{Canadian Perspectives Survey Series} \\"' `"\cline{2-9} \cline{10-13}\\"' `"&\multicolumn{4}{c}{All Months 2016 -- 2020}   &\multicolumn{4}{c}{March 2020} &\multicolumn{4}{c}{March/April 2020} \\ "' `"\cline{2-5} \cline{6-9} \cline{10-13}\\"' `"\textit{Summary Statistics} "') ///
		posthead(`"\hline"' `"\\"') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
		mlabels(, none) ///
		varlabels(_cons Constant, begin(\hspace{0.5cm})  end([0.25em]) nolast) 
*/
		
		
eststo clear 

/* timer off */
	timer off 14 
	timer list 