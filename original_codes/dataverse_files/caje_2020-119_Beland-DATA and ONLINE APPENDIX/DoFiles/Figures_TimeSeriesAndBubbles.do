/*
	Figures
														   Monday, March 1, 2021
										  
Overview:

	Try and replicate the figures from the US paper. 
	
	The code will have the following flavour:
		(a) The first set of loops recreates the American Paper loops 
		(b) The second set of loops creates the aggregate hours worked and earnings
		
	Then we will create and individual graphs. 
		clear all 


Version 2
	- Updating for the revise and resubmit 		
	- Making sure the axes make sense (They didn't before)
	- Changing the age group to less than 55 
		
Version 3 
	- The age groups will be less than 69 for the whole analysis now
	
Version 4
	- The age groups will be 15 - 64 for now.
	- Marital Status will be updated to include common-law as a variable
	- New Age Group Categories 

Version 5 (March 4, 2021)
	- Calls the new dataset so we don't have this mess of variable declarations
		at the beginning
	- March 5 2021: use the most up-to-date .dta file 
	
Version 6 (March 5, 2021)
	- Calls the new dataset 8Mar2021
	
Version 7 (March 5, 2021)
	- Calls the new dataset 30Mar2021
	
global D1_pathway "C:\Users\Derek Mikola\Dropbox"
global LP_pathway ""
global A_pathway ""
global T_pathway ""



cd "$masterPathway"

*/

	clear 

/* timer on */
	timer on 12
	
/* Call the .dta file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"
	
/* FEBRUARY 26, 2021 - KEEPING ONLY VARIABLES WE CARE ABOUT - FOR SPEED */
	keep K_prov K_year K_month w_unemp w_lfpartic alt_hours_actual alt_wages ///
		parents sex ageCats ageCats_alt marStat immig ftpt union Educ ysm_immig student ///
		womanWithKids ageByUnion weekEarnQuart selfEmpIncorp median_proximity ///
		median_exposure median_critNumber median_HomeWork women_kidsLessThan6 ///
		women_kids6to12 women_kids13to17 women_kids18to24 K_age_12 K_lfsstat ///
		K_cowmain K_fweight weeklyEarnings K_noc_40 physProx_weightedIndex ///
		exposure_weightedIndex critNumber_weightedIndex HomeWork_weightedIndex ///
		twoDigitSum_LFS marStat_2 ageCats_alt
	
/* Getting to the Figures! */	

/* Taylor's Style
 	ssc install blindschemes, replace 
	set scheme plotplainblind
 */
 
 /* 
	Derek's Style 
 */
	set scheme sj 	
	
	grstyle init 
	grstyle type 
	grstyle set color s2, opacity(75): p#lineplot
	grstyle set linewidth 3pt: plineplot
	grstyle set plain 
	
	
/* Four different conditions - OLD - FROM THE ORIGINAL SUBMISSION 
*NOTE! These change because of the different conditions1
	local  conditions1 "if K_lfsstat != 3" //3 means someone is out of the labour force 
	local  conditions2 ""
	local  conditions3 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
	local  conditions4 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
*/

/* 
	FOUR CONDITIONS - NEW - for R&R
		- Between 15 and 64. 
*/
	local  conditions1 "if K_lfsstat != 3 & K_age_12 <= 10" //3 means someone is out of the labour force 
	local  conditions2 "if K_age_12 <= 10"
	local  conditions3 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
	local  conditions4 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
	
	
/* Weights */
	local weights "[pweight = K_fweight]"


// Keep track of what type of collapse we are doing. <2 == rates, >=2 == averages
	local counter = 1

/* IMPORTANT! OUR REPLACE ALL GRAPHS SWITCH */
	local switch "ON" 


