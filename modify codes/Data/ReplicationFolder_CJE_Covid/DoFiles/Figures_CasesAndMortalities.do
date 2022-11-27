/*
	Making Figures By Province
	
January

Version 1 
	- All of the old Code 
	
Version 2
	- Only the code that makes graphs that we care about 
*/


clear	
	
/* Timer */	
	timer on 9
	
/*------------------------------------------------------------------------------ 	
*
* Cases
*
------------------------------------------------------------------------------*/
// OLD DATA SOURCE	import delimited "https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/timeseries_prov/cases_timeseries_prov.csv"
// NEW DATA SOURCE 	import delimited "https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_prov/cases_timeseries_prov.csv"
	import delimited "ReplicationFolder_CJE_Covid/Data/cases_timeseries_prov_April3.csv"
	
// Create province categorical variables out of the string 	
	encode province, gen(prov)

// See what it looks like 	
	tab prov
	tab prov, nolabel

// Recode the provinces so that they are in order from East to West 	
	recode prov (5 8 14 12 = . ) (1 = 48 "Alberta") (2 = 59 "British Columbia") (3 = 46 "Manitoba") ///
		(11 = 24 "Quebec") (13 = 47 "Saskatchewan") (6 = 13 "New Brunswick") (10 = 11 "Prince Edward Island") ///
		 (7 = 12 "Nova Scotia") (9 = 35 "Ontario") ///
		(4 = 10 "Newfoundland and Labrador") ///
		, gen(provNumbers)

// Again, checking that everything is correct 		
	tab prov
	tab prov, nolab
	tab provNumbers
	tab provNumbers, nolab

/* NUMBER OF CASES */
	preserve 

// Doing the cases 
	keep if cases != .
	
// Start breaking down the strings day-month-year 
	split date_report, parse("-")

// Rename parts of the date 	
	rename (date_report1 date_report2 date_report3) (day month year)

// Destring the string 
	destring day month year, replace

// Create a new time-series variables 	
	gen monthDayYear = mdy(month, day, year)
	clonevar rawDate = monthDayYear
	format monthDayYear %td

// Order and sort the variable 	
	order province monthDayYear day month year cases 
	sort province monthDayYear day month year cases 

// COLLAPSE INTO CUMULATIVE CASES BY PROVINCE X DAY 
	collapse (sum) cumulative_cases, by(provNumbers monthDayYear)

	// Label the new variable. 	
		label variable cumulative_cases "Daily Cumulative Cases"

	// Keep only provinces
		keep if provNumbers != . 

	// Generate the logarithm of the cumulative cases 	
		gen logCumCases = log10(1 + cumulative_cases)
		
	// Label the variable for logarithm 
		label variable logCumCases "Daily Cumulative Cases (Log-base 10)"

	/* Taylor's Style */
	// ssc install blindschemes, replace 
		set scheme plotplain
		xtset provNumbers monthDayYear, daily 

		
	// CASES, All Provinces, Linear 
		xtline cumulative_cases ///
			if inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ///
			, overlay ///
			xtitle("", margin(medium)) ///
			ytitle(, margin(medium))  ///
			tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")

	// Export the graph to the new location 
		graph export "ReplicationFolder_CJE_Covid/Figures/CumCases_allProv.pdf", as(pdf) replace	

		
		
	// CASES, All Province, Logarithmic 
		xtline logCumCases ///
			if inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ///
			, overlay ///
			xtitle("", margin(medium)) ///
			ytitle(, margin(medium)) ylabel(0 "0" 1 "10" 2 "100" 3 "1,000" 3.69897000434 "5,000" 4 "10,000" 4.39794001 "25,000" 5 "100,000" 6 "1,000,000")	  ///
			tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")
		
		graph export "ReplicationFolder_CJE_Covid/Figures/logCumCases_allProv.pdf", as(pdf) replace
		
		
		
	// CASES, Four Largest Provinces, Linear
		xtline cumulative_cases ///
			if 	( inlist(provNumbers, 59, 48, 35, 24) ) & ( inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ) ///
			, overlay ///
			plot1opts(lp(solid) lw(medthick) lc(gs3)) ///
			plot2opts(lp(dash) lw(medthick) lc(gs3)) ///
			plot3opts(lp("...-..") lw(medthick) lc(gs3)) ///
			plot4opts(lp("._.") lw(medthick) lc(gs3)) ///
			xtitle("", margin(medium)) ///
			ytitle(, margin(medium))   ///
			tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")
				
		graph export "ReplicationFolder_CJE_Covid/Figures/CumCases_4Prov.pdf", as(pdf) replace		


	// CASES, Four Largest Provinces, Logarithmic
		xtline logCumCases ///
			if 	( inlist(provNumbers, 59, 48, 35, 24) ) ///
			& 	( inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ) ///
			, 	overlay ///
			plot1opts(lp(solid) lw(medthick) lc(gs3)) ///
			plot2opts(lp(dash) lw(medthick) lc(gs3)) ///
			plot3opts(lp("...-..") lw(medthick) lc(gs3)) ///
			plot4opts(lp("._.") lw(medthick) lc(gs3)) ///
			xtitle("", margin(medium)) ///
			ytitle(, margin(medium)) ylabel(0 "0" 1 "10" 2 "100" 3 "1,000" 3.69897000434 "5,000" 4 "10,000" 4.39794001 "25,000" 5 "100,000" 6 "1,000,000")	  ///
			tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")

		graph export "ReplicationFolder_CJE_Covid/Figures/logCumCases_4Prov.pdf", as(pdf) replace

