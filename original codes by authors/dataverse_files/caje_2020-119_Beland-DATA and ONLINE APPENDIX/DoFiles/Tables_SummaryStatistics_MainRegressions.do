/*
Summary Statistics

Version 1
	- First pass, likely from June 2020 
	
Version 2
	- Accommodating the R and R 
	
	- Update the dataset 
	
	- Update the restrictions (15 - 64) and in the public & private sector 
	
	- clean up the esttab command and display the contents in Stata 
	
	- Update the latex File 
		This is done so that the table is more easily recreated 
		
	- Delete all the excess code at the bottom (index and demographic
		summary statistics) See January_*_v2 for the deleted code 

Version 3
	- Moving some of the labels to the cleaning data file (v2's lines: 50 - 57)
	
Version 4
	- Adding the standardized variables for indexes to the table 
	
Version 5
	- Updating the file: 	30mar2021
	
*/
	
/* Clear all  */	
	clear all 

/* Timer */	
	timer on 27
	
/* Grab the current dataset */	
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta"


/* Just a reminder of the conditions that will be imposed on the regressions */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" 
	local  regConditions2 "if (K_age_12 <= 10)"
	local  regConditions3 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)"
	local  regConditions4 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)"

	
/* 
Impose the same restrictions on the summary statistics as on the regression.
This is done because there are multiple different conditions
*/
	gen sum_w_unemp = w_unemp ///
		if (K_age_12 <= 10) & (K_lfsstat != 3)
		
	gen sum_w_lfp = w_lfpartic ///
		if (K_age_12 <= 10)
		
	gen sum_alt_wages = alt_wages ///
		if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)
		
	gen sum_alt_hours = alt_hours ///
		if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)
		
	gen sum_alt_hours_actual = alt_hours_actual ///
		if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)

	
/* Label variables so that they look pretty in the tables */	
	label variable sum_w_unemp 			"Unemployed"                   
	label variable sum_w_lfp 			"Labour Force Participation"           
	label variable sum_alt_wages 		"Real Hourly Wage"                    
	label variable sum_alt_hours 		"Total Usual Hours of Work"           
	label variable sum_alt_hours_actual "Total Actual Hours of Work"

	
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

	
/* New Table */
	estpost summarize ///
		sum_w_unemp sum_w_lfp sum_alt_wages sum_alt_hours_actual ///
		sum_stdzd_PhysProx sum_stdzd_Exposure sum_stdzd_Critical sum_stdzd_Homework ///
		[aweight = K_finalwt]
			
/* Export to LaTeX */
	esttab using "ReplicationFolder_CJE_Covid/Tables/March_SummaryStatisticsForOutcomes_actualHours.tex" ///
		, 	replace /// 
		noisily compress label /// 
		eqlabels(none) varwidth(50) modelwidth(4) wrap ///
		varlabels(_cons Constant, begin(\hspace{0.5cm})  end([0.25em]) nolast) /// 
		mlabels(, none) nobase nodepvars nonumbers noobs ///
		refcat( sum_w_unemp "\textit{Labour Market Outcomes}" sum_stdzd_PhysProx "\textit{Index Variables}", nolabel) ///
		cells("mean( fmt(%9.2f) label( Mean ) ) sd( fmt(%9.2f) label( Std. Dev. ) ) min( fmt(%9.1f) label( Min ) ) max( fmt(%9.1f) label( Max ) ) count( fmt(%9.0f) label( Observations ) )") ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `" &\multicolumn{5}{c}{Labour Force Survey} \\"' `"\cline{2-6} \\"' `"\textit{Summary Statistics}"') ///
		posthead(`"\hline"' `"\\"') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"')
		 
/* 
Directions for perfectly recreating the tables in LaTeX 
	- Add a linebreak between the last labour market outcome variable and the 
		first index variable 
	- Make the \hspace{0.25cm} for each of the panel titles 
*/
			
/* Clear the estimates so that there is no interference */			
	est clear
	
/* Timer */	
	timer off 27
	timer list 27 