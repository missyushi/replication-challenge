/*

Summary Statistics for NOC10 groups of the index values 

Version 1 (March 5, 2021)
	- First pass

Version 2 (March 30, 2021)
	- Updated .dta File 
	
*/
	
/* Clear */	
	clear 
	
/* Timer */	
	timer on 28	

/* Use the most up-to-date data file */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"

/* */
// bysort K_noc_40: eststo: estpost ttest w_unemp [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3), by(postCovid) 
	

	
matrix storingTestStatistics = J(40,16,.)	
	
forval noc = 1/40{
	di `noc'
	
	/* Quietly */
	quietly{ 
		/* Unemployment */
		summ w_unemp [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & K_noc_40 == `noc'	& (postCovid == 0)
		
		matrix storingTestStatistics[`noc',1] = r(mean)*100
			
		summ w_unemp [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3)	& (K_noc_40 == `noc')	& postCovid == 1
			
		matrix storingTestStatistics[`noc',2] = r(mean)*100
		
		regress w_unemp postCovid [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) 	& (K_noc_40 == `noc')
			
		matrix temp = r(table)	
			
		matrix storingTestStatistics[`noc',3] = _b[postCovid]*100
		matrix storingTestStatistics[`noc',4] = temp[3,1]	
		
		
		/* LFP */
		summ w_lfp [aweight = K_finalwt] if (K_age_12 <= 10) & K_noc_40 == `noc'	& (postCovid == 0)
		
		matrix storingTestStatistics[`noc',5] = r(mean)*100
			
		summ w_lfp [aweight = K_finalwt] if (K_age_12 <= 10) & (K_noc_40 == `noc')	& postCovid == 1
			
		matrix storingTestStatistics[`noc',6] = r(mean)*100
		
		regress w_lfp postCovid [aweight = K_finalwt] if (K_age_12 <= 10)	& (K_noc_40 == `noc')
			
		matrix temp = r(table)	
			
		matrix storingTestStatistics[`noc',7] = _b[postCovid]*100
		matrix storingTestStatistics[`noc',8] = temp[3,1]	
		
		
		/* Hourly Wage */
		summ alt_wages [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2) & K_noc_40 == `noc' & (postCovid == 0)
		
		matrix storingTestStatistics[`noc',9] = r(mean)
			
		summ alt_wages [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2) & (K_noc_40 == `noc')	& postCovid == 1
			
		matrix storingTestStatistics[`noc',10] = r(mean)
		
		regress alt_wages postCovid [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)	& (K_noc_40 == `noc')
			
		matrix temp = r(table)	
			
		matrix storingTestStatistics[`noc',11] = _b[postCovid]
		matrix storingTestStatistics[`noc',12] = temp[3,1]	
		
		
		/* Hours Worked */
		summ alt_hours_actual [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2) & K_noc_40 == `noc' & (postCovid == 0)
		
		matrix storingTestStatistics[`noc',13] = r(mean)
			
		summ alt_hours_actual [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2) & (K_noc_40 == `noc')	& postCovid == 1
			
		matrix storingTestStatistics[`noc',14] = r(mean)
		
		regress alt_hours_actual postCovid [aweight = K_finalwt] if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)	& (K_noc_40 == `noc')
			
		matrix temp = r(table)	
			
		matrix storingTestStatistics[`noc',15] = _b[postCovid]
		matrix storingTestStatistics[`noc',16] = temp[3,1]	
	}	
}	

matrix list storingTestStatistics
	
/* What does it look like ? */	
	matrix list storingTestStatistics	
	
	matrix Z_one = storingTestStatistics[1..40, 1..8]	
	matrix Z_two = storingTestStatistics[1..40, 9..16]
	
/* Export the table to LaTeX */	
	esttab matrix(Z_one	, fmt(%9.1f)) ///
		using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_summaryStatistics_NOC_40_unempLfp.tex" ///
		, 	replace ///
		label noisily ///
		compress /// 
		varwidth(20) modelwidth(4) wrap nobase nodepvars ///
		eqlabels(, none) ///
		collabels(,none ) /// 
		delimiter("	&") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" & \multicolumn{4}{c}{Unemployment (\%)} & \multicolumn{4}{c}{Labour Force Participation (\%)} \\ "' `" \cline{2-5} \cline{6-9} \\"' ) ///
		posthead(`"& \multicolumn{2}{c}{Means} & & &\multicolumn{2}{c}{Means} \\"' `" \cline{2-3} \cline{6-7} \\"' `" &Pre-COVID &Post-COVID &Difference &t-statistic &Pre-COVID &Post-COVID &Difference &t-statistic \\"' `"\hline"' `"\\"') ///
		/// Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
		mlabels(, none) ///
		mgroups( , none) ///
		varlabels(_cons Constant, end("" "%") nolast) 		

		
/* Export the table to LaTeX */	
	esttab matrix(Z_two	, fmt(%9.1f)) ///
		using "ReplicationFolder_CJE_Covid/Tables/March_beforeAndAfter_summaryStatistics_NOC_40_wageHours.tex" ///
		, 	replace ///
		label noisily ///
		compress /// 
		varwidth(20) modelwidth(4) wrap nobase nodepvars ///
		eqlabels(, none) ///
		collabels(,none ) /// 
		delimiter("	&") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" & \multicolumn{4}{c}{Real Hourly Wages (\$ CAD)} & \multicolumn{4}{c}{Total Actual Hours Worked Weekly} \\ "' `" \cline{2-5} \cline{6-9} \\"' ) ///
		posthead(`"& \multicolumn{2}{c}{Means} & & & \multicolumn{2}{c}{Means} \\"' `" \cline{2-3} \cline{6-7} \\"' `" &Pre-COVID &Post-COVID &Difference &t-statistic &Pre-COVID &Post-COVID &Difference &t-statistic \\"' `"\hline"' `"\\"') ///
		/// Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic Pre-COVID Post-COVID Difference t-statistic
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') ///
		mlabels(, none) ///
		mgroups( , none) ///
		varlabels(_cons Constant, end("" "%") nolast) 	
		
		
/* THINGS TO MAKE THE TABLE LOOK LIKE A FINISHED PRODUCT 
	- You will need to add the following labels by hand, and in this order. 
	
	Senior management occupations 
	Specialized middle management occupations  
	Middle management occupations in retail and wholesale trade and customer services  
	Middle management occupations in trades, transportation, production and utilities  
	Professional occupations in business and finance  
	Administrative and financial supervisors and administrative occupations  
	Finance, insurance and related business administrative occupations 
	Office support occupations 
	Distribution, tracking and scheduling co-ordination occupations  
	Professional occupations in natural and applied science  
	Technical occupations related to natural and applied sciences 
	Professional occupations in nursing  
	Professional occupations in health (except nursing) 
	Technical occupations in health  
	Assisting occupations in support of health services  
	Professional occupations in education services  
	Professional occupations in law and social, community and government services  
	Paraprofessional occupations in legal, social, community and education services   
	Occupations in front-line public protection services  
	Care providers and educational, legal and public protection support occupations  
	Professional occupations in art and culture  
	Technical occupations in art, culture, recreation and sport   
	Retail sales supervisors and specialized sales occupations  
	Service supervisors and specialized service occupations  
	Sales representatives and salespersons - wholesale and retail trade   
	Service representatives and other customer and personal service occupations  
	Sales support occupations  
	Service support and other service occupations, n.e.c.  
	Industrial, electrical and construction trades  
	Maintenance and equipment operation trades 
	Other installers, repairers and servicers and material handlers  
	Transport and heavy equipment operation and related maintenance occupations  
	Trades helpers, construction labourers and related occupations  
	Supervisors and technical occupations in natural resources, agriculture and related production  
	Workers in natural resources, agriculture and related production 
	Harvesting, landscaping and natural resources labourers 
	Processing, manufacturing and utilities supervisors and central control operators  
	Processing and manufacturing machine operators and related production workers 
	Assemblers in manufacturing 
	Labourers in processing, manufacturing and utilities  	

*/	

timer off 28
timer list 28 