foreach x in w_unemp w_lfpartic alt_hours_actual alt_wages{ 
	foreach z in sex womanWithKids ageCats_alt marStat_2 weekEarnQuart Educ immig ysm_immig ftpt union median_proximity median_exposure median_critNumber median_HomeWork{
		
		// Check that the graph exists 
		if `counter'==1 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_`z'.pdf"
		}
		else if `counter'==2 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_`z'.pdf"
		}
		else if `counter'==3 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_actualHrsWorked_`z'.pdf"
		}
		else if `counter'==4 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_`z'.pdf"
		}
		
		di _rc
		
		if (_rc != 0) | ( (_rc == 0) & ("`switch'" == "ON") ){
		    
		    di "The `z' graph doesn't exist OR the switch is on => Create New Graph"	
			
			preserve 
		
			/* The RATES graphs */
			if `counter' <= 2{
				/* Collapse variables into aggregates */
				collapse (sum) sum_`x' = `x' (count) count_`x' = `x' `conditions`counter'' `weights', by(K_year K_month `z')	
				
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				xtset `z' yearmonth, monthly 
				
				/* Generate the rate */
				gen `x'_rate = (sum_`x'/count_`x')*100 
				
				/* 
				Making the Graphs Prettier 
				*/
				
				if `counter' == 1 {
					xtline `x'_rate, ///
						overlay ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Unemployment Rate (%)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_`z'.pdf", as(pdf) replace 
				}
				else if `counter' == 2{
					xtline `x'_rate, ///
						overlay ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Labour Force Participation Rate (%)") yscale(titlegap(*15)) ///	
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_`z'.pdf", as(pdf) replace 
				}

			}
			/* The AVERAGES graphs */
			else if `counter' > 2{
				
				collapse (mean) mean_`x' = `x' `conditions`counter'' `weights', by(K_year K_month `z')
				
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				xtset `z' yearmonth, monthly 
				
				/* There is some issues with selfEmpIncorp */
				if `counter' == 3 {
					xtline mean_`x', ///
						overlay ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Total Actual Weekly Hours Worked") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_actualHrsWorked_`z'.pdf", as(pdf) replace 
				}
				else if `counter' == 4 & "`z'" != "selfEmpIncorp"{
					xtline mean_`x', ///
						overlay ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Real Hourly Wage (2018)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_`z'.pdf", as(pdf) replace 
				}
			}
			restore 	
		}
		else{
		    di " The `z' graph exists and the switch is off"
			di " => No new graph"
		}
		
		*************************	
	}
	local counter = `counter' + 1
}
	

/* Provincial Graphs */


recode K_prov (10/13 = 1 "Atlantic Canada") (24 = 2 "Ouebec") (35 = 3 "Ontario") ///
	(46/47 = 4 "Manitoba/Saskatchewan") (48 = 5 "Alberta") (59 = 6 "British Columbia") ///
	, gen(altProvinces)

// Aggregate Hours Worked and Aggregate Wages 
	set scheme sj 	
	
	grstyle init 
	grstyle type 
	grstyle set color s2, opacity(75): p#lineplot
	grstyle set linewidth 3pt: plineplot
	grstyle set plain 
	
/* Four different conditions */
local  conditions1 "if K_lfsstat != 3 & K_age_12 <= 10" //3 means someone is out of the labour force 
local  conditions2 "if K_age_12 <= 10"
local  conditions3 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
local  conditions4 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"

/* Weights */
local weights "[pweight = K_fweight]"

// Restart the counter 
local counter = 1

/* IMPORTANT! OUR REPLACE ALL GRAPHS SWITCH */
local switch "ON" 
// This is a switch. If you turn it ON then we will replace all graphs. 
// If the switch is OFF it will only create new graphs. 

foreach x in w_unemp w_lfpartic alt_hours_actual alt_wages{
	foreach z in altProvinces{
		
		// Check that the graph exists 
		if `counter'==1 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_altProvinces.pdf"
		}
		else if `counter'==2 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_altProvinces.pdf"
		}
		else if `counter'==3 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_actualHrsWorked_altProvinces.pdf"
		}
		else if `counter'==4 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_altProvinces.pdf"
		}
		
		di _rc
		
		if (_rc != 0) | (_rc == 0 & "`switch'" == "ON"){
		    
		    di "altProvinces"
			di " "
		    di " The graphdoesn't exist"
			di " => Create New Graph"	
			
			preserve 
		
			/* The RATES graphs */
			if `counter' <= 2{
				/* Collapse variables into aggregates */
				collapse (sum) sum_`x' = `x' (count) count_`x' = `x' `conditions`counter'' `weights', by(K_year K_month `z')		
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				xtset `z' yearmonth, monthly 
				
				di "Here"
				
				/* Generate the rate */
				gen `x'_rate = (sum_`x'/count_`x')*100 
				
				/* 
				Making the Graphs Prettier 
				*/
				
				if `counter' == 1 {
					xtline `x'_rate, ///
					overlay /// 
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Unemployment Rate (%)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_altProvinces.pdf", as(pdf) replace
				}
				else if `counter' == 2{
					xtline `x'_rate, ///
						overlay /// 
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Labour Force Participation Rate (%)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_altProvinces.pdf", as(pdf) replace
				}

			}
			/* The AVERAGES graphs */
			else if `counter' > 2 {
				
				collapse (mean) mean_`x' = `x' `conditions`counter'' `weights', by(K_year K_month `z')
				
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				xtset `z' yearmonth, monthly 
				
				/* There is some issues with selfEmpIncorp */
				if `counter' == 3 {
					xtline mean_`x', ///
						overlay ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Total Actual Weekly Hours Worked") yscale(titlegap(*15)) ////
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_actualHrsWorked_altProvinces.pdf", as(pdf) replace
				}
				else if `counter' == 4 {
					xtline mean_`x', ///
						overlay /// 
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Real Hourly Wage (2018)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_altProvinces.pdf", as(pdf) replace
				}
			}
			restore 	
		}
		else{
		    di "altProvinces"
		    di " The graph exists and the switch is off"
			di " => No new graph"
			di ""
		}
		
		*************************	
	}
	local counter = `counter' + 1
}

	grstyle clear 

	
