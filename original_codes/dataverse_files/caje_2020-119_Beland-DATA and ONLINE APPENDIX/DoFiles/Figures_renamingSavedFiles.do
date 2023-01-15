/* 
Renaming the figures with appropriate names 

OVERVIEW 
	- Renames all of the figures so that they align with the document 

Version 1
	- First Pass 

*/

/* clear */
	clear 

/* timer on */
	timer on 30 

/* Can we make a new directory? */	
	capture mkdir "ReplicationFolder_CJE_Covid/Figures/RenamedFigures"

/* Display error message */
	di _rc
	di "0 	== New Folder Created "
	di "693 == Folder Already Exists "

/* Change Directory since we are only in one place */
	cd "ReplicationFolder_CJE_Covid/Figures/"
	
/*------------------------------------------------------------------------------
			MAIN FIGURES
------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
 FIGURE - 1 
------------------------------------------------------------------------------*/	
	copy 	"CumCases_4Prov.pdf"	///
			"RenamedFigures/Figure_1_A_CumulativeCases_FourProvinces.pdf" ///
			,	replace 

	copy 	"Cumdeaths_4Prov.pdf"	///
			"RenamedFigures/Figure_1_B_CumulativeDeaths_FourProvinces.pdf" ///
			,	replace			
	
	
/*------------------------------------------------------------------------------
 FIGURE - 2
------------------------------------------------------------------------------*/	
	copy 	"bubblesExposureAndProx_HomeWorkQuartiles.pdf"	///
			"RenamedFigures/Figure_2_A_bubblesExposureAndProx_HomeWorkQuartiles.pdf" ///
			,	replace
		
	copy 	"bubblesExposureAndProx_HomeWorkQuartiles.pdf"	///
			"RenamedFigures/Figure_2_A_bubblesExposureAndProx_critWorkerQuartiles.pdf" ///
			,	replace		
		
		