// Restore the collapsed datasets 
	restore 

/*------------------------------------------------------------------------------ 
*
* NUMBER OF DEATHS 
*
------------------------------------------------------------------------------*/
	clear 
	
// OLD DATASET CALL	import delimited "https://raw.githubusercontent.com/ishaberry/Covid19Canada/master/timeseries_prov/mortality_timeseries_prov.csv"
// NEW DATASET CALL import delimited "https://raw.githubusercontent.com/ccodwg/Covid19Canada/master/timeseries_prov/mortality_timeseries_prov.csv"
	import delimited "ReplicationFolder_CJE_Covid/Data/mortality_timeseries_prov_April3.csv"

// Doing the deaths 
	keep if deaths != .
	

	split date_death_report, parse("-")

// 
	rename (date_death_report1 date_death_report2 date_death_report3) (day month year)
	destring day month year, replace

	gen monthDayYear = mdy(month, day, year)
	format monthDayYear %td

// order province health_region monthDayYear day month year deaths 
// sort province health_region monthDayYear day month year deaths 

	unique province 

	label variable cumulative_deaths "Daily Cumulative Deaths"

/* Taylor's Style */
// ssc install blindschemes, replace 
	set scheme plotplain

// Make the provinces have numbers. 
	encode province, gen(provNum)

// Recode the provinces so it is in order from east to west 
	recode provNum (5 8 12 14 = . ) (1 = 48 "Alberta") (2 = 59 "British Columbia") (3 = 46 "Manitoba") ///
		(11 = 24 "Quebec") (13 = 47 "Saskatchewan") (6 = 13 "New Brunswick") (10 = 11 "Prince Edward Island") ///
		 (7 = 12 "Nova Scotia") (9 = 35 "Ontario") ///
		(4 = 10 "Newfoundland and Labrador") ///
		, gen(provNumbers)

// Eliminate the redundant variable
	drop provNum
	drop if provNumbers == . 
	
// Declare the datasets as panel 
	xtset provNumbers monthDayYear, daily 

	collapse (sum) cumulative_deaths, by(provNumbers monthDayYear)

	gen logCumdeaths = log10(1 + cumulative_deaths)
	label variable logCumdeaths "Daily Cumulative Deaths (Log-base 10)"
	
// DEATHS, All Provinces, Linear
	xtline cumulative_deaths ///
		if inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ///
		, overlay ///
		xtitle("", margin(medium)) ///
		ytitle(, margin(medium))   ///
		tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")	

	graph export "ReplicationFolder_CJE_Covid/Figures/Cumdeaths_allProv.pdf", as(pdf) replace	



// DEATHS, All Provinces, Logarithmic 
	xtline logCumdeaths ///
		if inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ///
		, overlay ///
		xtitle("", margin(medium)) ///
		ytitle(, margin(medium)) ylabel(0 "0" 1 "10" 2 "100" 3 "1,000" 3.69897000434 "5,000" 4 "10,000")  ///
		tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")
	
	graph export "ReplicationFolder_CJE_Covid/Figures/logCumdeaths_allProv.pdf", as(pdf) replace
	


// DEATHS, Four Largest Provinces, Linear 
	xtline cumulative_deaths ///
		if 	( inlist(provNumbers, 59, 48, 35, 24) ) ///
		& 	( inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ) ///
		, 	overlay ///
		plot1opts(lp(solid) lw(medthick) lc(gs3)) ///
		plot2opts(lp(dash) lw(medthick) lc(gs3)) ///
		plot3opts(lp("...-..") lw(medthick) lc(gs3)) ///
		plot4opts(lp("._.") lw(medthick) lc(gs3)) ///
		/// legend(order(4 "Quebec" 3 "Ontario" 1 "Alberta" 2 "British Columbia")) /// 
		xtitle("", margin(medium)) ///
		ytitle(, margin(medium))   ///
		tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")

	graph export "ReplicationFolder_CJE_Covid/Figures/Cumdeaths_4Prov.pdf", as(pdf) replace		
	

	
// DEATHS, Four Largest Provinces, Logarithmic 
	xtline logCumdeaths ///
		if 	( inlist(provNumbers, 59, 48, 35, 24) ) ///
		& 	( inrange(monthDayYear, mdy(1,1,2020), mdy(12,31,2020)) ) ///
		, 	overlay ///
		plot1opts(lp(solid) lw(medthick) lc(gs3)) ///
		plot2opts(lp(dash) lw(medthick) lc(gs3)) ///
		plot3opts(lp("...-..") lw(medthick) lc(gs3)) ///
		plot4opts(lp("._.") lw(medthick) lc(gs3)) ///
		/// legend(order(4 "Quebec" 3 "Ontario" 1 "Alberta" 2 "British Columbia")) /// 
		xtitle("", margin(medium)) ///
		ytitle(, margin(medium)) ylabel(0 "0" 1 "10" 2 "100" 3 "1,000" 3.69897000434 "5,000" 4 "10,000")  ///
		tlabel(31Jan2020 "Jan. 31, 2020" 31Jul2020 "Jul. 31 2020" 31Dec2020 "Dec. 31, 2020")

	graph export "ReplicationFolder_CJE_Covid/Figures/logCumdeaths_4Prov.pdf", as(pdf) replace
		
		
/* timer off */
	timer off 9
	timer list 