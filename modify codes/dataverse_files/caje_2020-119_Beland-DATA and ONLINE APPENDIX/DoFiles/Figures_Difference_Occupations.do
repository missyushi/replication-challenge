/*------------------------------------------------------------------------------
*
* Difference Figures in Stata 
*
* March 8, 2021
*
* Version 1
*	- First Pass 
*	- Using Taylor's code as a template 
*	- Dataset: 		mainDataset_Prov_8Mar2021_AdditionalMeasures_v3
*
* VERSION 2
* 	- renaming the exported file names 
*
* VERSION 3
*	- Updated dataset 
------------------------------------------------------------------------------*/


/* Clear all */	
	clear 

/* timer */
	timer on 10 
	
/* Call the .dta file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"
	
/* Restrict the endpoints for comparison (January 2021 and May 2021) */
	keep if (K_year == 2020 & K_month == 1) | (K_year == 2020 & K_month == 5) // start and end points for comparison
	
/* Looking at the dataset */	
	order K_year K_month K_noc_10 K_noc_40
	sort K_year K_month K_noc_10 K_noc_40
	
/* Confirm / check the labels for the graphs */
	tab K_noc_10
	tab K_noc_10, nolab 
	
/*	Updating the labels for the NOC broad categories */
	label define broadGroups ///
		1 "Business, finance and administration" ///
		2 "Natural and applied sciences" ///
		3 "Management occupations" ///
		4 "Health occupations" ///
		5 "Education, law and social, community and government services" ///
		6 "Art, culture, recreation and sport" ///
		7 "Sales and service" ///
		8 "Trades, transport and equipment operators" ///
		9 "Natural resources, agriculture" ///
		10 "Manufacturing and utilities"
		
	label values K_noc_10 broadGroups 
 
/* drop missing observations for NOC broad categories */	
	drop if missing(K_noc_10)	
		
		
// generate the occupation specific index values
	bysort K_noc_10: egen mean_proximity 	= mean(stdzd_Exposure) 		if postCovid == 1
	bysort K_noc_10: egen mean_exposure		= mean(stdzd_PhysProx) 		if postCovid == 1
	bysort K_noc_10: egen mean_critWork 	= mean(stdzd_Homework) 		if postCovid == 1		
	bysort K_noc_10: egen mean_homeWork 	= mean(stdzd_Critical) 		if postCovid == 1

/* Generate the occupation specific unemployment rate */
	bysort K_noc_10 K_year K_month: egen aggNoc_unemp 	= total(w_unemp * K_finalwt)
	bysort K_noc_10 K_year K_month: egen aggNoc_lf 		= total( w_lfpartic * K_finalwt)
	bysort K_noc_10 K_year K_month: gen  aggNoc_rate 	= (aggNoc_unemp / aggNoc_lf) * 100	
		
/*------------------------------------------------------------------------------
*
* Do this for PROXIMITY INDEX 
*
------------------------------------------------------------------------------*/

/* Preserve */
	preserve 
	
/* Collapse into average dataset */
	collapse (mean) aggNoc_rate mean_proximity, by(K_noc_10 K_year K_month)

	// Change in unemployment rate by NOC. 
		bysort K_noc_10: gen diff_urate = aggNoc_rate[2] - aggNoc_rate[1] // get the change in unemployment rate
		
	/* Generate Position markers */
		gen pos = 3 
		
		replace pos = 9 	if ( inlist(K_noc_10,2,3,4) )
		replace pos = 12 	if ( inlist(K_noc_10,10,5) )
		replace pos = 1		if ( inlist(K_noc_10,1))
		replace pos = 5 	if (inlist(K_noc_10,8) )
		
	// Regress difference in unemployment rate on proximity
		reg diff_urate mean_proximity
		
	// Grab the r-squared from the regression to put in the figure
		local r2: display %5.3f e(r2) 
		
	// Graph the two outcomes together 
		graph twoway ///
			(scatter diff_urate mean_proximity ///
				if (K_year == 2020 & K_month == 5) ///
				,  mlabv(pos) mlabel(K_noc_10) ///
			) ///
			(lfit diff_urate mean_proximity ///
				, 	lpattern(dash)), xtitle(Proximity Index) ///
				ytitle(Percentage Point Change in Unemployment Rate) ///
				xscale(range(-3.5 3.5)) xlabel(-3(1)3) ///
				text(2 2 "R-squared = `r2'") legend(off)
		  
	// Export the graph. 	  
		graph export "ReplicationFolder_CJE_Covid/Figures/occ_physProx_unemp.pdf", as(pdf) replace
		
/* Restore */		
	restore

/*------------------------------------------------------------------------------
*
* Do this for EXPOSURE INDEX 
*
------------------------------------------------------------------------------*/

/* Preserve */
	preserve 
	
