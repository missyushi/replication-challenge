/* Regression Tables */ 


clear 

/* timer */
	timer on 17

use "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset_CPSS.dta"


		
/* Regression Tables */ 


********************************************************************************
/* MAIN TABLE 8 - PERCEIVED MENTAL HEALTH */
********************************************************************************

// Make two tables with two panels in each. 
global basicChars "i.(sex marStat) ib3.ageCats ib3.(educ) i.immig"

// Different Control Variables 
local spec1 $basicChars ib1.empStat
local spec2 $basicChars ib3.telework
local spec3 $basicChars i.impactOnFinResp_3 i.mightLoseJob_2

local options ", robust "


// MENTAL HEALTH
foreach y in rev_mentalHealth{
    forval i = 1/3{
	   quietly eststo: oprobit `y' `spec`i'' [pweight = covid_wt] if `y' != 9 `options'
		estadd local basicChars "Yes"
	}
}


esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_MentalHealth.tex" ///
	, 	replace ///
	drop( cut* ) b(%9.3f) se(%9.3f) /// 
	label noisily nostar compress eqlabels(none) noomit  ///
	varwidth(50) wrap nobase nodepvars mlabels( , none ) ///
	mgroups( , none ) ///
	varlabels(_cons Constant, end("[0.5em]") nolast) ///
	prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `"& \multicolumn{3}{c}{ \textsc{Perceived Mental Health} } \\"' `"\cline{2-4} \\"') ///
	posthead(`"\hline"' `"\\"') ///
	prefoot(`"\\"') ///
	postfoot( `"\hline \hline"' `"\end{tabular*}"')	
	

eststo drop * 



********************************************************************************
/* 	MAIN TABLE 9 - LABOUR MARKET OUTCOMES */
********************************************************************************
// Different Control Variables 
local spec1 $basicChars 
local spec2 $basicChars ib1.empStat
local spec3 $basicChars ib3.telework	
	

foreach y in lm_40 lm_30{
    forval i = 1/3{
	    
		if `i' == 2 & "`y'" == "lm_30"{
		    local addCond "& empStat != 4"
		}
	   quietly eststo: oprobit `y' `spec`i'' [pweight = covid_wt] if `y' != 9 `addCond' `options'
		estadd local basicChars "Yes"
	}
}

esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_LabourConcerns.tex" ///
	, 	replace ///
	drop( cut* ) b(%9.3f) se(%9.3f) /// 
	label noisily nostar compress eqlabels(none) noomit  ///
	varwidth(50) wrap nobase nodepvars mlabels( , none ) ///
	mgroups( , none ) ///
	varlabels(_cons Constant, end("[0.5em]") nolast) ///
	prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `"& \multicolumn{3}{c}{ \textsc{Financial Concerns} } & \multicolumn{3}{c}{ \textsc{Might Lose Job} } \\"' `" \cline{2-4} \cline{5-7} \\"' ) ///
	posthead(`"\hline"' `"\\"') ///
	prefoot(`"\\"') ///
	postfoot( `"\hline \hline"' `"\end{tabular*}"')		

eststo drop *



********************************************************************************
/*	APPENDIX TABLE 15 - PRECEIVED HEALTH */
********************************************************************************
local spec1 $basicChars ib1.empStat
local spec2 $basicChars ib3.telework
local spec3 $basicChars i.impactOnFinResp_3 i.mightLoseJob_2
// ALL HEALTH 
foreach y in rev_health{
    forval i = 1/3{
	   eststo: oprobit `y' `spec`i'' [pweight = covid_wt] if `y' != 9 `options'
	}
}


esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_Health.tex" ///
	, 	replace ///
	drop( cut* ) b(%9.3f) se(%9.3f) /// 
	label noisily nostar compress eqlabels(none) noomit  ///
	varwidth(50) wrap nobase nodepvars mlabels( , none ) ///
	mgroups( , none ) ///
	varlabels(_cons Constant, end("[0.5em]") nolast) ///
	prehead(`"\begin{tabular*}{\textwidth}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `"& \multicolumn{3}{c}{ \textsc{Perceived Health} } \\"' `"\cline{2-4} \\"') ///
	posthead(`"\hline"' `"\\"') ///
	prefoot(`"\\"') ///
	postfoot( `"\hline \hline"' `"\end{tabular*}"')			
		
	

eststo drop *	



********************************************************************************
/* CPSS - SUMMARY STATISTICS APPENDIX TABLE 2*/
********************************************************************************

	eststo: estpost tabulate bh_30 pempstc [aweight = covid_wt] 
	esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_SummaryStatistics.tex" ///
		, replace  ///
		compress sfmt(%9.3f) noobs label unstack noisily nonumbers ///
		eqlabels( ,none) /// 
		cells("rowpct(fmt(%9.1f))" ) ///
		delimiter( " & ") ///
		varwidth(50) ///
		mlabels(, none) ///
		collabels(,none) ///
		varlabels( , begin("\hspace{0.25cm}") end( ) nolast) /// 
		modelwidth(4) wrap ///
		prehead(`"\begin{tabular*}{\hsize}{ @{\extracolsep{\fill}}l*{@span}{c}}"' `"\hline\hline"' `"\\"' `"&\multicolumn{6}{c}{ \textbf{Employment Status Categories} } \\"' `"\cline{2-7} \\"' `"&\multicolumn{3}{c}{ \textbf{Employed} } \\ "' `"\cline{2-4} \\"' `" & At Work & Absent, Not COVID & Absent COVID & Unemployed & Not Stated & \textbf{Total} \\"') ///
		posthead(`"\hline"' `"\\"' `"\hspace{0.25cm}\textbf{Perceived Mental Health} \\"') ///
		prefoot(`"%"') ///
		postfoot( `"%"') 
		
	eststo clear 	
		
	eststo: estpost tabulate lm_40 pempstc [aweight = covid_wt] 
	esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_SummaryStatistics.tex" ///
		, append ///
		compress sfmt(%9.3f) noobs label unstack noisily nonumbers /// 
		eqlabels( ,none) /// 
		cells("rowpct(fmt(%9.1f))" ) ///
		delimiter( " & ") ///
		varwidth(50) ///
		collabels(,none) /// 
		mlabels(, none) varlabels( , begin("\hspace{0.25cm}") end( ) nolast) ///
		modelwidth(4) wrap ///
		prehead(`"\\"') ///
		posthead(`"\hline"' `"\\"' `"\hspace{0.25cm}\textbf{COVID-19 impacts ability meet Financial obligations or essential needs} \\"') ///
		postfoot( `""') 
		
	eststo clear
		
	eststo: estpost tabulate lm_30 pempstc [aweight = covid_wt] 
	esttab using "ReplicationFolder_CJE_Covid/Tables/CPSS_SummaryStatistics.tex" ///
		, append ///
		compress sfmt(%9.3f) noobs label unstack noisily nonumbers ///
		eqlabels( ,none) /// 
		cells("rowpct(fmt(%9.1f))" ) ///
		delimiter( " & ") ///
		varwidth(50) ///
		collabels(,none) ///		
		mlabels(, none) varlabels( , begin("\hspace{0.25cm}") end( ) nolast) /// 
		refcat( 2.lm_30 `"\textbf{I might lose main job or main self-emp income next 4 weeks}"') ///
		modelwidth(4) wrap ///
		prehead(`"\\"') ///
		posthead(`"\hline"' `"\\"' `"\hspace{0.25cm}\textbf{I might lose main job or main self-emp income next 4 weeks} \\ "') ///
		prefoot(`"\\"') ///
		postfoot( `"\hline \hline"' `"\end{tabular*}"') 
		
	eststo clear 
	
/* timer off */
	timer off 17 
	timer list 