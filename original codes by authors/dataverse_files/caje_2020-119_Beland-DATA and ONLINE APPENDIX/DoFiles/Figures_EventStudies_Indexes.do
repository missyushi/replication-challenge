/*

Event Study Graphs												March 19, 2021 
	
	
PREVIOUSLY: N/A
	
Version 1 
	- First Pass 
	- Trying to incorporate the comments from the referees 
	
VERSION 2
	- Major Overhall. 
	- Reducing the pre-time periods to 6 months.
	
Version 3
	- Updated .dta set 
*/

clear 	
	
/* timer */
	timer on 11
	
/* Check if the merged event dataset exists */
	capture confirm file  "ReplicationFolder_CJE_Covid/Data/dtaFiles/EventStudy.dta"
	display _rc 
	
/* if */
	if _rc==0 {
		display "The file EventStudy.dta exists already"
		display "=> Skip the file creation"
	}
	else {
		display "The file EventStudy.dta does not exist"
		display "=> Create the file"
		
	/* Use the most up-to-date data file */	
		use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

	/* 
	Generate the event study variable - CODE OUTLINE 
		- Keep only the variables which matter 
		- Keep only unique Prov X Year X Month X PostCOVID
		- Generate the event study variables
		- Save temporary file
		- merge m:1 back with the original dataset
	*/	

	/* Preserve */
		preserve 
		
		/* Checking (This ordering is weird but fastest)  */
			keep K_prov K_year K_month postCovid 
			order K_prov K_year K_month postCovid 
			// duplicates report K_prov K_year K_month postCovid
			duplicates drop K_prov K_year K_month postCovid, force 	
			
			sort K_prov K_year K_month 
			
			duplicates report K_prov K_year K_month postCovid 

		/* Start trying to generate the event study identifiers  */
		/* This is an identifier row. */
			sort K_prov K_year K_month 
			bysort K_prov: 	gen getsTreatment_event = 0 + 1*(postCovid[_n-1] == 0)*(postCovid[_n] == 1) 
			
		/* This is the target row. */	
			by K_prov: 	gen getsTreatment_target = _n if getsTreatment_event == 1  
			
		/* This will set all of the row values equal to zero. */	
			egen getsTreatment_td = min(getsTreatment_target), by(K_prov)  
			
		/* Take the difference of these */ 	
			by K_prov: gen getsTreatment_dif = _n - getsTreatment_td
			
		/* Full Year */ 	
			gen yearWindow = 0 
			replace yearWindow = 14 + getsTreatment_dif if abs(getsTreatment_dif)<=14	
			replace yearWindow = 29 if getsTreatment_dif > 28
			
		/*
		*
		* NOTE! The current event is centered on March 2021
		*
		*/ 

		/* Save the temporary file */
			tempfile eventStudyNumbers 
			save `eventStudyNumbers'
			
	/* Restore the original dataset */
		restore 
		
	/* Drop the merge */
		drop _merge 

	/* Give each observation the eventStudyNumbers */ 	
		merge m:1 K_prov K_year K_month using `eventStudyNumbers'		
		
	/* Save the file */
		save "ReplicationFolder_CJE_Covid/Data/dtaFiles/EventStudy.dta" ///
			, replace 
		
	}
	
// Call the event study dataset 	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/EventStudy.dta"
	
// Rename a variable 
	rename yearWindow yw	
	
/* Reduce the time period for yw to 6 months before */	
	replace yw = 0 if yw <= 7
	replace yw = yw - 7 if yw >= 8 
	tab yw // 7 is march 
 
 
 /* Derek's Graph Style */
	set scheme sj 	
	
	grstyle init 
	grstyle type 
	grstyle set color s2, opacity(75): p#lineplot
	grstyle set linewidth 3pt: plineplot
	grstyle set plain 		
	
	
/* Specifications */ 
	global basicChars 		"i.(female marStat_2) ib3.ageCats_alt"
	global additionalChars 	"i.(Educ)"
	
	global basicFE 			"i.(K_prov K_year K_month)"
	global additionalFE 	"i.K_year#i.K_prov"
	
