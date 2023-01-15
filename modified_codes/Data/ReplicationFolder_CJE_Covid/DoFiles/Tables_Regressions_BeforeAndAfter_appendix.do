/*

PREVIOUSLY: January_analysis_beforeAndAfter_v1

Before and After Analysis 										March 10, 2021 
	
	
PREVIOUSLY: January_analysis_beforeAndAfter_v1 
	
Version 1 	(labelled as v3)
	This file comes from version 3 of the March_analysis_beforeAndAfter
	
Version 2 (labelled as v4)
	Updating incorrect code for the standard errors 
	
Version 5 
	Adding Bootstraps and multiway clusters 
	
Version 6
	Adding pre/post means to all tables. 
	Updated .dta file 
*/

/* CLEAR */
	clear 

/* Timer on */
	timer on 16
	
/* Use the most up-to-date data file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

/* Specifications */ 
	global basicChars 		"i.(female marStat_2) ib3.ageCats_alt"
	global additionalChars 	"i.(Educ)"
	
	global Canada_basicFE 	"i.(K_prov K_year K_month)"
	global Prov_basicFE 	"i.(K_year K_month)"
	
	global Canada_additionalFE 	"i.K_year#i.K_prov"
	global Prov_additionalFE 	""

/* Trying alternative */
	bysort K_prov K_year K_month: egen grandMean = mean(alt_wages)
	gen diff_wages =  alt_wages - grandMean 
	
// Weights, Conditions, Options 
	local weights "[pw = K_finalwt]"

/* Just a reminder of the conditions that will be imposed on the regressions 
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // restricted age + in the labour force 
	local  regConditions2 "if (K_age_12 <= 10)" // restricted age */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for 
	local  regConditions2 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for
	
	//local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // robustness check
	//local  regConditions2 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // robustness check
	
/* 
NOTE! This restriction is redundant with the conditions but should help speed 
up all of the code (since we drop 1,333,230) observations
*/
	keep if K_age_12 <= 10
	
	
/* Options */
 	local options1 ", vce(cluster K_prov)"
	local options2 ", robust"


// Tracking our Bootstrapped P-values
	matrix multiway = J(1,6,.)
	matrix bootstraps = J(1,6,.)

// Column Iterator 
	local column = 1

// Iterating the Panels of the table 
	local panelNum = 1 
	