// Canada Graphs  
	set scheme sj 	
	
	grstyle init 
	grstyle type 
	grstyle set color s2, opacity(75): p#lineplot
	grstyle set linewidth 3pt: plineplot
	grstyle set plain 
	
/* Four different conditions */
local  conditions1 "if K_lfsstat != 3 & K_age_12 <= 10" //3 means someone is out of the labour force 
local  conditions2 "if K_age_12 <= 10"
local  conditions3 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"
local  conditions4 "if K_age_12 <= 10 & K_lfsstat != 3 & K_cowmain <= 2"

/* Weights */
local weights "[pweight = K_fweight]"

// Restart the counter 
local counter = 1

/* IMPORTANT! OUR REPLACE ALL GRAPHS SWITCH */
local switch "ON" 
// This is a switch. If you turn it ON then we will replace all graphs. 
// If the switch is OFF it will only create new graphs. 


foreach x in w_unemp w_lfpartic alt_hours_actual alt_wages{
	foreach z in Canada{
		
		// Check that the graph exists 
		if `counter'==1 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_Canada.pdf"
		}
		else if `counter'==2 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_Canada.pdf"
		}
		else if `counter'==3 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_actualHrsWorked_Canada.pdf"
		}
		else if `counter'==4 {
			capture: confirm file "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_Canada.pdf"
		}
		
		di _rc
		
		if (_rc != 0) | (_rc == 0 & "`switch'" == "ON"){
		    
		    di "Canada"
			di " "
		    di " The graph doesn't exist or the switch is on"
			di " => Create New Graph"	
			
			preserve 
		
			/* The RATES graphs */
			if `counter' <= 2{
				/* Collapse variables into aggregates */
				collapse (sum) sum_`x' = `x' (count) count_`x' = `x' `conditions`counter'' `weights', by(K_year K_month)		
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				tsset yearmonth, monthly 
				
				di "Here"
				
				/* Generate the rate */
				gen `x'_rate = (sum_`x'/count_`x')*100 
				
				/* 
				Making the Graphs Prettier 
				*/
				
				if `counter' == 1 {
					tsline `x'_rate, ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Unemployment Rate (%)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_unempRate_Canada.pdf", as(pdf) replace
				}
				else if `counter' == 2{
					tsline `x'_rate, ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Labour Force Participation Rate (%)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_lfp_Canada.pdf", as(pdf) replace
				}

			}
			/* The AVERAGES graphs */
			else if `counter' > 2 {
				
				collapse (mean) mean_`x' = `x' `conditions`counter'' `weights', by(K_year K_month)
				
				/* Label the time series */
				gen yearmonth = ym(K_year, K_month)
				format yearmonth %tm 
				
				/* Set the panel */
				tsset yearmonth, monthly 
				
				/* There is some issues with selfEmpIncorp */
				if `counter' == 3 & "Canada" != "selfEmpIncorp"{
					tsline mean_`x', ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Total Actual Weekly Hours Worked") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_actualHrsWorked_Canada.pdf", as(pdf) replace
				}
				else if `counter' == 4 & "Canada" != "selfEmpIncorp"{
					tsline mean_`x', ///
						xtitle("", margin(medium)) tlabel(2016m1 2017m1 2018m1 2019m1 2020m1 2021m1) tmtick(2016m1(1)2021m1) ///
						ytitle("Real Hourly Wage (2018)") yscale(titlegap(*15)) ///
						legend(size(small))
						
					graph export "ReplicationFolder_CJE_Covid/Figures/alt_w_hrWage_Canada.pdf", as(pdf) replace
				}
			}
			restore 	
		}
		else{
		    di "Canada"
		    di " The graph exists and the switch is off"
			di " => No new graph"
			di ""
		}
		
		*************************	
	}
	local counter = `counter' + 1
}	
	
	