// Weights, Conditions, Options 
	local weights "[pw = K_finalwt]"
	
/* Just a reminder of the conditions that will be imposed on the regressions */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // restricted age + in the labour force 
	local  regConditions2 "if (K_age_12 <= 10)" // restricted age 
	local  regConditions3 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for 
	local  regConditions4 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we 	
	
 	local options1 ", vce(cluster K_prov)"		
	
/* Specification */
	global spec1 "ib6.yw#c.(stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework) ib6.yw stdzd_PhysProx stdzd_Exposure stdzd_Critical stdzd_Homework" 
	
/*
	UNEMPLOYMENT 
*/
// run regression UNEMPLOYMENT 
	reg w_unemp ${spec1} ${basicChars} ${additionalChars} ${basicFE} ${additionalFE} `weights' `regConditions1' `options1'
	estimates store fullYear

	
	forval i = 0/23{
		
		local labelling = -13 + `i'
		
		local yearwindow_pp `yearwindow_pp' "`i'.yw#c.stdzd_PhysProx"
		local pp_label `pp_label' "`i'.yw#c.stdzd_PhysProx = `labelling' "
		
		local yearwindow_ex `yearwindow_ex' "`i'.yw#c.stdzd_Exposure"
		local yearwindow_cr `yearwindow_cr' "`i'.yw#c.stdzd_Critical"
		local yearwindow_hw `yearwindow_hw' "`i'.yw#c.stdzd_Homework"
	}

	di `yearwindow_cr'
	di `pp_label'
	
	// 1.yw#c.stdzd_PhysProx = "-12" 2.yw#c.stdzd_PhysProx = "-11" 3.yw#c.stdzd_PhysProx = "-10" 4.yw#c.stdzd_PhysProx = "-9" 5.yw#c.stdzd_PhysProx = "-8" 6.yw#c.stdzd_PhysProx = "-7" 7.yw#c.stdzd_PhysProx = "-6" 8.yw#c.stdzd_PhysProx = "-5" 9.yw#c.stdzd_PhysProx = "-4" 10.yw#c.stdzd_PhysProx = "-3" 11.yw#c.stdzd_PhysProx = "-2" 12.yw#c.stdzd_PhysProx = "-1" 13.yw#c.stdzd_PhysProx = "0" 14.yw#c.stdzd_PhysProx = "1" 15.yw#c.stdzd_PhysProx = "2" 16.yw#c.stdzd_PhysProx = "3" 17.yw#c.stdzd_PhysProx = "4" 18.yw#c.stdzd_PhysProx = "5" 19.yw#c.stdzd_PhysProx = "6" 20.yw#c.stdzd_PhysProx = "7" 21.yw#c.stdzd_PhysProx = "8" 22.yw#c.stdzd_PhysProx = "9" 23.yw#c.stdzd_PhysProx = "10" 

// NEED TO ADD THE INTERACTION NUMBERS FOR THE GRAPHS 	
	