/* Collapse into average dataset */
	collapse (mean) aggNoc_rate mean_exposure, by(K_noc_10 K_year K_month)

	// Change in unemployment rate by NOC. 
		bysort K_noc_10: gen diff_urate = aggNoc_rate[2] - aggNoc_rate[1] // get the change in unemployment rate
		
	/* Generate Position markers */
		gen pos = 3 
	
	/* The changes */
		replace pos = 9 	if ( inlist(K_noc_10,2,3,4) )
		replace pos = 12 	if ( inlist(K_noc_10,10,5) )
	
	// Regress difference in unemployment rate on exposure
		reg diff_urate mean_exposure
		
	// Grab the r-squared from the regression to put in the figure
		local r2: display %5.3f e(r2) 
		
	// Graph the two outcomes together 
		graph twoway ///
			(scatter diff_urate mean_exposure ///
				if (K_year == 2020 & K_month == 5) ///
				,  mlabv(pos) mlabel(K_noc_10) ///
			) ///
			(lfit diff_urate mean_exposure ///
				, 	lpattern(dash)), xtitle(Exposure Index) ///
				ytitle(Percentage Point Change in Unemployment Rate) ///
				xscale(range(-3.5 3.5)) xlabel(-3(1)3) xlabel(-3(1)3) ///
				text(2 2 "R-squared = `r2'") legend(off)
		  
	// Export the graph. 	  
		graph export "ReplicationFolder_CJE_Covid/Figures/occ_exposure_unemp.pdf", as(pdf) replace
		
/* Restore */		
	restore

	
/*------------------------------------------------------------------------------
*
* Do this for CRITICAL WORKERS INDEX 
*
------------------------------------------------------------------------------*/

/* Preserve */
	preserve 
	
/* Collapse into average dataset */
	collapse (mean) aggNoc_rate mean_critWork, by(K_noc_10 K_year K_month)

	// Change in unemployment rate by NOC. 
		bysort K_noc_10: gen diff_urate = aggNoc_rate[2] - aggNoc_rate[1] // get the change in unemployment rate
		
	/* Generate Position markers */
		gen pos = 3 
	
	/**/
		replace pos = 12 	if ( inlist(K_noc_10,10,1,5) )
		replace pos = 6 	if (inlist(K_noc_10,8) )
		
		
	// Regress difference in unemployment rate on critWork
		reg diff_urate mean_critWork
		
	// Grab the r-squared from the regression to put in the figure
		local r2: display %5.3f e(r2) 
		
	// Graph the two outcomes together 
		graph twoway ///
			(scatter diff_urate mean_critWork ///
				if (K_year == 2020 & K_month == 5) ///
				,  mlabv(pos) mlabel(K_noc_10) ///
			) ///
			(lfit diff_urate mean_critWork ///
				, 	lpattern(dash)), xtitle(Critical Worker Index) ///
				ytitle(Percentage Point Change in Unemployment Rate) ///
				xscale(range(-3.5 3.5)) xlabel(-3(1)3) ///
				text(2 -2 "R-squared = `r2'") legend(off)
		  
	// Export the graph. 	  
		graph export "ReplicationFolder_CJE_Covid/Figures/occ_critWork_unemp.pdf", as(pdf) replace
		
/* Restore */		
	restore
	
/*------------------------------------------------------------------------------
*
* Do this for WORK FROM HOME INDEX
*
------------------------------------------------------------------------------*/

/* Preserve */
	preserve 
	
/* Collapse into average dataset */
	collapse (mean) aggNoc_rate mean_homeWork, by(K_noc_10 K_year K_month)

	// Change in unemployment rate by NOC. 
		bysort K_noc_10: gen diff_urate = aggNoc_rate[2] - aggNoc_rate[1] // get the change in unemployment rate
		
	/* Generate Position markers*/
		gen pos = 3 
		
		replace pos = 12 	if ( inlist(K_noc_10,5) )	
		replace pos = 10 	if ( inlist(K_noc_10,1,10) )	
		replace pos = 9 	if ( inlist(K_noc_10,8,3,4) )

	// Regress difference in unemployment rate on homeWork
		reg diff_urate mean_homeWork
		
	// Grab the r-squared from the regression to put in the figure
		local r2: display %5.3f e(r2) 
		
	// Graph the two outcomes together 
		graph twoway ///
			(scatter diff_urate mean_homeWork ///
				if (K_year == 2020 & K_month == 5) ///
				,  mlabv(pos) mlabel(K_noc_10) ///
			) ///
			(lfit diff_urate mean_homeWork ///
				, 	lpattern(dash)), xtitle(Work from Home Index) ///
				ytitle(Percentage Point Change in Unemployment Rate) ///
				xscale(range(-3.5 3.5)) xlabel(-3(1)3) ///
				text(2 2 "R-squared = `r2'") legend(off)
		  
	// Export the graph. 	  
		graph export "ReplicationFolder_CJE_Covid/Figures/occ_homeWork_unemp.pdf", as(pdf) replace
		
/* Restore */		
	restore
	
/* timer off */
	timer off 10 
	timer list 