*******************************************************************************
*                             BUBBLES                                         *
*******************************************************************************

preserve

collapse physProx_weightedIndex exposure_weightedIndex critNumber_weightedIndex ///
	HomeWork_weightedIndex twoDigitSum_LFS ///
	if K_age_12 <= 10 [pweight = K_fweight], by(K_noc_40)

sum HomeWork_weightedIndex, detail
gen HomeWorkQuart = .
replace HomeWorkQuart = 1 if HomeWork_weightedIndex < r(p25)
replace HomeWorkQuart = 2 if HomeWork_weightedIndex > r(p25) & HomeWork_weightedIndex < r(p50)
replace HomeWorkQuart = 3 if HomeWork_weightedIndex > r(p50) & HomeWork_weightedIndex < r(p75)
replace HomeWorkQuart = 4 if HomeWork_weightedIndex > r(p75) & !missing(HomeWork_weightedIndex)

sum critNumber_weightedIndex, detail
gen critWorkerQuart = .
replace critWorkerQuart = 1 if critNumber_weightedIndex < r(p25)
replace critWorkerQuart = 2 if critNumber_weightedIndex > r(p25) & critNumber_weightedIndex < r(p50)
replace critWorkerQuart = 3 if critNumber_weightedIndex > r(p50) & critNumber_weightedIndex < r(p75)
replace critWorkerQuart = 4 if critNumber_weightedIndex > r(p75) & !missing(critNumber_weightedIndex)


gen lab = ""
replace lab = "Professional Occupations in Nursing" if K_noc_40 == 12
replace lab = "Occupations in Front-Line Public Protection"  if K_noc_40 == 19
// replace lab = "Professional Occupations in Art and Culture" if K_noc_40 == 21
// replace lab = "Specialized Middle Management Occupations" if K_noc_40 == 2
replace lab = "Transport and Heavy Equipment Operation " if K_noc_40 == 32
replace lab = "Finance, Insurance and Related Business |" if K_noc_40 == 7

// March 2 - Update 
	replace lab = "Office Support Occupations" if K_noc_40 == 8
	replace lab = "Care Providers & Educational, legal & Public Protection Support Occupations" if K_noc_40 == 20
	replace lab = "Sales Support Occupations" if K_noc_40 == 27


gen highlight = 1 if inlist(K_noc_40,8)
gen lowlight = 1 if inlist(K_noc_40,12,19,20)
gen medlight = 1 if inlist(K_noc_40,27,7,32)
/*
gen lowlight = 1 if soc == "533099"
*/



// RAW CORRELATION for the index of Figure 1
	corr exposure_weightedIndex physProx_weightedIndex HomeWork_weightedIndex critNumber_weightedIndex

/* Taylor's Style */
// ssc install blindschemes, replace 
 set scheme plotplainblind 
 
 
/* 
*
* Exposure X Physical
* Circles that are Work from Home 
*
*/ 
scatter exposure_weightedIndex physProx_weightedIndex if highlight == 1, msymbol(none) mlabposition(2) mlabel(lab) mlabcolor("black")  || ///
scatter exposure_weightedIndex physProx_weightedIndex if medlight == 1, msymbol(none) mlabposition(3) mlabel(lab) mlabcolor("black")  || ///
scatter exposure_weightedIndex physProx_weightedIndex if lowlight == 1, msymbol(none) mlabposition(9) mlabel(lab) mlabcolor("black") || ///
scatter exposure_weightedIndex physProx_weightedIndex  if HomeWorkQuart == 1 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex physProx_weightedIndex  if HomeWorkQuart == 2 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex physProx_weightedIndex  if HomeWorkQuart == 3 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex physProx_weightedIndex  if HomeWorkQuart == 4 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex physProx_weightedIndex  if highlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex physProx_weightedIndex  if medlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex physProx_weightedIndex  if lowlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") || , ///
	legend(rows(2) position(6) order (4 "Remote Work 1st Quartile" 5 "Remote Work 2nd Quartile" ///
	6 "Remote Work 3rd Quartile" 7 "Remote Work 4th Quartile")) ytitle("Exposure to infection/disease") xtitle("Physical proximity to coworkers")