/* UNEMP X Physical Proximity  */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_pp') drop(6.yw#c.stdzd_PhysProx) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_PhysProx = "{&le}-6" 1.yw#c.stdzd_PhysProx = "-5" 2.yw#c.stdzd_PhysProx = "-4" 3.yw#c.stdzd_PhysProx = "-3" 4.yw#c.stdzd_PhysProx = "-2" 5.yw#c.stdzd_PhysProx = "-1" 6.yw#c.stdzd_PhysProx = "0" 7.yw#c.stdzd_PhysProx = "1" 8.yw#c.stdzd_PhysProx = "2" 9.yw#c.stdzd_PhysProx = "3" 10.yw#c.stdzd_PhysProx = "4" 11.yw#c.stdzd_PhysProx = "5" 12.yw#c.stdzd_PhysProx = "6" 13.yw#c.stdzd_PhysProx = "7" 14.yw#c.stdzd_PhysProx = "8" 15.yw#c.stdzd_PhysProx = "9" 16.yw#c.stdzd_PhysProx = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Unemployment") yscale(titlegap(*5)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(0.04 6.5 "February 2020", place(w)) 
		
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_unemp_physProx.pdf", as(pdf) replace	
	
	
/* UNEMP X Exposure */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_ex') drop(6.yw#c.stdzd_Exposure) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Exposure = "{&le}-6" 1.yw#c.stdzd_Exposure = "-5" 2.yw#c.stdzd_Exposure = "-4" 3.yw#c.stdzd_Exposure = "-3" 4.yw#c.stdzd_Exposure = "-2" 5.yw#c.stdzd_Exposure = "-1" 6.yw#c.stdzd_Exposure = "0" 7.yw#c.stdzd_Exposure = "1" 8.yw#c.stdzd_Exposure = "2" 9.yw#c.stdzd_Exposure = "3" 10.yw#c.stdzd_Exposure = "4" 11.yw#c.stdzd_Exposure = "5" 12.yw#c.stdzd_Exposure = "6" 13.yw#c.stdzd_Exposure = "7" 14.yw#c.stdzd_Exposure = "8" 15.yw#c.stdzd_Exposure = "9" 16.yw#c.stdzd_Exposure = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Unemployment") yscale(titlegap(*5)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-0.03 6.5 "February 2020", place(w)) 
		
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_unemp_exposure.pdf", as(pdf) replace
		
		
/* UNEMP X Critical Worker */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_cr') drop(6.yw#c.stdzd_Critical) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Critical = "{&le}-6" 1.yw#c.stdzd_Critical = "-5" 2.yw#c.stdzd_Critical = "-4" 3.yw#c.stdzd_Critical = "-3" 4.yw#c.stdzd_Critical = "-2" 5.yw#c.stdzd_Critical = "-1" 6.yw#c.stdzd_Critical = "0" 7.yw#c.stdzd_Critical = "1" 8.yw#c.stdzd_Critical = "2" 9.yw#c.stdzd_Critical = "3" 10.yw#c.stdzd_Critical = "4" 11.yw#c.stdzd_Critical = "5" 12.yw#c.stdzd_Critical = "6" 13.yw#c.stdzd_Critical = "7" 14.yw#c.stdzd_Critical = "8" 15.yw#c.stdzd_Critical = "9" 16.yw#c.stdzd_Critical = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Unemployment") yscale(titlegap(*5)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-0.015 6.5 "February 2020", place(w)) 
		
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_unemp_critWorkers.pdf", as(pdf) replace		
		
		
/* UNEMP X Work from Home */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_hw') drop(6.yw#c.stdzd_Homework) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Homework = "{&le}-6" 1.yw#c.stdzd_Homework = "-5" 2.yw#c.stdzd_Homework = "-4" 3.yw#c.stdzd_Homework = "-3" 4.yw#c.stdzd_Homework = "-2" 5.yw#c.stdzd_Homework = "-1" 6.yw#c.stdzd_Homework = "0" 7.yw#c.stdzd_Homework = "1" 8.yw#c.stdzd_Homework = "2" 9.yw#c.stdzd_Homework = "3" 10.yw#c.stdzd_Homework = "4" 11.yw#c.stdzd_Homework = "5" 12.yw#c.stdzd_Homework = "6" 13.yw#c.stdzd_Homework = "7" 14.yw#c.stdzd_Homework = "8" 15.yw#c.stdzd_Homework = "9" 16.yw#c.stdzd_Homework = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Unemployment") yscale(titlegap(*5)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(0.03 6.5 "February 2020", place(w)) 
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_unemp_homeWork.pdf", as(pdf) replace	
	
// Clear the stored estimates 
	estimates clear 
	macro drop yearwindow_pp yearwindow_ex yearwindow_cr yearwindow_hw
	
// GOOD TO HERE. 
	
	
	
/* 	LABOUR FORCE PARTICIPATION  */	
// run regression LFP
	reg w_lfpartic ${spec1} ${basicChars} ${additionalChars} ${basicFE} ${additionalFE} `weights' `regConditions2' `options1'
	estimates store fullYear

	forval i = 0/23{
		local yearwindow_pp `yearwindow_pp' "`i'.yw#c.stdzd_PhysProx"
		local yearwindow_ex `yearwindow_ex' "`i'.yw#c.stdzd_Exposure"
		local yearwindow_cr `yearwindow_cr' "`i'.yw#c.stdzd_Critical"
		local yearwindow_hw `yearwindow_hw' "`i'.yw#c.stdzd_Homework"
	}
	
