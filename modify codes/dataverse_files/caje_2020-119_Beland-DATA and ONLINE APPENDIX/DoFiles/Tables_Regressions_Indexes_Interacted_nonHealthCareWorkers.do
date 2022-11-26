/*

Indexes Interacted	- Non-Health Care Workers					March 18, 2021 
	
	
PREVIOUSLY: March_analysis_indexesInteracted_v2_ideasAboutHealthCareWorkers
	
Version 1 
	- First Pass 
	- Restricting the regressions to only those not in health care 
	
Version 2
	- Updated data file (March 30, 2021)
*/

/* Clear */
	clear 

/* timer */
	timer on 23 
	
/* Grab the current dataset */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

	
/* Specifications */ 
	global basicChars 		"i.(female marStat_2) ib3.ageCats_alt"
	global additionalChars 	"i.(Educ)"
	global basicFE 			"i.(K_prov K_year K_month)"
	global additionalFE 	"i.K_year#i.K_prov"

	local controls ${basicChars} ${additionalChars} ${basicFE} ${additionalFE}
	
/* Interactions and lack there of */
	local spec1 "i.postCovid stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework"
	local spec2 "i.postCovid stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework i.(postCovid)#c.(stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework)"
	
// Weights, Conditions, Options 
	local weights "[pw = K_finalwt]"

	
/* Just a reminder of the conditions that will be imposed on the regressions  */
	local  alt_regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3) & K_noc_10 != 2" // restricted age + in the labour force + not in health care professions
	local  alt_regConditions2 "if (K_age_12 <= 10) & K_noc_10 != 2" // restricted age + not in health care professions
	
	
/* THE BELOW ARE RESTRICTIONS ON THE WAGES AND HOURS, RESPECTIVELY  	
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for 
	local  regConditions2 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for
*/	


/* 
NOTE! This restriction is redundant with the conditions but should help speed 
up all of the code (since we drop 1,333,230) observations
*/
	keep if K_age_12 <= 10
	
	
/* Options */
 	local options ", vce(cluster K_prov)"

// Regression conditions iterator 
	local regCondNum = 1 
	
	
/* Looping over outcome variables (UNEMP and LFP) */
	foreach y in w_unemp w_lfpartic{
		
	/* What outcome variable are we doing? */
		di "	`y'"	
		di "	Conditions Number 	== `regCondNum'."
		di "	LEGEND = {1 is unemp, 2 is lfp}"
		
	/* Looping over columns */
		forval x = 1/2{
		    
		/* Run the regression */	
			eststo: reg `y' `spec`x'' `controls' `alt_regConditions`regCondNum'' `weights' `options' // ADDITIONAL THINGS 
	
		/* Estadd locals */
			estadd local basicChars "\checkmark"
			estadd local addChars "\checkmark"
			estadd local prov "\checkmark"
			estadd local year "\checkmark"
			estadd local month "\checkmark"
			estadd local provTrends "\checkmark"
			
		} /* END OF THE COLUMNS LOOP */
	
	/* Update the regression conditions counter */
		local regCondNum = `regCondNum' + 1 
		
	} /* END OF THE OUTCOMES LOOP */
	
	
/* Create a pretty table */
	esttab using "ReplicationFolder_CJE_Covid/Tables/March_indexesInteracted_nonHealthCare.tex" ///
		, 	replace ///
		keep(1.postCovid std*Prox std*Exposure std*Critical std*Homework 1.postCovid*std*) label noisily nostar ///
		b(%9.3f) se(%9.3f) compress eqlabels(none) noomit /// 
		varwidth(40) modelwidth(4) wrap nobase nodepvars ///
		delimiter("	&") ///
		prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{4}{c}{Canada, Labour Force Survey} \\"' `" &\multicolumn{4}{c}{Non-Health Care Workers} \\"' `"\cline{2-5} \\"' `"&\multicolumn{2}{c}{} &\multicolumn{2}{c}{Labour} \\"' `"&\multicolumn{2}{c}{Unemployment} &\multicolumn{2}{c}{Force Participation} \\"' `"\cline{2-3} \cline{4-5} \\"' ) ///
		posthead(`"\hline"' `"\\"') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
		mlabels(, none) ///
		stats(N basicChars addChars prov year month provTrends, fmt(%18.0g a3 a3 a3 a3 a3 a3) labels(`"Observations"'  `"Indv. Char."' `"Educ."' `"Prov. FE"' `"Year FE"' `"Month FE"' `"Prov. X Year FE"')) ///
		mgroups( , none) ///
		varlabels(_cons Constant, end("[0.5em]" "%") nolast) 

/* 	Drop the stored value */
	eststo drop *

/* How to make the tables perfectly 
	- Take out the (Standardized) writing
	- Add \hline between Observations and the fixed effects checkmarks 
*/	

/* timer */
	timer off 23 
	timer list 