/*------------------------------------------------------------------------------
 FIGURE - 3
------------------------------------------------------------------------------*/
	global panel1 "A"
	global panel2 "B"
	global panel3 "C"
	global panel4 "D"
	
	local counter = 1 
	
	foreach outcome in "unempRate_Canada" "lfp_Canada" "unempRate_altProvinces" "lfp_altProvinces"{
	    
		copy 	"alt_w_`outcome'.pdf"	///
				"RenamedFigures/Figure_3_${panel`counter'}_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
	
	
/*------------------------------------------------------------------------------
 FIGURE - 4
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "proximity" "exposure" "critNumber" "HomeWork"{
	    
		copy 	"alt_w_unempRate_median_`outcome'.pdf"	///
				"RenamedFigures/Figure_4_${panel`counter'}_unempRate_median_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
			
			
/*------------------------------------------------------------------------------
 FIGURE - 5 
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "proximity" "exposure" "critNumber" "HomeWork"{
	    
		copy 	"alt_w_lfp_median_`outcome'.pdf"	///
				"RenamedFigures/Figure_5_${panel`counter'}_lfp_median_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
	
			
/*------------------------------------------------------------------------------
 FIGURE - 6 
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "physProx" "exposure" "critWork" "homeWork"{
	    
		copy 	"occ_`outcome'_unemp.pdf"	///
				"RenamedFigures/Figure_6_${panel`counter'}_occ_`outcome'_unemp.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
			
/*------------------------------------------------------------------------------
 FIGURE - 7
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "physProx" "exposure" "critWorkers" "homeWork"{
	    
		copy 	"eventStudy_unemp_`outcome'.pdf"	///
				"RenamedFigures/Figure_7_${panel`counter'}_eventStudy_unemp_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
			
/*------------------------------------------------------------------------------
 FIGURE - 8
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "physProx" "exposure" "critWorkers" "homeWork"{
	    
		copy 	"eventStudy_lfp_`outcome'.pdf"	///
				"RenamedFigures/Figure_8_${panel`counter'}_eventStudy_lfp_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
		
		
		
/*------------------------------------------------------------------------------
			APPENDIX FIGURES
------------------------------------------------------------------------------*/		
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 1
------------------------------------------------------------------------------*/	
	copy 	"logCumCases_4Prov.pdf"	///
			"RenamedFigures/Appendix_Figure_1_A_LogCumulativeCases_FourProvinces.pdf" ///
			,	replace 

	copy 	"logCumdeaths_4Prov.pdf"	///
			"RenamedFigures/Appendix_Figure_1_B_LogCumulativeDeaths_FourProvinces.pdf" ///
			,	replace		
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 2
------------------------------------------------------------------------------*/	
	copy 	"CumCases_allProv.pdf"	///
			"RenamedFigures/Appendix_Figure_2_A_CumulativeCases_AllProvinces.pdf" ///
			,	replace 

	copy 	"Cumdeaths_allProv.pdf"	///
			"RenamedFigures/Appendix_Figure_2_B_CumulativeDeaths_AllProvinces.pdf" ///
			,	replace		
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 3
------------------------------------------------------------------------------*/	
	copy 	"logCumCases_allProv.pdf"	///
			"RenamedFigures/Appendix_Figure_3_A_LogCumulativeCases_AllProvinces.pdf" ///
			,	replace 

	copy 	"Cumdeaths_allProv.pdf"	///
			"RenamedFigures/Appendix_Figure_3_B_LogCumulativeDeaths_AllProvinces.pdf" ///
			,	replace	
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 4 
------------------------------------------------------------------------------*/	
	copy 	"bubblesExposureAndHomeWork_critWorkerQuartiles.pdf"	///
			"RenamedFigures/Appendix_Figure_4_A_bubblesExposureAndHomeWork_critWorkerQuartiles.pdf" ///
			,	replace
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 5 
------------------------------------------------------------------------------*/
	local counter = 1 
	
	foreach outcome in "actualHrsWorked_Canada" "hrWage_Canada" "actualHrsWorked_altProvinces" "hrWage_altProvinces"{
	    
		copy 	"alt_w_`outcome'.pdf"	///
				"RenamedFigures/Appendix_Figure_5_${panel`counter'}_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}			
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURES - DOUBLE-LOOP; DOING 6 - 9 
------------------------------------------------------------------------------*/	
	global name1 "unempRate"
	global name2 "lfp"
	global name3 "actualHoursWorked"
	global name4 "hrWage"
	
	local figureNumber = 6 
	
	foreach variable in "sex" "womanWithKids" "ageCats_alt" "marStat_2"{
	    
		local counter = 1
		
		foreach outcome in "alt_w_unempRate" "alt_w_lfp" "alt_actualHrsWorked" "alt_w_hrWage"{ 
		    
			copy 	"`outcome'_`variable'.pdf"	///
					"RenamedFigures/Appendix_Figure_`figureNumber'_${panel`counter'}_${name`counter'}_`variable'.pdf" ///
				,	replace	    
					
			local counter = `counter' + 1 
		}	
		
		local figureNumber = `figureNumber' + 1 
	}

	
/*------------------------------------------------------------------------------
 APPENDIX FIGURES - 11 
------------------------------------------------------------------------------*/	
	copy 	"alt_actualHrsWorked_weekEarnQuart.pdf"	///
			"RenamedFigures/Appendix_Figure_11_A_actualHrsWorked_weekEarnQuart.pdf" ///
			,	replace 

	copy 	"alt_w_hrWage_weekEarnQuart.pdf"	///
			"RenamedFigures/Appendix_Figure_11_B_actualHrsWorked_hrWage.pdf" ///
			,	replace

			
/*------------------------------------------------------------------------------
 APPENDIX FIGURES - DOUBLE-LOOP; DOING 11 - 13 
------------------------------------------------------------------------------*/	
	local figureNumber = 11 
	
	foreach variable in "Educ" "immig" "ysm_immig" {
	    
		local counter = 1
		
		foreach outcome in "alt_w_unempRate" "alt_w_lfp" "alt_actualHrsWorked" "alt_w_hrWage"{ 
		    
			copy 	"`outcome'_`variable'.pdf"	///
					"RenamedFigures/Appendix_Figure_`figureNumber'_${panel`counter'}_${name`counter'}_`variable'.pdf" ///
				,	replace	    
					
			local counter = `counter' + 1 
		}	
		
		local figureNumber = `figureNumber' + 1 
	}	
 	
	
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 14
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "proximity" "exposure" "critNumber" "HomeWork"{
	    
		copy 	"alt_actualHrsWorked_median_`outcome'.pdf"	///
				"RenamedFigures/Figure_4_${panel`counter'}_actualHrsWorked_median_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}
			
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 15 
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "proximity" "exposure" "critNumber" "HomeWork"{
	    
		copy 	"alt_w_hrWage_median_`outcome'.pdf"	///
				"RenamedFigures/Figure_5_${panel`counter'}_hrWage_median_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}	
	
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 16
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "physProx" "exposure" "critWorkers" "homeWork"{
	    
		copy 	"eventStudy_wages_`outcome'.pdf"	///
				"RenamedFigures/Appendix_Figure_16_${panel`counter'}_eventStudy_wages_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}	
			
/*------------------------------------------------------------------------------
 APPENDIX FIGURE - 17
------------------------------------------------------------------------------*/	
	local counter = 1 
	
	foreach outcome in "physProx" "exposure" "critWorkers" "homeWork"{
	    
		copy 	"eventStudy_hours_`outcome'.pdf"	///
				"RenamedFigures/Appendix_Figure_17_${panel`counter'}_eventStudy_hours_`outcome'.pdf" ///
			,	replace	    
				
		local counter = `counter' + 1 
	}	
	
/* timer off */
	timer off 30
	timer list 