/* LFP X Physical Proximity  */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_pp') drop(6.yw#c.stdzd_PhysProx) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_PhysProx = "{&le}-6" 1.yw#c.stdzd_PhysProx = "-5" 2.yw#c.stdzd_PhysProx = "-4" 3.yw#c.stdzd_PhysProx = "-3" 4.yw#c.stdzd_PhysProx = "-2" 5.yw#c.stdzd_PhysProx = "-1" 6.yw#c.stdzd_PhysProx = "0" 7.yw#c.stdzd_PhysProx = "1" 8.yw#c.stdzd_PhysProx = "2" 9.yw#c.stdzd_PhysProx = "3" 10.yw#c.stdzd_PhysProx = "4" 11.yw#c.stdzd_PhysProx = "5" 12.yw#c.stdzd_PhysProx = "6" 13.yw#c.stdzd_PhysProx = "7" 14.yw#c.stdzd_PhysProx = "8" 15.yw#c.stdzd_PhysProx = "9" 16.yw#c.stdzd_PhysProx = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Labour Force Participation") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-0.03 6.5 "February 2020", place(w))  
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_lfp_physProx.pdf", as(pdf) replace	
	
/* LFP X Exposure */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_ex') drop(6.yw#c.stdzd_Exposure) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Exposure = "{&le}-6" 1.yw#c.stdzd_Exposure = "-5" 2.yw#c.stdzd_Exposure = "-4" 3.yw#c.stdzd_Exposure = "-3" 4.yw#c.stdzd_Exposure = "-2" 5.yw#c.stdzd_Exposure = "-1" 6.yw#c.stdzd_Exposure = "0" 7.yw#c.stdzd_Exposure = "1" 8.yw#c.stdzd_Exposure = "2" 9.yw#c.stdzd_Exposure = "3" 10.yw#c.stdzd_Exposure = "4" 11.yw#c.stdzd_Exposure = "5" 12.yw#c.stdzd_Exposure = "6" 13.yw#c.stdzd_Exposure = "7" 14.yw#c.stdzd_Exposure = "8" 15.yw#c.stdzd_Exposure = "9" 16.yw#c.stdzd_Exposure = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Labour Force Participation") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(0.03 6.5 "February 2020", place(w)) 
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_lfp_exposure.pdf", as(pdf) replace		
		
/* LFP X Critical Worker */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_cr') drop(6.yw#c.stdzd_Critical) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Critical = "{&le}-6" 1.yw#c.stdzd_Critical = "-5" 2.yw#c.stdzd_Critical = "-4" 3.yw#c.stdzd_Critical = "-3" 4.yw#c.stdzd_Critical = "-2" 5.yw#c.stdzd_Critical = "-1" 6.yw#c.stdzd_Critical = "0" 7.yw#c.stdzd_Critical = "1" 8.yw#c.stdzd_Critical = "2" 9.yw#c.stdzd_Critical = "3" 10.yw#c.stdzd_Critical = "4" 11.yw#c.stdzd_Critical = "5" 12.yw#c.stdzd_Critical = "6" 13.yw#c.stdzd_Critical = "7" 14.yw#c.stdzd_Critical = "8" 15.yw#c.stdzd_Critical = "9" 16.yw#c.stdzd_Critical = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Labour Force Participation") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-0.01 6.5 "February 2020", place(w)) 
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_lfp_critWorkers.pdf", as(pdf) replace		
		