/* Looping over panels (geography) */	
	foreach geo in "!=." "==24"	"==35" "==48" "==59"{
		
	/* What geography are we at? */
		di 	"`geo'"
		
	/* Conditions iterator: either 1 (unemp) or 2 (lfp) 
		and it restarts with every panel)  */
		local i = 1 	
		
	/* Looping over outcome variables */
		foreach y in alt_wages alt_hours_actual{
			
		/* What outcome variable are we doing? */
			di "	`y'"	
			di "	Conditions Number 	== `i'."
			di "	LEGEND = {1 is wages, 2 is hours}"
			
		/* Looping over columns */
			forval x = 1/3{
				
			/* What column are we doing? */
			// Different Control Variables 
			if `panelNum' == 1{
			    
			/* The Canada regressions */	
				local spec1 ${Canada_basicFE}
				local spec2 ${Canada_basicFE} ${basicChars}
				local spec3 ${Canada_basicFE} ${basicChars} ${additionalChars} ${Canada_additionalFE}				
				
			/* Cluster on Province */	
				local options `options1'
			}
			else{
			    
			/* The Provincial Regressions */	
				local spec1 ${Prov_basicFE}
				local spec2 ${Prov_basicFE} ${basicChars}
				local spec3 ${Prov_basicFE} ${basicChars} ${additionalChars} ${Prov_additionalFE}		
				
			/* Change to robust standard errors because there is only one province */
				local options `options2'
			}
				
				di "		`spec`x''"
					
			/* QUIETLY - SUPPRESS OUTPUT FOR TESTING */
			//	quietly{ 		
					
				/* Run the regression */	
					eststo: reg `y' i.postCovid `spec`x'' ///
						`regConditions`i'' & (K_prov `geo') /// < CONDITIONS 
						`weights' `options' // < ADDITIONAL THINGS 
							
				/* Adding the Fixed Effects FOR THE FIRST PANEL */
					if (`x' == 1) & (`panelNum' == 1){
						estadd local basicChars ""
						estadd local addChars ""
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends ""
						
					} // If conditional END 
					
					if (`x' == 2) & (`panelNum' == 1){
						estadd local basicChars "\checkmark"
						estadd local addChars ""
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends ""
						
					} // If conditional END
					
					if (`x' == 3) & (`panelNum' == 1){
						estadd local basicChars "\checkmark"
						estadd local addChars "\checkmark"
						estadd local prov "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						estadd local provTrends "\checkmark"
						
					} // If conditional END							
				/* END OF CHECKMARKS FOR THE FIRST PANEL*/
				
			/* Bootstrap matrices */
				if (`panelNum' == 1){
					
				// Run the bootstraps 
					boottest 1.postCovid, cluster(K_prov) nograph noci weight(webb) reps(999) seed(1103)  
					local val round(`r(p)', 0.0001)
					matrix bootstraps[1,`column'] = `val'
					
					
				/* Run the boottest
 
					waldtest 1.postCovid, cluster(K_prov K_month) nograph noci 
					local val round(`r(p)', 0.0001)
					matrix multiway[1,`column'] = `val'	
				*/	
					local column = `column' + 1 
				}				
					
			
				/* Adding the Fixed Effects FOR THE LAST PANEL */
					if (`x' == 1) & (`panelNum' == 5){
						estadd local basicChars ""
						estadd local addChars ""
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						
					} // If conditional END 
					
					if (`x' == 2) & (`panelNum' == 5){
						estadd local basicChars "\checkmark"
						estadd local addChars ""
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						
					} // If conditional END
					
					if (`x' == 3) & (`panelNum' == 5){
						estadd local basicChars "\checkmark"
						estadd local addChars "\checkmark"
						estadd local year "\checkmark"
						estadd local month "\checkmark"
						
					} // If conditional END				
				/* END OF CHECKMARKS FOR THE FIRST PANEL*/		
			
			/* Get the pre-treatment mean */
				summ `y' if e(sample) == 1 & postCovid == 0 
				estadd scalar preTreatMean = `r(mean)'	
				
			//	} // QUIETLY END 				
			} // COLUMN LOOP END 
			
		/* Iterate on the conditions counter */
			local i = `i' + 1
			
		} // OUTCOME VARIABLE LOOP END 
		
	/* Create top panel */
		di "Panel Number `panelNum'"
	
		if `panelNum' == 1{
			di "Top Panel"
			eststo dir 
			
			matrix list multiway
			matrix list bootstraps	
			
			matrix addedInfo = bootstraps \ multiway
			matrix rownames addedInfo = "\textit{Bootstrapped p-value}" "\textit{Multiway p-value}"
			
			esttab using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_Canada_appendix.tex" ///
				, 	replace ///
				keep(1.postCovid*) label noisily nostar ///
				b(%9.3f) se(%9.3f)  compress eqlabels(none) noomit /// 
				varwidth(50) modelwidth(4) wrap nobase nodepvars ///
				title("COVID-19 Before and After Analysis, OLS") /// 
				prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{6}{c}{Labour Force Survey} \\"' `"\cline{2-7} \\"' `"& & & &\multicolumn{3}{c}{Total Actual} \\"' `"&\multicolumn{3}{c}{Real Hourly Wage} &\multicolumn{3}{c}{Hours Worked Weekly} \\"' `"\cline{2-4} \cline{5-7} \\"' ) ///
				posthead(`"\hline"' `"\\"') ///
				prefoot(`"\\"') ///
				postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
				mlabels(, none) ///
				stats( preTreatMean N basicChars addChars prov year month provTrends, fmt( %9.3f %18.0g a3 a3 a3 a3 a3 a3) labels( `"Pre-COVID Mean"' `"Observations"'  `"Indv. Char."' `"Educ."' `"Prov. FE"' `"Year FE"' `"Month FE"' `"Prov. X Year FE"')) ///
				mgroups( , none) ///
				varlabels(_cons Constant, end("" [0.5em]) nolast) 
				
				
		/* Export the table to LaTeX */	
			esttab matrix(addedInfo, fmt(%9.4f)) ///
				using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_Canada_appendix.tex" ///
				, 	append ///
				label noisily ///
				compress /// 
				varwidth(20) modelwidth(4) wrap nobase nodepvars ///
				eqlabels(, none) ///
				delimiter("	&") ///
				prehead(`""') ///
				posthead(`"\hline"' `"\\"') ///
				prefoot(`"\\"') ///
				postfoot( `""'') ///
				mlabels(, none) ///
				mgroups( , none) ///
				varlabels(_cons Constant, end("" "%") nolast) 				
						
			eststo drop *
			
		}
		
	/* Create middle panel */
		if `panelNum' == 2 {
			di "Middle Panel"
			
			local panel2_title "Quebec"
			local altPanelNum = `panelNum' - 1
			
			// Middle Panel Panel
			esttab using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_QcOnAbBc_appendix.tex" ///
				, 	replace ///
				label keep(1.postCovid*) noisily nostar ///
				b(%9.3f) se(%9.3f)  compress eqlabels(none) noomit numbers /// 
				varwidth(50) modelwidth(4) wrap nobase nodepvars ///
				title(, none) /// 
				prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{6}{c}{Labour Force Survey} \\"' `"\cline{2-7} \\"' `"& & & &\multicolumn{3}{c}{Total Actual} \\"' `"&\multicolumn{3}{c}{Real Hourly Wage} &\multicolumn{3}{c}{Hours Worked Weekly} \\"' `"\cline{2-4} \cline{5-7} \\"' ) ///
				posthead( `"\hline"' `"\\"' `"Panel `altPanelNum': &\multicolumn{6}{c}{ \textsc{ `panel`panelNum'_title' } } \\"' `"\hline"' `"\\"') ///
				prefoot(`"\\"') ///
				postfoot( `"\hline \hline"') ///
				mlabels(, none) ///
				mgroups( ,none) /// mgroups( `"Unemployment"' `"Labour Force Participation"', pattern(1 0 0 1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}) ) ///
				stats(preTreatMean N, fmt(%9.3f %18.0g) labels( `"Pre-COVID Mean"' `"Observations"'))  ///
				varlabels(_cons Constant, end("" [0.5em]) nolast) 

			eststo drop *
		}
		
	/* Create middle panel */
		if `panelNum' >= 3 & `panelNum' <=4 {
			di "Middle Panel"
			
			local altPanelNum = `panelNum' - 1			
			local panel3_title "Ontario"
			local panel4_title "Alberta"
			
			// Middle Panel Panel
			esttab using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_QcOnAbBc_appendix.tex" ///
				, 	append ///
				label keep(1.postCovid*) noisily nostar ///
				b(%9.3f) se(%9.3f)  compress eqlabels(none) noomit nonumbers /// 
				varwidth(50) modelwidth(4) wrap nobase nodepvars ///
				title(, none) /// 
				prehead("\\") ///
				posthead(`"Panel `altPanelNum': &\multicolumn{6}{c}{ \textsc{ `panel`panelNum'_title' } } \\"' `"\hline"' `"\\"') ///
				prefoot(`"\\"') ///
				postfoot( `"\hline \hline"') ///
				mlabels(, none) ///
				mgroups( ,none) /// mgroups( `"Unemployment"' `"Labour Force Participation"', pattern(1 0 0 1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}) ) ///
				stats(preTreatMean N, fmt(%9.3f %18.0g) labels( `"Pre-COVID Mean"' `"Observations"'))  ///
				varlabels(_cons Constant, end("" [0.5em]) nolast) 

			eststo drop *
		}		
		
	/* Create bottom panel */
		if `panelNum' == 5{
			di "Bottom Panel"
			
			local altPanelNum = `panelNum' - 1				
			
			esttab using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_QcOnAbBc_appendix.tex" ///
				, 	append ///
				keep(1.postCovid*) label noisily nostar ///
				scalars("basicChars Indv. Char." "addChars Educ." "index Indices" "prov Prov. FE" "year Year FE" "month Month FE" "provTrends Prov. X Year FE"  ) ///
				b(%9.3f) se(%9.3f)  compress eqlabels(none) noomit nonumbers /// 
				varwidth(50) modelwidth(4) wrap nobase nodepvars ///
				title(, none) /// 
				prehead("\\") ///
				posthead(`"Panel `altPanelNum': &\multicolumn{6}{c}{ \textsc{ British Columbia } } \\ "' `"\hline"' `"\\"') ///
				prefoot(`"\\"') ///
				postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
				mlabels(, none) ///
				stats(preTreatMean N basicChars addChars year month, fmt( %9.3f %18.0g a3 a3 a3 a3 a3 a3) labels( `"Pre-COVID Mean"' `"Observations"'  `"Indv. Char."' `"Educ."' `"Year FE"' `"Month FE"')) ///
				mgroups( ,none)  /// mgroups( `"Real Hourly Wage"' `"Total Actual Hours Worked"', pattern(1 0 0 1 0 0) span prefix(\multicolumn{3}{c}{) suffix(}))  ///
				varlabels(_cons Constant, end("" [0.5em]) nolast) 

			eststo drop * 			
		}
		
	/* Update the panel number */
		local panelNum = `panelNum' + 1 
		
	} // GEOGRAPHY LOOP END 
	
/* Clear all the stored regressions */
	eststo clear 
	
/* Timer off */
	timer off 16
	timer list 
