/*

	Analysis Do-Files 
	
Version 1 (March 5, 2021)
	- First Pass 
	
Components 

DATA  

January_addingDifferentMeasures_toBeUsedForAnalysisFiles_v3.do 
	LAST UPDATED: 	March 30, 2021
	LAST RUN: 		March 30, 2021 
	
FIGURES 
	January_figures_actualHours_v7
		LAST UPDATED: 	March 30, 2021
		LAST RUN: 		March 30, 2021 

	March_differenceFigures_v3	
		LAST UPDATED:	March 30, 2021
		LAST RUN:		March 30, 2021 
		
	March_differenceFigures_characteristics_v2
		LAST UPDATED:	March 30, 2021
		LAST RUN:		March 30, 2021 		
		
		
TABLES (Out of order)
	March_analysis_summaryStatistics_actualHours_v5.do
		LAST UPDATED: 	March 30, 2021 
		LAST RUN:		March 30, 2021 
	
	March_analysis_summaryStatistics_NOCMeans_v2.do
		LAST UPDATED:	March 30, 2021 
		LAST RUN:		March 30, 2021 
	
	March_analysis_summaryStatistics_demographics_v3.do
		LAST UPDATED: 	MARCH 30, 2021 
		LAST RUN:		MARCH 30, 2021
	
	March_analysis_beforeAndAfter_v7
		LAST UPDATED: 	MARCH 30, 2021
		LAST RUN:		March 30, 2021 	
	
	March_analysis_indexesInteracted_appendix_v1.do	
		LAST UPDATED: 	March 18, 2021 
		LAST RUN:		MARCH 18, 2021 		
	
	March_analysis_indexesInteracted_nonHealthCareWorkers_appendix_v1.do	
		LAST UPDATED: 	March 18, 2021 
		LAST RUN:		MARCH 18, 2021 			
	
	
APPENDIX TABLES 
	ComparingLFSwithCPSS_v3
		LAST UPDATED: 	MARCH 5, 2021 
		LAST RUN:		MARCH 5, 2021 

		
	March_analysis_beforeAndAfter_appendixTables_v5
		LAST UPDATED: 	MARCH 16, 2021
		LAST RUN:		March 16, 2021 
		
	March_analysis_shortTerm_ReasonsAwayFromWork_v1		
		LAST UPDATED: 	March 15, 2021 
		LAST RUN:		MARCH 15, 2021 
		
	March_analysis_indexesInteracted_v1.do"
		LAST UPDATED: 	March 18, 2021 
		LAST RUN:		MARCH 18, 2021 		

	March_analysis_indexesInteracted_nonHealthCareWorkers_v1.do"
		LAST UPDATED: 	March 18, 2021 
		LAST RUN:		MARCH 18, 2021 			
		
	March_analysis_heterogeneity_v1		
		LAST UPDATED: 	March 15, 2021 
		LAST RUN:		MARCH 15, 2021 		
		
*/

/* Preamble */

/* Version number */
	version 16
	
/* CLEAR ALL */
	clear all 

/* A selection of global */
	global D1_pathway "C:/Users/Derek Mikola/Dropbox/"
	global D2_pathway "C:/Users/derek/Dropbox"
	global D3_pathway "C:/Users/Derek Mikola/Dropbox/ARCHIVE_COVID_Papers/Covid-19 Canada/Final_ReplicationFolder/Data"
	
/* Set the pathway */
	global masterPathway "$D3_pathway" // 											
	
/* Change the pathway */
	cd "${masterPathway}"
	
/* timer */
	timer on 1 

/* Relevant PACKAGES - last installed on May 31, 2021 
	ssc install estout, replace 
	ssc install boottest, replace
	ssc install unique, replace 
	ssc install coefplot, replace 
	ssc install blindschemes, replace 
	ssc install grstyle, replace 
	ssc install palettes, replace 
	ssc install colrspace, replace 
	ssc install tabout, replace
*/	

/* Set-up local ado folder */
	global adoBase "${masterPathway}/ReplicationFolder_CJE_Covid/ado"
	capture mkdir "${adoBase}"
	
/* Install any packages locally */
	sysdir set PERSONAL "${adoBase}"