/* LFP X Work from Home */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_hw') drop(6.yw#c.stdzd_Homework) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Homework = "{&le}-6" 1.yw#c.stdzd_Homework = "-5" 2.yw#c.stdzd_Homework = "-4" 3.yw#c.stdzd_Homework = "-3" 4.yw#c.stdzd_Homework = "-2" 5.yw#c.stdzd_Homework = "-1" 6.yw#c.stdzd_Homework = "0" 7.yw#c.stdzd_Homework = "1" 8.yw#c.stdzd_Homework = "2" 9.yw#c.stdzd_Homework = "3" 10.yw#c.stdzd_Homework = "4" 11.yw#c.stdzd_Homework = "5" 12.yw#c.stdzd_Homework = "6" 13.yw#c.stdzd_Homework = "7" 14.yw#c.stdzd_Homework = "8" 15.yw#c.stdzd_Homework = "9" 16.yw#c.stdzd_Homework = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Labour Force Participation") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-.03 6.5 "February 2020", place(w)) 
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_lfp_homeWork.pdf", as(pdf) replace		
	
// Clear the stored estimates 
	estimates clear 
	macro drop yearwindow_pp yearwindow_ex yearwindow_cr yearwindow_hw	

	
	
	
/* 	WAGES */	
// run regression WAGES 
	reg alt_wages ${spec1} ${basicChars} ${additionalChars} ${basicFE} ${additionalFE} `weights' `regConditions3' `options1'
	estimates store fullYear

	forval i = 0/23{
		local yearwindow_pp `yearwindow_pp' "`i'.yw#c.stdzd_PhysProx"
		local yearwindow_ex `yearwindow_ex' "`i'.yw#c.stdzd_Exposure"
		local yearwindow_cr `yearwindow_cr' "`i'.yw#c.stdzd_Critical"
		local yearwindow_hw `yearwindow_hw' "`i'.yw#c.stdzd_Homework"
	}
	
/* WAGES X Exposure */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_pp') drop(6.yw#c.stdzd_PhysProx) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_PhysProx = "{&le}-6" 1.yw#c.stdzd_PhysProx = "-5" 2.yw#c.stdzd_PhysProx = "-4" 3.yw#c.stdzd_PhysProx = "-3" 4.yw#c.stdzd_PhysProx = "-2" 5.yw#c.stdzd_PhysProx = "-1" 6.yw#c.stdzd_PhysProx = "0" 7.yw#c.stdzd_PhysProx = "1" 8.yw#c.stdzd_PhysProx = "2" 9.yw#c.stdzd_PhysProx = "3" 10.yw#c.stdzd_PhysProx = "4" 11.yw#c.stdzd_PhysProx = "5" 12.yw#c.stdzd_PhysProx = "6" 13.yw#c.stdzd_PhysProx = "7" 14.yw#c.stdzd_PhysProx = "8" 15.yw#c.stdzd_PhysProx = "9" 16.yw#c.stdzd_PhysProx = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Real Hourly Wages") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-1 6.5 "February 2020", place(w)) 
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_wages_physProx.pdf", as(pdf) replace	
	
/* WAGES X Physical Proximity  */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_ex') drop(6.yw#c.stdzd_Exposure) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Exposure = "{&le}-6" 1.yw#c.stdzd_Exposure = "-5" 2.yw#c.stdzd_Exposure = "-4" 3.yw#c.stdzd_Exposure = "-3" 4.yw#c.stdzd_Exposure = "-2" 5.yw#c.stdzd_Exposure = "-1" 6.yw#c.stdzd_Exposure = "0" 7.yw#c.stdzd_Exposure = "1" 8.yw#c.stdzd_Exposure = "2" 9.yw#c.stdzd_Exposure = "3" 10.yw#c.stdzd_Exposure = "4" 11.yw#c.stdzd_Exposure = "5" 12.yw#c.stdzd_Exposure = "6" 13.yw#c.stdzd_Exposure = "7" 14.yw#c.stdzd_Exposure = "8" 15.yw#c.stdzd_Exposure = "9" 16.yw#c.stdzd_Exposure = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Unemployment") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(1 6.5 "February 2020", place(w)) 
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_wages_exposure.pdf", as(pdf) replace	
		
