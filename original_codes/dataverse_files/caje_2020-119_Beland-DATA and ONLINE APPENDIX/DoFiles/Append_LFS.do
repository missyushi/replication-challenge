/*
	Constructing An Appended LFS 
	
	First Pass: 
		- April 2, 2020. 
			Start: 0852
			End: 1111
	
	Second Pass:
		- April 14, 2020
	
	Added endYear and endMonth arguments so that we can use the file as a 
	functions. 
	
	Rewrote the append section so that it works more generally with new endMonths
	and endYears
	
	Objective:
		Take all of the LFS from Jan. 2016 - Present.
		Append all datasets with uniform variable names. 
		Get sociodemographic variables and economic information by province and
		CMA.  <= WILL BE DONE IN NEXT DO-FILE
		
	Comments:
		- Had to rename some of the folders and filenames by hand. To make the loops consistent
		- 2016 appears to have all of the correct variable names, BUT, additional
			variables starting with the column yaway
		- The final dataset is ordered (rows) backwards: 2020 ->(desecending) 2016
*/

clear 

/* timer */
	timer on 4

local endYear = 2020
local endMonth "December"


/*
	How the folder below is structure:
	$pathway (to dropbox)
		> Covid-19 Canada\Data\LFS
			> yearNumber 
				> lfs-71M0001-E-yearNumber-monthName 
					> lfs-71M0001-E-yearNumber-monthName_F1.sav

		
	This structure will describe our loop:
		1. loop over year
			i. loop over month
			ii. Keep track of an exit rule which will allow us to control when to 
			describe the end of the panel, and thus, when to exit the loops. 
	
	
	Within both loops, and for a given iteration. 
		1. Check if the file has already been named. 
			If not, create it. (This is for speed)
				~ Import from spss, all in lowercase. 
				~ Order the important material first 
				~ Create variables which contain the values in them
				~ Save
				~ Clear				
		2. If we reach the end of our panel (February 2020):
			Using a loopExitRule, break from both loops.
*/


/* Instantiate. Turn equal to one when we reach February 2020 */
local loopExitRule = 0 

display "CREATE DATASETSS"
/* Start of the Loop */
forval yearNumber = 2016 (1) 2020{
	foreach monthName in january february march april may june july august september october november december{
		
	/* Confirm a file exists. If not, we will create it." */
		capture: confirm file "ReplicationFolder_CJE_Covid/Data/dtaFiles/LFS/lfs_`yearNumber'_`monthName'.dta"
		
	/* If there is no file name found where expected, create a new file. */ 
		if (_rc != 0){
				    
			display "`yearNumber', `monthName': has not been created"
				
		/* All files are in *.sav. Therefore, convert Stata to SAS. Make variables lower case.*/
			import spss using "ReplicationFolder_CJE_Covid/Data/LFS/`yearNumber'/lfs-71M0001-E-`yearNumber'-`monthName'/lfs-71M0001-E-`yearNumber'-`monthName'_F1.sav" ///
				, 	case(lower)

					
		/* Order things appropriately */
			order *, alpha 
			order rec_num survyear survmnth lfsstat prov cma
				
		/* CATCHING EXCEPTIONS
			1. survmnth for May 2016 is incorrectly coded
		*/
			if (`yearNumber' == 2016 & "`monthName'" == "may"){
				replace survmnth = 5
			}
				
		/* Decode all of the labelled variables */
			foreach x of varlist _all{
			
				capture decode 	`x', generate(D_`x')
				
				if _rc==0 {
					tab D_`x'					    
				}

			}
				
		/* Save the file */
		// save "lfs_`yearNumber'_`monthName'.dta", replace 
			save "ReplicationFolder_CJE_Covid/Data/dtaFiles/LFS/lfs_`yearNumber'_`monthName'.dta", replace 
				
		/* Close the file */
			clear 
			
		}	
		else {
			display "The individual dataset from the lfs for `monthName' `yearNumber' has already been created"
		}
	
	/* Stop the monthName loop if in February 2020 */
		if (`yearNumber' == `endYear' & "`monthName'" == "`endMonth'"){
			display "		I have entered the conditional"
			display " `endMonth' `endYear'"
			local loopExitRule = 1 
				
			/* Break from the Loop */
			continue, break 
		}
	}
	
/* Do we break yet or not? */
	display "	  The break from loop number is `loopExitRule'"
	display "	`yearNumber', `monthName'"
/* Stop the yearNumber loop*/
	if (`loopExitRule' == 1){
		break  
	}
}




/*
	Instantiating the Appended file
*/

clear 

display "APPEND"

local loopExitRule = 0

/* Confirm a file exists. If not, we will create it." */
capture: confirm file "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016jan_to_`endYear'`endMonth'.dta"
		
/* An _rc of 0 means that there is a file name found where expected*/
display _rc
		
/* If there is no file name found where expected, create a new file. */ 
if (_rc != 0){
	forval yearNumber = 2016 (1) 2020{
		display "`yearNumber'"
		foreach monthName in january february march april may june july august september october november december{
			display"	`monthName'"
			
			if (`yearNumber' == 2016 & "`monthName'" == "january"){
				use "ReplicationFolder_CJE_Covid/Data/dtaFiles/LFS/lfs_`yearNumber'_`monthName'.dta"
				di "HERE!!" 
			}
			else {
				quietly append using "ReplicationFolder_CJE_Covid/Data/dtaFiles/LFS/lfs_`yearNumber'_`monthName'.dta"	
			}

			/* IF endYear and endMonth are reached, exit loops */
			if (`yearNumber' == `endYear' & "`monthName'" == "`endMonth'"){
				display "		I have entered the conditional"
					
				local loopExitRule = 1 
					
				/* Break from the Loop */
				continue, break 
			}
			
			 /* Exit the loop if we hit */
			 if (`loopExitRule' == 1){
				break 
			}
		}
	}


	/* This is the file which we will append to*/
	save "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016jan_to_`endYear'`endMonth'.dta", replace
}
else {
	display "The appended LFS datasets are already created"
}

/* timer */
	timer off 4
	timer list 