/*

Heteorgeneity by Demographic Group 						  Monday, March 15, 2021
	
PREVIOUSLY: January_analysis_demographicGroups_v3
	
	Omitted 
		- No more provincial cases. This has repercussions for the style of the 
		loop.

		
	Cleaning
		- Updated the new preamble 
		- Loop is significantly different from earlier. In particular, I am no
		longer looping over the contents of a local, but rather, am naming the
		variables explicitly in the loop declaration line. 

		
	New / To-Do List  (March 15, 2021)
		- New dataset (DONE)
		- Update the age groups to be between 15 - 64 (DONE)
		- Change marital status (to marStat_2) and age categories (to ageCats_alt) (DONE)
		- Replace sex with female (DONE)
		- Add Standardized Indices for the regressions 
		- Update where the table is exported to 
		
	Version 2
		- New do-file 
	
*/

/* */
	clear
 	
/* timer on */
	timer on 18
	
/* Use the most up-to-date data file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"
	
	
// Heterogeneity Variables. These are needed so that we interact them correctly 
	local x_het "female marStat_2 ageCats_alt Educ"
	
	
// Additional Controls Fixed Effects, Weights and Options
	local spec3 "i.female i.marStat_2 ib3.ageCats_alt ib2.Educ i.(K_prov K_year K_month) i.K_year#i.K_prov" 
	local indexes "stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework"
	
	
/* Weighting the regressions */
	local weights "[pw = K_finalwt]"
	
	
/* Clustering on Province */
	local options ", vce(cluster K_prov)"
	
	
/* THESE ARE THE NEW CONDITIONS FOR FIGURES AND REGRESSIONS */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // restricted age + in the labour force 
	local  regConditions2 "if (K_age_12 <= 10)" // restricted age 
	local  regConditions3 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for 
	local  regConditions4 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for

	
/* File naming locals */
	local name1 "unemp"
	local name2 "lfp"
	local name3 "wage"
	local name4 "hours"
	
	
/* Making the tables prettier */
	local title1 "Unemployment"
	local title2 "Labour Force Participation"
	local title3 "Real Hourly Wage"
	local title4 "Total Actual Hours Worked Weekly"
	
/* 
NOTE! This restriction is redundant with the conditions but should help speed 
up all of the code (since we drop 1,333,230) observations
*/
	keep if K_age_12 <= 10
	
	
/* Keeping track of the regression conditions */
	local conditionsIterator = 1

	
/* Looping over the outcome variables */
	foreach y in w_unemp w_lfpartic alt_wages alt_hours{
		
		/* Which table are we doing? */
		di "OUTCOME/TABLE: `title`conditionsIterator'' / `y' "
		
	/* Looping over what we will interact with the post COVID dummy */	
		foreach hetx in female marStat_2 ageCats_alt Educ{
			di "HETERO/COLUMN:	`hetx'"
			
		/* Mute the output */
			quietly{
				
			/* Actually Run Regression */ 
				eststo: reg `y' i.postCovid i.postCovid#i.`hetx' `spec3' `indexes' ///
					`regConditions`conditionsIterator'' `weights' `options'
					
			/* Add the rows of coefficients checkmarks at the bottom of the table */		
				estadd local indices "\checkmark"
				estadd local pym "\checkmark"
				estadd local provTrends "\checkmark"
				
			} /* END OF MUTE THE OUTPUT */
			
		} /* END OF THE LOOP OVER COLUMNS */
		
	/* Make a table out of the previously run regressions */	
		esttab using "ReplicationFolder_CJE_Covid/Tables/March_hetero_`name`conditionsIterator''_postCovid.tex" ///
			, 	replace ///
			keep(1.postCovid ?.female ?.marStat_2 ?.ageCats_alt 0.Educ 1.Educ 1.postCovid#1.female 1.postCovid#?.marStat_2 1.postCovid#?.ageCats_alt 1.postCovid#?.Educ ) ///
			scalars("indices Standardized Indexes" "pym Province, Year, Month FE " "provTrends Prov. X Year FE") ///
			b(%9.3f) se(%9.3f) /// 
			label noisily nostar compress eqlabels(none) noomit  wrap nobase nodepvars mlabels( , none ) ///
			mgroups( , none ) ///
			varlabels(_cons Constant, end("" [0.5em]) nolast) ///
			prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `"& \multicolumn{4}{c}{ \textsc{`title`conditionsIterator''} } \\"') ///
			posthead(`"\hline"' `"\\"') ///
			prefoot(`"\\"') ///
			postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
			title("COVID-19 Before and After Analysis, OLS") nostar 			
		
	/* Drop the previously stored models */	
		eststo drop * 
			
			
	/* Update the conditions */		
		local conditionsIterator = `conditionsIterator' + 1 		
	
	} /* END OF THE LOOP OVER OUTCOME VARIABLES */
	
	
/* 
ADDITIONAL WORK WHICH NEEDS TO BE DONE IN LaTeX in order to finish the tables :
	1. Add "\cline{2-5} \\" for line under the column title
	2. Move the Post COVID X Female lower in the graphs 
	3. Add "\hline" to cut the table between observations and standardized indexes 
	4. Table Notes 
*/

/* timer off */
	timer off 18
	timer list 