/* WAGES X Critical Worker */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_cr') drop(6.yw#c.stdzd_Critical) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Critical = "{&le}-6" 1.yw#c.stdzd_Critical = "-5" 2.yw#c.stdzd_Critical = "-4" 3.yw#c.stdzd_Critical = "-3" 4.yw#c.stdzd_Critical = "-2" 5.yw#c.stdzd_Critical = "-1" 6.yw#c.stdzd_Critical = "0" 7.yw#c.stdzd_Critical = "1" 8.yw#c.stdzd_Critical = "2" 9.yw#c.stdzd_Critical = "3" 10.yw#c.stdzd_Critical = "4" 11.yw#c.stdzd_Critical = "5" 12.yw#c.stdzd_Critical = "6" 13.yw#c.stdzd_Critical = "7" 14.yw#c.stdzd_Critical = "8" 15.yw#c.stdzd_Critical = "9" 16.yw#c.stdzd_Critical = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Real Hourly Wages") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(0.5 6.5 "February 2020", place(w)) 
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_wages_critWorkers.pdf", as(pdf) replace
		
/* WAGES X Work from Home */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_hw') drop(6.yw#c.stdzd_Homework) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Homework = "{&le}-6" 1.yw#c.stdzd_Homework = "-5" 2.yw#c.stdzd_Homework = "-4" 3.yw#c.stdzd_Homework = "-3" 4.yw#c.stdzd_Homework = "-2" 5.yw#c.stdzd_Homework = "-1" 6.yw#c.stdzd_Homework = "0" 7.yw#c.stdzd_Homework = "1" 8.yw#c.stdzd_Homework = "2" 9.yw#c.stdzd_Homework = "3" 10.yw#c.stdzd_Homework = "4" 11.yw#c.stdzd_Homework = "5" 12.yw#c.stdzd_Homework = "6" 13.yw#c.stdzd_Homework = "7" 14.yw#c.stdzd_Homework = "8" 15.yw#c.stdzd_Homework = "9" 16.yw#c.stdzd_Homework = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Real Hourly Wages") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(1 6.5 "February 2020", place(w)) 
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_wages_homeWork.pdf", as(pdf) replace	
	
// Clear the stored estimates 
	estimates clear 
	macro drop yearwindow_pp yearwindow_ex yearwindow_cr yearwindow_hw
	

	
	
	
/* 	HOURS WORKED  */	
// run regression hours worked
	reg alt_hours_actual ${spec1} ${basicChars} ${additionalChars} ${basicFE} ${additionalFE} `weights' `regConditions4' `options1'
	estimates store fullYear

	forval i = 0/23{
		local yearwindow_pp `yearwindow_pp' "`i'.yw#c.stdzd_PhysProx"
		local yearwindow_ex `yearwindow_ex' "`i'.yw#c.stdzd_Exposure"
		local yearwindow_cr `yearwindow_cr' "`i'.yw#c.stdzd_Critical"
		local yearwindow_hw `yearwindow_hw' "`i'.yw#c.stdzd_Homework"
	}
	