/*------------------------------------------------------------------------------
*
* DATA
*
------------------------------------------------------------------------------*/ 

/*------------------------------------------------------------------------------
																Append_LFS.do

Append_LFS.do appends all of the LFS from January 2016 to December 2020. 

First, the file converts .sav files to .dta files. 

Second, the file appends all of the .dta files into a single file. This single
file is called: 
	lfs_2016jan_to_2020December.dta  
------------------------------------------------------------------------------*/
// do "ReplicationFolder_CJE_Covid/DoFiles/Append_LFS.do"



/*------------------------------------------------------------------------------
															CheckingData_LFS.do

CheckingData_LFS.do acts is a first pass at cleaning the dataset. 

This file is used to check the coding of the various elements of the LFS. It 
should be noted that Stata appends (some) values of variables incorrectly across 
different years of the LFS. 

In order to overcome this, we create new variables which take the old, 
appended variables, and convert their labels to unique categories as strings. 
From here, we manually group the categories of the variables which have the same 
categories but minor discrepancies. 

An example of this is something like class of worker, where after our append, we
have 20 groups all with different values and different labels. The key is that 
the LFS only has ever had 7 groups across our time period (Private, Public, 
four types of self-employed, and unpaid family work). Inspecting the value labels
confirms this. So we regroup them appropriately. 
------------------------------------------------------------------------------*/
// do "ReplicationFolder_CJE_Covid/DoFiles/CheckingData_LFS.do"


/*------------------------------------------------------------------------------ 
																CleaningCPI.do
																
CleaningCPI.do takes in a CANSIM table for all-items between 2016 and 2020 and 
makes tidier the dataset so we can merge it with our main dataset later on. 
------------------------------------------------------------------------------*/ 
// do "ReplicationFolder_CJE_Covid/DoFiles/CleaningCPI.do"



/*------------------------------------------------------------------------------ 
														Index_Construction.do 
														
Index_Construction.do takes in our ONet measures, the Dingle-Nieman measures, 
and the essential workers measures and then creates a single file which can be
merged. 									
------------------------------------------------------------------------------*/
// do "ReplicationFolder_CJE_Covid/DoFiles/Index_Construction.do"


 
/*------------------------------------------------------------------------------
												AdditionalDataCleaning_LFS.do
												
This merges the CPI, indexes and the LFS data into one file called 
mainDataset.dta which is the last stage before analysis. This file is called in
most often of all the .dta files. 
------------------------------------------------------------------------------*/
// do "ReplicationFolder_CJE_Covid/DoFiles/AdditionalDataCleaning_LFS.do"


/*------------------------------------------------------------------------------
														DataCleaning_CPSS.do
														
This file assembles the CPSS dataset and cleans the variables necessary for 
the analysis. It creates a dataset called mainDataset_CPSS.dta.
------------------------------------------------------------------------------*/
// do "ReplicationFolder_CJE_Covid/DoFiles/DataCleaning_CPSS.do"


/*------------------------------------------------------------------------------
*
* FIGURES
*
------------------------------------------------------------------------------*/

/*
												Figures_CasesAndMortalities.do
												
All of the time-series graphs of the cases and mortalities over time. This do-
file requires calling from the internet to download the dataset from the follow-
ing website: https://github.com/ccodwg/Covid19Canada. 
*/
do "ReplicationFolder_CJE_Covid/DoFiles/Figures_CasesAndMortalities.do"


/*
												Figures_TimeSeriesAndBubbles.do
												
All of the time-series graph, NOC-index Bubbles, and the correlations in the 
are constructed here. 

********************************************************************************There are undoubtedly some graphs which are produced and
********************************************************************************are not used. These will have to be cleaned. 
 
*/
	do "ReplicationFolder_CJE_Covid/DoFiles/Figures_TimeSeriesAndBubbles.do"
	
	
/*------------------------------------------------------------------------------
											Figures_Difference_Occupations.do

These are the Difference figures for the indices and by occupations. 
------------------------------------------------------------------------------*/	
	do "ReplicationFolder_CJE_Covid/DoFiles/Figures_Difference_Occupations.do"
	
	
	