graph export "ReplicationFolder_CJE_Covid/Figures/bubblesExposureAndProx_HomeWorkQuartiles.pdf", as(pdf) replace


/* 
*
* Exposure X Physical 
* Circles that are Critical Worker 
*
*/ 

// Drop the lights 
drop *light

gen highlight = 1 if inlist(K_noc_40,8)
gen lowlight = 1 if inlist(K_noc_40,12,19,20)
gen medlight = 1 if inlist(K_noc_40,27,7,32)

scatter exposure_weightedIndex physProx_weightedIndex if highlight == 1, msymbol(none) mlabposition(2) mlabel(lab) mlabcolor("black")  || ///
scatter exposure_weightedIndex physProx_weightedIndex if medlight == 1, msymbol(none) mlabposition(3) mlabel(lab) mlabcolor("black")  || ///
scatter exposure_weightedIndex physProx_weightedIndex if lowlight == 1, msymbol(none) mlabposition(9) mlabel(lab) mlabcolor("black") || ///
scatter exposure_weightedIndex physProx_weightedIndex  if critWorkerQuart == 1 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex physProx_weightedIndex  if critWorkerQuart == 2 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex physProx_weightedIndex  if critWorkerQuart == 3 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex physProx_weightedIndex  if critWorkerQuart == 4 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex physProx_weightedIndex  if highlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex physProx_weightedIndex  if medlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex physProx_weightedIndex  if lowlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") || , ///
	legend(rows(2) position(6) order (4 "Critical Work 1st Quartile" 5 "Critical Work 2nd Quartile" ///
	6 "Critical Work 3rd Quartile" 7 "Critical Work 4th Quartile")) ytitle("Exposure to infection/disease") xtitle("Physical proximity to coworkers")

graph export "ReplicationFolder_CJE_Covid/Figures/bubblesExposureAndProx_critWorkerQuartiles.pdf", as(pdf) replace



/* 
*
* Exposure X Remote Worker 
* Circles that are Critical Worker 
*
*/ 

// Replace the highlight/lowlights
drop *light 
gen highlight = 1 	if inlist(K_noc_40,7,8)
gen lowlight = 1 	if inlist(K_noc_40,12,19,32,27)
gen medlight = 1 	if inlist(K_noc_40,20)


scatter exposure_weightedIndex HomeWork_weightedIndex if highlight == 1, msymbol(none) mlabposition(7) mlabel(lab) mlabcolor("black")  || ///
scatter exposure_weightedIndex HomeWork_weightedIndex if lowlight == 1, msymbol(none) mlabposition(4) mlabel(lab) mlabcolor("black") || ///
scatter exposure_weightedIndex HomeWork_weightedIndex if medlight == 1, msymbol(none) mlabposition(6) mlabel(lab) mlabcolor("black") || ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if critWorkerQuart == 1 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if critWorkerQuart == 2 [w=twoDigitSum_LFS], msymbol(Oh)  || ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if critWorkerQuart == 3 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if critWorkerQuart == 4 [w=twoDigitSum_LFS], msymbol(Oh) || ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if highlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if lowlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") ||  ///
scatter exposure_weightedIndex HomeWork_weightedIndex  if medlight == 1 [w=twoDigitSum_LFS], msymbol(Oh) mcolor("black") || , ///
	legend(rows(2) position(6) order (4 "Critical Work 1st Quartile" 5 "Critical Work 2nd Quartile" ///
	6 "Critical Work 3rd Quartile" 7 "Critical Work 4th Quartile")) ytitle("Exposure to infection/disease") xtitle("Work from Home")

graph export "ReplicationFolder_CJE_Covid/Figures/bubblesExposureAndHomeWork_critWorkerQuartiles.pdf", as(pdf) replace

restore 

/* timer */
	timer off 12 
	timer list 