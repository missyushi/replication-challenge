/*

PREVIOUSLY: January_analysis_beforeAndAfter_v1

Before and After Analysis 										March 10, 2021 
	
	
PREVIOUSLY: January_analysis_beforeAndAfter_v1 
	
Version 1 	
	Cleaning
		- removed/updated the new preamble 

	WHAT NEEDS TO BE DONE (March 4, 2021)
		- Update the age groups to be between 15 - 64 (DONE)
		- Change marital status (to marStat_2) and age categories (to ageCats_alt) (DONE)
	
Version 2
	- Adding pre-COVID means to tables 
	
*/

/* CLEAR */
	clear 
	
/* Timer */
	timer on 25
	
/* Use the most up-to-date data file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

/* Specifications */ 
	global basicChars 		"i.(female marStat_2) ib3.ageCats_alt"
	global additionalChars 	"i.(Educ)"
	global basicFE 			"i.(K_prov K_year K_month)"
	global additionalFE 	"i.K_year#i.K_prov"
	
/* 
NOTE! This restriction is redundant with the conditions but should help speed 
up all of the code (since we drop 1,333,230) observations
*/
	keep if K_age_12 <= 10
	
/* Options */
 	local options ", vce(cluster K_prov)"


/* Regression Tables */ 
// Different Control Variables 
	local spec1 $basicFE
	local spec2 $basicFE $basicChars
	local spec3 $basicFE $basicChars $additionalChars $additionalFE

	
// Weights 
	local weights "[pw = K_finalwt]"

	
// Options 
	local options ", vce(cluster K_prov)"

	
/* BOOTSTRAPS 
	mata: bootstraps = J(3,6,.)
	local column = 1
*/


/* Conditions iterator */
	local i = 1 

	
/* Iterating the Panels of the table */
	local panelNum = 1 

	
/* Conditions */	
	local regConditions1 "if (K_age_12 <= 10)"
	local regConditions2 "if (K_age_12 <= 10)"
	local regConditions3 "if (K_age_12 <= 10)"
	local regConditions4 "if (K_age_12 <= 10)"

	
/* 
IMPORTANT! OUR REPLACE ALL GRAPHS SWITCH 
	- Can be either ON or OFF (must be in caps)
	
// This is a switch. If you turn it ON then we will replace all graphs. 
// If the switch is OFF it will only create new graphs. 	
*/
local switch "ON" 