/*------------------------------------------------------------------------------
										Figures_EventStudies_Indexes.do
										
Does the first event studies for the paper. This also creates a .dta file if it
does not already exist. 
------------------------------------------------------------------------------*/
	do "ReplicationFolder_CJE_Covid/DoFiles/Figures_EventStudies_Indexes.do"			
 

/*------------------------------------------------------------------------------
*
* TABLES 
*
------------------------------------------------------------------------------*/


// Table 1 - Outcome variables and standardized indexes 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_SummaryStatistics_MainRegressions.do"

	
// Table 2 - Indexes across occupations 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_SummaryStatistics_NOCMeans.do"
	
	
// Table 3 - Indexes across demographic characteristics 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_SummaryStatistics_demographics.do"
	
	
// Tables 5 + 6 - ( Unemp + LFP X {Canada, (Qc, On, Ab, Bc)} ) 
/*
	IMPORTANT NOTE: THE BOOTSTRAPPED and MULTIWAY STANDARD ERRORS NEED TO BE 
	MOVED IN THE LATEX DOCUMENT FOR THE PDF to PROPERLY COMPILE 
*/
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_BeforeAndAfter"

	
// 	TABLE 6 - Indexes with interactions (Unemp and LFP)
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted.do"

	
// 	TABLE 7 - Indexes with interactions for only non-Healthcare Workers (Unemp and LFP)	
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted_nonHealthCareWorkers.do"
	
	
// TABLE 8	- (CPSS) Perceived Mental Health 
// TABLE 9	- (CPSS) Financial Concenrs / Might Lose Job 
// APPENDIX TABLE 2: CANADIAN PERSPECTIVES SURVEY SERIES SUMMARY STATISTICS 
// APPENDIX TABLE 15 - CPSS SOMETHING OR OTHER 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_CPSS.do"


/* 
*
* APPENDIX TABLES 
*
*/


// APPENDIX TABLE 1: THIS IS NOT PRODUCED BUT RATHER A DOCUMENT 


// APPENDIX TABLE 2: CANADIAN PERSPECTIVES SURVEY SERIES SUMMARY STATISTICS 
// CREATED ABOVE 

// APPENDIX TABLE 3	- CPSS and LFS COMPARISON 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_ComparingLFS_And_CPSS.do"	
	
// APPENDIX TABLES 4 and 5 - ( Hourly Wage + Hours Worked X {Canada, (Qc, On, Ab, Bc)} )
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_BeforeAndAfter_appendix.do"
	
// APPENDIX TABLE 6 - Short-term Differences from Work (Old Appendix Table 3) 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_ReasonAwayFromWork_appendix.do"	
	
// APPENDIX TABLE 7 - Indexes with interactions (Real Wages and Hours Worked) 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted_appendix.do"		
	
// APPENDIX TABLE 8 - Indexes with interactioncs for only non-Healthcare Workers  (Real Wages and Hours Worked) 	
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted_nonHealthCareWorkers_appendix.do"	
	
// APPENDIX TABLES 9 - Indexes with interactions - ESSENTIAL WORKERS  (Unemp and LFP) 	
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted_AlternativeIndexForEssentialWorker.do"		
	
// APPENDIX TABLES 10 - Indexes with interactions - ESSENTIAL WORKERS  (Real Wages and Hours Worked) 	
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Indexes_Interacted_AlternativeIndexForEssentialWorker_appendix.do"		
	
// APPENDIX TABLES 11 - 14 - Heterogeneity Tables 
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_Regressions_Heterogeneity_appendix.do"	
	
	
// APPENDIX TABLE 15 - CPSS SOMETHING OR OTHER 
// CREATED ABOVE 

	
// APPENDIX TABLES 16 and 17 - Difference before and after COVID-19 for outcomes  
	do "ReplicationFolder_CJE_Covid/DoFiles/Tables_SummaryStatistics_NOC_Difference_BeforeAndAfter_appendix.do"
	
	
/*------------------------------------------------------------------------------
*
* OTHER 
*
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
										Figures_renamingSavedFiles.do
------------------------------------------------------------------------------*/	
	do "ReplicationFolder_CJE_Covid/DoFiles/Figures_renamingSavedFiles.do"
	
/* timer */	
	timer off 1
	timer list 