/* HOURS X Physical Proximity  */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_pp') drop(6.yw#c.stdzd_PhysProx) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_PhysProx = "{&le}-6" 1.yw#c.stdzd_PhysProx = "-5" 2.yw#c.stdzd_PhysProx = "-4" 3.yw#c.stdzd_PhysProx = "-3" 4.yw#c.stdzd_PhysProx = "-2" 5.yw#c.stdzd_PhysProx = "-1" 6.yw#c.stdzd_PhysProx = "0" 7.yw#c.stdzd_PhysProx = "1" 8.yw#c.stdzd_PhysProx = "2" 9.yw#c.stdzd_PhysProx = "3" 10.yw#c.stdzd_PhysProx = "4" 11.yw#c.stdzd_PhysProx = "5" 12.yw#c.stdzd_PhysProx = "6" 13.yw#c.stdzd_PhysProx = "7" 14.yw#c.stdzd_PhysProx = "8" 15.yw#c.stdzd_PhysProx = "9" 16.yw#c.stdzd_PhysProx = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Total Actual Hours Worked Weekly") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-2 6.5 "February 2020", place(w))
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_hours_physProx.pdf", as(pdf) replace	
	
	
/* HOURS X Exposure */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_ex') drop(6.yw#c.stdzd_Exposure) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Exposure = "{&le}-6" 1.yw#c.stdzd_Exposure = "-5" 2.yw#c.stdzd_Exposure = "-4" 3.yw#c.stdzd_Exposure = "-3" 4.yw#c.stdzd_Exposure = "-2" 5.yw#c.stdzd_Exposure = "-1" 6.yw#c.stdzd_Exposure = "0" 7.yw#c.stdzd_Exposure = "1" 8.yw#c.stdzd_Exposure = "2" 9.yw#c.stdzd_Exposure = "3" 10.yw#c.stdzd_Exposure = "4" 11.yw#c.stdzd_Exposure = "5" 12.yw#c.stdzd_Exposure = "6" 13.yw#c.stdzd_Exposure = "7" 14.yw#c.stdzd_Exposure = "8" 15.yw#c.stdzd_Exposure = "9" 16.yw#c.stdzd_Exposure = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Total Actual Hours Worked Weekly") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(2 6.5 "February 2020", place(w)) 
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_hours_exposure.pdf", as(pdf) replace		
		
		
/* HOURS X Critical Worker */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_cr') drop(6.yw#c.stdzd_Critical) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Critical = "{&le}-6" 1.yw#c.stdzd_Critical = "-5" 2.yw#c.stdzd_Critical = "-4" 3.yw#c.stdzd_Critical = "-3" 4.yw#c.stdzd_Critical = "-2" 5.yw#c.stdzd_Critical = "-1" 6.yw#c.stdzd_Critical = "0" 7.yw#c.stdzd_Critical = "1" 8.yw#c.stdzd_Critical = "2" 9.yw#c.stdzd_Critical = "3" 10.yw#c.stdzd_Critical = "4" 11.yw#c.stdzd_Critical = "5" 12.yw#c.stdzd_Critical = "6" 13.yw#c.stdzd_Critical = "7" 14.yw#c.stdzd_Critical = "8" 15.yw#c.stdzd_Critical = "9" 16.yw#c.stdzd_Critical = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Total Actual Hours Worked Weekly") yscale(titlegap(*15)) ///
		xline(5.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(-1.5 6.5 "February 2020", place(w)) 
	
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_hours_critWorkers.pdf", as(pdf) replace 	
	
	
/* HOURS X Work from Home */
	coefplot (fullYear) ///
		, 	keep(`yearwindow_hw') drop(6.yw#c.stdzd_Homework) vertical omitted baselevels ///
		coeflabels( 0.yw#c.stdzd_Homework = "{&le}-6" 1.yw#c.stdzd_Homework = "-5" 2.yw#c.stdzd_Homework = "-4" 3.yw#c.stdzd_Homework = "-3" 4.yw#c.stdzd_Homework = "-2" 5.yw#c.stdzd_Homework = "-1" 6.yw#c.stdzd_Homework = "0" 7.yw#c.stdzd_Homework = "1" 8.yw#c.stdzd_Homework = "2" 9.yw#c.stdzd_Homework = "3" 10.yw#c.stdzd_Homework = "4" 11.yw#c.stdzd_Homework = "5" 12.yw#c.stdzd_Homework = "6" 13.yw#c.stdzd_Homework = "7" 14.yw#c.stdzd_Homework = "8" 15.yw#c.stdzd_Homework = "9" 16.yw#c.stdzd_Homework = "10" ) ///
		yline(0, lcolor(gs8) lstyle(major_grid) ) ytitle("Total Actual Hours Worked Weekly") yscale(titlegap(*15)) ///
		xline(6.5, lcolor(10) lstyle(minor_grid) ) xtitle("Months since February 2020", margin(medium)) ///
		text(2 6.5 "February 2020", place(w))
		
		graph export "ReplicationFolder_CJE_Covid/Figures/eventStudy_hours_homeWork.pdf", as(pdf) replace 

// Clear the stored estimates 
	estimates clear 
	macro drop yearwindow_pp yearwindow_ex yearwindow_cr yearwindow_hw
	
/* timer off */
	timer off 11
	timer list 