/* Loops */
/* Looping over the three different outcomes which will be panels */
	foreach y in unemp_losersIllness fullWeekAbsence partWeekAbsence{
		
	/* Check whether the file already exists. */	
		capture: confirm file "ReplicationFolder_CJE_Covid/Tables/March_diffLM_Outcomes.tex"
		
	/* The ON/OFF Switch*/
		if (_rc != 0) | (_rc == 0 & "`switch'" == "ON"){
			
			di `y'
			di `panelNum'
			di "Either the switch is ON, OR the table doesn't exist => create/replace table"
		
		/* Looping over the specifications */
			forval m = 1/3{	
				
				quietly{ 
					
					/* Run the regression */
					eststo: reg `y' i.postCovid `spec`m'' `regConditions`i'' `weights' `options'

					/* If specification 1 */					
					if (`m' == 1) & (`panelNum' == 3) {
						estadd local basicChars ""
						estadd local addChars ""
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends ""
					} 
					/* If specification 2 */
					else if (`m' == 2)  & (`panelNum' == 3) {
						estadd local basicChars "\checkmark"
						estadd local addChars ""
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends ""
					}
					/* If specification 2 */					
					else if (`m' == 3)  & (`panelNum' == 3) {
						estadd local basicChars "\checkmark"
						estadd local addChars "\checkmark"
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends "\checkmark"
					}
				}
				
				
			/* Get the pre-treatment mean */
				summ `y' if e(sample) == 1 & postCovid == 0 
				estadd scalar preTreatMean = `r(mean)'		
				
				/*
				boottest 1.postCovid, cluster(K_prov) nograph noci weight(webb) seed(1103)
				local val round(`r(p)', 0.0001)
				mata: bootstraps[`panelNum',`column'] = `val'				
					
				local column = `column' + 1
				*/
			}
		
			
		/* Create the LaTeX Output directly to a panel */	
			if `panelNum' == 1 {
					
				// First Panel
				esttab using "ReplicationFolder_CJE_Covid/Tables/March_diffLM_outcomes.tex" ///
					, 	replace ///
					label keep(1.postCovid) noisily nostar ///
					b(%9.3f) se(%9.3f) compress eqlabels(none) noomit /// 
					varwidth(50) modelwidth(4) wrap nobase nodepvars ///
					title("COVID-19 Before and After Analysis, OLS") /// 
					prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"') ///
					posthead(`"\hline"' `"\\"') ///
					prefoot(`"\\"') ///
					postfoot( `"\hline"') ///
					mlabels(, none) ///
					mgroups( `"\textsc{Related Unemployed}"', pattern(1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}) ) ///
					stats(preTreatMean N, fmt(%9.3f %18.0g) labels( `"Pre-COVID Mean"' `"Observations"'))  ///
					varlabels(_cons Constant, end("" [0.5em]) nolast) 
							
				eststo drop *  	
				
			}
			else if `panelNum' == 2{
					
				// Final Panel
				esttab using "ReplicationFolder_CJE_Covid/Tables/March_diffLM_outcomes.tex" ///
					, 	append ///
					label keep(1.postCovid) noisily nostar ///
					b(%9.3f) se(%9.3f) compress eqlabels(none) noomit nonumbers /// 
					varwidth(50) modelwidth(4) wrap nobase nodepvars ///
					title(, none) /// 
					prehead("\\") ///
					posthead(`"\hline"' `"\\"') ///
					prefoot(`"\\"') ///
					postfoot( `"\hline"') ///
					mlabels(, none) ///
					mgroups( `"\textsc{Full Week Absence}"', pattern(1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}) ) ///
					stats(preTreatMean N, fmt(%9.3f %18.0g) labels( `"Pre-COVID Mean"' `"Observations"'))  ///
					varlabels(_cons Constant, end("" [0.5em]) nolast) 

				eststo drop * 				

			}
			else if `panelNum' == 3{
					
				// Final Panel
				esttab using "ReplicationFolder_CJE_Covid/Tables/March_diffLM_outcomes.tex" ///
					, 	append ///
					label keep(1.postCovid) noisily nostar ///
					scalars("basicChars Indv. Char." "addChars Educ." "prov Prov. FE" "year Year FE" "month Month FE" "provTrends Prov. X Year FE"  ) ///
					b(%9.3f) se(%9.3f) compress eqlabels(none) noomit nonumbers /// 
					varwidth(50) modelwidth(4) wrap nobase nodepvars ///
					title(, none) /// 
					prehead("\\") ///
					posthead(`"\hline"' `"\\"') ///
					prefoot(`"\\"') ///
					postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
					mlabels(, none) ///
					mgroups( `"\textsc{Part Week Absence}"', pattern(1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}) ) ///
					stats( preTreatMean N basicChars addChars prov year month provTrends, fmt(%9.3f %18.0g a3 a3 a3 a3 a3 a3) labels( `"Pre-COVID Mean"' `"Observations"'  `"Indv. Char."' `"Educ."' `"Prov. FE"' `"Year FE"' `"Month FE"' `"Prov. X Year FE"')) ///
					varlabels(_cons Constant, end("" [0.5em]) nolast) 

				eststo drop * 				

			}
			
			
		/* Update the regression restrictions */	
			local i = `i' + 1 
			
		/* Update the panel number */	
			local panelNum = `panelNum' + 1 	
			
		}
		else {
			di "The switch is off or panel already exists"
		}
	}
	
/* Timer */
	timer off 25
	timer list 