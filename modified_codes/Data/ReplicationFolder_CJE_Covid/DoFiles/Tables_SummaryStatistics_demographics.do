/*

Summary Statistics for Demographic Characteristics of the index values 

Version 1 (March 5, 2021)
	- First pass
	
Version 2 (March 8, 2021)
	- Updating the data file:	8mar2021
	
Version 3 (March 30, 2021)
	- Updating the data file: 30mar2021
	
	
*/

	clear 
	
/* Timer */	
	timer on 26
	
/* Grab the current dataset */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

/* Just a reminder of the conditions that will be imposed on the regressions */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" 
	local  regConditions2 "if (K_age_12 <= 10)"
	local  regConditions3 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)"
	local  regConditions4 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)"

	
/* Generate the restricted standardized index values 
	- SHOULD BE NOTED! We are just restricting to ages 15 - 64
*/
	gen sum_stdzd_PhysProx = stdzd_PhysProx ///
		if (K_age_12 <= 10) 
	
	gen sum_stdzd_Exposure = stdzd_Exposure ///
		if (K_age_12 <= 10) 
	
	gen sum_stdzd_Critical = stdzd_Critical ///
		if (K_age_12 <= 10) 
	
	gen sum_stdzd_Homework = stdzd_Homework ///
		if (K_age_12 <= 10)
		
/* Label variables so that they look pretty in the tables */
	label variable sum_stdzd_PhysProx "Physical Proximity (Standardized)"
	label variable sum_stdzd_Exposure "Exposure (Standardized)"
	label variable sum_stdzd_Critical "Critical Worker (Standardized)" 
	label variable sum_stdzd_Homework "Work from Home (Standardized)"


/* Keeping track of the locals. Will extend with every iteration */	
	local varLabels ""
	

/* TOP PANEL - FEMALE */	
	estpost tabstat ///
		sum_stdzd_PhysProx sum_stdzd_Exposure sum_stdzd_Critical sum_stdzd_Homework ///
		[aweight = K_finalwt] ///
		,	by(female) ///
		statistics(mean sd) nototal 

/* Show in LaTeX */
	esttab using "ReplicationFolder_CJE_Covid/Tables/March_SummaryStatistics_indexes_demographics.tex" ///
		, 	replace /// 
		noisily compress label /// 
		eqlabels(`e(labels)', begin(\hspace{0.25cm})) varwidth(50) modelwidth(4) wrap ///
		varlabels(_cons Constant, nolast) /// 
		mlabels(, none) nobase nodepvars nonumbers noobs ///
		cells("sum_stdzd_PhysProx( fmt(%9.3f) ) sum_stdzd_Exposure( fmt(%9.3f) ) sum_stdzd_Critical( fmt(%9.3f) ) sum_stdzd_Homework( fmt(%9.3f) )") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{4}{c}{Indexes (Standardized)} \\"' `"\cline{2-5} \\"' `"&\multicolumn{1}{c}{Physical} &\multicolumn{1}{c}{Exposure} &\multicolumn{1}{c}{Critical} &\multicolumn{1}{c}{Work} \\"' `"\textit{Summary Statistics} &\multicolumn{1}{c}{Proximity} &\multicolumn{1}{c}{to Diesase} &\multicolumn{1}{c}{Worker} &\multicolumn{1}{c}{from Home} \\"') ///
		posthead(`"\hline"' `"\\"') ///
		prefoot(`""') ///
		postfoot(`"\\"')		
	
	
	
/* MIDDLE PANELS - Loop over the characteristics */
	foreach x in women_kidsUnder13 marStat_2 ageCats_alt{

		estpost tabstat ///
			sum_stdzd_PhysProx sum_stdzd_Exposure sum_stdzd_Critical sum_stdzd_Homework ///
			[aweight = K_finalwt] ///
			,	by(`x') ///
			statistics(mean sd) nototal 
			
	/* Show in LaTeX */
		esttab using "ReplicationFolder_CJE_Covid/Tables/March_SummaryStatistics_indexes_demographics.tex" ///
			, 	append /// 
			noisily compress label /// 
			eqlabels(`e(labels)', begin(\hspace{0.25cm})) varwidth(50) modelwidth(4) wrap ///
			varlabels(_cons Constant, nolast) /// 
			mlabels(, none) nobase nodepvars nonumbers noobs ///
			cells("sum_stdzd_PhysProx( fmt(%9.3f) ) sum_stdzd_Exposure( fmt(%9.3f) ) sum_stdzd_Critical( fmt(%9.3f) ) sum_stdzd_Homework( fmt(%9.3f) )") ///
			prehead(`""') ///
			posthead(`""') ///
			prefoot(`""') ///		
			postfoot(`"\\"')
		
	}
	
/* Bottom Panel */	
	estpost tabstat ///
		sum_stdzd_PhysProx sum_stdzd_Exposure sum_stdzd_Critical sum_stdzd_Homework ///
		[aweight = K_finalwt] ///
		,	by(Educ) ///
		statistics(mean sd) nototal 
	
	
/* Show in LaTeX */
	esttab using "ReplicationFolder_CJE_Covid/Tables/March_SummaryStatistics_indexes_demographics.tex" ///
		, 	append /// 
		noisily compress label /// 
		eqlabels(`e(labels)', begin(\hspace{0.25cm})) varwidth(50) modelwidth(4) wrap ///
		varlabels(_cons Constant, nolast) /// 
		mlabels(, none) nobase nodepvars nonumbers noobs ///
		cells("sum_stdzd_PhysProx( fmt(%9.3f) ) sum_stdzd_Exposure( fmt(%9.3f) ) sum_stdzd_Critical( fmt(%9.3f) ) sum_stdzd_Homework( fmt(%9.3f) )") ///
		prehead(`""') ///
		posthead(`""') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"')	
		
 
/* 
Directions for perfectly recreating the tables in LaTeX 
	- Delete all of the useless rows in the table. (e.g. 17 - 21)
	- Delete "mean and sd" from rows, and make the variable labels match up with
		the first row (mean) 
	- Put parentheses around the std. dev. 
	- Clean up the row names. 
*/
			
/* Clear the estimates so that there is no interference */			
	est clear
	
/* Timer */	
	timer off 26
	timer list 